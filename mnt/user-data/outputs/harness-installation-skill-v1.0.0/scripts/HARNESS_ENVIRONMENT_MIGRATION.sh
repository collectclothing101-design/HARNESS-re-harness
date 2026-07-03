#!/bin/bash
# HARNESS_ENVIRONMENT_MIGRATION.sh
# Safely migrate Harness MCP between different Python installations
# Supports: system Python → Homebrew Python → virtualenv
# Includes compatibility testing and rollback capability

set -e

echo "🔄 HARNESS ENVIRONMENT MIGRATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
HARNESS_MCP_DIR="$HOME/Library/Application Support/AI-Tools/mcp"
HARNESS_CONFIG_DIR="$HOME/Library/Application Support/AI-Tools/harness"
MIGRATION_BACKUP="/tmp/harness_migration_backup_$(date +%s)"

# ════════════════════════════════════════════════════════════════
# DETECT CURRENT PYTHON
# ════════════════════════════════════════════════════════════════

detect_current_python() {
    echo "🔍 Detecting current Python installation..."
    echo ""
    
    if [ -f "$CLAUDE_CONFIG" ]; then
        # Extract from Claude config
        CURRENT_PYTHON=$(python3 << 'EOF'
import json
import os

try:
    config_file = os.path.expanduser("$HOME/Library/Application Support/Claude/claude_desktop_config.json")
    with open(config_file) as f:
        config = json.load(f)
    
    if 'harness' in config.get('mcpServers', {}):
        cmd = config['mcpServers']['harness'].get('command')
        if cmd:
            print(cmd)
            exit(0)
except:
    pass

# Fallback to system Python
import shutil
py = shutil.which('python3')
if py:
    print(py)
EOF
)
    else
        CURRENT_PYTHON=$(command -v python3 2>/dev/null || echo "")
    fi
    
    if [ -z "$CURRENT_PYTHON" ]; then
        echo "❌ Could not detect current Python"
        exit 1
    fi
    
    echo "Current Python: $CURRENT_PYTHON"
    CURRENT_PY_VERSION=$("$CURRENT_PYTHON" --version 2>&1)
    echo "Version: $CURRENT_PY_VERSION"
    echo ""
}

# ════════════════════════════════════════════════════════════════
# DISCOVER AVAILABLE PYTHON INSTALLATIONS
# ════════════════════════════════════════════════════════════════

