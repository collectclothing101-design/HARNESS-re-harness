#!/bin/bash

##############################################################################
# HARNESS v3.0.0 - COMPLETE UNINSTALL & CLEANUP
# Safely removes all Harness components and restores system state
##############################################################################

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║        Harness v3.0.0 - Complete Uninstall & Cleanup          ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

echo -e "${RED}WARNING: This will completely remove Harness from your system.${RESET}"
echo ""
echo "This includes:"
echo "  • Virtual environment (~/harness_venv)"
echo "  • MCP server files"
echo "  • Claude Desktop configuration entries"
echo "  • Harness data directory"
echo "  • Skill files"
echo ""
echo "This action is REVERSIBLE by re-running installation scripts."
echo ""

read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo -e "${BOLD}Uninstall Progress${RESET}"
echo "─────────────────────────────────────────────────────────────────"
echo ""

# Step 1: Close Claude
echo "Closing Claude Desktop..."
killall Claude 2>/dev/null || true
sleep 2
echo -e "${GREEN}✓${RESET} Claude closed"
echo ""

# Step 2: Remove virtual environment
echo "Removing virtual environment..."
if [ -d ~/harness_venv ]; then
    rm -rf ~/harness_venv
    echo -e "${GREEN}✓${RESET} Virtual environment removed"
else
    echo -e "${YELLOW}⊘${RESET} Virtual environment not found"
fi
echo ""

# Step 3: Remove MCP files
echo "Removing MCP server files..."
MCP_DIR=~/Library/Application\ Support/AI-Tools/mcp
if [ -d "$MCP_DIR" ]; then
    rm -f "$MCP_DIR/harness_claude_advanced_mcp.py"
    echo -e "${GREEN}✓${RESET} MCP server file removed"
    
    # Remove MCP directory if empty
    if [ -z "$(ls -A "$MCP_DIR")" ]; then
        rmdir "$MCP_DIR"
        echo -e "${GREEN}✓${RESET} MCP directory removed (was empty)"
    fi
else
    echo -e "${YELLOW}⊘${RESET} MCP directory not found"
fi
echo ""

# Step 4: Remove Harness data
echo "Removing Harness data directory..."
HARNESS_DIR=~/Library/Application\ Support/AI-Tools/harness
if [ -d "$HARNESS_DIR" ]; then
    rm -rf "$HARNESS_DIR"
    echo -e "${GREEN}✓${RESET} Harness data removed"
else
    echo -e "${YELLOW}⊘${RESET} Harness directory not found"
fi
echo ""

# Step 5: Remove skill files
echo "Removing Harness skill files..."
SKILL_DIR=~/Library/Application\ Support/Claude/skills/harness-installation
if [ -d "$SKILL_DIR" ]; then
    rm -rf "$SKILL_DIR"
    echo -e "${GREEN}✓${RESET} Skill files removed"
else
    echo -e "${YELLOW}⊘${RESET} Skill directory not found"
fi
echo ""

# Step 6: Remove Claude configuration entry
echo "Removing Harness from Claude configuration..."
CONFIG=~/Library/Application\ Support/Claude/claude_desktop_config.json

if [ -f "$CONFIG" ]; then
    # Backup original
    cp "$CONFIG" "${CONFIG}.backup"
    echo -e "${GREEN}✓${RESET} Configuration backup created: ${CONFIG}.backup"
    
    # Remove harness entry
    python3 << 'PYTHON_EOF'
import json
import os

config_file = os.path.expanduser("~/Library/Application Support/Claude/claude_desktop_config.json")

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    if "mcpServers" in config and "harness" in config["mcpServers"]:
        del config["mcpServers"]["harness"]
        
        with open(config_file, 'w') as f:
            json.dump(config, f, indent=2)
        
        print("✓ Harness entry removed from Claude config")
    else:
        print("⊘ Harness entry not found in config")
except Exception as e:
    print(f"✗ Error updating config: {e}")
PYTHON_EOF
else
    echo -e "${YELLOW}⊘${RESET} Claude configuration file not found"
fi
echo ""

# Step 7: Remove pip package (if installed globally)
echo "Removing MCP pip package..."
if python3 -c "import mcp" 2>/dev/null; then
    echo "Detected MCP installed via pip. Options:"
    echo "  A) Leave installed (may be used by other tools)"
    echo "  B) Remove (if not needed elsewhere)"
    read -p "Remove MCP pip package? (a/b): " choice
    
    if [ "$choice" = "b" ] || [ "$choice" = "B" ]; then
        python3 -m pip uninstall -y mcp 2>/dev/null || true
        echo -e "${GREEN}✓${RESET} MCP package removed"
    else
        echo -e "${YELLOW}⊘${RESET} MCP package left installed"
    fi
else
    echo -e "${YELLOW}⊘${RESET} MCP not found in pip packages"
fi
echo ""

# Step 8: Summary
echo -e "${BLUE}──────────────────────────────────────────────────────────────${RESET}"
echo ""
echo -e "${BOLD}Uninstall Complete${RESET}"
echo ""
echo "Removed:"
echo "  ✓ Virtual environment (~/harness_venv)"
echo "  ✓ MCP server files"
echo "  ✓ Harness data directory"
echo "  ✓ Skill files"
echo "  ✓ Claude configuration entry"
echo ""
echo "Preserved:"
echo "  ✓ Configuration backup (${CONFIG}.backup)"
echo "  ✓ Deployment files (/mnt/user-data/outputs/)"
echo ""

echo -e "${BOLD}Next Steps${RESET}"
echo ""
echo "1. Restart Claude:"
echo "   open /Applications/Claude.app"
echo ""
echo "2. Verify removal:"
echo "   • Check Settings → Integrations"
echo "   • Harness should NOT appear"
echo ""
echo "3. Restore if needed:"
echo "   • Re-run installation script"
echo "   • bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh"
echo ""

echo -e "${BOLD}Restore Configuration (if needed)${RESET}"
echo ""
echo "If something went wrong, restore from backup:"
echo "  cp ${CONFIG}.backup ${CONFIG}"
echo ""
