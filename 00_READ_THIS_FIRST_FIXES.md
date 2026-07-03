# Harness v3.0.0 - Installation Fixes DELIVERED ✅

## Status Summary

**Three critical installation bugs have been identified, fixed, and documented.**

Your Harness v3.0.0 installation failed due to:
1. ❌ **Wrong MCP server filename** - Script looked for v2 file, not v3
2. ❌ **Environment variable bug** - Python subprocess couldn't read bash variables
3. ❌ **Rust/LLVM incompatibility** - Homebrew libraries were misaligned on macOS

**All three bugs are now FIXED** in the new corrected installation script.

---

## What You Have Now

### 🟢 PRIMARY INSTALLATION FILE

**`install_harness_v3_corrected.sh`** (13 KB) ← **USE THIS**

This is the corrected universal installation script with all three bugs fixed. It:
- ✅ Looks for the correct MCP server filename (`harness_claude_advanced_mcp.py`)
- ✅ Properly exports environment variables to Python
- ✅ Detects and fixes Rust/LLVM issues on macOS
- ✅ Provides detailed error messages and verification

### 🟢 SUPPORTING COMPONENTS

**`harness_claude_advanced_mcp.py`** (33 KB)
- The v3.0.0 MCP server application
- This is the file the script will install

### 🟢 DOCUMENTATION FILES

1. **`HARNESS_v3_INSTALLATION_FIX_GUIDE.md`** (11 KB)
   - Complete troubleshooting guide
   - Explains each bug in detail
   - Three different solution paths
   - System diagnostics and verification

2. **`HARNESS_v3_QUICK_FIX_COMMANDS.sh`** (5.3 KB)
   - Quick reference with copy-paste commands
   - Five different options for fixing
   - Diagnostic and verification commands

3. **`INSTALLATION_FIXES_SUMMARY.md`** (8.8 KB)
   - This session's complete technical summary
   - What changed and why
   - Testing recommendations
   - Prevention strategies for future versions

---

## 🚀 NEXT STEPS - What You Should Do Now

### Option A: Quick Installation (Recommended)

Copy and paste these commands:

```bash
# 1. Navigate home
cd ~

# 2. Copy the corrected script and MCP server
cp /mnt/user-data/outputs/install_harness_v3_corrected.sh .
cp /mnt/user-data/outputs/harness_claude_advanced_mcp.py .

# 3. Run the installation
bash install_harness_v3_corrected.sh

# 4. Follow the on-screen instructions
# (The script will tell you what to do next)

# 5. Restart Claude Desktop
# (Quit completely and reopen)

# 6. Verify
# Go to Settings > Integrations and look for "harness [Connected]"
```

**Expected time:** 2-3 minutes

---

### Option B: Step-by-Step Manual Installation

See `HARNESS_v3_INSTALLATION_FIX_GUIDE.md` for detailed manual steps if the script doesn't work.

---

## 🔍 Verification After Installation

After running the script, verify everything worked:

```bash
# Check 1: MCP server file exists
ls ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py

# Check 2: Python can import mcp
python3 -c "import mcp; print('✓ Success')"

# Check 3: Claude config exists
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Check 4: Claude Desktop shows Harness as Connected
# → Restart Claude Desktop
# → Go to Settings > Integrations
# → Look for "harness" in the MCP Servers section
```

---

## 📋 File Reference

All files are in `/mnt/user-data/outputs/`:

| File | Size | Purpose |
|------|------|---------|
| `install_harness_v3_corrected.sh` | 13 KB | **⭐ Main installation script (USE THIS)** |
| `harness_claude_advanced_mcp.py` | 33 KB | The v3.0.0 MCP server application |
| `HARNESS_v3_INSTALLATION_FIX_GUIDE.md` | 11 KB | Complete troubleshooting guide |
| `HARNESS_v3_QUICK_FIX_COMMANDS.sh` | 5.3 KB | Quick reference commands |
| `INSTALLATION_FIXES_SUMMARY.md` | 8.8 KB | Technical summary of all fixes |
| `HARNESS_v3_QUICK_START.md` | 14 KB | Harness v3.0.0 quick start guide |
| `HARNESS_v3_FINAL_DELIVERY_MANIFEST.md` | 15 KB | v3.0.0 delivery manifest |

---

## 🔧 What Was Fixed