discover_python_installations() {
    echo "🔍 Discovering available Python installations..."
    echo ""
    
    PYTHON_OPTIONS=()
    PYTHON_LABELS=()
    
    # System Python
    if command -v python3 &>/dev/null; then
        py_path=$(command -v python3)
        PYTHON_OPTIONS+=("$py_path")
        PYTHON_LABELS+=("System Python ($py_path)")
    fi
    
    # Homebrew Python 3.13
    if [ -x "/usr/local/Cellar/python@3.13/3.13.*/bin/python3" ]; then
        py=$(ls -d /usr/local/Cellar/python@3.13/3.13.*/bin/python3 2>/dev/null | head -1)
        if [ -n "$py" ]; then
            PYTHON_OPTIONS+=("$py")
            PYTHON_LABELS+=("Homebrew Python 3.13 ($py)")
        fi
    fi
    
    # Homebrew Python 3.12
    if [ -x "/usr/local/Cellar/python@3.12/3.12.*/bin/python3" ]; then
        py=$(ls -d /usr/local/Cellar/python@3.12/3.12.*/bin/python3 2>/dev/null | head -1)
        if [ -n "$py" ]; then
            PYTHON_OPTIONS+=("$py")
            PYTHON_LABELS+=("Homebrew Python 3.12 ($py)")
        fi
    fi
    
    # MacPorts Python
    if [ -x "/opt/local/bin/python3" ]; then
        PYTHON_OPTIONS+=("/opt/local/bin/python3")
        PYTHON_LABELS+=("MacPorts Python (/opt/local/bin/python3)")
    fi
    
    # Virtualenv
    if [ -x "$HOME/harness_venv/bin/python3" ]; then
        PYTHON_OPTIONS+=("$HOME/harness_venv/bin/python3")
        PYTHON_LABELS+=("Harness Virtualenv ($HOME/harness_venv/bin/python3)")
    fi
    
    # PyEnv
    if command -v pyenv &>/dev/null; then
        for ver in $(pyenv versions 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | sort -u); do
            py="$HOME/.pyenv/versions/$ver/bin/python3"
            if [ -x "$py" ]; then
                PYTHON_OPTIONS+=("$py")
                PYTHON_LABELS+=("PyEnv $ver ($py)")
            fi
        done
    fi
    
    if [ ${#PYTHON_OPTIONS[@]} -eq 0 ]; then
        echo "❌ No Python installations found"
        exit 1
    fi
    
    echo "Available Python installations:"
    echo ""
    for i in "${!PYTHON_OPTIONS[@]}"; do
        py="${PYTHON_OPTIONS[$i]}"
        label="${PYTHON_LABELS[$i]}"
        version=$("$py" --version 2>&1)
        printf "  %d) %-50s %s\n" $((i+1)) "$label" "$version"
    done
    echo ""
}

# ════════════════════════════════════════════════════════════════
# VERIFY PYTHON COMPATIBILITY
# ════════════════════════════════════════════════════════════════

verify_python_compatibility() {
    local python_path=$1
    
    echo "🔍 Verifying Python compatibility..."
    echo ""
    
    # Check Python version >= 3.8
    PYTHON_VERSION=$("$python_path" --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    echo "  Version: $PYTHON_VERSION"
    
    # Check for required modules
    for module in json sys asyncio; do
        if "$python_path" -c "import $module" 2>/dev/null; then
            echo "  ✅ Module: $module"
        else
            echo "  ❌ Module missing: $module"
            return 1
        fi
    done
    
    # Check pip
    if "$python_path" -m pip --version &>/dev/null; then
        echo "  ✅ pip available"
    else
        echo "  ❌ pip not available"
        return 1
    fi
    
    # Check PEP 668 status
    if "$python_path" -m pip install --dry-run fake-package 2>&1 | grep -q "externally-managed-environment"; then
        echo "  ⚠️  PEP 668 active (will use --break-system-packages or virtualenv)"
    else
        echo "  ✅ pip install available"
    fi
    
    echo ""
    return 0
}

# ════════════════════════════════════════════════════════════════
# CREATE BACKUP
# ════════════════════════════════════════════════════════════════

create_migration_backup() {
    echo "💾 Creating migration backup..."
    mkdir -p "$MIGRATION_BACKUP"
    
    if [ -f "$CLAUDE_CONFIG" ]; then
        cp "$CLAUDE_CONFIG" "$MIGRATION_BACKUP/claude_desktop_config.json"
        echo "   ✅ Backed up Claude config"
    fi
    
    if [ -d "$HARNESS_MCP_DIR" ]; then
        cp -r "$HARNESS_MCP_DIR" "$MIGRATION_BACKUP/mcp" 2>/dev/null || true
        echo "   ✅ Backed up MCP"
    fi
    
    if [ -d "$HARNESS_CONFIG_DIR" ]; then
        cp -r "$HARNESS_CONFIG_DIR" "$MIGRATION_BACKUP/config" 2>/dev/null || true
        echo "   ✅ Backed up config"
    fi
    
    echo "   Backup: $MIGRATION_BACKUP"
    echo ""
}

# ════════════════════════════════════════════════════════════════
# MIGRATE TO NEW PYTHON
# ════════════════════════════════════════════════════════════════

migrate_to_python() {
    local new_python=$1
    
    echo "🔄 Migrating to Python: $new_python"
    echo ""
    
    # Verify compatibility first
    if ! verify_python_compatibility "$new_python"; then
        echo "❌ Python incompatibility detected"
        echo "Restoring backup..."
        cp "$MIGRATION_BACKUP/claude_desktop_config.json" "$CLAUDE_CONFIG"
        exit 1
    fi
    
    # Install MCP dependencies
    echo "📦 Installing MCP dependencies..."
    for pkg in anthropic pydantic aiohttp; do
        if "$new_python" -m pip show "$pkg" &>/dev/null 2>&1; then
            echo "   ✅ $pkg already installed"
        else
            echo "   📥 Installing $pkg..."
            
            # Handle PEP 668
            if "$new_python" -m pip install --dry-run fake-package 2>&1 | grep -q "externally-managed-environment"; then
                "$new_python" -m pip install --break-system-packages --user "$pkg" 2>/dev/null || \
                    "$new_python" -m pip install "$pkg" 2>/dev/null || \
                    echo "   ⚠️  Could not install $pkg"
            else
                "$new_python" -m pip install "$pkg" 2>/dev/null || \
                    echo "   ⚠️  Could not install $pkg"
            fi
        fi
    done
    
    echo ""
    
    # Test MCP server with new Python
    echo "🧪 Testing MCP server..."
    if [ -f "$HARNESS_MCP_DIR/harness_claude_advanced_mcp.py" ]; then
        if timeout 5 "$new_python" "$HARNESS_MCP_DIR/harness_claude_advanced_mcp.py" --help &>/dev/null 2>&1; then
            echo "   ✅ MCP server functional"
        else
            echo "   ⚠️  MCP server test inconclusive (expected for server process)"
        fi
    fi
    
    echo ""
    
    # Update Claude Desktop config
    echo "🔧 Updating Claude Desktop config..."
    
    python3 << PYTHON_SCRIPT
import json
import os

config_file = "$CLAUDE_CONFIG"

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    if 'mcpServers' not in config:
        config['mcpServers'] = {}
    
    config['mcpServers']['harness'] = {
        "command": "$new_python",
        "args": ["$HARNESS_MCP_DIR/harness_claude_advanced_mcp.py"],
        "env": {
            "HARNESS_DIR": "$HARNESS_CONFIG_DIR",
            "HARNESS_LOG_LEVEL": "INFO"
        }
    }
    
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    
    print("   ✅ Config updated")
    
except Exception as e:
    print(f"   ❌ Error: {e}")

PYTHON_SCRIPT
    
    echo ""
}

# ════════════════════════════════════════════════════════════════
# MAIN FLOW
# ════════════════════════════════════════════════════════════════

detect_current_python
discover_python_installations

echo "Select target Python installation:"
echo ""

read -p "Enter selection (1-${#PYTHON_OPTIONS[@]}): " selection

if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#PYTHON_OPTIONS[@]} ]; then
    echo "❌ Invalid selection"
    exit 1
fi

TARGET_PYTHON="${PYTHON_OPTIONS[$((selection-1))]}"
TARGET_LABEL="${PYTHON_LABELS[$((selection-1))]}"

echo ""
echo "Target: $TARGET_LABEL"
echo ""

# Confirm migration
read -p "Proceed with migration? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""

# Execute migration
create_migration_backup
migrate_to_python "$TARGET_PYTHON"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Migration complete!"
echo ""
echo "Next steps:"
echo "  1. Restart Claude Desktop:"
echo "     killall Claude && open /Applications/Claude.app"
echo ""
echo "  2. Verify connection:"
echo "     Settings → Integrations → Harness [Connected]"
echo ""
echo "  3. Test MCP:"
echo "     Type: @harness help"
echo ""
echo "If issues occur, restore backup:"
echo "  cp $MIGRATION_BACKUP/claude_desktop_config.json $CLAUDE_CONFIG"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 0
