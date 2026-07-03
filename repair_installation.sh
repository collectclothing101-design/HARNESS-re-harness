#!/bin/bash

##############################################################################
# HARNESS v3.0.0 - REPAIR & RECOVERY SCRIPT
# Diagnoses and fixes common installation issues
##############################################################################

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║        Harness v3.0.0 - Repair & Recovery Script              ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Function to prompt user
ask_yes_no() {
    read -p "$1 (y/n): " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        return 0
    else
        return 1
    fi
}

# DIAGNOSIS PHASE
echo -e "${BOLD}DIAGNOSIS PHASE${RESET}"
echo "─────────────────────────────────────────────────────────────────"
echo ""

# Check Python
echo "Checking Python..."
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗${RESET} Python 3 not found"
    exit 1
else
    PYTHON_VERSION=$(python3 --version 2>&1)
    echo -e "${GREEN}✓${RESET} Python: $PYTHON_VERSION"
fi

# Check MCP
echo "Checking MCP module..."
if ! python3 -c "import mcp" 2>/dev/null; then
    echo -e "${RED}✗${RESET} MCP module missing"
    MCP_MISSING=true
else
    echo -e "${GREEN}✓${RESET} MCP module found"
    MCP_MISSING=false
fi

# Check MCP server file
echo "Checking MCP server file..."
MCP_SERVER=~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py
if [ ! -f "$MCP_SERVER" ]; then
    echo -e "${RED}✗${RESET} MCP server file missing"
    SERVER_MISSING=true
else
    echo -e "${GREEN}✓${RESET} MCP server file found"
    SERVER_MISSING=false
fi

# Check Claude config
echo "Checking Claude configuration..."
CONFIG=~/Library/Application\ Support/Claude/claude_desktop_config.json
if [ ! -f "$CONFIG" ]; then
    echo -e "${RED}✗${RESET} Configuration file missing"
    CONFIG_MISSING=true
    CONFIG_BROKEN=false
elif ! python3 -m json.tool "$CONFIG" > /dev/null 2>&1; then
    echo -e "${RED}✗${RESET} Configuration file has invalid JSON"
    CONFIG_MISSING=false
    CONFIG_BROKEN=true
elif ! grep -q '"harness"' "$CONFIG" 2>/dev/null; then
    echo -e "${YELLOW}⚠${RESET} Harness entry not found in config"
    CONFIG_MISSING=false
    CONFIG_BROKEN=false
else
    echo -e "${GREEN}✓${RESET} Configuration file valid"
    CONFIG_MISSING=false
    CONFIG_BROKEN=false
fi

# Check Claude running
echo "Checking Claude Desktop..."
if pgrep -x "Claude" > /dev/null; then
    echo -e "${GREEN}✓${RESET} Claude is running"
else
    echo -e "${YELLOW}⚠${RESET} Claude not running (restart recommended)"
fi

echo ""
echo "─────────────────────────────────────────────────────────────────"
echo ""

# REPAIR PHASE
echo -e "${BOLD}REPAIR PHASE${RESET}"
echo ""

# Issue 1: MCP module missing
if [ "$MCP_MISSING" = "true" ]; then
    echo -e "${YELLOW}Issue: MCP module missing${RESET}"
    echo ""
    echo "This requires reinstalling from pip. Options:"
    echo "  1. Use QUICK_FIX method (--break-system-packages --user)"
    echo "  2. Use VENV method (recommended, more isolated)"
    echo ""
    
    if ask_yes_no "Install MCP using VENV method?"; then
        echo ""
        echo "Creating virtual environment at ~/harness_venv..."
        
        # Remove old venv if exists
        if [ -d ~/harness_venv ]; then
            rm -rf ~/harness_venv
        fi
        
        # Create and activate venv
        python3 -m venv ~/harness_venv
        source ~/harness_venv/bin/activate
        
        # Upgrade pip
        pip install --upgrade pip > /dev/null 2>&1
        
        # Install mcp
        pip install mcp > /dev/null 2>&1
        
        deactivate
        
        echo -e "${GREEN}✓${RESET} MCP installed in venv"
        echo ""
        echo "Next: Update Claude config to use venv Python"
        echo "  Command path: /Users/USERNAME/harness_venv/bin/python3"
        echo ""
    elif ask_yes_no "Install MCP using QUICK_FIX method?"; then
        export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
        python3 -m pip install --break-system-packages --user mcp
        echo -e "${GREEN}✓${RESET} MCP installed"
    fi
