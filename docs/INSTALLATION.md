# Installation Guide

Single source of truth for installing Harness MCP Server on any platform.

## Prerequisites

- Python 3.9+ ([download](https://www.python.org/downloads/))
- Git ([download](https://git-scm.com/downloads))
- Claude Desktop

## Quick Start

### Option A: One-Command Install (Recommended)

**macOS / Linux:**
```bash
bash install/install_harness_universal.sh
```

**Windows PowerShell (Run as Admin):**
```powershell
.\install\install_harness.ps1
```

**Windows Command Prompt (Run as Admin):**
```cmd
install\install_harness.bat
```

### Option B: Manual Install

```bash
# 1. Clone or copy HARNESS to ~/.local/share/ai-tools/harness
# 2. Install dependencies
pip install mcp pydantic
# 3. Configure Claude Desktop (see Config section below)
```

### Option C: PEP 668 Systems (macOS with externally-managed Python)

If you see `error: externally-managed-environment`:

```bash
# Quick fix (30 seconds)
bash install/QUICK_FIX_INSTALL_NOW.sh

# Or recommended: virtual environment (2 minutes)
bash install/VENV_SETUP_RECOMMENDED.sh
```

## What Gets Installed

| Component | macOS/Linux | Windows |
|-----------|-------------|---------|
| MCP Server | `~/.local/share/ai-tools/mcp/` | `%LOCALAPPDATA%\AI-Tools\mcp\` |
| Harness Data | `~/.local/share/ai-tools/harness/` | `%LOCALAPPDATA%\AI-Tools\harness\` |
| Skills | `~/.claude/skills/harness/` | `%LOCALAPPDATA%\Claude\skills\harness\` |
| Claude Config | `~/.config/claude/claude_desktop_config.json` | `%APPDATA%\Claude\claude_desktop_config.json` |

## Claude Desktop Configuration

Add to your `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "harness": {
      "command": "python",
      "args": ["/path/to/harness_mcp_server.py"],
      "env": {
        "HARNESS_DIR": "/path/to/harness"
      }
    }
  }
}
```

**Config template:** `install/claude_desktop_config.template.json`

## Post-Installation

1. **Restart Claude Desktop** (close and reopen)
2. **Verify:** Type `/mcp` in Claude — you should see `harness [Connected]`
3. **Test:** Type `harness status` or `/harness_status`

## Verify Installation

```bash
bash install/verify_harness_installation.sh
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

## Uninstall

```bash
bash install/HARNESS_UNINSTALL_AND_CLEANUP.sh
```

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## Windows-Specific Notes

See [WINDOWS.md](WINDOWS.md).
