# 🚀 HARNESS v3.0.0 - INSTALLATION DECISION TREE

## WHERE ARE YOU?

### ❌ Installation is failing with PEP 668 error
→ You're in the right place. Pick your solution below.

---

## WHICH SOLUTION DO YOU WANT?

### 🔥 FASTEST (30 seconds - Recommended for testing)
```bash
bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh
```
**Good for:**
- First time setup
- Quick testing
- Just want it working now

**What it does:**
- Overrides PEP 668 safely with `--break-system-packages --user`
- Installs mcp to ~/.local (user scope only)
- Updates Claude config
- You're done

**Time**: ~30 seconds (plus Claude restart)

---

### 🏆 RECOMMENDED (2 minutes - Best for production)
```bash
bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh
```
**Good for:**
- Production deployments
- Team environments
- Long-term maintenance
- Keeping system Python clean

**What it does:**
- Creates isolated Python virtual environment
- Installs mcp only in venv (no system changes)
- Updates Claude to use venv
- Maximum isolation and safety

**Time**: ~2 minutes (plus Claude restart)

---

### 🛠️ ADVANCED (Manual control)
```bash
# See TROUBLESHOOTING_AND_QUICK_REFERENCE.md
# → SOLUTION 3: MANUAL OVERRIDE
```
**Good for:**
- Custom configurations
- Understanding what's happening
- Debugging issues
- CI/CD pipelines

**What it does:**
- You run each step manually
- Full control
- Full understanding

**Time**: ~3 minutes

---

## AFTER INSTALLATION

### Step 1: Restart Claude
```bash
killall Claude && open /Applications/Claude.app
```

### Step 2: Verify in Settings
1. Open Claude
2. Go to Settings ⚙️
3. Click "Integrations" tab
4. Look for **"harness [Connected]"** (should be green)

### Step 3: Test
In any Claude chat, type:
```
@harness help
```

Should see Harness commands and options.

---

## TROUBLESHOOTING

### Still getting PEP 668 error?
**Solutions ran but still failing?**
1. Check you ran the right script
2. Make sure Claude is fully closed: `killall Claude`
3. Try the other solution (VENV if you used QUICK_FIX, or vice versa)
4. See: `TROUBLESHOOTING_AND_QUICK_REFERENCE.md`

### Harness shows [Disconnected]?
1. Check Claude config: `cat ~/Library/Application\ Support/Claude/claude_desktop_config.json`
2. Verify paths are correct (copy-paste from script output)
3. Restart Claude completely: `killall Claude`
4. Wait 5 seconds, then: `open /Applications/Claude.app`

### "@harness" command not recognized?
1. Verify harness [Connected] in Settings → Integrations
2. Restart Claude
3. Make sure you're typing `@harness` (with the @ symbol)
4. Try: `@harness help` or `@harness status`

### mcp module import fails?
```bash
# Check which Python
python3 --version

# Verify mcp installed in that Python
python3 -c "import mcp; print('OK')"

# If missing, install it
python3 -m pip install --break-system-packages --user mcp
```

---

## 📊 COMPARISON TABLE

| Aspect | QUICK FIX | VENV | MANUAL |
|--------|-----------|------|--------|
| Time | 30 sec | 2 min | 3 min |
| Complexity | Easiest | Easy | Medium |
| System Changes | Minimal | None | User-controlled |
| Reversal | Easy | Easy | Easy |
| Production Ready | Yes | ✅ Yes | Yes |
| Team Friendly | OK | ✅ Best | OK |
| **Recommended** | ✅ First try | ✅ Best | Advanced |

---

## 🎯 WHAT TO DO RIGHT NOW

### If you just want Harness working ASAP:
```bash
bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh
```
Then restart Claude. Done.

### If you have time and want it done right:
```bash
bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh
```
Then restart Claude. Done (properly).

### If you want to understand everything:
1. Read: `FIX_PEP668_EXTERNALLY_MANAGED_ENVIRONMENT.md`
2. Then run whichever script you prefer

---

## 📂 FILES IN THIS DELIVERY

```
/mnt/user-data/outputs/

Installation Scripts:
├── QUICK_FIX_INSTALL_NOW.sh           [Run this for fastest fix]
├── VENV_SETUP_RECOMMENDED.sh           [Run this for production]
├── install_harness_v3_PEP668_AWARE.sh  [Smart installer]
└── install_harness_v3_corrected.sh     [Original (no PEP 668 fix)]

Documentation:
├── THIS FILE (Decision guide)
├── FIX_PEP668_EXTERNALLY_MANAGED_ENVIRONMENT.md [Full explanation]
├── TROUBLESHOOTING_AND_QUICK_REFERENCE.md       [Complete guide]
├── HARNESS_SKILL_v1_0_0_COMPLETE_DELIVERY.md    [Skill docs]
└── (8+ other reference docs)

MCP Server:
└── harness_claude_advanced_mcp.py      [The actual server]

Skill Package:
└── harness-installation/
    ├── SKILL.md
    ├── README.md
    └── references/
        ├── ADVANCED_TROUBLESHOOTING.md
        └── claude_desktop_config.template.json
```

---

## ✅ INSTALLATION CHECKLIST

After running your chosen script:

- [ ] Script completed without errors
- [ ] Claude was restarted
- [ ] Settings → Integrations shows "harness [Connected]"
- [ ] @harness help command works
- [ ] You can type: @harness status
- [ ] Everything is green ✅

If all checked: **You're done!**

---

## 🆘 ONE-LINE HELP

**Still not working?**
→ Open: `TROUBLESHOOTING_AND_QUICK_REFERENCE.md`

**Want to understand PEP 668?**
→ Open: `FIX_PEP668_EXTERNALLY_MANAGED_ENVIRONMENT.md`

**Need Harness documentation?**
→ Open: `HARNESS_SKILL_v1_0_0_COMPLETE_DELIVERY.md`

---

**Last Updated**: 2026-07-01  
**Version**: Harness v3.0.0  
**Status**: ✅ Ready to install
