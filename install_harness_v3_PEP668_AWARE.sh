#!/bin/bash

##############################################################################
# HARNESS v3.0.0 - Universal Installation (PEP 668 AWARE)
# This is the primary installation script
# It detects PEP 668 issues and guides the user to the correct solution
##############################################################################

set -e

echo "═════════════════════════════════════════════════════════════════"
echo "Harness v3.0.0 - Universal Installation (PEP 668 AWARE)"
echo "═════════════════════════════════════════════════════════════════"
echo ""

# Detect OS
OS=$(uname -s)
if [ "$OS" == "Darwin" ]; then
    DETECTED_OS="macos"
elif [ "$OS" == "Linux" ]; then
    DETECTED_OS="linux"
else
    DETECTED_OS="unknown"
fi

echo "Detected OS: $DETECTED_OS"
echo ""

# Step 1: Check Python
echo "═════════════════════════════════════════════════════════════════"
echo "Checking Prerequisites"
echo "═════════════════════════════════════════════════════════════════"

if ! command -v python3 &> /dev/null; then
    echo "✗ Python 3 not found"
    exit 1
fi

PYTHON3=$(which python3)
PYTHON_VERSION=$($PYTHON3 --version 2>&1 | awk '{print $2}')
echo "✓ Python 3 found: $PYTHON_VERSION"
echo ""

# Step 2: Detect Python environment type
echo "═════════════════════════════════════════════════════════════════"
echo "Detecting Python Environment"
echo "═════════════════════════════════════════════════════════════════"

PYTHON_PREFIX=$($PYTHON3 -c "import sys; print(sys.prefix)")
IS_HOMEBREW=false
IS_MACPORTS=false
IS_PYENV=false
IS_SYSTEM=false

if [[ "$PYTHON_PREFIX" == *"Homebrew"* ]] || [[ "$PYTHON_PREFIX" == *"/usr/local"* ]]; then
    IS_HOMEBREW=true
    echo "  Homebrew Python detected: $PYTHON_PREFIX"
    echo "  ⚠ PEP 668 enforced (pip install blocked globally)"
elif [[ "$PYTHON_PREFIX" == *"/opt/local"* ]]; then
    IS_MACPORTS=true
    echo "  MacPorts Python detected: $PYTHON_PREFIX"
    echo "  ✓ PEP 668 not enforced"
elif [[ "$PYTHON_PREFIX" == *".pyenv"* ]]; then
    IS_PYENV=true
    echo "  pyenv Python detected: $PYTHON_PREFIX"
    echo "  ✓ PEP 668 not enforced"
elif [[ "$PYTHON_PREFIX" == *"/usr/bin"* ]]; then
    IS_SYSTEM=true
    echo "  System Python detected: $PYTHON_PREFIX"
    echo "  ⚠ PEP 668 may be enforced"
else
    echo "  Unknown Python: $PYTHON_PREFIX"
fi
echo ""

# Step 3: Handle PEP 668 (if Homebrew or System)
if [ "$IS_HOMEBREW" == "true" ] || [ "$IS_SYSTEM" == "true" ]; then
    echo "═════════════════════════════════════════════════════════════════"
    echo "PEP 668 DETECTED - Python install is externally managed"
    echo "═════════════════════════════════════════════════════════════════"
    echo ""
    echo "This environment blocks global pip installs for system protection."
    echo ""
    echo "CHOOSE ONE SOLUTION:"
    echo ""
    echo "  OPTION A (Recommended): Virtual Environment"
    echo "    bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh"
    echo ""
    echo "  OPTION B (Quick): Override with --break-system-packages"
    echo "    bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh"
    echo ""
    echo "  OPTION C (Advanced): Switch Python"
    echo "    brew install pyenv"
    echo "    pyenv install 3.12.0"
    echo "    pyenv global 3.12.0"
    echo ""
    exit 0
fi

# Step 4: Create directories (for non-PEP 668 environments)
echo "═════════════════════════════════════════════════════════════════"
echo "Creating Installation Directories"
echo "═════════════════════════════════════════════════════════════════"

HARNESS_DIR=~/Library/Application\ Support/AI-Tools/harness
MCP_DIR=~/Library/Application\ Support/AI-Tools/mcp
SKILLS_DIR=~/Library/Application\ Support/Claude/skills
CONFIG_FILE=~/Library/Application\ Support/Claude/claude_desktop_config.json

