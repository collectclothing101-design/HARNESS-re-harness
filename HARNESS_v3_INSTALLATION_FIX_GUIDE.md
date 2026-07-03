# Harness v3.0.0 Installation - Complete Troubleshooting & Fixes

## Executive Summary

Your Harness v3.0.0 installation encountered **three bugs** that have now been fixed:

1. **Wrong MCP filename** - Script looked for `harness_mcp_server_v2.py` instead of `harness_claude_advanced_mcp.py`
2. **Environment variable passing bug** - Python subprocess couldn't access bash environment variables  
3. **Rust/LLVM incompatibility** - Homebrew versions of Rust and LLVM on macOS are incompatible

**All fixes are implemented in the new script:** `install_harness_v3_corrected.sh`

---

## What Went Wrong

### Error #1: MCP Server Not Found
```
! harness_mcp_server_v2.py not found in expected locations
```

**Root Cause:** The installation script was written for v2.0 but you're installing v3.0.0. The v3 MCP server has a different filename:
- ❌ `harness_mcp_server_v2.py` (old, no longer used)
- ✅ `harness_claude_advanced_mcp.py` (v3.0.0 - correct)

### Error #2: Claude Config Path Error
```
FileNotFoundError: [Errno 2] No such file or directory: ''
```

**Root Cause:** The Python subprocess couldn't read bash environment variables. When the script did:
```bash
python3 << 'EOF'
config_file = os.path.expandvars("$CONFIG_FILE")
EOF
```

The `$CONFIG_FILE` variable was not exported, so Python received an empty string.

### Error #3: Rust/LLVM Compilation Failure
```
error: process didn't exit successfully: `rustc -vV` (signal: 6, SIGABRT)
Symbol not found: __ZN4llvm10PGOOptionsC1E...
Referenced from: /usr/local/Cellar/rust/1.93.1/lib/librustc_driver-*.dylib
Expected in: /usr/local/Cellar/llvm/22.1.7_1/lib/libLLVM.dylib
```

**Root Cause:** Your macOS system has:
- **Rust 1.93.1** (installed via Homebrew)
- **LLVM 22.1.7** (installed via Homebrew)

These two versions were built against different LLVM versions and are incompatible. When `pip install mcp` tries to compile the `cryptography` package from source, Rust crashes with SIGABRT.

---

## Solutions

### Solution 1: Use the Corrected Installation Script (RECOMMENDED)

The new script `install_harness_v3_corrected.sh` has all three bugs fixed:

```bash
# Step 1: Download the corrected script (or copy from outputs)
cd ~/Downloads
cp /mnt/user-data/outputs/install_harness_v3_corrected.sh .
chmod +x install_harness_v3_corrected.sh

# Step 2: Make sure the MCP server file is in the same directory
cp /mnt/user-data/outputs/harness_claude_advanced_mcp.py .

# Step 3: Run the corrected installation script
./install_harness_v3_corrected.sh
```

**What this script does:**
- ✅ Looks for the correct filename: `harness_claude_advanced_mcp.py`
- ✅ Properly exports bash variables before calling Python
- ✅ Detects Homebrew Rust/LLVM issues and uses pre-built wheels to avoid compilation
- ✅ Provides better error messages and verification

---

### Solution 2: Fix the Underlying Rust/LLVM Issue (Optional)

If you want to fix the underlying system issue:

**Option A: Reinstall Rust (Easiest)**
```bash
brew reinstall rust
```
This recompiles Rust against your current LLVM version.

**Option B: Remove LLVM and let Rust use System LLVM**
```bash
brew uninstall llvm
brew reinstall rust
```

**Option C: Clean Everything and Reinstall**
```bash
brew uninstall llvm
brew uninstall rust
brew install rust
```

---

### Solution 3: Manual Installation (If Script Fails)

If the corrected script still fails, you can install manually:

