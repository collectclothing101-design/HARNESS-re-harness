# HARNESS v3.0.0 - QUICK REFERENCE CARD

**Print this page or keep it open for quick lookups**

---

## 🚀 QUICK START (Choose One)

```bash
# Fastest (30 sec)
bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh

# Recommended (2 min)
bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh

# Smart (60 sec)
bash /mnt/user-data/outputs/install_harness_v3_PEP668_AWARE.sh
```

---

## ✅ VERIFICATION COMMANDS

```bash
# Quick status (10 seconds)
bash /mnt/user-data/outputs/status.sh

# Full verification (2 minutes)
bash /mnt/user-data/outputs/verify_installation_comprehensive.sh

# Config validation (30 seconds)
python3 /mnt/user-data/outputs/validate_claude_config.py
```

---

## 📁 CRITICAL PATHS

```
Python venv:
  ~/harness_venv/bin/python3

MCP Server:
  ~/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py

Claude Config:
  ~/Library/Application Support/Claude/claude_desktop_config.json

Harness Data:
  ~/Library/Application Support/AI-Tools/harness/

Skills:
  ~/Library/Application Support/Claude/skills/harness-installation/

Deployment Files:
  /mnt/user-data/outputs/
```

---

## 🔧 RESTART / RECONNECT

```bash
# Restart Claude
killall Claude && open /Applications/Claude.app

# Check if Claude running
pgrep -x "Claude"

# Wait for Claude startup
sleep 10

# Verify harness connection
# Settings → Integrations → look for "harness [Connected]"
```

---

## 🧪 TESTING

```bash
# In Claude chat, type:
@harness help          # Basic command test
@harness status        # Status check
@harness list          # List available commands
```

---

## 🐛 TROUBLESHOOTING FLOWCHART

```
Something broken?
├─ Run: bash status.sh
│  ├─ Shows errors? → Use validate_claude_config.py
│  ├─ Shows warnings? → Restart Claude + recheck
│  └─ All good? → Restart Claude
│
├─ "harness [Disconnected]"?
│  ├─ Run: python3 validate_claude_config.py
│  ├─ Check paths are correct
│  └─ Restart Claude
│
├─ "@harness help" fails?
│  ├─ Check: Settings → Integrations → [Connected]?
│  ├─ If not: Run installation script again
│  └─ If yes: Restart Claude, wait 10 sec
│
└─ Installation script fails?
   ├─ Are you on Homebrew Python? → Use VENV method
   ├─ Are you in venv already? → Run outside venv
   ├─ Disk full? → Free up space
   └─ Permission denied? → Check sudo access
```

---

## 📚 DOCUMENTATION FILES

```
Quick intro:
  00_IMMEDIATE_ACTION_SUMMARY.md (2 min read)

Decision help:
  00_START_HERE_INSTALLATION_GUIDE.md (5 min read)

Errors & fixes:
  TROUBLESHOOTING_AND_QUICK_REFERENCE.md (10 min read)

Technical details:
  FIX_PEP668_EXTERNALLY_MANAGED_ENVIRONMENT.md (15 min read)

Full scope:
  FINAL_DELIVERY_SUMMARY.md (10 min read)

Team deployment:
  TEAM_DEPLOYMENT_GUIDE.md (20 min read)

File catalog:
  HARNESS_v3_FILE_INDEX.md (5 min read)
```

---

## 🚨 EMERGENCY CLEANUP

```bash
# Remove everything (reset to clean state)
rm -rf ~/harness_venv
rm ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py

# Edit config file to remove harness entry
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
# Delete the "harness" section

# Restart Claude
killall Claude && open /Applications/Claude.app
```

---

## 🔍 DIAGNOSTIC COMMANDS

```bash
# Check Python version
python3 --version

# Check Python prefix
python3 -c "import sys; print(sys.prefix)"

# Check MCP module
python3 -c "import mcp; print(mcp.__version__)"

# Check MCP server file
ls -lh ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py

# Check config file
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | python3 -m json.tool

# Check Claude version
/Applications/Claude.app/Contents/Info.plist

# Check network (Anthropic API)
curl -s -I https://api.anthropic.com | head -1
```

---

## 🔗 ENVIRONMENT VARIABLES

```bash
# Show all Harness-related env vars
env | grep HARNESS

# Set for next command only
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1 && python3 -m pip install mcp

# Set permanently (add to ~/.zshrc or ~/.bash_profile)
export HARNESS_DIR="$HOME/Library/Application Support/AI-Tools/harness"
export HARNESS_LOG_LEVEL="INFO"
```

---

## 📊 INSTALLATION DECISION TABLE

| Scenario | Method | Time | Safety | Best For |
|----------|--------|------|--------|----------|
| Testing | QUICK_FIX | 30s | High | First time users |
| Production | VENV | 2m | Highest | Teams |
| Automated | PEP668_AWARE | 1m | High | CI/CD |
| Understanding | Manual | 5m | High | Architects |

---

## ✨ CLAUDE SETTINGS PATH

```
Claude Desktop
  → Click ⚙️ (Settings) - top right
    → Look for "Integrations" or "Developers"
      → Find "harness"
        → Should show [Connected] with ✓
```

---

## 🎯 SUCCESS CHECKLIST

- [ ] Installation script completed without errors
- [ ] status.sh shows all ✓
- [ ] Claude Settings → Integrations → "harness [Connected]"
- [ ] @harness help works in Claude chat
- [ ] verify_installation_comprehensive.sh passes

**All checked?** ✅ You're ready!

---

## 📞 SUPPORT QUICK LOOKUP

| Issue | Command | File |
|-------|---------|------|
| "Can't install" | VENV method | 00_START_HERE... |
| "Config broken" | validate_claude_config.py | TROUBLESHOOTING... |
| "Can't verify" | verify_installation_comprehensive.sh | INSTALLATION_CHECKLIST |
| "Understand PEP 668" | (nothing, just read) | FIX_PEP668... |
| "Team setup" | TEAM_DEPLOYMENT_GUIDE.md | TEAM_DEPLOYMENT... |

---

## 🔐 SECURITY NOTES

```
✓ Safe: All scripts are reversible
✓ Safe: Virtual environment is isolated
✓ Safe: Uses --user scope for user installs
✓ Safe: No system Python modifications
✗ Caution: Needs admin password for PATH setup
✗ Caution: Reads/writes to ~/Library/

Data stored in:
  ~/.local/lib/python3.x/mcp/     (quick fix)
  ~/harness_venv/                  (venv method)
  ~/Library/Application Support/   (Claude config)
```

---

## ⏱️ TIME ESTIMATES

```
Installation:
  QUICK_FIX:    30 seconds
  VENV:         2 minutes
  PEP668_AWARE: 1 minute

Verification:
  status.sh:              10 seconds
  validate_config.py:     30 seconds
  comprehensive check:    2 minutes

Total from zero to working:
  Fastest:        5 minutes
  Recommended:    15 minutes
  Full audit:     20 minutes
```

---

## 🎓 LEARNING PATH

**5 min**: 00_IMMEDIATE_ACTION_SUMMARY.md → Run QUICK_FIX → Done

**15 min**: 00_START_HERE_INSTALLATION_GUIDE.md → Choose method → Run script → Verify

**30 min**: Full docs → Understand options → Choose best method → Deploy

**60 min**: Read everything → Understand architecture → Deploy + audit → Team setup

---

**Bookmark this page for quick access!**

**Last updated**: 2026-07-01  
**Version**: Harness v3.0.0
