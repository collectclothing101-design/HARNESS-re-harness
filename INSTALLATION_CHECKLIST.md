# HARNESS v3.0.0 - INSTALLATION CHECKLIST

## Pre-Installation Phase ⓪

- [ ] Read `00_IMMEDIATE_ACTION_SUMMARY.md`
- [ ] Understand the problem (PEP 668 prevents pip install)
- [ ] Choose installation method (QUICK_FIX or VENV)
- [ ] Close Claude Desktop completely: `killall Claude`
- [ ] Verify Python version: `python3 --version`

**Est. Time**: 3-5 minutes

---

## Installation Phase ①

### Choose ONE installation method:

#### Option A: QUICK_FIX (Recommended for testing)

- [ ] Run: `bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh`
- [ ] Script completes without errors
- [ ] See message: "✓ INSTALLATION COMPLETE"

**Expected time**: ~30 seconds

#### Option B: VENV (Recommended for production)

- [ ] Run: `bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh`
- [ ] Virtual environment created at `~/harness_venv`
- [ ] mcp installed inside venv
- [ ] Claude config updated with venv Python path
- [ ] See message: "✓ INSTALLATION COMPLETE"

**Expected time**: ~2 minutes

#### Option C: Manual (Advanced)

- [ ] Set environment: `export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1`
- [ ] Install mcp: `python3 -m pip install --break-system-packages --user mcp`
- [ ] Create directories manually
- [ ] Copy MCP server file
- [ ] Update Claude config with JSON
- [ ] Restart Claude

**Expected time**: ~3 minutes

---

## Post-Installation Phase ②

### After running installation script:

- [ ] Installation script completed without errors
- [ ] Directories created:
  - [ ] `~/Library/Application Support/AI-Tools/harness/`
  - [ ] `~/Library/Application Support/AI-Tools/mcp/`
  - [ ] `~/Library/Application Support/Claude/skills/`
- [ ] MCP server file copied: `~/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py`
- [ ] Claude config updated: `~/Library/Application Support/Claude/claude_desktop_config.json`

**Est. Time**: Automatic (part of installation script)

---

## Claude Restart Phase ③

### Restart Claude Desktop:

```bash
killall Claude && open /Applications/Claude.app
```

- [ ] Claude closes completely
- [ ] Claude starts up
- [ ] Wait for Claude to fully load (30-60 seconds)
- [ ] Claude shows main window and chat interface

**Est. Time**: 1-2 minutes

---

## Verification Phase ④

### Verify connection in Claude Desktop:

- [ ] Open Claude Settings (⚙️ icon, usually top-right)
- [ ] Click "Integrations" tab
- [ ] Look for "harness" entry
- [ ] Status shows: **"harness [Connected]"** (green checkmark ✓)
- [ ] NOT showing: "harness [Disconnected]" (red X)

**Visual verification**: Should show green indicator

**Est. Time**: 1 minute

---

## Functional Testing Phase ⑤

### Test Harness commands:

#### Test 1: Basic Command
- [ ] In Claude chat, type: `@harness help`
- [ ] Claude responds with Harness help output
- [ ] Command executes without errors

#### Test 2: Status Check
- [ ] In Claude chat, type: `@harness status`
- [ ] Claude responds with status information
- [ ] Shows Harness version and availability

#### Test 3: List Command
- [ ] In Claude chat, type: `@harness list`
- [ ] Claude displays available commands or options
- [ ] No connection errors

**Expected result**: All three commands work  
**Est. Time**: 2-3 minutes

---

## Verification Testing Phase ⑥

### Run verification scripts:

#### Option A: Comprehensive Verification
```bash
bash /mnt/user-data/outputs/verify_installation_comprehensive.sh
```
- [ ] Script runs without errors
- [ ] Shows: "✓ Installation verified successfully!"
- [ ] Checks: 10 different verification points
- [ ] All checks pass or show warnings only

**Est. Time**: 1-2 minutes

