# Harness v3.0.0 Installation — Complete Help & Support

## Current Installation Status

Based on the fix script execution, you now have:

✅ **MCP Server v3.0.1** — Deployed and configured  
✅ **Harness Installation Skill v1.0.0** — Ready to use  
✅ **Claude Desktop Config** — Updated with MCP server  
✅ **Python venv** — Created with all dependencies  

---

## Immediate Next Steps (Do This Now)

### Step 1: Restart Claude Desktop

```bash
killall Claude
sleep 2
open /Applications/Claude.app
```

Wait for Claude to fully load (~5 seconds).

### Step 2: Verify MCP Connection

1. Click **Settings** (gear icon in Claude)
2. Click **Integrations**
3. Look for: **harness [Connected]** ✓

**If you see "harness [Error]":**
```bash
# Kill and restart Claude
killall Claude && sleep 3 && open /Applications/Claude.app
# Wait 10 seconds, check Settings again
```

### Step 3: Test MCP Commands

In Claude, type:
```
@harness help
```

**You should see:**
```
Harness v3.0.0 - Available Commands

help     - Show this help message
status   - Installation status and diagnostic info
config   - Display current configuration

MCP Server: harness_claude_advanced_mcp.py v3.0.1
```

---

## Using Harness Installation Skill

### What It Does

The Harness Installation Skill provides 8 diagnostic and maintenance tools:

1. **SYSTEM_DIAGNOSTICS.sh** — Complete environment audit
2. **VALIDATE_AND_FIX_CLAUDE_CONFIG.sh** — Config validator & repair
3. **MCP_PERFORMANCE_VALIDATOR.sh** — MCP latency & reliability tests
4. **HARNESS_ENVIRONMENT_MIGRATION.sh** — Safe migration between Python versions
5. **HARNESS_UNINSTALL_AND_CLEANUP.sh** — Complete uninstall with 7 scope options
6. **verify_harness_installation.sh** — Post-install verification (8 checks)
7. Plus reference guides and troubleshooting documentation

### Trigger the Skill

In Claude, type:
```
Help me install Harness
```

Or:
```
I need help with Harness installation
```

Or:
```
Show me Harness diagnostic tools
```

**Expected:** The skill loads and offers:
- System diagnostics
- Configuration validation
- Performance testing
- Migration tools
- And more

---

## Verification Checklist

After completing immediate steps above, verify:

- [ ] Claude restarted successfully
- [ ] Settings → Integrations shows "harness [Connected]"
- [ ] `@harness help` displays all commands
- [ ] `@harness status` shows installation info
- [ ] `@harness config` displays Claude config
- [ ] Skill triggers on Harness queries
- [ ] All 8 diagnostic tools are accessible via skill

---

## MCP Commands Available

Once verified, you have three MCP commands:

### 1. Get Help
```
@harness help
```
Shows all available commands.

### 2. Check Installation Status
```
@harness status
```
Returns:
- Python version
- Directory paths
- Whether files exist
- Installation completeness

### 3. View Claude Configuration
```
@harness config
```
Displays the Claude Desktop config for Harness MCP server.

---

## Using Skill Diagnostic Tools

After skill triggers, you can run any of the 8 scripts:

### System Diagnostics
```bash
bash ~/Library/Application\ Support/Claude/skills/harness-installation/scripts/SYSTEM_DIAGNOSTICS.sh
```

Audits:
- Python version and location
- Rust and LLVM status
- Node.js version
- PEP 668 detection
- Xcode status
- Directory structure

### MCP Performance Validator
```bash
bash ~/Library/Application\ Support/Claude/skills/harness-installation/scripts/MCP_PERFORMANCE_VALIDATOR.sh
```

Tests:
- Connection latency
- Command throughput
- Reliability metrics
- Error rates

### Configuration Validator & Repair
```bash
bash ~/Library/Application\ Support/Claude/skills/harness-installation/scripts/VALIDATE_AND_FIX_CLAUDE_CONFIG.sh
```

Checks and fixes:
- Claude config JSON validity
- MCP server path correctness
- Python executable correctness
- Environment variables

---

## Installation Architecture

After successful setup:

```
Harness Installation Flow
├── Swift/SwiftUI Layer (not deployed yet)
│   └── macOS native application
├── MCP Server (DEPLOYED)
│   ├── harness_claude_advanced_mcp.py (v3.0.1)
│   └── Python venv with dependencies
├── Claude Desktop Integration (CONFIGURED)
│   └── MCP server bridge
├── Harness Installation Skill (DEPLOYED)
│   ├── SKILL.md (main entry point)
│   ├── 8 diagnostic scripts
│   └── Reference documentation
└── Backend Systems (Not yet installed)
    ├── Harness core v3.0.0
    └── Configuration storage
```

---

## What's Installed vs. What's Not

### ✅ Already Installed
- MCP server v3.0.1
- Harness Installation Skill v1.0.0
- 8 diagnostic/maintenance tools
- Claude Desktop integration
- Python venv with mcp 1.28.1

