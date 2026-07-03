# EXECUTE NOW — Harness v3.0.1 Complete Fix

## Current Status ✅

All prerequisite checks passed:
- ✅ Skill directory exists: `/mnt/user-data/outputs/harness-installation-skill-v1.0.0/`
- ✅ Fix scripts ready
- ✅ venv will be created automatically

---

## Execute the Fix

### Option A: With Monitoring (RECOMMENDED)

```bash
chmod +x /mnt/user-data/outputs/RUN_HARNESS_FIX_WITH_MONITORING.sh
bash /mnt/user-data/outputs/RUN_HARNESS_FIX_WITH_MONITORING.sh
```

This will:
1. Run the complete fix
2. Log all output to: `~/Desktop/harness_fix_execution.log`
3. Print clear next steps
4. Show any errors

### Option B: Direct Execution

```bash
chmod +x /mnt/user-data/outputs/COMPLETE_HARNESS_FIX.sh
bash /mnt/user-data/outputs/COMPLETE_HARNESS_FIX.sh
```

---

## What the Fix Does

### Phase 1: MCP Server v3.0.1 Deployment
1. Backs up current MCP server (if exists)
2. Deploys fixed `harness_claude_advanced_mcp.py`
3. Creates venv: `~/...AI-Tools/mcp/.venv/`
4. Installs mcp dependencies inside venv
5. Updates Claude Desktop config
6. Validates with syntax check

### Phase 2: Skill Installation
1. Verifies skill directory exists
2. Creates Claude skills directory
3. Copies skill to: `~/...Claude/skills/harness-installation/`
4. Sets execute permissions on scripts

**Total Time:** ~2-3 minutes

---

## After the Fix Runs

### Step 1: Restart Claude Desktop
```bash
killall Claude && open /Applications/Claude.app
```

Wait ~5 seconds for Claude to fully launch.

### Step 2: Verify MCP Connection
1. Open Claude Desktop
2. Click **Settings** (gear icon)
3. Click **Integrations**
4. Look for: **harness [Connected]** ✓

If you see "harness [Error]", see **Troubleshooting** below.

### Step 3: Test MCP Commands
Type in Claude:
```
@harness help
```

Should display:
```
Harness v3.0.0 - Available Commands

help     - Show this help message
status   - Installation status and diagnostic info
config   - Display current configuration

MCP Server: harness_claude_advanced_mcp.py v3.0.1
```

### Step 4: Test Skill
Type in Claude:
```
Help me install Harness
```

Should load the **Harness Installation Skill v1.0.0** with options for:
- System diagnostics
- MCP validation
- Claude config repair
- And more

---

## Troubleshooting

### If MCP shows "Error" in Settings

**Quick Fix:**
```bash
killall Claude
sleep 2
open /Applications/Claude.app
```

**Verify venv Python:**
```bash
~/Library/Application\ Support/AI-Tools/mcp/.venv/bin/python --version
```

**Check MCP syntax:**
```bash
~/Library/Application\ Support/AI-Tools/mcp/.venv/bin/python -c \
  "import mcp; print('OK')"
```

### If @harness commands don't work

1. Wait 30 seconds after Claude restart
2. Try again: `@harness help`
3. If still broken, check config:
   ```bash
   cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | grep -A 5 harness
   ```

### If Skill doesn't trigger

1. Restart Claude: `killall Claude && open /Applications/Claude.app`
2. Type exactly: `Help me install Harness`
3. Check skill exists:
   ```bash
   ls ~/Library/Application\ Support/Claude/skills/harness-installation/SKILL.md
   ```

---

## Files Deployed

After successful fix run:

```
~/.../AI-Tools/mcp/
├── harness_claude_advanced_mcp.py          ← FIXED v3.0.1
├── harness_claude_advanced_mcp.py.backup.* ← Original (kept as backup)
└── .venv/                                   ← Python venv
    └── lib/python3.14/site-packages/
        └── mcp/                             ← mcp 1.28.1

~/.../Claude/
├── skills/
│   └── harness-installation/                ← Skill v1.0.0
│       ├── SKILL.md
│       ├── README.md
│       ├── scripts/                         ← 8 tools
│       └── references/
└── claude_desktop_config.json               ← Updated
```

---

## Configuration Verified

Claude Desktop config will contain:

```json
{
  "mcpServers": {
    "harness": {
      "command": "/Users/johndoe/Library/Application Support/AI-Tools/mcp/.venv/bin/python",
      "args": ["/Users/johndoe/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"],
      "env": {
        "PYTHONUNBUFFERED": "1",
        "HARNESS_HOME": "/Users/johndoe/Library/Application Support/AI-Tools/harness"
      }
    }
  }
}
```

---

## Success Checklist

After completing all steps above:

- [ ] Fix script ran without errors
- [ ] Claude Desktop restarted
- [ ] Settings → Integrations shows "harness [Connected]"
- [ ] `@harness help` displays command list
- [ ] "Help me install Harness" triggers skill
- [ ] Skill shows diagnostic tools
- [ ] All 8 scripts in skill are accessible

---

## Version Info After Fix

- **MCP Server:** v3.0.1 (mcp 1.28.1 compatible)
- **Python:** 3.14.6 (your system)
- **mcp library:** 1.28.1
- **Harness Installation Skill:** v1.0.0

---

## Ready? Execute Now

**Recommended:**
```bash
bash /mnt/user-data/outputs/RUN_HARNESS_FIX_WITH_MONITORING.sh
```

**Or direct:**
```bash
bash /mnt/user-data/outputs/COMPLETE_HARNESS_FIX.sh
```

---

## Support

If you encounter any issues:

1. Check execution log: `~/Desktop/harness_fix_execution.log`
2. Review this guide's Troubleshooting section
3. Run skill's diagnostic tools: `@harness status`
4. Use skill's repair script: Run diagnostic, then follow repair steps

---

**Status: Ready for immediate execution ✅**