#### Option B: Configuration Validation
```bash
python3 /mnt/user-data/outputs/validate_claude_config.py
```
- [ ] Script runs successfully
- [ ] Shows: "✓ Configuration is valid!"
- [ ] Checks: JSON syntax, paths, environment variables
- [ ] No errors reported

**Est. Time**: 1 minute

---

## Troubleshooting Phase ⑦ (If needed)

### If anything failed:

- [ ] Check: `00_IMMEDIATE_ACTION_SUMMARY.md` → Troubleshooting section
- [ ] Read: `TROUBLESHOOTING_AND_QUICK_REFERENCE.md`
- [ ] Match error to scenario (4 common scenarios listed)
- [ ] Follow fix steps

### If "harness [Disconnected]":
- [ ] Verify Claude config is valid: `python3 /mnt/user-data/outputs/validate_claude_config.py`
- [ ] Check file paths in config
- [ ] Restart Claude: `killall Claude && open /Applications/Claude.app`
- [ ] Wait 10 seconds and check again

### If "@harness" command fails:
- [ ] Verify connection shows as [Connected]
- [ ] Restart Claude
- [ ] Try simpler command: `@harness help`
- [ ] Check Claude logs/console

---

## Success Criteria ✅

You're done when:

- [x] Installation script completed
- [x] Claude restarted
- [x] Settings → Integrations shows "harness [Connected]"
- [x] `@harness help` works in chat
- [x] Verification script shows all checks passed
- [x] Configuration validation reports no errors

**All items checked**: ✅ **INSTALLATION SUCCESSFUL**

---

## Quick Reference Checklist

### Daily Use

- [ ] Claude Desktop running
- [ ] Check "harness [Connected]" in Settings/Integrations
- [ ] Use `@harness` commands as needed
- [ ] No error messages in chat

### Maintenance (Weekly)

- [ ] Run verification script: `bash verify_installation_comprehensive.sh`
- [ ] Run config validation: `python3 validate_claude_config.py`
- [ ] Check Claude logs for any warnings

### Troubleshooting (If issues appear)

1. [ ] Note error message
2. [ ] Check `TROUBLESHOOTING_AND_QUICK_REFERENCE.md`
3. [ ] Match error to scenario
4. [ ] Follow fix steps
5. [ ] Restart Claude
6. [ ] Re-verify with scripts

---

## Estimated Total Installation Time

| Phase | Time | Cumulative |
|-------|------|-----------|
| Pre-Installation | 3-5 min | 3-5 min |
| Installation (QUICK_FIX) | 0.5 min | 3.5-5.5 min |
| Post-Installation | Auto | Auto |
| Claude Restart | 1-2 min | 4.5-7.5 min |
| Verification | 1-2 min | 5.5-9.5 min |
| Testing | 2-3 min | 7.5-12.5 min |
| **Total** | | **7.5-12.5 min** |

**Fastest path** (QUICK_FIX + minimal verification): ~10 minutes  
**Recommended path** (VENV + full verification): ~15 minutes

---

## Sign-Off

When you've completed all phases:

**Installation Date**: _____________  
**Method Used**: ☐ QUICK_FIX  ☐ VENV  ☐ MANUAL  
**Completed By**: _____________________  
**All Tests Passed**: ☐ YES  ☐ NO

**Notes/Issues**: ___________________________________________________________

---

## File Reference

All tools referenced in this checklist are in:
```
/mnt/user-data/outputs/
```

- `QUICK_FIX_INSTALL_NOW.sh` — Fast installation
- `VENV_SETUP_RECOMMENDED.sh` — Best practice installation
- `verify_installation_comprehensive.sh` — Detailed verification
- `validate_claude_config.py` — Config validation
- `TROUBLESHOOTING_AND_QUICK_REFERENCE.md` — Error scenarios

---

**Version**: Harness v3.0.0  
**Last Updated**: 2026-07-01  
**Status**: Ready for use
