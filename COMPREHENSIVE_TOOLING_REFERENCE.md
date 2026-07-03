#!/usr/bin/env markdown
# HARNESS v3.0.0 INSTALLATION TOOLING REFERENCE

Complete guide to the Harness v3.0.0 installation toolkit covering diagnosis, installation, validation, maintenance, and troubleshooting.

---

## 📊 Tooling Ecosystem Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                   HARNESS v3.0.0 INSTALLATION                   │
│                      TOOLING ECOSYSTEM                          │
└─────────────────────────────────────────────────────────────────┘

DIAGNOSIS & PLANNING
└── SYSTEM_DIAGNOSTICS.sh
    ├─ Detects Python, Rust, LLVM, Node.js versions
    ├─ Checks for PEP 668 externally-managed-environment
    ├─ Tests Xcode, build tools, virtualenv availability
    ├─ Reports MCP installation status
    └─ Generates detailed log file

INSTALLATION
├── QUICK_FIX_INSTALL_NOW.sh (⭐ Recommended - 30 sec)
│   ├─ Installs pip dependencies (anthropic, pydantic, aiohttp)
│   ├─ Creates MCP directories
│   ├─ Configures Claude Desktop
│   ├─ Handles PEP 668 with --break-system-packages --user
│   └─ Validates installation
│
├── VENV_SETUP_RECOMMENDED.sh (⭐ Cleanest - 2 min)
│   ├─ Creates isolated virtualenv (~/harness_venv)
│   ├─ Installs dependencies in venv (no PEP 668 issues)
│   ├─ Configures Claude Desktop to use venv Python
│   ├─ Provides rollback instructions
│   └─ Most reproducible/maintainable approach
│
└── install_harness_v3_PEP668_AWARE.sh (Smart installer)
    ├─ Auto-detects PEP 668 status
    ├─ Chooses virtualenv if needed
    ├─ Falls back to --break-system-packages
    └─ Comprehensive error handling

CONFIGURATION & VALIDATION
├── VALIDATE_AND_FIX_CLAUDE_CONFIG.sh
│   ├─ Validates JSON syntax
│   ├─ Detects missing Harness configuration
│   ├─ Auto-selects Python (system/venv/Homebrew)
│   ├─ Repairs misconfigured configs
│   └─ Interactive fix workflow
│
├── MCP_PERFORMANCE_VALIDATOR.sh
│   ├─ Starts MCP server in background
│   ├─ Tests connectivity, latency, throughput
│   ├─ Validates configuration files
│   ├─ Checks error handling
│   ├─ Reports resource usage
│   └─ Performance benchmarking
│
└── verify_harness_installation.sh
    ├─ 8-point post-installation verification
    ├─ Checks all dependencies
    ├─ Tests Claude Desktop integration
    └─ Validates MCP connectivity

MAINTENANCE & MIGRATION
├── HARNESS_ENVIRONMENT_MIGRATION.sh
│   ├─ Discover all Python installations
│   ├─ Migrate between system/Homebrew/virtualenv
│   ├─ Tests compatibility
│   ├─ Safe backup & rollback
│   └─ Claude config auto-update
│
└── HARNESS_UNINSTALL_AND_CLEANUP.sh
    ├─ Full uninstall (all files, config, venv)
    ├─ Partial removal (MCP/config/venv only)
    ├─ Configuration reset
    ├─ Backup to Desktop/Harness Backups/
    ├─ Archive generation (tar.gz)
    └─ Restore capability

SYSTEM DIAGNOSIS
└── SYSTEM_DIAGNOSTICS.sh
    └─ Comprehensive environment audit
```

---

## 🚀 INSTALLATION WORKFLOWS

### Workflow A: Quick Installation (Recommended for most users)

**Time: ~30 seconds | Approach: System Python + PEP 668 workaround**

```bash
# 1. Run installer
bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh

# 2. Restart Claude Desktop
killall Claude && open /Applications/Claude.app

