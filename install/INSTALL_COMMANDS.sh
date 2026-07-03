#!/bin/bash

# ============================================================================
# HARNESS v3.0.0 - EXACT COMMANDS TO FIX YOUR INSTALLATION
# ============================================================================
# Copy & paste these commands one section at a time
# Stop if you see an error and check QUICK_FIX.md
# ============================================================================

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║     Harness v3.0.0 - Installation Fix Script                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
# STEP 1: FIX CRYPTOGRAPHY ISSUE (macOS with Homebrew)
# ============================================================================

echo "STEP 1: Setting up environment for cryptography..."
echo ""

# Export these environment variables
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1

echo "✓ Environment variables set"
echo "  CRYPTOGRAPHY_DONT_BUILD_WHEEL=1"
echo "  CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1"
echo ""

# ============================================================================
# STEP 2: INSTALL MCP PACKAGE
# ============================================================================

echo "STEP 2: Installing MCP package..."
echo ""

python3 -m pip install --upgrade pip

python3 -m pip install mcp

if [ $? -eq 0 ]; then
    echo "✓ MCP package installed successfully"
else
    echo "✗ MCP installation failed"
    echo "  Try: python3 -m pip install --only-binary :all: mcp"
    exit 1
fi
echo ""

# ============================================================================
# STEP 3: CREATE DIRECTORIES
# ============================================================================

echo "STEP 3: Creating installation directories..."
echo ""

mkdir -p ~/Library/Application\ Support/AI-Tools/mcp/
mkdir -p ~/Library/Application\ Support/AI-Tools/harness/
mkdir -p ~/Library/Application\ Support/Claude/

echo "✓ Directories created"
echo "  ~/Library/Application Support/AI-Tools/mcp/"
echo "  ~/Library/Application Support/AI-Tools/harness/"
echo ""

# ============================================================================
# STEP 4: COPY MCP SERVER FILE
# ============================================================================

echo "STEP 4: Copying MCP server file..."
echo ""

# Find the MCP server file
if [ -f "harness_claude_advanced_mcp.py" ]; then
    MCP_SOURCE="harness_claude_advanced_mcp.py"
elif [ -f "./harness_claude_advanced_mcp.py" ]; then
    MCP_SOURCE="./harness_claude_advanced_mcp.py"
elif [ -f "/mnt/user-data/outputs/harness_claude_advanced_mcp.py" ]; then
    MCP_SOURCE="/mnt/user-data/outputs/harness_claude_advanced_mcp.py"
else
    echo "✗ Cannot find harness_claude_advanced_mcp.py"
    echo "  Make sure the file is in your current directory or /mnt/user-data/outputs/"
    exit 1
fi

cp "$MCP_SOURCE" ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py

if [ $? -eq 0 ]; then
    echo "✓ MCP server file copied"
    echo "  To: ~/Library/Application Support/AI-Tools/mcp/"
else
    echo "✗ Failed to copy MCP server file"
    exit 1
fi
echo ""

# ============================================================================
# STEP 5: MAKE MCP SERVER EXECUTABLE
# ============================================================================

echo "STEP 5: Setting file permissions..."
echo ""

chmod +x ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py

if [ -x ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py ]; then
    echo "✓ MCP server is now executable"
else
    echo "✗ Failed to set executable permission"
    exit 1
fi
echo ""

# ============================================================================
# STEP 6: CONFIGURE CLAUDE DESKTOP
# ============================================================================

echo "STEP 6: Configuring Claude Desktop..."
echo ""

python3 << 'PYTHON_CONFIG'
import json
from pathlib import Path
import os

# Paths
config_path = Path.home() / "Library/Application Support/Claude/claude_desktop_config.json"
mcp_file = Path.home() / "Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"
harness_dir = Path.home() / "Library/Application Support/AI-Tools/harness"

