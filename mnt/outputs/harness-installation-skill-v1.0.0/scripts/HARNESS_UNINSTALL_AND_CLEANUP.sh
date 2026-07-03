#!/bin/bash
# HARNESS_UNINSTALL_AND_CLEANUP.sh
# Safely removes Harness v3.0.0 installation with comprehensive backup and restore capability
# Options: full uninstall, MCP only, virtualenv only, config reset, backup archive

set -e

echo "🗑️  HARNESS UNINSTALL & CLEANUP"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

HARNESS_MCP_DIR="$HOME/Library/Application Support/AI-Tools/mcp"
HARNESS_CONFIG_DIR="$HOME/Library/Application Support/AI-Tools/harness"
HARNESS_VENV="$HOME/harness_venv"
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

BACKUP_DIR="/tmp/harness_backup_$(date +%s)"
ARCHIVES_DIR="$HOME/Desktop/Harness Backups"

# ════════════════════════════════════════════════════════════════
# MENU
# ════════════════════════════════════════════════════════════════

echo "Choose uninstall scope:"
echo ""
echo "  1) Full uninstall (all Harness files + config + virtualenv)"
echo "  2) MCP server only (keeps config & virtualenv)"
echo "  3) Config only (keeps MCP server & virtualenv)"
echo "  4) Virtualenv only (keeps MCP & config)"
echo "  5) Reset config (backup then reset)"
echo "  6) Backup only (no deletion)"
echo "  7) Cancel"
echo ""

read -p "Enter choice (1-7): " choice

echo ""

case $choice in
    1) UNINSTALL_MODE="full" ;;
    2) UNINSTALL_MODE="mcp_only" ;;
    3) UNINSTALL_MODE="config_only" ;;
    4) UNINSTALL_MODE="venv_only" ;;
    5) UNINSTALL_MODE="reset_config" ;;
    6) UNINSTALL_MODE="backup_only" ;;
    7)
        echo "Cancelled."
        exit 0
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

# ════════════════════════════════════════════════════════════════
# CREATE BACKUP
# ════════════════════════════════════════════════════════════════

create_backup() {
    echo "💾 Creating backup..."
    mkdir -p "$BACKUP_DIR"
    
    if [ -d "$HARNESS_MCP_DIR" ]; then
        cp -r "$HARNESS_MCP_DIR" "$BACKUP_DIR/mcp" 2>/dev/null
        echo "   ✅ Backed up MCP directory"
    fi
    
    if [ -d "$HARNESS_CONFIG_DIR" ]; then
        cp -r "$HARNESS_CONFIG_DIR" "$BACKUP_DIR/config" 2>/dev/null
        echo "   ✅ Backed up config directory"
    fi
    
    if [ -d "$HARNESS_VENV" ]; then
        cp -r "$HARNESS_VENV" "$BACKUP_DIR/venv" 2>/dev/null
        echo "   ✅ Backed up virtualenv"
    fi
    
    if [ -f "$CLAUDE_CONFIG" ]; then
        cp "$CLAUDE_CONFIG" "$BACKUP_DIR/claude_desktop_config.json" 2>/dev/null
        echo "   ✅ Backed up Claude Desktop config"
    fi
    
    echo ""
    echo "Backup location: $BACKUP_DIR"
    
    # Create archive for Desktop
    mkdir -p "$ARCHIVES_DIR"
    ARCHIVE_NAME="Harness_Backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$ARCHIVES_DIR/$ARCHIVE_NAME" -C "$BACKUP_DIR" . 2>/dev/null
    echo "Archive created: $ARCHIVES_DIR/$ARCHIVE_NAME"
    echo ""
}

# ════════════════════════════════════════════════════════════════
# UNINSTALL PROCEDURES
# ════════════════════════════════════════════════════════════════

uninstall_mcp() {
    if [ -d "$HARNESS_MCP_DIR" ]; then
        echo "🗑️  Removing MCP directory..."
        rm -rf "$HARNESS_MCP_DIR"
        echo "   ✅ Removed: $HARNESS_MCP_DIR"
    else
        echo "ℹ️  MCP directory not found"
    fi
}

uninstall_config() {
    if [ -d "$HARNESS_CONFIG_DIR" ]; then
        echo "🗑️  Removing config directory..."
        rm -rf "$HARNESS_CONFIG_DIR"
        echo "   ✅ Removed: $HARNESS_CONFIG_DIR"
    else
        echo "ℹ️  Config directory not found"
    fi
}

uninstall_venv() {
    if [ -d "$HARNESS_VENV" ]; then
        echo "🗑️  Removing virtualenv..."
        rm -rf "$HARNESS_VENV"
        echo "   ✅ Removed: $HARNESS_VENV"
    else
        echo "ℹ️  Virtualenv not found"
    fi
}