```bash
# Step 1: Create installation directories
MCP_DIR="$HOME/Library/Application Support/AI-Tools/mcp"
HARNESS_DIR="$HOME/Library/Application Support/AI-Tools/harness"
CONFIG_DIR="$HOME/Library/Application Support/Claude"

mkdir -p "$MCP_DIR"
mkdir -p "$HARNESS_DIR"
mkdir -p "$CONFIG_DIR"

# Step 2: Copy MCP server file
cp harness_claude_advanced_mcp.py "$MCP_DIR/"
chmod +x "$MCP_DIR/harness_claude_advanced_mcp.py"

# Step 3: Install Python dependencies (with workarounds for Rust/LLVM issue)
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1

python3 -m pip install --upgrade pip
python3 -m pip install mcp

# Alternative if above fails:
# python3 -m pip install --only-binary :all: --no-deps mcp
# python3 -m pip install anyio httpx pydantic starlette uvicorn sse-starlette httpx-sse jsonschema

# Step 4: Create Claude Desktop config manually
CONFIG_FILE="$CONFIG_DIR/claude_desktop_config.json"
python3 << 'EOF'
import json
from pathlib import Path

config_path = Path("$HOME/Library/Application Support/Claude/claude_desktop_config.json")
config_path.parent.mkdir(parents=True, exist_ok=True)

if config_path.exists():
    with open(config_path) as f:
        config = json.load(f)
else:
    config = {"mcpServers": {}}

if "mcpServers" not in config:
    config["mcpServers"] = {}

config["mcpServers"]["harness"] = {
    "command": "python3",
    "args": ["$HOME/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"],
    "env": {
        "HARNESS_DIR": "$HOME/Library/Application Support/AI-Tools/harness",
        "HARNESS_LOG_LEVEL": "INFO"
    }
}

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print(f"Config written to: {config_path}")
EOF

# Step 5: Verify
echo "Checking installation..."
ls -la "$MCP_DIR/harness_claude_advanced_mcp.py"
cat "$CONFIG_FILE" | python3 -m json.tool

# Step 6: Restart Claude Desktop and check Settings > Integrations
```

---

## Verification Checklist

After installation, verify each component:

### 1. MCP Server File
```bash
ls -la "$HOME/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"
```
Should show: file exists and is executable (has `x` permission)

### 2. Python Dependencies
```bash
python3 -c "import mcp; print('✓ mcp package installed')"
```
Should output: `✓ mcp package installed`

### 3. Claude Desktop Config
```bash
cat "$HOME/Library/Application Support/Claude/claude_desktop_config.json" | python3 -m json.tool
```
Should contain a `harness` entry under `mcpServers` with the correct path to `harness_claude_advanced_mcp.py`

### 4. Claude Desktop Connection
- Restart Claude Desktop completely (Quit from menu, not just close window)
- Open Settings > Integrations
- You should see **"harness [Connected]"** in the MCP Servers list

---

## System Environment Information

Your system as detected during the failed installation:

- **OS:** macOS (likely Sonoma or Ventura)
- **Architecture:** Apple Silicon (arm64) or Intel (x86_64)
- **Python:** `/opt/local/bin/python3` (MacPorts), version 3.14.6
- **Rust:** `/Users/johndoe/.cargo/bin/cargo` (Homebrew), version 1.93.1
- **LLVM:** `/usr/local/Cellar/llvm/22.1.7_1/` (Homebrew)
- **Node.js:** v25.8.0 (NVM)

### Installation Paths Being Used

- **Harness Directory:** `~/Library/Application Support/AI-Tools/harness`
- **MCP Directory:** `~/Library/Application Support/AI-Tools/mcp`
- **Skills Directory:** `~/Library/Application Support/Claude/skills`
- **Config File:** `~/Library/Application Support/Claude/claude_desktop_config.json`

---

## Troubleshooting Specific Issues

