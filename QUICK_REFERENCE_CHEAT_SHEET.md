#!/usr/bin/env markdown
# HARNESS v3.0.0 QUICK REFERENCE CHEAT SHEET

**Quickest reference for common operations**  
Print this or keep it bookmarked!

---

## ⚡ INSTALLATION (Choose One)

### Option A: Fastest (30 seconds)
```bash
bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh
```

### Option B: Cleanest (2 minutes, recommended)
```bash
bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh
```

---

## 🚀 POST-INSTALLATION

```bash
# Restart Claude Desktop
killall Claude && open /Applications/Claude.app

# Verify connection
# Settings → Integrations → Harness [Connected] ✅

# Test MCP command
@harness help

# Validate performance
bash /mnt/user-data/outputs/MCP_PERFORMANCE_VALIDATOR.sh
```

---

## 🔍 TROUBLESHOOTING

| Issue | Solution |
|-------|----------|
| **Harness offline** | `bash VALIDATE_AND_FIX_CLAUDE_CONFIG.sh` |
| **Config error** | `bash VALIDATE_AND_FIX_CLAUDE_CONFIG.sh` |
| **Slow response** | `bash MCP_PERFORMANCE_VALIDATOR.sh` |
| **PEP 668 error** | Run `QUICK_FIX_INSTALL_NOW.sh` or `VENV_SETUP_RECOMMENDED.sh` |
| **Python not found** | `bash SYSTEM_DIAGNOSTICS.sh` then use `HARNESS_ENVIRONMENT_MIGRATION.sh` |
| **Dependency missing** | `bash QUICK_FIX_INSTALL_NOW.sh` |

---

## 🔄 COMMON OPERATIONS

### Diagnose System
```bash
bash /mnt/user-data/outputs/SYSTEM_DIAGNOSTICS.sh
```
**Output:** Comprehensive environment report → `/tmp/harness_diagnostics_*.log`

### Validate Configuration
```bash
bash /mnt/user-data/outputs/VALIDATE_AND_FIX_CLAUDE_CONFIG.sh
```
**Action:** Interactive config repair with Python selection

### Switch Python Version
```bash
bash /mnt/user-data/outputs/HARNESS_ENVIRONMENT_MIGRATION.sh
```
**Supports:** System Python → Homebrew → Virtualenv → PyEnv

### Uninstall / Reset
```bash
bash /mnt/user-data/outputs/HARNESS_UNINSTALL_AND_CLEANUP.sh
```
**Options:** Full removal, partial removal, config reset, backup only

### Verify Installation
```bash
bash /mnt/user-data/outputs/verify_harness_installation.sh
```
**Checks:** 8-point post-install verification suite

---

## 📍 KEY DIRECTORIES

```bash
# MCP Server
~/Library/Application Support/AI-Tools/mcp/
# File: harness_claude_advanced_mcp.py

# Configuration
~/Library/Application Support/AI-Tools/harness/

# Claude Desktop Config
~/Library/Application Support/Claude/claude_desktop_config.json

# Virtualenv (if using VENV setup)
~/harness_venv/
```

---

## 🔧 CLAUDE DESKTOP CONFIG (if manual edit needed)

```json
{
  "mcpServers": {
    "harness": {
      "command": "python3",
      "args": ["/Users/YOUR_USERNAME/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"],
      "env": {
        "HARNESS_DIR": "/Users/YOUR_USERNAME/Library/Application Support/AI-Tools/harness",
        "HARNESS_LOG_LEVEL": "INFO"
      }
    }
  }
}
```

**If using virtualenv:**
```json
"command": "/Users/YOUR_USERNAME/harness_venv/bin/python3"
```

---

## 🔐 ENVIRONMENT VARIABLES

```bash
# Set log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
export HARNESS_LOG_LEVEL="DEBUG"

# Override config directory
export HARNESS_DIR="/custom/harness/path"

# Activate virtualenv (if using VENV setup)
source ~/harness_venv/bin/activate
```

---

## ✅ VERIFICATION CHECKLIST

- [ ] Run installation script (QUICK_FIX or VENV)
- [ ] Restart Claude Desktop (`killall Claude && open /Applications/Claude.app`)
- [ ] Verify connection: Settings → Integrations → Harness [Connected]
- [ ] Test command: `@harness help`
- [ ] Run validator: `bash MCP_PERFORMANCE_VALIDATOR.sh`
- [ ] Save diagnostics: `bash SYSTEM_DIAGNOSTICS.sh`

