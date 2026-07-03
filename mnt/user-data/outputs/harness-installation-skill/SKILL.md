---
name: harness-installation
description: Install, configure, and troubleshoot Harness v3.0.0 MCP server for Claude Desktop. Provides corrected installation scripts, bug fixes for common failures (MCP filename mismatch, environment variable passing, Rust/LLVM toolchain issues), pre-built verification tools, and Claude Desktop configuration guidance. Use this skill whenever user mentions Harness installation, needs to fix install failures, wants to verify MCP server status, or requires Claude Desktop MCP server configuration help. Essential for Principal Engineer workflows requiring advanced MCP integrations.
compatibility: 
  - Claude Desktop (required)
  - macOS (tested on johndoe@Johns-iMac environment)
  - Python 3.10+ (MacPorts or Homebrew)
  - Rust 1.93.1+ (Homebrew)
  - Node.js v25.8.0+ (NVM)
---

# Harness v3.0.0 Installation & Troubleshooting

Professional-grade installation workflow for Harness v3.0.0 MCP server integration with Claude Desktop. This skill provides corrected scripts, root-cause analysis of three critical bugs, workarounds, and verification protocols.

## Quick Reference

**Installation Status**: ✅ Three bugs fixed and validated  
**Corrected Script**: `install_harness_v3_corrected.sh` (13 KB)  
**MCP Server**: `harness_claude_advanced_mcp.py` (33 KB)  
**Config Location**: `~/.config/Claude/claude_desktop_config.json`  
**Verification Tool**: `verify_harness_installation.sh` (8 checks)

---

## Bug Inventory

| Bug | Root Cause | Fix | Impact |
|-----|-----------|-----|--------|
| MCP filename mismatch | Script looked for `harness_mcp_server_v2.py` (v2 filename) instead of `harness_claude_advanced_mcp.py` (v3 filename) | Updated filename in install script | ❌ Installation fails immediately |
| Environment variable not exported | Python subprocess received empty string; `expandvars()` on unexported `$CONFIG_FILE` | Added `export` statements before Python invocation; switched to `os.environ.get()` | ❌ FileNotFoundError during setup |
| Rust/LLVM toolchain mismatch | Homebrew Rust 1.93.1 compiled against different LLVM than 22.1.7; `pip install mcp` triggers cryptography build → SIGABRT | Set `CRYPTOGRAPHY_DONT_BUILD_WHEEL=1` + `CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1`; use `--only-binary :all:` | ⚠️ Pip fails, blocks installation |

---

## Installation Workflow

### Phase 1: Pre-Flight Check

```bash
# Verify Python environment
python3 -c "import sys; print(f'Python {sys.version}')"

# Verify Rust/Cargo
cargo --version

# Check existing Harness installation
ls -la ~/Library/Application\ Support/AI-Tools/mcp/ 2>/dev/null || echo "Fresh install"

# Check Claude Desktop config
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | grep -A 5 "harness" || echo "No harness config found"
```

### Phase 2: Deploy Corrected Script

```bash
# Copy from deliverables
cp /mnt/user-data/outputs/install_harness_v3_corrected.sh ~/Harness/
cp /mnt/user-data/outputs/harness_claude_advanced_mcp.py ~/Harness/

# Inspect (optional but recommended)
head -30 ~/Harness/install_harness_v3_corrected.sh
```

### Phase 3: Run Installation

```bash
cd ~/Harness
bash install_harness_v3_corrected.sh
```

**Expected output**:
```
✓ Checking Python environment
✓ Found Python at /opt/local/bin/python3
✓ Installing pip dependencies
✓ MCP server installed to ~/.../mcp/harness_claude_advanced_mcp.py
✓ Claude Desktop configuration updated
✓ Installation complete. Restart Claude Desktop to activate.
```

### Phase 4: Restart Claude Desktop

```bash
# Force quit
killall Claude

# Reopen from Applications
open /Applications/Claude.app
```

### Phase 5: Verify Connection

1. **In Claude**: Settings → Integrations → scroll to "harness" → should show **[Connected]**
2. **Run verification** (optional):
```bash
bash ~/Harness/verify_harness_installation.sh
```

Expected checks (8 total):
- ✓ MCP server file exists
- ✓ Python executable found
- ✓ Config file created
- ✓ Harness directory writable
- ✓ MCP entry in Claude Desktop config
- ✓ Config syntax valid (JSON)
- ✓ Deployment directories accessible
- ✓ MCP server imports successfully

---

## Troubleshooting by Error

### Error: "harness_mcp_server_v2.py not found"

**Root Cause**: Using old `install_harness_universal.sh` script (v2 naming convention).

**Fix**:
```bash
# Use corrected script
bash install_harness_v3_corrected.sh
```

### Error: "FileNotFoundError: [Errno 2] No such file or directory: ''"

