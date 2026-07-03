#!/bin/bash
# VALIDATE_AND_FIX_CLAUDE_CONFIG.sh
# Detects and repairs claude_desktop_config.json Harness MCP configuration issues
# Interactive repair: prompts user for Python path, venv detection, validates syntax

CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
CLAUDE_CONFIG="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"
CLAUDE_CONFIG_BACKUP="$CLAUDE_CONFIG_DIR/claude_desktop_config.json.backup.$(date +%s)"

HARNESS_MCP_DIR="$HOME/Library/Application Support/AI-Tools/mcp"
HARNESS_CONFIG_DIR="$HOME/Library/Application Support/AI-Tools/harness"
HARNESS_VENV="$HOME/harness_venv"

echo "🔧 CLAUDE DESKTOP CONFIGURATION VALIDATOR & FIXER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ════════════════════════════════════════════════════════════════
# CHECK IF CONFIG EXISTS
# ════════════════════════════════════════════════════════════════

if [ ! -f "$CLAUDE_CONFIG" ]; then
    echo "❌ Claude Desktop config not found:"
    echo "   $CLAUDE_CONFIG"
    echo ""
    echo "This file is created when Claude Desktop is first launched."
    echo "Solution: Open /Applications/Claude.app and run it once, then retry this script."
    exit 1
fi

echo "✅ Config file found"
echo "   $CLAUDE_CONFIG"
echo ""

# ════════════════════════════════════════════════════════════════
# VALIDATE JSON SYNTAX
# ════════════════════════════════════════════════════════════════

echo "🔍 Validating JSON syntax..."
if ! python3 -m json.tool "$CLAUDE_CONFIG" > /dev/null 2>&1; then
    echo "❌ JSON syntax error detected"
    echo ""
    echo "Config file is malformed. Restore backup or manually fix."
    exit 1
fi
echo "✅ JSON syntax valid"
echo ""

# ════════════════════════════════════════════════════════════════
# CHECK HARNESS MCP CONFIGURATION
# ════════════════════════════════════════════════════════════════

echo "🔍 Checking Harness MCP configuration..."
echo ""

HARNESS_CONFIGURED=0
if grep -q '"harness"' "$CLAUDE_CONFIG"; then
    HARNESS_CONFIGURED=1
    echo "✅ Harness MCP entry found in config"
fi

# Check if MCP server file exists
if [ -f "$HARNESS_MCP_DIR/harness_claude_advanced_mcp.py" ]; then
    echo "✅ MCP server file exists"
    echo "   $HARNESS_MCP_DIR/harness_claude_advanced_mcp.py"
else
    echo "⚠️  MCP server file not found"
    echo "   Expected: $HARNESS_MCP_DIR/harness_claude_advanced_mcp.py"
    echo "   Run: QUICK_FIX_INSTALL_NOW.sh or VENV_SETUP_RECOMMENDED.sh"
    HARNESS_CONFIGURED=0
fi

echo ""

# ════════════════════════════════════════════════════════════════
# DETECT PYTHON INSTALLATION
# ════════════════════════════════════════════════════════════════

echo "🔍 Detecting Python installation..."
echo ""

PYTHON_CANDIDATES=()
PYTHON_CHOICE=""

# Check for virtualenv first (preferred)
if [ -f "$HARNESS_VENV/bin/python3" ]; then
    echo "✅ Found Harness virtualenv Python"
    PYTHON_CANDIDATES+=("$HARNESS_VENV/bin/python3")
    echo "   $HARNESS_VENV/bin/python3"
fi

# Check system Python
if command -v python3 &>/dev/null; then
    SYSTEM_PY=$(command -v python3)
    echo "✅ Found system Python"
    PYTHON_CANDIDATES+=("$SYSTEM_PY")
    echo "   $SYSTEM_PY"
fi

# Check Homebrew Python paths
BREW_PYTHONS=$(find /usr/local/Cellar/python* -name "python3" 2>/dev/null)
if [ -n "$BREW_PYTHONS" ]; then
    while IFS= read -r py; do
        echo "✅ Found Homebrew Python"
        PYTHON_CANDIDATES+=("$py")
        echo "   $py"
    done <<< "$BREW_PYTHONS"
fi

echo ""

