# Harness Installation Skill v1.0.0

Complete installation and maintenance toolkit for Harness v3.0.0 on macOS.

## Files

- **SKILL.md** — Main skill content (trigger + instructions)
- **scripts/** — Executable tools for installation, diagnostics, repair
- **references/** — Deep-dive documentation

## Installation Tools

1. `QUICK_FIX_INSTALL_NOW.sh` — Fastest PEP 668 fix (30 sec)
2. `VENV_SETUP_RECOMMENDED.sh` — Recommended solution (2 min)
3. `SYSTEM_DIAGNOSTICS.sh` — Environment audit (1 min)
4. `VALIDATE_AND_FIX_CLAUDE_CONFIG.sh` — Config validator & auto-fixer
5. `MCP_PERFORMANCE_VALIDATOR.sh` — Performance testing
6. `HARNESS_ENVIRONMENT_MIGRATION.sh` — Python version migration
7. `HARNESS_UNINSTALL_AND_CLEANUP.sh` — 7 granular uninstall options
8. `verify_harness_installation.sh` — Post-install verification (8 checks)

## Quick Start

```bash
# 1. Check environment
bash scripts/SYSTEM_DIAGNOSTICS.sh

# 2. Install (choose one)
bash scripts/QUICK_FIX_INSTALL_NOW.sh          # Fast
bash scripts/VENV_SETUP_RECOMMENDED.sh         # Recommended

# 3. Restart Claude
killall Claude && open /Applications/Claude.app

# 4. Verify
bash scripts/verify_harness_installation.sh
```

## Reference Materials

- `references/ADVANCED_TROUBLESHOOTING.md` — Deep-dive troubleshooting
- `references/claude_desktop_config.template.json` — Config template

## Skill Version

v1.0.0 — Harness v3.0.0 installation and maintenance toolkit
