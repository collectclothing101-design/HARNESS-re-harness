# Automated Harness Installation Guide

## Quick Start

### Option 1: Run Installation Script (Recommended)

```bash
# Download and run
curl -fsSL https://your-domain/install_harness.sh | bash

# Or run locally
bash ./install_harness.sh
```

The script will:
1. Clone Harness repository
2. Copy MCP server script
3. Install Harness skill
4. Configure Claude Desktop
5. Verify all components
6. Show next steps

**Time**: ~2 minutes  
**Result**: Fully configured, ready to use

---

## Step-by-Step Installation

### 1. Get the Script

Save the installation script:

```bash
# Option A: Copy from outputs
cp /mnt/user-data/outputs/install_harness.sh ~/install_harness.sh
chmod +x ~/install_harness.sh

# Option B: Create inline
cat > ~/install_harness.sh << 'SCRIPT'
[paste script content here]
SCRIPT
chmod +x ~/install_harness.sh
```

### 2. Customize (Optional)

Edit variables at the top:

```bash
# Default locations (you can customize)
HARNESS_DIR="${HARNESS_DIR:-$HOME/.local/share/ai-tools/harness}"
MCP_DIR="${MCP_DIR:-$HOME/.local/share/ai-tools/mcp}"
SKILL_DIR="${SKILL_DIR:-$HOME/.claude/skills}"
```

Or pass via environment:

```bash
HARNESS_DIR=/custom/path ./install_harness.sh
```

### 3. Run Installation

```bash
bash ~/install_harness.sh
```

Output will show:

```
═══════════════════════════════════════
Harness MCP Server - Full Setup
═══════════════════════════════════════

Configuration:
  Harness dir: /root/.local/share/ai-tools/harness
  MCP dir:     /root/.local/share/ai-tools/mcp
  Skills dir:  /root/.claude/skills
  Config dir:  /root/.config/claude

Step 1: Cloning Harness Repository
  ✓ Repository cloned
  ✓ Harness SKILL.md verified

Step 2: Installing Harness Skill
  ✓ Skill installed to /root/.claude/skills/harness

Step 3: Installing MCP Server
  ✓ MCP server installed to /root/.local/share/ai-tools/mcp

Step 4: Configuring Claude Desktop
  ✓ Claude Desktop configured

Step 5: Installing Integration Modules
  ✓ skill-creator integration installed
  ✓ wix:wix-manage integration installed

Step 6: Verification
  ✓ Harness repository
  ✓ Harness SKILL.md
  ✓ MCP server script
  ✓ Claude Desktop config

Verification: 4/4 checks passed

═══════════════════════════════════════
✓ Installation Complete!
═══════════════════════════════════════

File Locations:
  Harness repo:    /root/.local/share/ai-tools/harness
  MCP server:      /root/.local/share/ai-tools/mcp/harness_mcp_server.py
  Claude config:   /root/.config/claude/claude_desktop_config.json
  Skill installed: /root/.claude/skills/harness

Next Steps:
  1. Restart Claude Desktop (close and reopen)
  2. Type: /mcp
  3. You should see 'harness' in the list
  4. Use Harness tools:
     /design_agent_team
     /generate_skill_scaffold
     /wix_app_agent_scaffold
     /validate_team_architecture
```

### 4. Restart Claude Desktop

Close and reopen Claude for Desktop to load the MCP server.

### 5. Verify Installation

In Claude, type:

```
/mcp
```

You should see:

```
Available MCP servers:
- harness [Connected]
```

---

## Configuration Files Created

### 1. Claude Desktop Config

**File**: `~/.config/claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "harness": {
      "command": "python3",
      "args": ["/root/.local/share/ai-tools/mcp/harness_mcp_server.py"],
      "env": {
        "HARNESS_DIR": "/root/.local/share/ai-tools/harness"
      }
    }
  }
}
```

### 2. Harness Skill

**Location**: `~/.claude/skills/harness/`

Contains:
- `SKILL.md` - Main skill documentation
- `references/` - Pattern documentation

### 3. MCP Server Script

**Location**: `~/.local/share/ai-tools/mcp/harness_mcp_server.py`

Executable Python script that runs the MCP server.

---

## Using with Automation Tools

### With Hermes Agent (or Similar)

Tell an automation agent to run the installation:

```
"Install Harness MCP Server using the installation script.
Run: bash ~/install_harness.sh
Then show the output and verify all checks passed."
```

### With GitHub Actions

```yaml
name: Setup Harness

on: [push]

jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - name: Install Harness
        run: |
          bash ~/install_harness.sh
      
      - name: Verify Installation
        run: |
          test -f ~/.local/share/ai-tools/harness/skills/harness/SKILL.md
          test -f ~/.local/share/ai-tools/mcp/harness_mcp_server.py
          grep -q "harness" ~/.config/claude/claude_desktop_config.json
```

### With Docker

```dockerfile
# Dockerfile
FROM python:3.11

RUN apt-get update && apt-get install -y git

COPY install_harness.sh /tmp/
RUN bash /tmp/install_harness.sh

# Harness now installed in container
CMD ["python3", "/root/.local/share/ai-tools/mcp/harness_mcp_server.py"]
```

### With Terraform

```hcl
resource "local_file" "harness_installer" {
  content  = file("${path.module}/install_harness.sh")
  filename = "${path.user.home}/.local/bin/install_harness.sh"

  provisioner "local-exec" {
    command = "bash ${self.filename}"
  }
}
```

---

## Uninstall (If Needed)

```bash
# Remove installed components
rm -rf ~/.local/share/ai-tools/harness
rm -rf ~/.local/share/ai-tools/mcp
rm -rf ~/.claude/skills/harness

# Remove from Claude config
# Edit ~/.config/claude/claude_desktop_config.json and remove the "harness" entry
```

---

## Troubleshooting

### Script Permission Denied

```bash
chmod +x install_harness.sh
bash ./install_harness.sh
```

### Git Not Found

```bash
# Install git first
sudo apt-get install git  # Ubuntu/Debian
brew install git         # macOS
```

### Python3 Not Found

```bash
# Install Python
sudo apt-get install python3  # Ubuntu/Debian
brew install python3         # macOS
```

### MCP Server Not Loading

1. Verify config syntax:
   ```bash
   python3 -m json.tool ~/.config/claude/claude_desktop_config.json
   ```

2. Check FastMCP is installed:
   ```bash
   pip install mcp
   ```

3. Restart Claude Desktop completely

### Installation Checks Failed

Run verification manually:

```bash
# Check Harness repo
ls ~/.local/share/ai-tools/harness/skills/harness/SKILL.md

# Check MCP server
ls ~/.local/share/ai-tools/mcp/harness_mcp_server.py

# Check Claude config
grep harness ~/.config/claude/claude_desktop_config.json

# Check Skill
ls ~/.claude/skills/harness/SKILL.md
```

---

## What Gets Installed

| Component | Location | Purpose |
|-----------|----------|---------|
| Harness repo | `~/.local/share/ai-tools/harness/` | Source code + skills |
| MCP server | `~/.local/share/ai-tools/mcp/harness_mcp_server.py` | Executable server |
| Skill | `~/.claude/skills/harness/` | Harness SKILL.md |
| Config | `~/.config/claude/claude_desktop_config.json` | Claude MCP configuration |
| Integrations | `~/.local/share/ai-tools/mcp/integrations/` | skill-creator, wix integrations |

---

## Configuration Saved

After running `install_harness.sh`:

✓ MCP server registered in Claude Desktop  
✓ Harness skill available  
✓ All components verified  
✓ Ready to use in Claude  

No manual steps needed beyond restarting Claude Desktop.

---

## Using After Installation

Once installed, in Claude Desktop:

```
/harness_status           # Check status
/design_agent_team        # Design agents
/generate_skill_scaffold  # Create SKILL.md
/wix_app_agent_scaffold   # Design Wix features
/validate_team_architecture # Verify designs
```

Or just describe what you want:

```
"Design a multi-agent team for product discovery"
"Create a SKILL.md for content analysis"
"Scaffold a Wix membership dashboard"
```

---

## Idempotent Installation

The script is **idempotent** - safe to run multiple times:

- If Harness already installed, it updates via `git pull`
- Overwrites config safely
- Verifies each step
- Only proceeds if requirements met

---

## Summary

**Installation**: `bash ~/install_harness.sh` (2 minutes)  
**Configuration**: Automatic (no manual config needed)  
**Verification**: All checks pass automatically  
**Ready to use**: After restarting Claude Desktop  

All configuration is saved. Harness tools ready immediately after restart.
