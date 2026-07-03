---
name: harness-installation
description: Install, configure, troubleshoot, and maintain Harness v3.0.0 on macOS. Use whenever the user mentions Harness installation issues, MCP server setup, PEP 668 errors, Claude Desktop configuration, Python environment problems, or needs diagnostics/validation/repair tools for Harness. Also use for uninstalling, migrating between Python versions, or performance validation of the Harness MCP integration.
---

# Harness Installation Skill

Comprehensive installation and maintenance toolkit for **Harness v3.0.0** on macOS, including PEP 668 resolution, MCP server setup, Claude Desktop configuration, environment diagnostics, and performance validation.

## Quick Start

### For First Installation

1. **Check your Python environment:**
   ```bash
   bash SYSTEM_DIAGNOSTICS.sh
   ```

2. **Choose one fix strategy:**
   - **Fastest (30 sec):** `bash QUICK_FIX_INSTALL_NOW.sh`
   - **Recommended (2 min):** `bash VENV_SETUP_RECOMMENDED.sh`

3. **Restart Claude Desktop:**
   ```bash
   killall Claude && open /Applications/Claude.app
   ```

4. **Verify installation:**
   - Settings → Integrations → "harness [Connected]"
   - Test: `@harness help`

---

## Installation Issues — All 4 Bugs Fixed

### Bug #1: MCP Server Filename Mismatch
**Symptom:** `FileNotFoundError: harness_mcp_server_v2.py`
**Fix:** Run `bash VALIDATE_AND_FIX_CLAUDE_CONFIG.sh` — auto-repairs config with correct filename.

### Bug #2: CONFIG_FILE Environment Variable Empty
**Symptom:** MCP server runs but no configuration
**Fix:** Ensure env vars exported in Claude Desktop config. `bash VALIDATE_AND_FIX_CLAUDE_CONFIG.sh` repairs this.

### Bug #3: Rust/LLVM ABI Mismatch
**Symptom:** `SIGABRT` during `pip install` on cryptography
**Fix:** Set `CRYPTOGRAPHY_DONT_BUILD_WHEEL=1` and use `--only-binary :all:`. Scripts handle this automatically.

### Bug #4: PEP 668 Externally-Managed Environment
**Symptom:** `error: externally-managed-environment`

**Three Solutions:**

#### A: Quick Fix (30 sec)
```bash
bash QUICK_FIX_INSTALL_NOW.sh
```
Uses `--break-system-packages --user` to install in user directory.

#### B: Virtual Environment (Recommended, 2 min)
```bash
bash VENV_SETUP_RECOMMENDED.sh
```
Creates isolated `~/harness_venv`, auto-updates Claude config.

#### C: Manual venv
```bash
python3 -m venv ~/harness_venv
source ~/harness_venv/bin/activate
pip install harness-claude-advanced-mcp
```

---

## Claude Desktop Configuration

### Standard Config (Non-venv)
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

**Location:** `~/Library/Application Support/Claude/claude_desktop_config.json`

### venv Config
If using virtual environment:
```json
"command": "/Users/johndoe/harness_venv/bin/python3"
```

---

## Diagnostic & Maintenance Tools

All scripts in current directory:

| Script | Purpose | Time |
|--------|---------|------|
| `SYSTEM_DIAGNOSTICS.sh` | Comprehensive environment audit | 1 min |
| `VALIDATE_AND_FIX_CLAUDE_CONFIG.sh` | Validate & auto-repair config | 30 sec |
| `QUICK_FIX_INSTALL_NOW.sh` | Install with `--break-system-packages` | 30 sec |
| `VENV_SETUP_RECOMMENDED.sh` | Create venv & install | 2 min |
| `MCP_PERFORMANCE_VALIDATOR.sh` | Latency/throughput/reliability test | 2 min |
| `HARNESS_ENVIRONMENT_MIGRATION.sh` | Migrate between Python versions | 5 min |
| `HARNESS_UNINSTALL_AND_CLEANUP.sh` | 7 granular uninstall options | 1 min |
| `verify_harness_installation.sh` | Post-install verification (8 checks) | 1 min |

---

## Common Scenarios

### "Harness not appearing in integrations"
```bash
bash SYSTEM_DIAGNOSTICS.sh
bash VALIDATE_AND_FIX_CLAUDE_CONFIG.sh
killall Claude && open /Applications/Claude.app
```

### "PEP 668 error on install"
Choose one:
```bash
bash QUICK_FIX_INSTALL_NOW.sh          # Fastest
bash VENV_SETUP_RECOMMENDED.sh         # Recommended
```

### "Move from --break-system-packages to venv"
```bash
bash HARNESS_ENVIRONMENT_MIGRATION.sh
# Select "Migrate to virtual environment"
```

### "Performance feels slow"
```bash
bash MCP_PERFORMANCE_VALIDATOR.sh
# Review latency and throughput metrics
```

### "Complete uninstall & reinstall"
```bash
bash HARNESS_UNINSTALL_AND_CLEANUP.sh
# Select "Complete cleanup (all files & venv)"
bash QUICK_FIX_INSTALL_NOW.sh          # Reinstall
```

---

## Installation Defaults

**MCP Server:** `/Users/johndoe/Library/Application Support/AI-Tools/mcp/`
**Harness Home:** `/Users/johndoe/Library/Application Support/AI-Tools/harness/`

---

## Reference Materials

### Advanced Troubleshooting
Read `references/ADVANCED_TROUBLESHOOTING.md` for:
- PEP 668 deep dive
- Rust/LLVM ABI debugging
- Environment variable scoping
- MCP server startup failures
- Virtual environment problems

### Config Template
See `references/claude_desktop_config.template.json`

---

## Post-Installation Verification

```bash
bash verify_harness_installation.sh
```

Checks:
1. Python installation
2. MCP server file exists
3. Claude config valid JSON
4. Harness home directory exists
5. Environment variables set
6. MCP server startup test
7. Claude Desktop can find config
8. Message round-trip test

---

## Support

1. Run `bash SYSTEM_DIAGNOSTICS.sh` for baseline
2. Run `bash VALIDATE_AND_FIX_CLAUDE_CONFIG.sh` for auto-repair
3. Read `references/ADVANCED_TROUBLESHOOTING.md` for deep dive
4. Check logs in the harness data directory

---

**Skill Version:** v1.0.0 — Harness v3.0.0 installation and maintenance
