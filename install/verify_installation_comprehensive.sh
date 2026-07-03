#!/bin/bash

##############################################################################
# HARNESS v3.0.0 - COMPREHENSIVE INSTALLATION VERIFICATION
# Run this after installation to verify everything is working correctly
##############################################################################

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║        Harness v3.0.0 - Installation Verification              ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Helper functions
pass() {
    echo -e "${GREEN}✓${RESET} $1"
    ((CHECKS_PASSED++))
}

fail() {
    echo -e "${RED}✗${RESET} $1"
    ((CHECKS_FAILED++))
}

warn() {
    echo -e "${YELLOW}⚠${RESET} $1"
    ((CHECKS_WARNING++))
}

info() {
    echo -e "${BLUE}ℹ${RESET} $1"
}

section() {
    echo ""
    echo -e "${BOLD}$1${RESET}"
    echo "─────────────────────────────────────────────────────────────────"
}

# CHECK 1: Python Environment
section "CHECK 1: Python Environment"

if ! command -v python3 &> /dev/null; then
    fail "Python 3 not found in PATH"
else
    PYTHON3=$(which python3)
    PYTHON_VERSION=$($PYTHON3 --version 2>&1)
    pass "Python 3 found: $PYTHON_VERSION"
    
    PYTHON_PREFIX=$($PYTHON3 -c "import sys; print(sys.prefix)")
    info "Python prefix: $PYTHON_PREFIX"
    
    # Check environment type
    if [[ "$PYTHON_PREFIX" == *"Homebrew"* ]] || [[ "$PYTHON_PREFIX" == *"/usr/local"* ]]; then
        pass "Detected: Homebrew Python (PEP 668)"
    elif [[ "$PYTHON_PREFIX" == *"/opt/local"* ]]; then
        pass "Detected: MacPorts Python"
    elif [[ "$PYTHON_PREFIX" == *".pyenv"* ]]; then
        pass "Detected: pyenv Python"
    elif [[ "$PYTHON_PREFIX" == *"harness_venv"* ]]; then
        pass "Detected: Virtual environment (harness_venv)"
    elif [[ "$PYTHON_PREFIX" == *"/usr/bin"* ]]; then
        warn "Detected: System Python (may have PEP 668)"
    else
        info "Detected: Custom Python installation ($PYTHON_PREFIX)"
    fi
fi
echo ""

# CHECK 2: MCP Module
section "CHECK 2: MCP Module Installation"

if python3 -c "import mcp" 2>/dev/null; then
    MCP_VERSION=$(python3 -c "import mcp; print(mcp.__version__ if hasattr(mcp, '__version__') else 'unknown')" 2>/dev/null)
    pass "MCP module imported successfully (version: $MCP_VERSION)"
    
    MCP_LOCATION=$(python3 -c "import mcp; import os; print(os.path.dirname(mcp.__file__))" 2>/dev/null)
    info "MCP location: $MCP_LOCATION"
else
    fail "MCP module not found - run installation script first"
fi
echo ""

# CHECK 3: MCP Server File
section "CHECK 3: MCP Server Installation"

MCP_SERVER_PATH=~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py

if [ -f "$MCP_SERVER_PATH" ]; then
    pass "MCP server file found"
    FILE_SIZE=$(du -h "$MCP_SERVER_PATH" | awk '{print $1}')
    info "File size: $FILE_SIZE"
    
    if grep -q "class HarnessMCPServer" "$MCP_SERVER_PATH" 2>/dev/null; then
        pass "MCP server contains HarnessMCPServer class"
    else
        warn "MCP server class definition not found (might be obfuscated)"
    fi
else
    fail "MCP server file not found at: $MCP_SERVER_PATH"
fi
echo ""

# CHECK 4: Installation Directories
section "CHECK 4: Installation Directories"

DIRS=(
    "~/Library/Application Support/AI-Tools/harness"
    "~/Library/Application Support/AI-Tools/mcp"
    "~/Library/Application Support/Claude/skills"
)

for dir in "${DIRS[@]}"; do
    expanded_dir=$(eval echo "$dir")
    if [ -d "$expanded_dir" ]; then
        pass "Directory exists: $dir"
    else
        warn "Directory missing: $dir (will be created on first use)"
    fi
done
echo ""

# CHECK 5: Claude Desktop Configuration
section "CHECK 5: Claude Desktop Configuration"

CONFIG_FILE=~/Library/Application\ Support/Claude/claude_desktop_config.json

if [ -f "$CONFIG_FILE" ]; then
    pass "Configuration file found"
    
    # Validate JSON syntax
    if python3 -m json.tool "$CONFIG_FILE" > /dev/null 2>&1; then
        pass "JSON syntax is valid"
    else
        fail "Configuration file has invalid JSON syntax"
    fi
    
    # Check for harness entry
    if grep -q '"harness"' "$CONFIG_FILE" 2>/dev/null; then
        pass "Harness MCP server entry found in config"
        
        # Extract and display harness config
        python3 << 'PYTHON_EOF'
import json
import os

config_file = os.path.expanduser("~/Library/Application Support/Claude/claude_desktop_config.json")
with open(config_file, 'r') as f:
    config = json.load(f)