if [ ${#PYTHON_CANDIDATES[@]} -eq 0 ]; then
    echo "❌ No Python installation found"
    echo "Install Python or create virtualenv:"
    echo "   bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh"
    exit 1
fi

# Select Python
if [ ${#PYTHON_CANDIDATES[@]} -eq 1 ]; then
    PYTHON_CHOICE="${PYTHON_CANDIDATES[0]}"
    echo "Using Python: $PYTHON_CHOICE"
else
    echo "Multiple Python versions detected. Select one:"
    echo ""
    for i in "${!PYTHON_CANDIDATES[@]}"; do
        echo "  $((i+1))) ${PYTHON_CANDIDATES[$i]}"
    done
    echo ""
    read -p "Enter selection (1-${#PYTHON_CANDIDATES[@]}): " selection
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#PYTHON_CANDIDATES[@]} ]; then
        PYTHON_CHOICE="${PYTHON_CANDIDATES[$((selection-1))]}"
        echo "Selected: $PYTHON_CHOICE"
    else
        echo "❌ Invalid selection"
        exit 1
    fi
fi

echo ""

# ════════════════════════════════════════════════════════════════
# VERIFY PYTHON AND MCP DEPENDENCIES
# ════════════════════════════════════════════════════════════════

echo "🔍 Verifying Python and MCP dependencies..."
echo ""

# Test Python
if ! "$PYTHON_CHOICE" --version &>/dev/null; then
    echo "❌ Python not executable: $PYTHON_CHOICE"
    exit 1
fi
PY_VERSION=$("$PYTHON_CHOICE" --version 2>&1)
echo "✅ Python available: $PY_VERSION"

# Check for MCP package
if "$PYTHON_CHOICE" -m pip show anthropic &>/dev/null 2>&1; then
    echo "✅ anthropic package installed"
else
    echo "⚠️  anthropic package not installed"
    echo "    Will be installed by: bash QUICK_FIX_INSTALL_NOW.sh"
fi

echo ""

# ════════════════════════════════════════════════════════════════
# GENERATE HARNESS CONFIG
# ════════════════════════════════════════════════════════════════

echo "🔨 Generating Harness MCP configuration..."
echo ""

HARNESS_CONFIG=$(cat <<EOF
    "harness": {
      "command": "$PYTHON_CHOICE",
      "args": ["$HARNESS_MCP_DIR/harness_claude_advanced_mcp.py"],
      "env": {
        "HARNESS_DIR": "$HARNESS_CONFIG_DIR",
        "HARNESS_LOG_LEVEL": "INFO"
      }
    }
EOF
)

echo "Generated config:"
echo "$HARNESS_CONFIG"
echo ""

# ════════════════════════════════════════════════════════════════
# UPDATE CLAUDE CONFIG
# ════════════════════════════════════════════════════════════════

if [ $HARNESS_CONFIGURED -eq 1 ]; then
    read -p "Harness already configured. Update? (y/n): " update_choice
    if [[ ! "$update_choice" =~ ^[yY]$ ]]; then
        echo "Skipping update."
        exit 0
    fi
fi

echo ""
echo "💾 Backing up current config..."
cp "$CLAUDE_CONFIG" "$CLAUDE_CONFIG_BACKUP"
echo "   $CLAUDE_CONFIG_BACKUP"
echo ""

echo "🔧 Updating configuration..."

# Use Python to safely merge JSON
python3 << 'PYTHON_SCRIPT'
import json
import sys
import os

config_file = os.path.expanduser("$HOME/Library/Application Support/Claude/claude_desktop_config.json")
harness_python = "$PYTHON_CHOICE"
harness_mcp_dir = "$HARNESS_MCP_DIR"
harness_config_dir = "$HARNESS_CONFIG_DIR"

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    # Ensure mcpServers exists
    if 'mcpServers' not in config:
        config['mcpServers'] = {}
    
    # Update or add harness entry
    config['mcpServers']['harness'] = {
        "command": harness_python,
        "args": [f"{harness_mcp_dir}/harness_claude_advanced_mcp.py"],
        "env": {
            "HARNESS_DIR": harness_config_dir,
            "HARNESS_LOG_LEVEL": "INFO"
        }
    }
    
    # Write back with pretty printing
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    
    print("✅ Configuration updated successfully")
    
except json.JSONDecodeError as e:
    print(f"❌ JSON error: {e}")
    sys.exit(1)
except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)

PYTHON_SCRIPT

# ════════════════════════════════════════════════════════════════
# VERIFY UPDATE
# ════════════════════════════════════════════════════════════════

echo ""
echo "🔍 Verifying update..."
echo ""

if grep -q '"harness"' "$CLAUDE_CONFIG"; then
    echo "✅ Harness entry verified in config"
    
    # Extract and display the harness section
    python3 << 'VERIFY_SCRIPT'
import json

config_file = "$CLAUDE_CONFIG"

with open(config_file, 'r') as f:
    config = json.load(f)

if 'harness' in config.get('mcpServers', {}):
    print("Current Harness configuration:")
    print(json.dumps(config['mcpServers']['harness'], indent=2))
else:
    print("❌ Harness config not found after update")

VERIFY_SCRIPT
else
    echo "❌ Update verification failed"
    echo "Restoring backup: $CLAUDE_CONFIG_BACKUP"
    cp "$CLAUDE_CONFIG_BACKUP" "$CLAUDE_CONFIG"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Configuration update complete!"
echo ""
echo "Next steps:"
echo "  1. Restart Claude Desktop:"
echo "     killall Claude && open /Applications/Claude.app"
echo ""
echo "  2. Verify Harness is connected:"
echo "     Settings → Integrations → Harness [Connected]"
echo ""
echo "  3. Test MCP:"
echo "     Type: @harness help"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 0