update_claude_config() {
    if [ ! -f "$CLAUDE_CONFIG" ]; then
        echo "ℹ️  Claude Desktop config not found"
        return 0
    fi
    
    echo "🔧 Updating Claude Desktop config..."
    
    # Backup first
    cp "$CLAUDE_CONFIG" "$CLAUDE_CONFIG.backup.$(date +%s)"
    
    # Remove Harness entry using Python
    python3 << 'PYTHON_SCRIPT'
import json
import os

config_file = os.path.expanduser("$HOME/Library/Application Support/Claude/claude_desktop_config.json")

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    # Remove harness entry
    if 'mcpServers' in config and 'harness' in config['mcpServers']:
        del config['mcpServers']['harness']
        print("   ✅ Removed Harness from mcpServers")
    else:
        print("   ℹ️  Harness entry not found in config")
    
    # Write back
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    
    print("   ✅ Config updated successfully")
    
except Exception as e:
    print(f"   ❌ Error: {e}")

PYTHON_SCRIPT
}

reset_config() {
    echo "🔧 Resetting Harness config..."
    
    if [ -d "$HARNESS_CONFIG_DIR" ]; then
        # Remove config but keep directory
        rm -f "$HARNESS_CONFIG_DIR"/*.json 2>/dev/null
        echo "   ✅ Removed config files"
    else
        echo "   ℹ️  Config directory not found"
    fi
    
    # Remove from Claude config
    update_claude_config
}

# ════════════════════════════════════════════════════════════════
# EXECUTE UNINSTALL
# ════════════════════════════════════════════════════════════════

echo "🔍 Checking Harness installation..."
echo ""

# Show what will be affected
AFFECTED_COUNT=0
if [ -d "$HARNESS_MCP_DIR" ]; then
    echo "  Found: MCP directory"
    ((AFFECTED_COUNT++))
fi
if [ -d "$HARNESS_CONFIG_DIR" ]; then
    echo "  Found: Config directory"
    ((AFFECTED_COUNT++))
fi
if [ -d "$HARNESS_VENV" ]; then
    echo "  Found: Virtualenv"
    ((AFFECTED_COUNT++))
fi
if grep -q '"harness"' "$CLAUDE_CONFIG" 2>/dev/null; then
    echo "  Found: Claude Desktop config entry"
    ((AFFECTED_COUNT++))
fi

if [ $AFFECTED_COUNT -eq 0 ]; then
    echo "  No Harness installation found"
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Confirm action
case $UNINSTALL_MODE in
    full)
        echo "⚠️  FULL UNINSTALL: All Harness files, config, and virtualenv will be removed"
        read -p "Confirm? Type 'yes' to proceed: " confirm
        ;;
    mcp_only)
        echo "⚠️  MCP SERVER REMOVAL: MCP server will be deleted"
        read -p "Confirm? Type 'yes' to proceed: " confirm
        ;;
    config_only)
        echo "⚠️  CONFIG REMOVAL: Configuration will be deleted"
        read -p "Confirm? Type 'yes' to proceed: " confirm
        ;;
    venv_only)
        echo "⚠️  VIRTUALENV REMOVAL: Virtual environment will be deleted"
        read -p "Confirm? Type 'yes' to proceed: " confirm
        ;;
    reset_config)
        echo "⚠️  CONFIG RESET: Configuration will be reset"
        read -p "Confirm? Type 'yes' to proceed: " confirm
        ;;
    backup_only)
        echo "Creating backup (no deletion)"
        confirm="yes"
        ;;
esac

echo ""

if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""

# Create backup for all modes except cancel
create_backup

echo ""

# Execute uninstall based on mode
case $UNINSTALL_MODE in
    full)
        echo "📋 Full Uninstall"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        uninstall_mcp
        echo ""
        uninstall_config
        echo ""
        uninstall_venv
        echo ""
        update_claude_config
        ;;
    mcp_only)
        echo "📋 MCP Server Removal"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        uninstall_mcp
        echo ""
        update_claude_config
        ;;
    config_only)
        echo "📋 Config Removal"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        uninstall_config
        ;;
    venv_only)
        echo "📋 Virtualenv Removal"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        uninstall_venv
        ;;
    reset_config)
        echo "📋 Config Reset"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        reset_config
        ;;
    backup_only)
        echo "📋 Backup Complete (no changes made)"
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Uninstall complete!"
echo ""
echo "Backup available at:"
echo "  Directory: $BACKUP_DIR"
echo "  Archive:   $ARCHIVES_DIR"
echo ""
echo "To restore from backup:"
echo "  1. Copy files from backup directory"
echo "  2. Or extract archive: tar -xzf $ARCHIVES_DIR/$ARCHIVE_NAME"
echo ""
echo "To reinstall Harness:"
echo "  bash QUICK_FIX_INSTALL_NOW.sh"
echo "  or"
echo "  bash VENV_SETUP_RECOMMENDED.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 0