if "mcpServers" in config and "harness" in config["mcpServers"]:
    harness_config = config["mcpServers"]["harness"]
    print(f"  Command: {harness_config.get('command', 'N/A')}")
    args = harness_config.get('args', [])
    if args:
        print(f"  Arguments: {len(args)} arg(s)")
        for arg in args:
            # Truncate long paths
            if len(arg) > 60:
                print(f"    - ...{arg[-57:]}")
            else:
                print(f"    - {arg}")
    
    if "env" in harness_config:
        print(f"  Environment variables: {len(harness_config['env'])} set")
        for key, value in harness_config["env"].items():
            if len(value) > 40:
                print(f"    {key}: ...{value[-37:]}")
            else:
                print(f"    {key}: {value}")
PYTHON_EOF
    else
        fail "Harness MCP server entry NOT found in config"
    fi
else
    fail "Configuration file not found at: $CONFIG_FILE"
fi
echo ""

# CHECK 6: Claude Desktop Running
section "CHECK 6: Claude Desktop Application"

if pgrep -x "Claude" > /dev/null; then
    pass "Claude Desktop is running"
else
    warn "Claude Desktop is not running"
    info "This is OK - just make sure to restart Claude for changes to take effect"
fi
echo ""

# CHECK 7: Skill Installation
section "CHECK 7: Harness Installation Skill"

SKILL_DIR=~/Library/Application\ Support/Claude/skills/harness-installation

if [ -d "$SKILL_DIR" ]; then
    pass "Harness skill directory found"
    
    if [ -f "$SKILL_DIR/SKILL.md" ]; then
        pass "SKILL.md found"
        SKILL_SIZE=$(du -h "$SKILL_DIR/SKILL.md" | awk '{print $1}')
        info "Skill size: $SKILL_SIZE"
    else
        warn "SKILL.md not found in skill directory"
    fi
else
    warn "Skill directory not found (will be created on Claude restart)"
fi
echo ""

# CHECK 8: MCP Server Execution Test
section "CHECK 8: MCP Server Execution Test"

MCP_SERVER=$MCP_SERVER_PATH

if [ -f "$MCP_SERVER" ]; then
    info "Testing MCP server startup (3 second timeout)..."
    
    # Start server in background with timeout
    if timeout 3 python3 "$MCP_SERVER" > /tmp/harness_mcp_test.log 2>&1 &
    then
        SERVER_PID=$!
        sleep 1
        
        if kill -0 $SERVER_PID 2>/dev/null; then
            pass "MCP server started successfully"
            kill $SERVER_PID 2>/dev/null || true
        else
            warn "MCP server exited quickly (might be waiting for network)"
            cat /tmp/harness_mcp_test.log | head -5
        fi
    else
        fail "MCP server failed to start"
        cat /tmp/harness_mcp_test.log | head -10
    fi
else
    fail "Cannot test - MCP server file not found"
fi
echo ""

# CHECK 9: Network Connectivity (Optional)
section "CHECK 9: Network Connectivity (Optional)"

if curl -s --connect-timeout 3 https://api.anthropic.com > /dev/null 2>&1; then
    pass "Network connectivity verified (Anthropic API reachable)"
else
    warn "Cannot reach Anthropic API (might be behind firewall)"
fi
echo ""

# CHECK 10: File Permissions
section "CHECK 10: File Permissions"

if [ -f "$MCP_SERVER_PATH" ]; then
    PERMS=$(ls -l "$MCP_SERVER_PATH" | awk '{print $1}')
    pass "MCP server file permissions: $PERMS"
    
    if [ -x "$MCP_SERVER_PATH" ]; then
        warn "MCP server is executable (should be non-executable Python file)"
    else
        pass "MCP server is non-executable (correct)"
    fi
fi
echo ""

# SUMMARY
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║                      VERIFICATION SUMMARY                      ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

echo -e "  ${GREEN}Passed:${RESET}  $CHECKS_PASSED"
echo -e "  ${YELLOW}Warnings:${RESET} $CHECKS_WARNING"
echo -e "  ${RED}Failed:${RESET}  $CHECKS_FAILED"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}${BOLD}✓ Installation verified successfully!${RESET}"
    echo ""
    echo "NEXT STEPS:"
    echo "  1. Restart Claude Desktop (if not already running)"
    echo "  2. Check Settings → Integrations → 'harness [Connected]'"
    echo "  3. Test with: @harness help"
    echo ""
else
    echo -e "${RED}${BOLD}✗ Installation verification found issues${RESET}"
    echo ""
    echo "ISSUES TO FIX:"
    echo "  - Review the failed checks above"
    echo "  - See TROUBLESHOOTING_AND_QUICK_REFERENCE.md for solutions"
    echo "  - Run installation script again: bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh"
    echo ""
fi

if [ $CHECKS_WARNING -gt 0 ]; then
    echo -e "${YELLOW}⚠ Review warnings above${RESET}"
    echo ""
fi

# Detailed diagnostic info if failures exist
if [ $CHECKS_FAILED -gt 0 ]; then
    echo ""
    echo -e "${BOLD}DIAGNOSTIC INFORMATION:${RESET}"
    echo "─────────────────────────────────────────────────────────────────"
    echo ""
    echo "Python environment:"
    python3 -c "import sys; print(f'  sys.prefix: {sys.prefix}'); print(f'  sys.version: {sys.version}')"
    echo ""
    echo "Environment variables:"
    env | grep -E "(PYTHON|HARNESS|CRYPTOGRAPHY)" || echo "  (none set)"
    echo ""
fi

exit $CHECKS_FAILED