# 3. Verify
# Settings → Integrations → Harness [Connected] ✅
# Type: @harness help

# 4. Optional: Run validator
bash /mnt/user-data/outputs/MCP_PERFORMANCE_VALIDATOR.sh
```

**Advantages:**
- Fastest approach
- Works with system Python
- PEP 668 handled automatically
- No additional environments

**Limitations:**
- System-level install (pip isolation workaround)
- Affects all system Python packages

---

### Workflow B: Virtualenv Installation (Recommended for developers)

**Time: ~2 minutes | Approach: Isolated Python environment**

```bash
# 1. Run virtualenv setup
bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh

# 2. Restart Claude Desktop
killall Claude && open /Applications/Claude.app

# 3. Verify
# Settings → Integrations → Harness [Connected] ✅
# Type: @harness help

# 4. Optional: Run validator
bash /mnt/user-data/outputs/MCP_PERFORMANCE_VALIDATOR.sh
```

**Advantages:**
- PEP 668 completely avoided
- Isolated environment (no conflicts)
- Reproducible (venv can be recreated)
- Clean uninstall (rm -rf ~/harness_venv)
- Best for development

**Limitations:**
- Takes slightly longer to set up
- Requires venv module (Python 3.3+)

---

### Workflow C: Diagnostic-First Installation

**Time: ~3 minutes | Approach: Diagnose, then install**

```bash
# 1. Run full system diagnostics
bash /mnt/user-data/outputs/SYSTEM_DIAGNOSTICS.sh

# Review output for issues:
# - Python version & path
# - PEP 668 status
# - MCP dependencies
# - Virtualenv availability

# 2. Choose installation approach based on diagnostics:
# If PEP 668 ACTIVE:
#   → Use VENV_SETUP_RECOMMENDED.sh (recommended)
#   OR QUICK_FIX_INSTALL_NOW.sh (faster but system-wide)
#
# If PEP 668 NOT active:
#   → Use QUICK_FIX_INSTALL_NOW.sh

bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh
# OR
bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh

# 3. Validate configuration
bash /mnt/user-data/outputs/VALIDATE_AND_FIX_CLAUDE_CONFIG.sh

# 4. Restart Claude Desktop
killall Claude && open /Applications/Claude.app
```

**Advantages:**
- Understands your environment
- Identifies and prevents issues
- Provides root cause analysis
- Generates detailed logs

**Use when:**
- First installation
- Environment is complex/mixed
- Issues occurred in past
- Need to understand system state

---

## 🔧 CONFIGURATION & TROUBLESHOOTING

### Configuration Validation

```bash
# Validate Claude Desktop configuration
bash /mnt/user-data/outputs/VALIDATE_AND_FIX_CLAUDE_CONFIG.sh

# This script will:
# ✅ Validate JSON syntax
# ✅ Detect if Harness is configured
# ✅ Find available Python versions
# ✅ Prompt for selection
# ✅ Test Python and dependencies
# ✅ Update config automatically
# ✅ Verify changes
```

**When to use:**
- After installation (verification)
- MCP not detected by Claude
- Settings show "harness [Offline]"
- Changing Python version
- Config file corrupted

### Performance Validation

```bash
# Validate MCP server performance
bash /mnt/user-data/outputs/MCP_PERFORMANCE_VALIDATOR.sh

# This script will:
# ✅ Start MCP server
# ✅ Test connectivity
# ✅ Measure latency
# ✅ Validate configuration
# ✅ Test error handling
# ✅ Report resource usage
```

**When to use:**
- Verify MCP is responsive
- Measure latency/throughput
- Debug communication issues
- Performance monitoring
- After Claude Desktop restart

---

## 🔄 MAINTENANCE & MIGRATION

### Migrate to Different Python

```bash
# Interactive migration between Python versions
bash /mnt/user-data/outputs/HARNESS_ENVIRONMENT_MIGRATION.sh

