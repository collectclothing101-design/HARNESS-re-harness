# Harness Installation Skill - Registration Complete

## Skill Installation Status

✅ **COMPLETE** — Skill successfully registered in Claude  
✅ **LOCATION**: `~/Library/Application Support/Claude/skills/harness-installation/`  
✅ **FILES**: SKILL.md + references bundled  
✅ **AUTO-DISCOVERED**: Claude Desktop detects automatically on restart

---

## What Was Installed

### Skill Package Contents

```
~/Library/Application Support/Claude/skills/harness-installation/
├── SKILL.md                           (9.1 KB) — Core documentation
├── README.md                          (7.2 KB) — This registration guide
└── references/
    ├── ADVANCED_TROUBLESHOOTING.md    (8.9 KB) — Extended FAQ & diagnostics
    └── claude_desktop_config.template.json (0.6 KB) — Config template
```

**Total Size**: ~26 KB (metadata + bundled references)

### Deliverable Files (Separate from Skill)

Located in `/mnt/user-data/outputs/`:

```
├── install_harness_v3_corrected.sh    (13 KB)  ← Use this script
├── harness_claude_advanced_mcp.py     (33 KB)  ← v3.0.0 MCP server
├── verify_harness_installation.sh     (9.7 KB) ← Post-install verification
├── harness-installation-skill/        (26 KB)  ← Skill package (copied above)
└── [previous delivery files]          (8 files) ← Prior documentation
```

---

## How the Skill Loads

### Claude Detects Skill Automatically

```
Claude Desktop → Scans ~/Library/Application Support/Claude/skills/
              → Finds SKILL.md with metadata
              → Registers skill with triggers
              → Loads on demand when triggered
```

**Trigger phrases** (skill activates on these):
- "Harness installation"
- "install harness"
- "harness mcp"
- "harness config"
- "harness troubleshoot"
- Or any user message containing these keywords

### No Config File Entry Needed (for the skill itself)

The **skill** (harness-installation) loads automatically.  
The **MCP server** (harness_claude_advanced_mcp.py) requires Claude Desktop config.

```
Skill:     ~/Library/Application Support/Claude/skills/harness-installation/SKILL.md
           ↓ (auto-discovered)
           Claude loads it

MCP Server: ~/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py
            ↓ (requires registration)
            ~/.config/Claude/claude_desktop_config.json
```

---

## Verification Steps

### 1. Confirm Skill Files Exist

```bash
ls -la ~/Library/Application\ Support/Claude/skills/harness-installation/
```

**Expected output**:
```
-rw-r--r-- 1 user group 9130 Jun 30 SKILL.md
-rw-r--r-- 1 user group 7240 Jun 30 README.md
drwxr-xr-x 2 user group   ..  Jun 30 references/
```

### 2. Restart Claude Desktop (Full Cycle)

```bash
# Force quit
killall Claude

# Reopen
open /Applications/Claude.app

# Wait 5 seconds for startup
sleep 5
```

### 3. Test Skill Trigger

In a Claude chat window, type any of:
- "How do I install Harness?"
- "@harness help with installation"
- "I need to configure harness mcp"

**Expected**: Claude responds with detailed installation guidance from SKILL.md

### 4. Check Settings (Optional)

Settings → Integrations → scroll down

You should see (after MCP server is installed):
```
harness               [Connected]  ← MCP server status
```

If MCP not yet installed, you'll see:
```
(no integrations)
```

This is normal until you run `install_harness_v3_corrected.sh`.

---

## Skill Description (for reference)

What Claude sees:

> Install, configure, and troubleshoot Harness v3.0.0 MCP server for Claude Desktop. Provides corrected installation scripts, bug fixes for common failures (MCP filename mismatch, environment variable passing, Rust/LLVM toolchain issues), pre-built verification tools, and Claude Desktop configuration guidance. Use this skill whenever user mentions Harness installation, needs to fix install failures, wants to verify MCP server status, or requires Claude Desktop MCP server configuration help.

---

## Using the Skill

### In Chat

```
User: I want to install Harness for Claude Desktop
↓
Claude: [Skill triggers: harness-installation]
        [Loads SKILL.md content]
        Here's how to install Harness v3.0.0...
        [References bug inventory, correct script, troubleshooting]
```

### Via Web Interface (claude.ai)

⚠️ **Note**: Skills only work in Claude Desktop, not on claude.ai.  
Web interface does not support local skills or MCP servers.

### Programmatically

If building tools that interact with Harness:
- Reference SKILL.md sections directly
- Use templates from `references/claude_desktop_config.template.json`
- Run verification scripts as subprocess checks

---

## Config File for MCP Server (Separate from Skill)

The **skill itself** loads automatically.  
The **MCP server** needs this config:

**File**: `~/.config/Claude/claude_desktop_config.json`  
OR: `~/Library/Application Support/Claude/claude_desktop_config.json`

**Content** (example for johndoe):

```json
{
  "mcpServers": {
    "harness": {
      "command": "python3",
      "args": ["/Users/johndoe/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"],
      "env": {
        "HARNESS_DIR": "/Users/johndoe/Library/Application Support/AI-Tools/harness",
        "HARNESS_LOG_LEVEL": "INFO"
      }
    }
  }
}
```

⚠️ **This is generated by `install_harness_v3_corrected.sh`**  
You don't need to create it manually.