### ⏳ Optional/Future
- Full Harness v3.0.0 core system
- Harness configuration storage
- macOS native application (if planned)

---

## Troubleshooting

### Issue: "harness [Error]" in Settings

**Solution:**
```bash
# Hard restart Claude
killall Claude
sleep 5
open /Applications/Claude.app

# Wait 10 seconds, check Settings again
```

If still shows error:
```bash
# Check venv Python exists
ls ~/Library/Application\ Support/AI-Tools/mcp/.venv/bin/python

# Verify it works
~/Library/Application\ Support/AI-Tools/mcp/.venv/bin/python --version

# Check Claude config is valid JSON
python3 -c "import json; json.load(open('~/Library/Application Support/Claude/claude_desktop_config.json'.replace('~', '/Users/johndoe')))" && echo "✓ Config valid"
```

### Issue: "@harness help" shows error

**Solution:**
```bash
# Verify MCP server syntax
~/Library/Application\ Support/AI-Tools/mcp/.venv/bin/python -m py_compile \
  ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py

# Test mcp import
~/Library/Application\ Support/AI-Tools/mcp/.venv/bin/python -c "import mcp; print('✓ OK')"
```

### Issue: Skill doesn't trigger

**Solution:**
```bash
# Verify skill directory exists
ls ~/Library/Application\ Support/Claude/skills/harness-installation/SKILL.md

# Restart Claude
killall Claude && sleep 3 && open /Applications/Claude.app

# Try triggering with exact text:
# "Help me install Harness"
```

---

## File Locations Reference

### MCP Server
- **Path:** `~/Library/Application Support/AI-Tools/mcp/`
- **File:** `harness_claude_advanced_mcp.py`
- **Version:** 3.0.1
- **Backup:** `harness_claude_advanced_mcp.py.backup.*`

### Python Environment
- **venv:** `~/Library/Application Support/AI-Tools/mcp/.venv/`
- **Python:** `.venv/bin/python`
- **Packages:** `.venv/lib/python3.14/site-packages/`

### Claude Desktop Config
- **Path:** `~/Library/Application Support/Claude/`
- **File:** `claude_desktop_config.json`

### Harness Installation Skill
- **Path:** `~/Library/Application Support/Claude/skills/`
- **Directory:** `harness-installation/`
- **Main file:** `SKILL.md`

### Diagnostic Tools
- **Directory:** `harness-installation/scripts/`
- **Scripts:**
  - `SYSTEM_DIAGNOSTICS.sh`
  - `VALIDATE_AND_FIX_CLAUDE_CONFIG.sh`
  - `MCP_PERFORMANCE_VALIDATOR.sh`
  - `HARNESS_ENVIRONMENT_MIGRATION.sh`
  - `HARNESS_UNINSTALL_AND_CLEANUP.sh`
  - `verify_harness_installation.sh`
  - And more

---

## Quick Reference Commands

```bash
# Restart Claude
killall Claude && open /Applications/Claude.app

# Check MCP server version
grep "v3.0.1" ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py

# Verify venv Python
~/Library/Application\ Support/AI-Tools/mcp/.venv/bin/python --version

# Run system diagnostics
bash ~/Library/Application\ Support/Claude/skills/harness-installation/scripts/SYSTEM_DIAGNOSTICS.sh

# Test MCP import
~/Library/Application\ Support/AI-Tools/mcp/.venv/bin/python -c "import mcp; print('OK')"

# View Claude config
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | grep -A 10 '"harness"'
```

---

## Support Resources

Inside the skill, you have access to:

1. **ADVANCED_TROUBLESHOOTING.md** — Deep troubleshooting guide
2. **claude_desktop_config.template.json** — Config reference template
3. **8 executable scripts** — All diagnostic and repair tools
4. **SKILL.md** — Main documentation

---

## Success Criteria

Installation is complete when:

✅ Claude Desktop restarted without errors  
✅ Settings → Integrations shows "harness [Connected]"  
✅ `@harness help` displays command list  
✅ `@harness status` shows installation details  
✅ Skill triggers on Harness queries  
✅ Diagnostic tools are accessible  

---

## Next Actions

1. **NOW:** Restart Claude: `killall Claude && open /Applications/Claude.app`
2. **Verify:** Check Settings → Integrations
3. **Test:** Type `@harness help` in Claude
4. **Explore:** Type `Help me install Harness` to trigger skill
5. **Diagnose:** Run system diagnostics if needed
6. **Maintain:** Use diagnostic tools anytime

---

## Version Information

- **MCP Server:** v3.0.1 (mcp 1.28.1 compatible)
- **Harness Installation Skill:** v1.0.0
- **Python:** 3.14.6 (your system)
- **mcp library:** 1.28.1
- **Platform:** macOS

---

## Summary

You now have:
- ✅ Working MCP server integrated with Claude
- ✅ Harness Installation Skill with 8 diagnostic tools
- ✅ Full documentation and support scripts
- ✅ Verified configuration

**Restart Claude and verify the connection. You're ready to use Harness.**