**Root Cause**: Environment variable `$CONFIG_FILE` not exported to Python subprocess.

**Manual Fix** (if needed):
```bash
export CONFIG_FILE="$HOME/Library/Application Support/AI-Tools/harness/config.json"
export MCP_DIR="$HOME/Library/Application Support/AI-Tools/mcp"
export HARNESS_DIR="$HOME/Library/Application Support/AI-Tools/harness"

python3 harness_claude_advanced_mcp.py
```

### Error: "rustc -vV (signal: 6, SIGABRT)"

**Root Cause**: Homebrew Rust 1.93.1 ABI incompatible with system LLVM 22.1.7. Triggered by `pip install mcp` attempting to build cryptography from source.

**Fix Option A** (Recommended — permanent):
```bash
brew reinstall rust
python3 -m pip install mcp
```

**Fix Option B** (Temporary — use pre-built wheels):
```bash
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1

python3 -m pip install --only-binary :all: --no-deps mcp
# If above fails, install missing dependencies:
python3 -m pip install anyio httpx pydantic pydantic-settings starlette uvicorn sse-starlette httpx-sse jsonschema python-multipart
```

**Fix Option C** (Skip cryptography):
```bash
python3 -m pip install --no-deps mcp
python3 -m pip install anyio httpx pydantic pydantic-settings starlette uvicorn sse-starlette httpx-sse jsonschema python-multipart
```

### Error: "harness [Disconnected]" in Claude Settings

**Checklist**:
1. Claude Desktop closed fully? → `killall Claude` then reopen
2. Config file syntax valid? → `python3 -m json.tool ~/Library/Application\ Support/Claude/claude_desktop_config.json`
3. MCP server file exists? → `ls -la ~/.../mcp/harness_claude_advanced_mcp.py`
4. Python path correct in config? → should match output of `which python3`
5. MCP server imports OK? → `python3 -c "import mcp; print(mcp.__version__)"`

---

## Configuration Reference

### Claude Desktop Config Location
```
~/Library/Application Support/Claude/claude_desktop_config.json
```

### Correct Config Structure
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

### Directory Structure After Install
```
~/.../AI-Tools/
├── mcp/
│   └── harness_claude_advanced_mcp.py    (v3.0.0 server)
├── harness/
│   ├── config.json                       (auto-generated)
│   ├── logs/                             (runtime logs)
│   └── state/                            (persistent data)
```

---

## Verification Commands

```bash
# 1. Check file installation
ls -la ~/.../AI-Tools/mcp/harness_claude_advanced_mcp.py

# 2. Validate Python executable
which python3
python3 -c "import sys; print(sys.executable)"

# 3. Test MCP server import
python3 -c "import mcp; print('✓ MCP imports OK')"

# 4. Check config syntax
python3 -m json.tool ~/.../claude_desktop_config.json

# 5. Verify environment setup
echo $HARNESS_DIR
echo $HARNESS_LOG_LEVEL

# 6. Test connectivity from Claude chat
# Try: @harness help
# Expected: MCP returns Harness command help
```

---

## System Environment (Reference Data)

**Tested Environment**:
- **User**: johndoe@Johns-iMac
- **Python**: `/opt/local/bin/python3` (MacPorts 3.14.6)
- **Rust**: `/Users/johndoe/.cargo/bin/cargo` (Homebrew 1.93.1)
- **LLVM**: `/usr/local/Cellar/llvm/22.1.7_1/lib/libLLVM.dylib`
- **Node.js**: v25.8.0 (NVM)
- **macOS**: (Intel/Apple Silicon compatible)

---

## Deliverable Files Reference

| File | Purpose | Size |
|------|---------|------|
| `install_harness_v3_corrected.sh` | Primary install script (all bugs fixed) | 13 KB |
| `harness_claude_advanced_mcp.py` | v3.0.0 MCP server | 33 KB |
| `verify_harness_installation.sh` | Post-install verification (8 checks) | 9.7 KB |
| `HARNESS_v3_QUICK_FIX_COMMANDS.sh` | Copy-paste command reference | 5.3 KB |

All files in: `/mnt/user-data/outputs/`

---

## Next Steps

1. **Run installation** → `bash install_harness_v3_corrected.sh`
2. **Restart Claude Desktop** → Full quit + reopen
3. **Verify connection** → Settings → Integrations → "harness [Connected]"
4. **Test in chat** → Use `@harness` in Claude messages
5. **Monitor logs** → `tail -f ~/.../harness/logs/harness.log`

---

## See Also

- `INSTALLATION_FIXES_SUMMARY.md` — Before/after code comparison for all three bugs
- `HARNESS_v3_INSTALLATION_FIX_GUIDE.md` — Extended troubleshooting guide
- **Previous Transcripts**: `/mnt/transcripts/` (see `journal.txt` for history)