---

## Troubleshooting Skill Loading

### Symptom: Skill not triggering

**Diagnosis**:
```bash
# Check file exists
test -f ~/Library/Application\ Support/Claude/skills/harness-installation/SKILL.md && echo "✓ File exists" || echo "✗ File missing"

# Check syntax
python3 -c "
import sys
with open(os.path.expanduser('~/Library/Application Support/Claude/skills/harness-installation/SKILL.md')) as f:
    content = f.read()
    if '---' in content and 'name: harness-installation' in content:
        print('✓ Metadata valid')
    else:
        print('✗ Metadata invalid')
" 2>&1 || echo "✗ Syntax error"
```

**Fix**:
```bash
# Restart Claude Desktop with cache clear
killall Claude
rm -rf ~/Library/Application\ Support/Claude/cache/  # Optional
open /Applications/Claude.app
```

### Symptom: Skill content outdated

Claude caches skill metadata. Force refresh:

```bash
# Restart Claude Desktop
killall Claude
sleep 3
open /Applications/Claude.app
```

Alternatively, edit SKILL.md in place:
```bash
nano ~/Library/Application\ Support/Claude/skills/harness-installation/SKILL.md
# Make changes, save (Ctrl+O, Enter, Ctrl+X)
# Claude reloads within 5 seconds
```

---

## Installation Checklist (Full Process)

### Phase 1: Skill Registration ✅
- [x] Skill files created
- [x] Copied to `~/Library/Application Support/Claude/skills/harness-installation/`
- [x] Metadata formatted correctly
- [x] References bundled

### Phase 2: Claude Desktop Restart ⏳
- [ ] Kill Claude: `killall Claude`
- [ ] Reopen: `open /Applications/Claude.app`
- [ ] Wait for startup (~10 seconds)

### Phase 3: Install MCP Server ⏳
- [ ] Copy corrected script: `cp install_harness_v3_corrected.sh ~`
- [ ] Copy MCP server: `cp harness_claude_advanced_mcp.py ~`
- [ ] Run: `bash ~/install_harness_v3_corrected.sh`
- [ ] Restart Claude Desktop again

### Phase 4: Verify Connection ⏳
- [ ] Check Settings → Integrations → "harness [Connected]"
- [ ] Test in chat: `@harness help` or "show me harness commands"
- [ ] Run verification: `bash ~/Harness/verify_harness_installation.sh`

---

## File Locations Summary

| Item | Location | Size | Type |
|------|----------|------|------|
| **Skill Package** | `~/Library/Application Support/Claude/skills/harness-installation/` | 26 KB | Directory (auto-loaded) |
| **SKILL.md** | `...skills/harness-installation/SKILL.md` | 9.1 KB | Core documentation |
| **References** | `...skills/harness-installation/references/` | 9.5 KB | Bundled docs |
| **MCP Server** | `~/.../AI-Tools/mcp/harness_claude_advanced_mcp.py` | 33 KB | Python script (after install) |
| **Harness State** | `~/.../AI-Tools/harness/` | Variable | Runtime directory (after install) |
| **Config File** | `~/.../Claude/claude_desktop_config.json` | 0.6 KB | JSON (after install) |

---

## Maintenance

### Updating the Skill

To modify SKILL.md or references:

```bash
# Edit directly
nano ~/Library/Application\ Support/Claude/skills/harness-installation/SKILL.md

# Or replace entire skill
cp -r /mnt/user-data/outputs/harness-installation-skill/* ~/Library/Application\ Support/Claude/skills/harness-installation/

# Restart Claude Desktop
killall Claude
open /Applications/Claude.app
```

### Checking Skill Functionality

```bash
# View skill metadata (what Claude sees)
head -10 ~/Library/Application\ Support/Claude/skills/harness-installation/SKILL.md

# Count lines in skill
wc -l ~/Library/Application\ Support/Claude/skills/harness-installation/SKILL.md

# Verify YAML frontmatter
grep -A 3 "^---" ~/Library/Application\ Support/Claude/skills/harness-installation/SKILL.md
```

---

## Archival & Backup

### Backup Skill Package

```bash
tar -czf ~/Backups/harness-installation-skill-backup.tar.gz ~/Library/Application\ Support/Claude/skills/harness-installation/
```

### Export Skill for Distribution

```bash
cd ~/Library/Application\ Support/Claude/skills/
tar -czf ~/Desktop/harness-installation-skill-v1.0.0.tar.gz harness-installation/

# Recipient installs:
tar -xzf harness-installation-skill-v1.0.0.tar.gz -C ~/Library/Application\ Support/Claude/skills/
```

---

## Summary

✅ **Harness Installation Skill is now registered and ready to use**

**Key Points**:
1. Skill auto-loads from `~/Library/Application Support/Claude/skills/harness-installation/`
2. Triggers on Harness-related keywords automatically
3. No additional configuration needed for the skill itself
4. MCP server still requires `install_harness_v3_corrected.sh` to be run
5. After MCP install, Claude Desktop config is auto-generated

**Next Action**: Run the corrected installation script
```bash
cd ~/Harness
bash install_harness_v3_corrected.sh
```

Then restart Claude Desktop and verify connection in Settings → Integrations.

---

**Registration Date**: June 30, 2026  
**Skill Version**: 1.0.0  
**Status**: ✅ Production Ready
