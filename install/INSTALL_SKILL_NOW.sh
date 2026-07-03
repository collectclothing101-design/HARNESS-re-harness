#!/bin/bash
# Install Harness Installation Skill v1.0.0 to Claude

set -e

SKILL_SOURCE="${PWD}/harness-installation-skill-v1.0.0"
SKILL_DEST="${HOME}/Library/Application Support/Claude/skills/harness-installation"

echo "================================================================================"
echo "Harness Installation Skill v1.0.0 Installer"
echo "================================================================================"
echo ""

# Verify source exists
if [ ! -d "$SKILL_SOURCE" ]; then
    echo "ERROR: Skill source not found: $SKILL_SOURCE"
    echo "Run this script from the directory containing harness-installation-skill-v1.0.0/"
    exit 1
fi

# Create Claude skills directory if needed
mkdir -p "${HOME}/Library/Application Support/Claude/skills"

# Copy skill
echo "Installing skill to: $SKILL_DEST"
rm -rf "$SKILL_DEST" 2>/dev/null || true
cp -r "$SKILL_SOURCE" "$SKILL_DEST"

# Set permissions
chmod -R +x "$SKILL_DEST/scripts"/*.sh 2>/dev/null || true

echo "✅ Skill installed successfully"
echo ""
echo "Location: $SKILL_DEST"
echo ""
echo "Next steps:"
echo "1. Restart Claude Desktop:"
echo "   killall Claude && open /Applications/Claude.app"
echo ""
echo "2. Trigger the skill by typing any Harness-related query:"
echo "   'Help me install Harness'"
echo "   'I'm getting a PEP 668 error'"
echo "   'Configure Harness for Claude Desktop'"
echo ""
echo "================================================================================"
