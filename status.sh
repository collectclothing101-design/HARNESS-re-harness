#!/bin/bash

##############################################################################
# HARNESS v3.0.0 - QUICK STATUS CHECK
# Fast status overview - shows system state at a glance
# Run anytime to check installation status
##############################################################################

BOLD='\033[1m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${BLUE}┌────────────────────────────────────────────────────────────────┐${RESET}"
echo -e "${BLUE}│          Harness v3.0.0 - Quick Status Check                  │${RESET}"
echo -e "${BLUE}└────────────────────────────────────────────────────────────────┘${RESET}"
echo ""

# 1. Python
echo -n "Python: "
if command -v python3 &> /dev/null; then
    PY_VERSION=$(python3 --version 2>&1)
    echo -e "${GREEN}✓${RESET} $PY_VERSION"
else
    echo -e "${RED}✗${RESET} Not found"
fi

# 2. MCP Module
echo -n "MCP Module: "
if python3 -c "import mcp" 2>/dev/null; then
    echo -e "${GREEN}✓${RESET} Installed"
else
    echo -e "${RED}✗${RESET} Missing"
fi

# 3. MCP Server File
echo -n "MCP Server: "
if [ -f ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py ]; then
    echo -e "${GREEN}✓${RESET} Present"
else
    echo -e "${RED}✗${RESET} Missing"
fi

# 4. Configuration File
echo -n "Config File: "
if [ -f ~/Library/Application\ Support/Claude/claude_desktop_config.json ]; then
    echo -e "${GREEN}✓${RESET} Present"
else
    echo -e "${YELLOW}⚠${RESET} Missing"
fi

# 5. Harness Entry
echo -n "Config Entry: "
if grep -q '"harness"' ~/Library/Application\ Support/Claude/claude_desktop_config.json 2>/dev/null; then
    echo -e "${GREEN}✓${RESET} Found"
else
    echo -e "${RED}✗${RESET} Not found"
fi

# 6. Claude Running
echo -n "Claude Running: "
if pgrep -x "Claude" > /dev/null; then
    echo -e "${GREEN}✓${RESET} Yes"
else
    echo -e "${YELLOW}⚠${RESET} No"
fi

echo ""
echo -e "${BLUE}──────────────────────────────────────────────────────────────${RESET}"
echo ""

# Quick recommendations
echo -e "${BOLD}Status Summary:${RESET}"

PY_OK=0
MCP_OK=0
SERVER_OK=0
CONFIG_OK=0
CLAUDE_OK=0

python3 -c "import mcp" 2>/dev/null && MCP_OK=1
[ -f ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py ] && SERVER_OK=1
[ -f ~/Library/Application\ Support/Claude/claude_desktop_config.json ] && CONFIG_OK=1
pgrep -x "Claude" > /dev/null && CLAUDE_OK=1

TOTAL=$((MCP_OK + SERVER_OK + CONFIG_OK + CLAUDE_OK))

if [ $TOTAL -eq 4 ]; then
    echo -e "${GREEN}✓ All systems ready!${RESET}"
    echo ""
    echo "Next step: Test with @harness help"
    exit 0
elif [ $TOTAL -eq 3 ]; then
    echo -e "${YELLOW}⚠ Almost ready${RESET}"
    echo ""
    if [ $CLAUDE_OK -eq 0 ]; then
        echo "Action: Restart Claude"
        echo "  killall Claude && open /Applications/Claude.app"
    fi
    exit 0
else
    echo -e "${RED}✗ Installation needed${RESET}"
    echo ""
    if [ $MCP_OK -eq 0 ]; then
        echo "Action: Run installation script"
        echo "  bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh"
    fi
    exit 1
fi