# This script will:
# 1. Detect current Python
# 2. Discover all Python installations
#    - System Python
#    - Homebrew Python
#    - MacPorts Python
#    - Virtualenv
#    - PyEnv versions
# 3. Let you select target
# 4. Verify compatibility
# 5. Install dependencies
# 6. Update Claude config
# 7. Create backup/rollback
```

**Use cases:**
- Switch from system → Homebrew Python
- Switch from system → virtualenv
- Add new Python version
- Update Python path in config

### Uninstall or Reset

```bash
# Interactive uninstall/cleanup tool
bash /mnt/user-data/outputs/HARNESS_UNINSTALL_AND_CLEANUP.sh

# Options:
# 1. Full uninstall (all files + config + venv)
# 2. MCP server only
# 3. Config only
# 4. Virtualenv only
# 5. Reset config (keep MCP & venv)
# 6. Backup only (no deletion)
# 7. Cancel

# Features:
# ✅ Automatic backup to /tmp/
# ✅ Archive to ~/Desktop/Harness Backups/
# ✅ Preservation of config files
# ✅ Safe rollback capability
# ✅ Detailed confirmation prompts
```

**Use cases:**
- Clean reinstallation
- Remove specific components
- Troubleshoot by reset
- Migrate to clean slate
- Full cleanup before uninstall

---

## 📋 TROUBLESHOOTING DECISION TREE

```
┌─ Is Harness showing in Claude Settings?
│
├─ NO
│  └─ Run: VALIDATE_AND_FIX_CLAUDE_CONFIG.sh
│     → Checks config, repairs if needed
│     → If still offline after restart:
│         └─ Run: SYSTEM_DIAGNOSTICS.sh
│            → Identify specific issue
│            → Run appropriate fix script
│
├─ YES (Connected) ✅
│  └─ Test with: @harness help
│     │
│     ├─ Response received ✅
│     │  └─ Run: MCP_PERFORMANCE_VALIDATOR.sh
│     │     → Measure latency
│     │     → Validate throughput
│     │
│     └─ No response / timeout
│        └─ Run: MCP_PERFORMANCE_VALIDATOR.sh
│           → Server connectivity test
│           → Check error handling
│           │
│           ├─ If server won't start
│           │  └─ Run: SYSTEM_DIAGNOSTICS.sh
│           │     → Check Python path
│           │     → Check dependencies
│           │
│           └─ If Python/dependencies issue
│              └─ Run: HARNESS_ENVIRONMENT_MIGRATION.sh
│                 OR QUICK_FIX_INSTALL_NOW.sh
│                 → Reinstall dependencies
```

---

## 🛠️ SCRIPT REFERENCE MATRIX

| Script | Purpose | Time | Complexity | User Input |
|--------|---------|------|-----------|-----------|
| **QUICK_FIX_INSTALL_NOW.sh** | Fast install | 30s | Low | None |
| **VENV_SETUP_RECOMMENDED.sh** | Clean install | 2m | Low | None |
| **install_harness_v3_PEP668_AWARE.sh** | Smart install | 1m | Medium | None |
| **SYSTEM_DIAGNOSTICS.sh** | Environment audit | 1m | Low | None |
| **VALIDATE_AND_FIX_CLAUDE_CONFIG.sh** | Config repair | 1m | Medium | Yes (Python selection) |
| **MCP_PERFORMANCE_VALIDATOR.sh** | Performance test | 2m | Low | None |
| **HARNESS_ENVIRONMENT_MIGRATION.sh** | Python migration | 3m | High | Yes (Python selection, confirm) |
| **HARNESS_UNINSTALL_AND_CLEANUP.sh** | Remove/reset | 2m | Medium | Yes (scope, confirm) |
| **verify_harness_installation.sh** | Post-install check | 1m | Low | None |

---

## 📁 FILE ORGANIZATION

```
/mnt/user-data/outputs/
├─ QUICK_FIX_INSTALL_NOW.sh ⭐ Start here (30 sec)
├─ VENV_SETUP_RECOMMENDED.sh ⭐ Or here (2 min)
│
├─ SYSTEM_DIAGNOSTICS.sh (diagnose issues)
├─ VALIDATE_AND_FIX_CLAUDE_CONFIG.sh (repair config)
├─ MCP_PERFORMANCE_VALIDATOR.sh (test performance)
│
├─ HARNESS_ENVIRONMENT_MIGRATION.sh (switch Python)
├─ HARNESS_UNINSTALL_AND_CLEANUP.sh (remove/reset)
│
├─ verify_harness_installation.sh (post-install verification)
├─ install_harness_v3_corrected.sh (primary installer, bugs 1-3)
├─ install_harness_v3_PEP668_AWARE.sh (smart installer)
│
└─ [Documentation files]
   ├─ HARNESS_v3_INSTALLATION_FIX_GUIDE.md
   ├─ FIX_PEP668_EXTERNALLY_MANAGED_ENVIRONMENT.md
   ├─ TROUBLESHOOTING_AND_QUICK_REFERENCE.md
   ├─ FINAL_DELIVERY_SUMMARY.md
   └─ [etc.]
