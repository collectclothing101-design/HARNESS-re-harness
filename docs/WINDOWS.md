# Windows Installation

## Prerequisites

- Python 3.9+ — check: `python --version`
- Git — check: `git --version`
- PowerShell or Command Prompt (Run as Administrator)

## Install

### PowerShell (Recommended)

```powershell
# Right-click PowerShell > Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install\install_harness.ps1
```

### Command Prompt

```cmd
# Right-click Command Prompt > Run as Administrator
install\install_harness.bat
```

## What Gets Installed

| Item | Location |
|------|----------|
| Harness core | `%LOCALAPPDATA%\AI-Tools\harness\` |
| MCP server | `%LOCALAPPDATA%\AI-Tools\mcp\harness_mcp_server.py` |
| Skills | `%LOCALAPPDATA%\Claude\skills\harness\` |
| Claude config | `%APPDATA%\Claude\claude_desktop_config.json` |

## Verify

1. Close and reopen Claude Desktop
2. Type `/mcp`
3. Confirm `harness [Connected]` appears

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "ExecutionPolicy" error | `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| "Python is not recognized" | Install from python.org, check "Add Python to PATH" |
| "Git is not recognized" | Install from git-scm.com, restart terminal |
| "Access Denied" | Run as Administrator |
| MCP not showing | Close Claude completely, wait 5 seconds, reopen |

## Uninstall

```powershell
Remove-Item "$env:LOCALAPPDATA\AI-Tools\harness" -Recurse -Force
Remove-Item "$env:LOCALAPPDATA\Claude\skills\harness" -Recurse -Force
```

Then remove the `harness` entry from `%APPDATA%\Claude\claude_desktop_config.json`.