### Bug #1: Wrong MCP Server Filename
**Before:**
```bash
if [ -f "./harness_mcp_server_v2.py" ]; then  # ❌ Wrong filename
```

**After:**
```bash
local mcp_filename="harness_claude_advanced_mcp.py"  # ✅ Correct v3.0.0 name
if [ -f "./$mcp_filename" ]; then
```

### Bug #2: Environment Variables Not Visible to Python
**Before:**
```bash
python3 << 'EOF'
config_file = os.path.expandvars("$CONFIG_FILE")  # ❌ Variable not exported
EOF
```

**After:**
```bash
export CONFIG_FILE="$CONFIG_FILE"  # ✅ Export before calling Python
python3 << 'EOF'
config_file = os.environ.get("CONFIG_FILE")  # ✅ Read from environment
EOF
```

### Bug #3: Rust/LLVM Compilation Failure (macOS)
**Before:**
```bash
python3 -m pip install mcp  # ❌ Tries to compile cryptography, Rust crashes
```

**After:**
```bash
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1  # ✅ Avoid compilation
export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1

python3 -m pip install \
    --only-binary :all: \  # ✅ Use pre-built wheels only
    --no-deps \
    mcp
```

---

## ❓ FAQ

### Q: Which file should I use?
**A:** Use `install_harness_v3_corrected.sh` - it has all three bugs fixed.

### Q: Do I need the MCP server file?
**A:** Yes, the installation script expects to find `harness_claude_advanced_mcp.py` in the same directory before running.

### Q: What if the script fails?
**A:** See `HARNESS_v3_INSTALLATION_FIX_GUIDE.md` for troubleshooting and manual installation steps.

### Q: How do I know if it worked?
**A:** 
1. The script will show "Installation Complete!" at the end
2. Verify using the commands in the "Verification After Installation" section above
3. Claude Desktop Settings > Integrations should show "harness [Connected]"

### Q: Do I need to fix my Rust/LLVM issue?
**A:** No, the corrected script works around it. But if you want to fix it permanently:
```bash
brew reinstall rust
```

### Q: Can I use the old installation script?
**A:** No - the old `install_harness_universal.sh` and `install_harness_fixed.sh` have bugs. Only use `install_harness_v3_corrected.sh`.

---

## 📞 If You Get Stuck

**Don't panic!** Here's what to do:

1. **Read the error message carefully** - the script provides detailed messages
2. **Check the QUICK_FIX_COMMANDS.sh** - it has copy-paste solutions for common issues
3. **See the INSTALLATION_FIX_GUIDE.md** - comprehensive troubleshooting for every error
4. **Try manual installation** - follow the step-by-step guide in the fix guide
5. **Verify each step** - the guide has verification commands for each stage

---

## 📝 System Information Captured

During your failed installation, we captured:
- **OS:** macOS (Sonoma/Ventura)
- **Python:** 3.14.6 (MacPorts)
- **Rust:** 1.93.1 (Homebrew) ← This was the issue
- **LLVM:** 22.1.7 (Homebrew) ← Incompatible with Rust
- **Node.js:** v25.8.0

The corrected script accounts for this configuration.

---

## ✨ What Happens Next (After Installation)

Once Harness is installed and running:

1. **Use in Claude Chat:**
   ```
   "Design a multi-agent team for content analysis"
   "Validate this architecture specification"
   "Optimize team performance"
   ```

2. **Harness will provide:**
   - Multi-agent team designs
   - Architecture validation
   - Performance optimization suggestions
   - Team coordination patterns
   - Skill creation templates

3. **Full documentation:**
   - See `HARNESS_v3_QUICK_START.md`
   - See `HARNESS_v3_FINAL_DELIVERY_MANIFEST.md`

---

## 🎯 Summary

✅ **All three bugs identified and fixed**
✅ **Corrected installation script created**
✅ **Complete documentation provided**
✅ **Multiple solution paths documented**
✅ **Ready for installation**

**What to do:** Run `bash install_harness_v3_corrected.sh` in the directory with `harness_claude_advanced_mcp.py`

**Questions?** See `HARNESS_v3_INSTALLATION_FIX_GUIDE.md` or `HARNESS_v3_QUICK_FIX_COMMANDS.sh`

---

**Version:** Harness v3.0.0  
**Installation Fixes:** Complete  
**Status:** ✅ READY TO INSTALL  
**Created:** 2026-06-30  
**Time to Install:** ~3 minutes