mkdir -p "$HARNESS_DIR"
mkdir -p "$MCP_DIR"
mkdir -p "$SKILLS_DIR"
mkdir -p ~/Library/Application\ Support/Claude

echo "✓ Directories created"
echo "  Harness:   $HARNESS_DIR"
echo "  MCP:       $MCP_DIR"
echo "  Skills:    $SKILLS_DIR"
echo "  Config:    $CONFIG_FILE"
echo ""

# Step 5: Install MCP server
echo "═════════════════════════════════════════════════════════════════"
echo "Installing MCP Server"
echo "═════════════════════════════════════════════════════════════════"

if [ -f "harness_claude_advanced_mcp.py" ]; then
    cp harness_claude_advanced_mcp.py "$MCP_DIR/"
    echo "✓ MCP server installed: $MCP_DIR/harness_claude_advanced_mcp.py"
elif [ -f "/mnt/user-data/outputs/harness_claude_advanced_mcp.py" ]; then
    cp /mnt/user-data/outputs/harness_claude_advanced_mcp.py "$MCP_DIR/"
    echo "✓ MCP server installed: $MCP_DIR/harness_claude_advanced_mcp.py"
else
    echo "✗ MCP server file not found"
    echo "  Expected: harness_claude_advanced_mcp.py"
    exit 1
fi
echo ""

# Step 6: Install Python dependencies (only for non-PEP 668 environments)
echo "═════════════════════════════════════════════════════════════════"
echo "Installing Python Dependencies"
echo "═════════════════════════════════════════════════════════════════"

export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1

echo "  Setting environment variables..."
echo "    CRYPTOGRAPHY_DONT_BUILD_WHEEL=1"
echo "    CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1"
echo ""

if python3 -m pip install --upgrade pip > /dev/null 2>&1; then
    echo "  ✓ pip upgraded"
else
    echo "  ⚠ pip upgrade had issues, continuing..."
fi

if python3 -m pip install --only-binary :all: mcp > /dev/null 2>&1; then
    echo "  ✓ mcp installed (pre-built wheel)"
elif python3 -m pip install mcp > /dev/null 2>&1; then
    echo "  ✓ mcp installed (from source)"
else
    echo "  ✗ Failed to install mcp"
    echo ""
    echo "  This environment may enforce PEP 668."
    echo "  Use one of the fix scripts instead:"
    echo "    bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh"
    echo "    bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh"
    exit 1
fi
echo ""

# Step 7: Update Claude Desktop config
echo "═════════════════════════════════════════════════════════════════"
echo "Updating Claude Desktop Configuration"
echo "═════════════════════════════════════════════════════════════════"

# Create config if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << 'EOF'
{
  "mcpServers": {}
}
EOF
fi

python3 << PYTHON_EOF
import json
import os

config_file = os.path.expanduser("~/Library/Application Support/Claude/claude_desktop_config.json")

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
except:
    config = {"mcpServers": {}}

# Add or update Harness MCP server
config["mcpServers"]["harness"] = {
    "command": "python3",
    "args": [os.path.expanduser("~/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py")],
    "env": {
        "HARNESS_DIR": os.path.expanduser("~/Library/Application Support/AI-Tools/harness"),
        "HARNESS_LOG_LEVEL": "INFO"
    }
}

with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)

print("✓ Claude Desktop config updated")
PYTHON_EOF

echo ""

# Step 8: Verify installation
echo "═════════════════════════════════════════════════════════════════"
echo "Verifying Installation"
echo "═════════════════════════════════════════════════════════════════"

if python3 -c "import mcp; print('✓ MCP module imported')" 2>/dev/null; then
    echo "✓ MCP module verified"
fi

if [ -f "$MCP_DIR/harness_claude_advanced_mcp.py" ]; then
    echo "✓ MCP server file present"
fi

if [ -f "$CONFIG_FILE" ]; then
    echo "✓ Claude config file present"
fi

echo ""
echo "═════════════════════════════════════════════════════════════════"
echo "✓ INSTALLATION COMPLETE"
echo "═════════════════════════════════════════════════════════════════"
echo ""
echo "NEXT STEPS:"
echo "  1. Restart Claude Desktop:"
echo "     killall Claude && open /Applications/Claude.app"
echo ""
echo "  2. Verify Harness is connected:"
echo "     Settings → Integrations → \"harness [Connected]\""
echo ""
echo "  3. Test with a command:"
echo "     Type in chat: @harness help"
echo ""
