#!/bin/bash

##############################################################################
# HARNESS v3.0.0 - VIRTUAL ENVIRONMENT SETUP
# This script uses a Python virtual environment (recommended for production)
# Run this for the cleanest, most maintainable installation
##############################################################################

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     Harness v3.0.0 - Virtual Environment Setup                ║"
echo "║     (Recommended for production)                              ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Create virtual environment
echo "Step 1: Creating Python virtual environment..."
VENV_PATH=~/harness_venv

if [ -d "$VENV_PATH" ]; then
    echo "⚠ Virtual environment already exists at $VENV_PATH"
    echo "  Remove it first: rm -rf ~/harness_venv"
    exit 1
fi

python3 -m venv $VENV_PATH
echo "✓ Virtual environment created at $VENV_PATH"
echo ""

# Step 2: Activate virtual environment
echo "Step 2: Activating virtual environment..."
source $VENV_PATH/bin/activate
echo "✓ Virtual environment activated"
echo "  (You should see (harness_venv) in your prompt)"
echo ""

# Step 3: Upgrade pip in venv
echo "Step 3: Upgrading pip inside virtual environment..."
pip install --upgrade pip setuptools wheel
echo "✓ pip upgraded"
echo ""

# Step 4: Install MCP in venv
echo "Step 4: Installing MCP inside virtual environment..."
pip install mcp
echo "✓ MCP installed"
echo ""

# Step 5: Create installation directories
echo "Step 5: Creating installation directories..."
mkdir -p ~/Library/Application\ Support/AI-Tools/harness
mkdir -p ~/Library/Application\ Support/AI-Tools/mcp
mkdir -p ~/Library/Application\ Support/Claude/skills
echo "✓ Directories created"
echo ""

# Step 6: Copy MCP server
echo "Step 6: Installing MCP server..."
if [ -f "harness_claude_advanced_mcp.py" ]; then
    cp harness_claude_advanced_mcp.py ~/Library/Application\ Support/AI-Tools/mcp/
    echo "✓ MCP server copied"
elif [ -f "/mnt/user-data/outputs/harness_claude_advanced_mcp.py" ]; then
    cp /mnt/user-data/outputs/harness_claude_advanced_mcp.py ~/Library/Application\ Support/AI-Tools/mcp/
    echo "✓ MCP server copied from outputs"
else
    echo "✗ MCP server file not found"
    exit 1
fi
echo ""

# Step 7: Update Claude Desktop config (IMPORTANT: use venv Python)
echo "Step 7: Updating Claude Desktop configuration..."
CONFIG_FILE=~/Library/Application\ Support/Claude/claude_desktop_config.json
VENV_PYTHON=$VENV_PATH/bin/python3

# Create config if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p ~/Library/Application\ Support/Claude
    cat > "$CONFIG_FILE" << 'EOF'
{
  "mcpServers": {}
}
EOF
fi

# Update config with Harness MCP server (using venv Python)
python3 << PYTHON_EOF
import json
import os

config_file = os.path.expanduser("~/Library/Application Support/Claude/claude_desktop_config.json")
venv_python = "$VENV_PYTHON"

with open(config_file, 'r') as f:
    config = json.load(f)

# Add or update Harness MCP server (pointing to venv Python)
config["mcpServers"]["harness"] = {
    "command": venv_python,
    "args": [os.path.expanduser("~/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py")],
    "env": {
        "HARNESS_DIR": os.path.expanduser("~/Library/Application Support/AI-Tools/harness"),
        "HARNESS_LOG_LEVEL": "INFO"
    }
}

with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)

print("✓ Claude config updated with venv Python path")
PYTHON_EOF

echo ""

# Step 8: Verify venv installation
echo "Step 8: Verifying virtual environment installation..."
python3 -c "import mcp; print('✓ MCP module imported successfully')"
echo "✓ MCP verified in venv"
echo ""

# Step 9: Deactivate venv (for now)
echo "Step 9: Deactivating virtual environment..."
deactivate
echo "✓ Virtual environment deactivated"
echo "  (Claude will use venv automatically via config)"
echo ""

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              ✓ INSTALLATION COMPLETE                          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Virtual Environment Details:"
echo "  Location: $VENV_PATH"
echo "  Python:   $VENV_PYTHON"
echo "  To activate manually: source $VENV_PATH/bin/activate"
echo "  To deactivate: deactivate"
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