fi

# Issue 2: MCP server file missing
if [ "$SERVER_MISSING" = "true" ]; then
    echo -e "${YELLOW}Issue: MCP server file missing${RESET}"
    echo ""
    
    if ask_yes_no "Copy MCP server file from deployment?"; then
        mkdir -p ~/Library/Application\ Support/AI-Tools/mcp/
        
        # Try to find source
        if [ -f /mnt/user-data/outputs/harness_claude_advanced_mcp.py ]; then
            cp /mnt/user-data/outputs/harness_claude_advanced_mcp.py "$MCP_SERVER"
            echo -e "${GREEN}✓${RESET} MCP server file copied"
        else
            echo -e "${RED}✗${RESET} Cannot find source file"
            echo "  Expected at: /mnt/user-data/outputs/harness_claude_advanced_mcp.py"
        fi
    fi
fi

# Issue 3: Config file broken
if [ "$CONFIG_BROKEN" = "true" ]; then
    echo -e "${RED}Issue: Configuration JSON is invalid${RESET}"
    echo ""
    
    if ask_yes_no "Restore configuration from backup?"; then
        if [ -f "${CONFIG}.backup" ]; then
            cp "${CONFIG}.backup" "$CONFIG"
            echo -e "${GREEN}✓${RESET} Configuration restored from backup"
        else
            echo -e "${RED}✗${RESET} No backup found"
            echo "  To fix manually: nano $CONFIG"
        fi
    fi
fi

# Issue 4: Harness entry missing
if [ "$CONFIG_MISSING" = "false" ] && [ "$CONFIG_BROKEN" = "false" ] && ! grep -q '"harness"' "$CONFIG" 2>/dev/null; then
    echo -e "${YELLOW}Issue: Harness entry not in configuration${RESET}"
    echo ""
    
    if ask_yes_no "Add harness entry to configuration?"; then
        python3 << 'PYTHON_EOF'
import json
import os
import sys

config_file = os.path.expanduser("~/Library/Application Support/Claude/claude_desktop_config.json")

# Read current config
with open(config_file, 'r') as f:
    config = json.load(f)

# Ensure mcpServers exists
if "mcpServers" not in config:
    config["mcpServers"] = {}

# Get username
username = os.getenv("USER") or os.path.expanduser("~").split("/")[-1]

# Add harness entry
config["mcpServers"]["harness"] = {
    "command": f"/Users/{username}/harness_venv/bin/python3",
    "args": [f"/Users/{username}/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"],
    "env": {
        "HARNESS_DIR": f"/Users/{username}/Library/Application Support/AI-Tools/harness",
        "HARNESS_LOG_LEVEL": "INFO"
    }
}

# Write updated config
with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)

print("✓ Harness entry added to configuration")
PYTHON_EOF
    fi
fi

echo ""
echo "─────────────────────────────────────────────────────────────────"
echo ""

# VERIFICATION PHASE
echo -e "${BOLD}VERIFICATION PHASE${RESET}"
echo ""

echo "Restart Claude Desktop:"
echo "  killall Claude && open /Applications/Claude.app"
echo ""
echo "Then verify:"
echo "  1. bash /mnt/user-data/outputs/status.sh"
echo "  2. Check Settings → Integrations → 'harness [Connected]'"
echo "  3. Type: @harness help"
echo ""

echo "For detailed diagnostics:"
echo "  python3 /mnt/user-data/outputs/validate_claude_config.py"
echo "  bash /mnt/user-data/outputs/verify_installation_comprehensive.sh"
echo ""

# SUGGESTIONS
echo -e "${BOLD}NEXT STEPS${RESET}"
echo ""

ISSUES=0
[ "$MCP_MISSING" = "true" ] && ((ISSUES++))
[ "$SERVER_MISSING" = "true" ] && ((ISSUES++))
[ "$CONFIG_BROKEN" = "true" ] && ((ISSUES++))

if [ $ISSUES -eq 0 ]; then
    echo "No critical issues found. Try:"
    echo "  1. Restart Claude"
    echo "  2. Check Settings → Integrations"
    echo "  3. Test with: @harness help"
else
    echo "Repair completed. Follow these steps:"
    echo "  1. Address any issues above"
    echo "  2. Restart Claude: killall Claude && open /Applications/Claude.app"
    echo "  3. Verify: bash /mnt/user-data/outputs/status.sh"
    echo "  4. Test: @harness help"
fi

echo ""
