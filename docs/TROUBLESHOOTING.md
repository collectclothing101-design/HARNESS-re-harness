# Troubleshooting

Complete reference for diagnosing and fixing Harness installation and runtime issues.

## Error: `externally-managed-environment` (PEP 668)

**Cause:** macOS/Linux system Python prevents `pip install` to protect system packages.

**Three solutions:**

### 1. Quick Fix (30 seconds)
```bash
bash install/QUICK_FIX_INSTALL_NOW.sh
```
Uses `--break-system-packages --user` to install in user directory.

### 2. Virtual Environment (Recommended, 2 minutes)
```bash
bash install/VENV_SETUP_RECOMMENDED.sh
```
Creates isolated `~/harness_venv`. Update Claude config to use venv Python path.

### 3. Manual venv
```bash
python3 -m venv ~/harness_venv
source ~/harness_venv/bin/activate
pip install mcp pydantic
```

## Error: `FileNotFoundError: harness_mcp_server_v2.py`

**Cause:** Claude config points to wrong filename.

**Fix:** Run `bash install/VALIDATE_AND_FIX_CLAUDE_CONFIG.sh` or manually update config to point to the correct server file.

## Error: `ModuleNotFoundError: No module named 'mcp'`

**Cause:** MCP package not installed in the Python Claude Desktop uses.

```bash
# Find which Python Claude uses
python --version

# Install mcp in that Python
pip install mcp pydantic

# Or for PEP 668 systems
pip install --break-system-packages --user mcp pydantic
```

## Error: `SIGABRT` during `pip install` (Rust/LLVM ABI mismatch)

**Cause:** Cryptography package requires Rust build tools.

```bash
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
pip install --only-binary :all: mcp pydantic
```

## Harness Not Showing in Claude Desktop

1. Check config file exists and has `harness` entry:
   ```bash
   cat ~/Library/Application\ Support/Claude/claude_desktop_config.json  # macOS
   cat ~/.config/claude/claude_desktop_config.json                       # Linux
   ```
2. Verify paths are correct (no `~` — use full paths)
3. Restart Claude Desktop completely
4. Wait 10 seconds, then type `/mcp`

## MCP Server Won't Start

```bash
# Test server directly
python /path/to/harness_mcp_server.py

# Check Python version
python --version  # Need 3.9+

# Verify dependencies
python -c "import mcp; import pydantic; print('OK')"
```

## Environment Variable Issues

The `HARNESS_DIR` env var must be set in Claude config, not in your shell. Check:

```json
{
  "mcpServers": {
    "harness": {
      "command": "python",
      "args": ["/full/path/to/harness_mcp_server.py"],
      "env": {
        "HARNESS_DIR": "/full/path/to/harness"
      }
    }
  }
}
```

## Complete Reset

```bash
# Remove all Harness files
bash install/HARNESS_UNINSTALL_AND_CLEANUP.sh

# Reinstall
bash install/install_harness_universal.sh
```

## Diagnostic Commands

```bash
bash install/SYSTEM_DIAGNOSTICS.sh           # Full environment audit
bash install/VALIDATE_AND_FIX_CLAUDE_CONFIG.sh  # Auto-repair config
bash install/MCP_PERFORMANCE_VALIDATOR.sh    # Test latency/throughput
bash install/verify_harness_installation.sh  # Post-install checks
```
