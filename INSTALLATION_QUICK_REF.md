# How to Tell a System to Install & Configure Harness

## TL;DR - One Command

```bash
bash ./install_harness.sh
```

Done. Everything installed and configured.

---

## For Automation Tools / Agents

### Tell Hermes (or any agent):

```
"Run the Harness installation script:

bash ./install_harness.sh

Then verify:
1. Harness repository cloned
2. MCP server configured
3. Claude config updated
4. All checks passed

Show the final verification output."
```

### Tell GitHub Actions:

```yaml
- name: Install and Configure Harness
  run: bash ./install_harness.sh
```

### Tell Docker to Install:

```bash
COPY install_harness.sh /tmp/
RUN bash /tmp/install_harness.sh
```

---

## What the Installation Script Does

**In order**:

1. **Clone Repository**
   ```bash
   git clone https://github.com/revfactory/harness.git ~/.local/share/ai-tools/harness
   ```

2. **Copy Harness Skill**
   ```bash
   cp -R harness/skills/harness ~/.claude/skills/
   ```

3. **Copy MCP Server Script**
   ```bash
   cp harness_mcp_server.py ~/.local/share/ai-tools/mcp/
   ```

4. **Configure Claude Desktop**
   ```bash
   # Updates ~/.config/claude/claude_desktop_config.json
   # Adds harness MCP server entry
   ```

5. **Copy Integration Modules**
   ```bash
   cp harness_*_integration.py ~/.local/share/ai-tools/mcp/integrations/
   ```

6. **Verify Everything**
   ```bash
   # Checks all files exist and are in right places
   # Shows: ✓ or ✗ for each component
   ```

7. **Show Summary**
   ```
   ✓ Installation Complete!
   
   File Locations:
     Harness repo:    ~/.local/share/ai-tools/harness
     MCP server:      ~/.local/share/ai-tools/mcp/harness_mcp_server.py
     Claude config:   ~/.config/claude/claude_desktop_config.json
   
   Next Steps:
     1. Restart Claude Desktop
     2. Type: /mcp
     3. See 'harness [Connected]'
   ```

---

## Configuration That Gets Saved

### 1. Claude Desktop Config

**File**: `~/.config/claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "harness": {
      "command": "python3",
      "args": ["~/.local/share/ai-tools/mcp/harness_mcp_server.py"],
      "env": {
        "HARNESS_DIR": "~/.local/share/ai-tools/harness"
      }
    }
  }
}
```

**What it does**: Tells Claude Desktop where the MCP server is and how to run it.

### 2. Harness Skill Installed

**Location**: `~/.claude/skills/harness/`

**Contains**: 
- Harness documentation
- Reference materials
- Pattern examples

### 3. MCP Server Ready

**Location**: `~/.local/share/ai-tools/mcp/harness_mcp_server.py`

**Purpose**: Provides Harness tools to Claude

---

## After Installation

### Restart Claude Desktop

Close and reopen Claude for Desktop. The MCP server loads automatically.

### Verify in Claude

Type:
```
/mcp
```

You'll see:
```
Available MCP servers:
- harness [Connected]
```

### Start Using Harness

```
/design_agent_team
/generate_skill_scaffold
/wix_app_agent_scaffold
/validate_team_architecture
/orchestration_template
/harness_status
```

Or just describe what you need:

```
"Design a multi-agent team for [your domain]"
"Create a SKILL.md for [your use case]"
"Scaffold a Wix [feature] with multi-agent design"
```

---

## Idempotent Installation

Safe to run multiple times:

```bash
# Run once
bash install_harness.sh

# Run again - it updates instead of re-downloading
bash install_harness.sh

# Run a third time - checks everything, updates as needed
bash install_harness.sh
```

Each run:
- ✓ Updates Harness repo
- ✓ Overwrites config (keeps settings)
- ✓ Verifies all components
- ✓ Shows status

---

## Custom Installation

### Use Different Directories

```bash
HARNESS_DIR=/opt/harness \
MCP_DIR=/opt/mcp \
SKILL_DIR=/opt/skills \
bash install_harness.sh
```

### Skip Some Steps (Manual)

```bash
# Just clone repo
git clone https://github.com/revfactory/harness.git ~/.local/share/ai-tools/harness

# Just copy MCP server
cp harness_mcp_server.py ~/.local/share/ai-tools/mcp/

# Just update config
# Manually edit ~/.config/claude/claude_desktop_config.json
```

---

## What Agents/Automation Can Do

### Hermes Agent:

```
"Task: Install Harness MCP Server

1. Execute: bash ./install_harness.sh
2. Wait for completion
3. Verify: Check that all 6 steps completed successfully
4. Confirm: Report back the verification output
5. Status: 'Installation [✓] Complete'"
```

### GitHub Actions Workflow:

```yaml
name: Setup Harness MCP

on: [push]

jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Install Dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y git python3
      
      - name: Install Harness
        run: bash ./install_harness.sh
      
      - name: Report Status
        run: |
          echo "Harness Installation Summary:"
          ls -lh ~/.local/share/ai-tools/harness/
          ls -lh ~/.local/share/ai-tools/mcp/
          cat ~/.config/claude/claude_desktop_config.json | python3 -m json.tool
```

### Docker Multi-Stage:

```dockerfile
FROM python:3.11

# Install dependencies
RUN apt-get update && apt-get install -y git

# Copy and run installer
COPY install_harness.sh /tmp/
COPY harness_mcp_server.py /tmp/
COPY harness_*_integration.py /tmp/
RUN bash /tmp/install_harness.sh

# Verify installation
RUN test -f /root/.local/share/ai-tools/harness/skills/harness/SKILL.md
RUN test -f /root/.local/share/ai-tools/mcp/harness_mcp_server.py

# Start MCP server
CMD ["python3", "/root/.local/share/ai-tools/mcp/harness_mcp_server.py"]
```

---

## Troubleshooting Automated Installation

### If Script Fails

Check these:

```bash
# Permission?
chmod +x install_harness.sh

# Python?
python3 --version

# Git?
git --version

# Disk space?
df -h

# Read config?
cat ~/.config/claude/claude_desktop_config.json
```

### If Verification Fails

Run manual checks:

```bash
# Does Harness exist?
ls ~/.local/share/ai-tools/harness/skills/harness/SKILL.md

# Is MCP server there?
ls -l ~/.local/share/ai-tools/mcp/harness_mcp_server.py

# Is it executable?
file ~/.local/share/ai-tools/mcp/harness_mcp_server.py

# Is config valid JSON?
python3 -m json.tool ~/.config/claude/claude_desktop_config.json
```

### If MCP Server Doesn't Load

```bash
# Check Claude logs
# Restart Claude completely (force quit)
# Verify FastMCP is installed
pip install mcp
# Try again
```

---

## Summary

**Installation Command**: `bash install_harness.sh`

**Time**: ~2 minutes

**Result**: 
- ✓ Harness repository cloned
- ✓ MCP server installed
- ✓ Claude config updated
- ✓ Skill available
- ✓ Ready to use after restart

**Configuration Saved**: Yes (auto-configured)

**Next Step**: Restart Claude Desktop

**Then Use**: `/design_agent_team`, `/wix_app_agent_scaffold`, etc.