# Ensure directories exist
config_path.parent.mkdir(parents=True, exist_ok=True)
harness_dir.mkdir(parents=True, exist_ok=True)

# Load existing config or create new
if config_path.exists():
    with open(config_path, 'r') as f:
        config = json.load(f)
    print(f"✓ Loaded existing config: {config_path}")
else:
    config = {"mcpServers": {}}
    print(f"✓ Created new config: {config_path}")

# Ensure mcpServers exists
if "mcpServers" not in config:
    config["mcpServers"] = {}

# Add Harness MCP server configuration
config["mcpServers"]["harness"] = {
    "command": "python3",
    "args": [str(mcp_file)],
    "env": {
        "HARNESS_DIR": str(harness_dir),
        "HARNESS_LOG_LEVEL": "INFO"
    }
}

# Write config back
with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print(f"✓ Harness server configured in Claude Desktop")
print(f"  Command: python3 {str(mcp_file)}")
print(f"  Data dir: {str(harness_dir)}")
PYTHON_CONFIG

if [ $? -eq 0 ]; then
    echo "✓ Claude Desktop configuration complete"
else
    echo "✗ Failed to configure Claude Desktop"
    exit 1
fi
echo ""

# ============================================================================
# STEP 7: VERIFY INSTALLATION
# ============================================================================

echo "STEP 7: Verifying installation..."
echo ""

# Check MCP file exists
if [ -f ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py ]; then
    echo "✓ MCP server file exists and is readable"
else
    echo "✗ MCP server file not found or not readable"
    exit 1
fi

# Check if executable
if [ -x ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py ]; then
    echo "✓ MCP server file is executable"
else
    echo "✗ MCP server file is not executable"
fi

# Check Python can import mcp
python3 -c "from mcp.server import Server; print('✓ Python mcp module is installed')" 2>/dev/null || {
    echo "⚠ Python mcp module import failed (may work after restart)"
}

# Check config file
if [ -f ~/Library/Application\ Support/Claude/claude_desktop_config.json ]; then
    echo "✓ Claude Desktop config file exists"
    
    # Validate JSON
    if python3 -m json.tool < ~/Library/Application\ Support/Claude/claude_desktop_config.json > /dev/null 2>&1; then
        echo "✓ Claude Desktop config is valid JSON"
    else
        echo "⚠ Claude Desktop config JSON validation failed"
    fi
else
    echo "✗ Claude Desktop config file not found"
    exit 1
fi
echo ""

# ============================================================================
# FINAL INSTRUCTIONS
# ============================================================================

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              Installation Complete!                           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo "NEXT STEPS:"
echo ""
echo "1. QUIT Claude Desktop (⌘Q or Quit from menu)"
echo "2. Wait 3 seconds"
echo "3. REOPEN Claude Desktop"
echo "4. Check Settings > Integrations (should see 'harness' listed)"
echo "5. In a chat, run: harness_status()"
echo ""
echo "Expected output from harness_status():"
echo "  ✓ status: operational"
echo "  ✓ version: 3.0.0"
echo "  ✓ teams: 0"
echo "  ✓ agents_tracked: 0"
echo ""

echo "TROUBLESHOOTING:"
echo ""
echo "If it doesn't work after restart:"
echo "1. Check Claude Desktop logs: ~/Library/Logs/Claude.log"
echo "2. Run: python3 -c 'from mcp.server import Server; print(\"OK\")'"
echo "3. Check config syntax: python3 -m json.tool < ~/Library/Application\\ Support/Claude/claude_desktop_config.json"
echo ""

echo "Files installed to:"
echo "  MCP Server: ~/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"
echo "  Config: ~/Library/Application Support/Claude/claude_desktop_config.json"
echo "  Data: ~/Library/Application Support/AI-Tools/harness/"
echo ""

echo "Documentation:"
echo "  Quick fixes: QUICK_FIX.md"
echo "  Full troubleshooting: INSTALLATION_FIXES.md"
echo ""
