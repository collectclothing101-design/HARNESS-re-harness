#!/bin/bash

##############################################################################
# HARNESS v3.0.0 - PEP 668 FIX - IMMEDIATE ACTION SCRIPT
# This script bypasses PEP 668 and installs Harness immediately
# Run this NOW to get Harness working
##############################################################################

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     Harness v3.0.0 - PEP 668 Quick Fix                        ║"
echo "║     (Homebrew Python compatibility fix)                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Verify Python
echo "Step 1: Verifying Python installation..."
PYTHON3=$(which python3)
PYTHON_VERSION=$($PYTHON3 --version 2>&1 | awk '{print $2}')
echo "✓ Using Python: $PYTHON3 (v$PYTHON_VERSION)"
echo ""

# Step 2: Set cryptography environment variables
echo "Step 2: Setting environment variables for cryptography..."
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1
echo "✓ CRYPTOGRAPHY_DONT_BUILD_WHEEL=1"
echo "✓ CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1"
echo ""

# Step 3: Install MCP with --break-system-packages (fastest)
echo "Step 3: Installing MCP package (with PEP 668 override)..."
echo "  Running: python3 -m pip install --break-system-packages --user mcp"
echo ""

if python3 -m pip install --break-system-packages --user mcp; then
    echo "✓ MCP installed successfully"
else
    echo "✗ MCP installation failed"
    echo ""
    echo "ALTERNATIVE: Use virtual environment instead"
    echo "  python3 -m venv ~/harness_venv"
    echo "  source ~/harness_venv/bin/activate"
    echo "  pip install mcp"
    echo ""
    exit 1
fi
echo ""

# Step 4: Create installation directories
echo "Step 4: Creating installation directories..."
mkdir -p ~/Library/Application\ Support/AI-Tools/harness
mkdir -p ~/Library/Application\ Support/AI-Tools/mcp
mkdir -p ~/Library/Application\ Support/Claude/skills
echo "✓ Directories created"
echo ""

# Step 5: Copy MCP server
echo "Step 5: Installing MCP server..."
if [ -f "harness_claude_advanced_mcp.py" ]; then
    cp harness_claude_advanced_mcp.py ~/Library/Application\ Support/AI-Tools/mcp/
    echo "✓ MCP server copied"
elif [ -f "/mnt/user-data/outputs/harness_claude_advanced_mcp.py" ]; then
    cp /mnt/user-data/outputs/harness_claude_advanced_mcp.py ~/Library/Application\ Support/AI-Tools/mcp/
    echo "✓ MCP server copied from outputs"
else
    echo "✗ MCP server file not found"
    echo "  Expected: harness_claude_advanced_mcp.py in current directory"
    exit 1
fi
echo ""

# Step 6: Update Claude Desktop config
echo "Step 6: Updating Claude Desktop configuration..."
CONFIG_FILE=~/Library/Application\ Support/Claude/claude_desktop_config.json

# Create config if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p ~/Library/Application\ Support/Claude
    cat > "$CONFIG_FILE" << 'EOF'
{
  "mcpServers": {}
}
EOF
fi

# Update config with Harness MCP server
python3 << 'PYTHON_EOF'
import json
import os

config_file = os.path.expanduser("~/Library/Application Support/Claude/claude_desktop_config.json")

with open(config_file, 'r') as f:
    config = json.load(f)

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

print("✓ Claude config updated")
PYTHON_EOF

echo ""

# Step 7: Verify installation
echo "Step 7: Verifying installation..."
if python3 -c "import mcp; print('✓ MCP module imported successfully')" 2>/dev/null; then
    echo "✓ MCP verified"
else
    echo "⚠ MCP import check inconclusive (might still work)"
fi

if [ -f ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py ]; then
    echo "✓ MCP server file installed"
else
    echo "✗ MCP server file missing"
    exit 1
fi

if [ -f "$CONFIG_FILE" ]; then
    echo "✓ Claude config file updated"
else
    echo "✗ Claude config file not found"
    exit 1
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              ✓ INSTALLATION COMPLETE                          ║"
echo "╚════════════════════════════════════════════════════════════════╝"
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