---

## 🆘 EMERGENCY RECOVERY

### Reset Everything
```bash
# Option 1: Clean reinstall with virtualenv
bash ~/Desktop/HARNESS_UNINSTALL_AND_CLEANUP.sh  # Full uninstall
bash VENV_SETUP_RECOMMENDED.sh                   # Fresh install

# Option 2: Restore from backup
cp /tmp/harness_migration_backup_*/claude_desktop_config.json \
   ~/Library/Application\ Support/Claude/
```

### Restore Backup
```bash
# Find backup
ls /tmp/harness_*_backup_*/
ls ~/Desktop/"Harness Backups"/

# Restore config
cp /tmp/harness_*/claude_desktop_config.json \
   ~/Library/Application\ Support/Claude/

# Restore directories
cp -r /tmp/harness_*/mcp \
      ~/Library/Application\ Support/AI-Tools/

cp -r /tmp/harness_*/config \
      ~/Library/Application\ Support/AI-Tools/
```

---

## 📊 PERFORMANCE TARGETS

| Metric | Expected | Warning |
|--------|----------|---------|
| MCP startup | <2s | >5s |
| Command latency | <100ms | >500ms |
| Memory usage | <50MB | >200MB |
| CPU (idle) | <1% | >10% |

---

## 🐍 PYTHON MANAGEMENT

### Check Current Python
```bash
which python3
python3 --version
```

### Check All Pythons
```bash
bash /mnt/user-data/outputs/SYSTEM_DIAGNOSTICS.sh | grep -A 20 "PYTHON"
```

### Switch to Virtualenv
```bash
source ~/harness_venv/bin/activate
python3 --version
deactivate  # to exit virtualenv
```

### Check PEP 668 Status
```bash
python3 -m pip install --dry-run fake-package 2>&1 | grep "externally-managed"
```

---

## 🎯 QUICK FIXES

```bash
# Harness offline? Try:
killall Claude && open /Applications/Claude.app && sleep 3

# Config wrong? Fix it:
bash VALIDATE_AND_FIX_CLAUDE_CONFIG.sh

# Slow? Test it:
bash MCP_PERFORMANCE_VALIDATOR.sh

# Don't know what's wrong? Diagnose:
bash SYSTEM_DIAGNOSTICS.sh
```

---

## 📱 FILE LOCATIONS (Reference)

```
/mnt/user-data/outputs/
├─ Installers
│  ├─ QUICK_FIX_INSTALL_NOW.sh
│  └─ VENV_SETUP_RECOMMENDED.sh
│
├─ Tools
│  ├─ SYSTEM_DIAGNOSTICS.sh
│  ├─ VALIDATE_AND_FIX_CLAUDE_CONFIG.sh
│  ├─ MCP_PERFORMANCE_VALIDATOR.sh
│  ├─ HARNESS_ENVIRONMENT_MIGRATION.sh
│  ├─ HARNESS_UNINSTALL_AND_CLEANUP.sh
│  └─ verify_harness_installation.sh
│
└─ Documentation
   ├─ COMPREHENSIVE_TOOLING_REFERENCE.md (this file)
   ├─ FIX_PEP668_*.md
   ├─ TROUBLESHOOTING_AND_*.md
   └─ [etc.]
```

---

## 💾 COMMANDS TO SAVE

```bash
# Alias for quick restart
alias restart-claude='killall Claude && open /Applications/Claude.app'

# Alias for diagnostics
alias diagnose-harness='bash /mnt/user-data/outputs/SYSTEM_DIAGNOSTICS.sh'

# Alias for validation
alias validate-harness='bash /mnt/user-data/outputs/VALIDATE_AND_FIX_CLAUDE_CONFIG.sh'

# Alias for performance check
alias test-harness='bash /mnt/user-data/outputs/MCP_PERFORMANCE_VALIDATOR.sh'
```

Add to `~/.zshrc` or `~/.bash_profile`:
```bash
# Harness shortcuts
source ~/.harness_aliases
```

---

## 📚 FULL DOCUMENTATION

For complete reference, see:
```bash
cat /mnt/user-data/outputs/COMPREHENSIVE_TOOLING_REFERENCE.md
```

---

**Version:** 1.0.0  
**Updated:** 2026-07-01  
**Quick Print:** Format: Fit to 1-2 pages for printing
