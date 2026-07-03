#!/usr/bin/env bash
# Automated Harness Installation & Configuration
# Run this once to fully set up Harness MCP Server

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}Harness MCP Server - Full Setup${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo

# Configuration
HARNESS_DIR="${HARNESS_DIR:-$HOME/.local/share/ai-tools/harness}"
MCP_DIR="${MCP_DIR:-$HOME/.local/share/ai-tools/mcp}"
SKILL_DIR="${SKILL_DIR:-$HOME/.claude/skills}"
CONFIG_DIR="$HOME/.config/claude"
CONFIG_FILE="$CONFIG_DIR/claude_desktop_config.json"

echo -e "${YELLOW}Configuration:${NC}"
echo "  Harness dir: $HARNESS_DIR"
echo "  MCP dir:     $MCP_DIR"
echo "  Skills dir:  $SKILL_DIR"
echo "  Config dir:  $CONFIG_DIR"
echo

# Step 1: Clone Harness Repository
echo -e "${BLUE}Step 1: Cloning Harness Repository${NC}"
mkdir -p "$(dirname "$HARNESS_DIR")"

if [ -d "$HARNESS_DIR/.git" ]; then
  echo "  Updating existing repo..."
  git -C "$HARNESS_DIR" pull --ff-only
  echo -e "  ${GREEN}✓${NC} Repository updated"
else
  echo "  Cloning new repo..."
  git clone https://github.com/revfactory/harness.git "$HARNESS_DIR"
  echo -e "  ${GREEN}✓${NC} Repository cloned"
fi

# Verify Harness skill
if [ ! -f "$HARNESS_DIR/skills/harness/SKILL.md" ]; then
  echo -e "  ${RED}✗${NC} Harness SKILL.md not found"
  exit 1
fi
echo -e "  ${GREEN}✓${NC} Harness SKILL.md verified"
echo

# Step 2: Copy Harness Skill
echo -e "${BLUE}Step 2: Installing Harness Skill${NC}"
mkdir -p "$SKILL_DIR"
rm -rf "$SKILL_DIR/harness"
cp -R "$HARNESS_DIR/skills/harness" "$SKILL_DIR/harness"
echo -e "  ${GREEN}✓${NC} Skill installed to $SKILL_DIR/harness"
echo

# Step 3: Copy MCP Server Script
echo -e "${BLUE}Step 3: Installing MCP Server${NC}"
mkdir -p "$MCP_DIR"

# Copy MCP server script (try advanced first, then v2, then basic)
if [ -f "./harness_claude_advanced_mcp.py" ]; then
  cp "./harness_claude_advanced_mcp.py" "$MCP_DIR/harness_mcp_server.py"
elif [ -f "./harness_mcp_server_v2.py" ]; then
  cp "./harness_mcp_server_v2.py" "$MCP_DIR/harness_mcp_server.py"
elif [ -f "./harness_mcp_server.py" ]; then
  cp "./harness_mcp_server.py" "$MCP_DIR/harness_mcp_server.py"
else
  echo -e "  ${RED}✗${NC} MCP server script not found"
  echo "    Expected: harness_claude_advanced_mcp.py, harness_mcp_server_v2.py, or harness_mcp_server.py"
  exit 1
fi

chmod +x "$MCP_DIR/harness_mcp_server.py"
echo -e "  ${GREEN}✓${NC} MCP server installed to $MCP_DIR"
echo

# Step 4: Configure Claude Desktop
echo -e "${BLUE}Step 4: Configuring Claude Desktop${NC}"
mkdir -p "$CONFIG_DIR"

python3 << 'PYTHON'
import json
from pathlib import Path

config_file = Path("'"$CONFIG_FILE"'")
mcp_server_path = "'"$MCP_DIR/harness_mcp_server.py"'"
harness_dir = "'"$HARNESS_DIR"'"

# Load or create config
if config_file.exists():
    with open(config_file) as f:
        config = json.load(f)
else:
    config = {"mcpServers": {}}

# Ensure mcpServers key
if "mcpServers" not in config:
    config["mcpServers"] = {}

# Add harness MCP server
config["mcpServers"]["harness"] = {
    "command": "python3",
    "args": [mcp_server_path],
    "env": {
        "HARNESS_DIR": harness_dir
    }
}

# Save config
with open(config_file, "w") as f:
    json.dump(config, f, indent=2)

print(f"  Config saved: {config_file}")
PYTHON

echo -e "  ${GREEN}✓${NC} Claude Desktop configured"
echo

# Step 5: Copy Integration Modules
echo -e "${BLUE}Step 5: Installing Integration Modules${NC}"
INTEGRATIONS_DIR="$MCP_DIR/integrations"
mkdir -p "$INTEGRATIONS_DIR"

if [ -f "./harness_skill_creator_integration.py" ]; then
  cp "./harness_skill_creator_integration.py" "$INTEGRATIONS_DIR/"
  echo -e "  ${GREEN}✓${NC} skill-creator integration installed"
fi

if [ -f "./harness_wix_integration.py" ]; then
  cp "./harness_wix_integration.py" "$INTEGRATIONS_DIR/"
  echo -e "  ${GREEN}✓${NC} wix:wix-manage integration installed"
fi
echo

# Step 6: Verify Installation
echo -e "${BLUE}Step 6: Verification${NC}"

checks=0
passes=0

# Check 1: Harness repo
if [ -d "$HARNESS_DIR/.git" ]; then
  echo -e "  ${GREEN}✓${NC} Harness repository"
  ((passes++))
else
  echo -e "  ${RED}✗${NC} Harness repository"
fi
((checks++))

# Check 2: SKILL.md
if [ -f "$HARNESS_DIR/skills/harness/SKILL.md" ]; then
  echo -e "  ${GREEN}✓${NC} Harness SKILL.md"
  ((passes++))
else
  echo -e "  ${RED}✗${NC} Harness SKILL.md"
fi
((checks++))

# Check 3: MCP server
if [ -f "$MCP_DIR/harness_mcp_server.py" ]; then
  echo -e "  ${GREEN}✓${NC} MCP server script"
  ((passes++))
else
  echo -e "  ${RED}✗${NC} MCP server script"
fi
((checks++))

# Check 4: Claude config
if [ -f "$CONFIG_FILE" ]; then
  if grep -q "harness" "$CONFIG_FILE"; then
    echo -e "  ${GREEN}✓${NC} Claude Desktop config"
    ((passes++))
  else
    echo -e "  ${RED}✗${NC} Claude Desktop config (harness not found)"
  fi
else
  echo -e "  ${RED}✗${NC} Claude Desktop config (file missing)"
fi
((checks++))

echo
echo -e "Verification: ${GREEN}$passes/$checks${NC} checks passed"
echo

# Step 7: Summary
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Installation Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo

echo -e "${YELLOW}File Locations:${NC}"
echo "  Harness repo:    $HARNESS_DIR"
echo "  MCP server:      $MCP_DIR/harness_mcp_server.py"
echo "  Claude config:   $CONFIG_FILE"
echo "  Skill installed: $SKILL_DIR/harness"
echo

echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Restart Claude Desktop (close and reopen)"
echo "  2. Type: /mcp"
echo "  3. You should see 'harness' in the list"
echo "  4. Use Harness tools:"
echo "     /design_agent_team"
echo "     /generate_skill_scaffold"
echo "     /wix_app_agent_scaffold"
echo "     /validate_team_architecture"
echo

echo -e "${YELLOW}To use Harness:${NC}"
echo '  "Design a multi-agent team for [domain]"'
echo '  "Scaffold a Wix [feature]"'
echo '  "Create a SKILL.md for [domain]"'
echo

echo -e "${YELLOW}Documentation:${NC}"
echo "  View: ~/.claude/skills/harness/SKILL.md"
echo "  View config: cat $CONFIG_FILE"
echo
