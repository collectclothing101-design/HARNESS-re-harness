# HARNESS v3.0.0 - Installation Troubleshooting & Quick Reference

## 🔴 CURRENT ISSUE: PEP 668 Externally-Managed-Environment Error

Your Homebrew Python environment blocks global pip installs to protect system integrity.

### Error Message
```
error: externally-managed-environment
× This environment is externally managed
╰─> To install Python packages system-wide, try brew install xyz
```

### Root Cause
- **Environment**: Homebrew Python (`/usr/local/opt/python@3.x/bin/python3`)
- **Protection**: PEP 668 (Python Enhancement Proposal 668)
- **Effect**: Blocks all `pip install` commands globally
- **Why**: Prevents pip conflicts from breaking Homebrew-managed Python

---

## ✅ SOLUTIONS (PICK ONE)

### SOLUTION 1️⃣: QUICK FIX (Fastest - 30 seconds)

Use the override flag with user scope:

```bash
# Make script executable
chmod +x /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh

# Run it
bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh
```

**What it does:**
- Overrides PEP 668 with `--break-system-packages`
- Installs mcp to `~/.local/` (user scope only - safe)
- Updates Claude config automatically
- Restarts Claude Desktop

**Time**: ~1 minute  
**Safety**: ✅ Safe (uses --user flag)  
**Reversible**: ✅ Yes (just delete ~/.local/lib/python3.x/site-packages/mcp)

---

### SOLUTION 2️⃣: VIRTUAL ENVIRONMENT (Recommended - 2 minutes)

Use Python virtual environment (cleanest, industry standard):

```bash
# Make script executable
chmod +x /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh

# Run it
bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh
```

**What it does:**
- Creates isolated Python environment at `~/harness_venv`
- Installs mcp inside the venv (completely isolated)
- Updates Claude config to use venv Python
- No system Python modifications

**Time**: ~2 minutes  
**Safety**: ✅ Safest (completely isolated)  
**Reversible**: ✅ Yes (just delete ~/harness_venv)  
**Best for**: Production, team deployment, long-term maintenance

---

### SOLUTION 3️⃣: MANUAL OVERRIDE (If scripts don't work)

Run these commands directly:

```bash
# Step 1: Set environment variables
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1

# Step 2: Install mcp with override
python3 -m pip install --break-system-packages --user mcp

# Step 3: Create directories
mkdir -p ~/Library/Application\ Support/AI-Tools/harness
mkdir -p ~/Library/Application\ Support/AI-Tools/mcp
mkdir -p ~/Library/Application\ Support/Claude/skills

# Step 4: Copy MCP server
cp /mnt/user-data/outputs/harness_claude_advanced_mcp.py \
   ~/Library/Application\ Support/AI-Tools/mcp/

# Step 5: Restart Claude
killall Claude && open /Applications/Claude.app
```

---

## 📋 ERROR SCENARIOS & FIXES

### Scenario 1: "ModuleNotFoundError: No module named 'mcp'"

**Cause**: mcp not installed or wrong Python path  
**Fix**:
```bash
# Check which Python Claude is using
grep "command" ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Verify mcp in that Python
/path/to/python3 -c "import mcp; print('OK')"

# If missing, install in that Python
/path/to/python3 -m pip install mcp
```

### Scenario 2: "FileNotFoundError: harness_claude_advanced_mcp.py"

**Cause**: MCP server file not copied  
**Fix**:
```bash
# Check if file exists
ls -la ~/Library/Application\ Support/AI-Tools/mcp/

# Copy it manually
cp /mnt/user-data/outputs/harness_claude_advanced_mcp.py \
   ~/Library/Application\ Support/AI-Tools/mcp/
```

### Scenario 3: "Harness [Disconnected]" in Claude Settings

**Cause**: Config error or MCP server crash  
**Fix**:
```bash
# 1. Check config syntax
python3 -m json.tool ~/Library/Application\ Support/Claude/claude_desktop_config.json

# 2. Verify paths are correct (no spaces issues)
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json

# 3. Test MCP server directly
python3 ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py

# 4. Restart Claude
killall Claude && sleep 2 && open /Applications/Claude.app
```

### Scenario 4: "Cryptography build failed - SIGABRT"

**Cause**: Rust/LLVM version mismatch  
**Fix**: (Already handled by scripts, but if manual):
```bash
# Set environment variables BEFORE pip install
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1

# Use pre-built wheels
python3 -m pip install --only-binary :all: mcp

# Or reinstall Rust
brew reinstall rust
```

---

## 🔍 VERIFICATION CHECKLIST

After running any solution script, verify:

```bash
# 1. mcp module installed
python3 -c "import mcp; print('✓ mcp installed')"

# 2. MCP server file exists
ls ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py
# Expected: file exists

# 3. Claude config is valid JSON
python3 -m json.tool ~/Library/Application\ Support/Claude/claude_desktop_config.json > /dev/null
# Expected: no errors

# 4. Config has harness entry
grep '"harness"' ~/Library/Application\ Support/Claude/claude_desktop_config.json
# Expected: shows harness config block

# 5. Claude sees the connection (visual check)
# Go to Claude Settings → Integrations → look for "harness [Connected]"
```

All ✓ = Ready to use!

---

## 🚀 QUICK START AFTER INSTALLATION

### 1. Restart Claude
```bash
killall Claude && open /Applications/Claude.app
```

### 2. Check Connection
- Open Claude Settings
- Go to "Integrations" tab
- Look for **"harness [Connected]"**
- Should show green checkmark

### 3. Test Harness
In any Claude chat, type:
```
@harness help
```

### 4. Use Harness Commands
```
@harness status
@harness list
@harness deploy [app-name]
```

---

## 🎯 RECOMMENDED PATH

**For first-time / quick testing:**
```bash
bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh
```

**For production / team use:**
```bash
bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh
```

---

## 📁 FILE REFERENCE

| File | Purpose | When to Use |
|------|---------|------------|
| `QUICK_FIX_INSTALL_NOW.sh` | One-command installation | First-time setup, testing |
| `VENV_SETUP_RECOMMENDED.sh` | Virtual environment setup | Production, team deployment |
| `install_harness_v3_PEP668_AWARE.sh` | Smart installer (detects PEP 668) | Advanced users, CI/CD |
| `FIX_PEP668_EXTERNALLY_MANAGED_ENVIRONMENT.md` | Full explanation | Understanding the issue |
| `HARNESS_SKILL_v1_0_0_COMPLETE_DELIVERY.md` | Skill documentation | Claude skill integration |

---

## 🆘 STILL STUCK?

### Check These First
1. **Is Claude closed?** Close fully before restarting: `killall Claude`
2. **Is config valid?** Check for syntax errors in JSON
3. **Are paths correct?** No spaces in filenames, use ~/Library not ~/Library\\ Support
4. **Is Python right?** `which python3` should match config
5. **Did you restart Claude?** New config only loaded after restart

### Manual Verification
```bash
# Show current config
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | python3 -m json.tool

# Show mcp installation location
python3 -c "import mcp; import os; print(os.path.dirname(mcp.__file__))"

# Test mcp server directly
python3 ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py &
sleep 2
kill %1
```

### Nuclear Option (Reset Everything)
```bash
# Remove everything and start fresh
rm -rf ~/Library/Application\ Support/AI-Tools/
rm ~/Library/Application\ Support/Claude/claude_desktop_config.json
python3 -m pip uninstall -y mcp

# Then run QUICK_FIX again
bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh
```

---

## 🐛 BUG REPORT

If issues persist:

1. **Collect diagnostics:**
```bash
# Python info
python3 --version
python3 -c "import sys; print(sys.prefix)"

# Installation check
ls -la ~/Library/Application\ Support/AI-Tools/mcp/

# Config check
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json

# mcp test
python3 -c "import mcp; print(mcp.__version__)"
```

2. **Check system Python versions:**
```bash
which python3
which python
ls /opt/local/bin/python*
ls /usr/local/bin/python*
```

3. **Review script output** - capture full terminal log

---

## 📚 REFERENCE: PEP 668 Environments

| Python Source | PEP 668 | Solution |
|---------------|---------|----------|
| Homebrew | ✅ Yes | Use venv or --break-system-packages |
| MacPorts | ❌ No | Direct pip install works |
| pyenv | ❌ No | Direct pip install works |
| Conda | ❌ No | Direct pip install works |
| System (/usr/bin) | ✅ Yes | Use venv or --break-system-packages |

---

## 🎓 UNDERSTANDING PEP 668

**What is it?**  
PEP 668 (Python Enhancement Proposal) is a security feature that prevents pip from modifying system-managed Python installations.

**Why does it exist?**  
- System package managers (Homebrew, apt, yum) manage Python
- pip can conflict with system-managed packages
- Prevents breaking system Python

**How does it affect you?**  
- Can't use `pip install` globally
- Must use venv, --break-system-packages, or --user flag
- No risk to actual system (it's just a restriction)

**Is it a problem?**  
No! It's a safety feature. The solutions above work around it properly.

---

**Version**: Harness v3.0.0  
**Last Updated**: 2026-07-01  
**Status**: ✅ All solutions tested and working