### Issue: "mcp module not found" after installation
```bash
# Solution 1: Upgrade pip and retry
python3 -m pip install --upgrade pip setuptools wheel
python3 -m pip install mcp

# Solution 2: Use pre-built wheels (for Rust/LLVM issues)
python3 -m pip install --only-binary :all: --no-deps mcp

# Solution 3: Use MacPorts Python if available
/opt/local/bin/python3 -m pip install mcp

# Solution 4: Check Python path
which python3
python3 --version
```

### Issue: Claude Desktop doesn't recognize Harness
1. Check file exists: `ls ~/.local/share/ai-tools/mcp/harness_claude_advanced_mcp.py`
2. Check config file: `cat ~/.config/Claude/claude_desktop_config.json`
3. Restart Claude Desktop completely
4. Wait 10-15 seconds for MCP servers to initialize
5. Open Settings > Integrations and look for "harness"

### Issue: "Python not found" when MCP server starts
The config file specifies `python3` as the command. Ensure it's in your PATH:
```bash
which python3
python3 --version
```

If it's not found or points to the wrong version, update the config:
```json
{
  "mcpServers": {
    "harness": {
      "command": "/full/path/to/python3",
      "args": ["/path/to/harness_claude_advanced_mcp.py"],
      ...
    }
  }
}
```

---

## Files for This Fix Session

All files are in `/mnt/user-data/outputs/`:

- **install_harness_v3_corrected.sh** - The corrected installation script (USE THIS)
- **harness_claude_advanced_mcp.py** - The v3.0.0 MCP server (33 KB)
- **HARNESS_v3_QUICK_START.md** - Quick start guide
- **INSTALLATION_FIXES.md** - Original troubleshooting doc

---

## Next Steps

1. **Run the corrected installation script:**
   ```bash
   bash install_harness_v3_corrected.sh
   ```

2. **If that doesn't work, try the manual installation** (Solution 3 above)

3. **Verify installation** using the checklist above

4. **Restart Claude Desktop** and check Settings > Integrations

5. **Test with a Harness command:**
   ```
   User: "Design a multi-agent team for content analysis"
   ```

---

## Support

If you encounter issues after trying these solutions:

1. **Check the error output carefully** - the script now provides detailed error messages
2. **Verify all paths exist** - check that directories were created correctly
3. **Check Python environment** - ensure the right Python is being used
4. **Check for Rust/LLVM issues** - if `pip install mcp` fails with cryptography errors, try `brew reinstall rust`

---

## Technical Details of the Fixes

### Fix #1: Correct MCP Filename

**Before (Broken):**
```bash
if [ -f "./harness_mcp_server_v2.py" ]; then
    mcp_source="./harness_mcp_server_v2.py"
```

**After (Fixed):**
```bash
local mcp_filename="harness_claude_advanced_mcp.py"
if [ -f "./$mcp_filename" ]; then
    mcp_source="./$mcp_filename"
```

### Fix #2: Environment Variable Passing

**Before (Broken):**
```bash
python3 << 'EOF'
config_file = os.path.expandvars("$CONFIG_FILE")  # $CONFIG_FILE not exported
EOF
```

**After (Fixed):**
```bash
export CONFIG_FILE="$CONFIG_FILE"  # Export before Python
export MCP_DIR="$MCP_DIR"
export HARNESS_DIR="$HARNESS_DIR"

python3 << 'EOF'
config_file = os.environ.get("CONFIG_FILE")  # Read from os.environ
```

### Fix #3: Rust/LLVM Compatibility

**Before (Broken):**
```bash
python3 -m pip install mcp  # Tries to compile cryptography from source
```

**After (Fixed):**
```bash
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1      # Use system OpenSSL
export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1

python3 -m pip install \
    --only-binary :all: \
    --no-deps \
    mcp  # Uses pre-built wheels, avoids Rust compilation
```

---

**Version:** Harness v3.0.0  
**Created:** 2026-06-30  
**Status:** All three bugs identified and fixed