```

---

## 🔐 ENVIRONMENT VARIABLES

### Used by Harness MCP

```bash
HARNESS_DIR
# Default: ~/Library/Application Support/AI-Tools/harness
# Purpose: Configuration directory
# Set by: Installation scripts

HARNESS_LOG_LEVEL
# Default: INFO
# Options: DEBUG, INFO, WARNING, ERROR, CRITICAL
# Purpose: Logging verbosity
# Set by: Installation scripts
```

### User Configuration

```bash
# Override default directories
export HARNESS_DIR="/custom/path/to/config"

# Change log level
export HARNESS_LOG_LEVEL="DEBUG"

# For virtualenv installations
source ~/harness_venv/bin/activate
```

---

## 📞 SUPPORT & NEXT STEPS

### If Installation Succeeds ✅

```bash
# 1. Verify MCP is connected
# Settings → Integrations → Harness [Connected]

# 2. Test basic command
@harness help

# 3. Optional: Run performance validator
bash MCP_PERFORMANCE_VALIDATOR.sh

# 4. Check documentation
# bash SYSTEM_DIAGNOSTICS.sh  # generates detailed log
cat /tmp/harness_diagnostics_*.log
```

### If Installation Fails ❌

```bash
# 1. Gather diagnostics
bash SYSTEM_DIAGNOSTICS.sh

# 2. Review output for issues:
#    - Python version
#    - PEP 668 status
#    - Dependency versions
#    - Configuration

# 3. Based on findings:
#    - PEP 668 active → VENV_SETUP_RECOMMENDED.sh
#    - Missing deps → QUICK_FIX_INSTALL_NOW.sh
#    - Config error → VALIDATE_AND_FIX_CLAUDE_CONFIG.sh

# 4. If still failing:
#    - Uninstall: HARNESS_UNINSTALL_AND_CLEANUP.sh
#    - Clean reinstall: VENV_SETUP_RECOMMENDED.sh
#    - Save diagnostics: cp /tmp/harness_diagnostics_*.log Desktop/
```

---

## 🎯 RECOMMENDED INSTALLATION PATH

**For 99% of users:**

```bash
# Step 1: Diagnose (optional but recommended)
bash /mnt/user-data/outputs/SYSTEM_DIAGNOSTICS.sh

# Step 2: Install (choose one)
# Option A: Fastest (30 sec)
bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh

# Option B: Cleanest (2 min, recommended)
bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh

# Step 3: Restart Claude Desktop
killall Claude && open /Applications/Claude.app

# Step 4: Verify
# Settings → Integrations → Harness [Connected] ✅
# Type: @harness help

# Step 5: Optional validation
bash /mnt/user-data/outputs/MCP_PERFORMANCE_VALIDATOR.sh
```

---

**Document Version:** 1.0.0  
**Last Updated:** 2026-07-01  
**Harness Version:** v3.0.0  
**macOS Requirement:** 10.15+  
**Python Requirement:** 3.8+
