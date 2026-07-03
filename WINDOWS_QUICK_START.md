# Windows Harness Installation - Quick Start

## TL;DR - One Command

### PowerShell (Recommended)

```powershell
# Right-click PowerShell, select "Run as Administrator"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install_harness.ps1
```

### Command Prompt

```cmd
# Right-click Command Prompt, select "Run as Administrator"
install_harness.bat
```

**Done.** Everything installed and configured automatically.

---

## Prerequisites (30 seconds each)

### 1. Admin PowerShell/Command Prompt
- Right-click PowerShell or Command Prompt
- Select "Run as Administrator"

### 2. Python 3
```cmd
python --version
```
If missing: https://www.python.org/downloads/ (check "Add Python to PATH")

### 3. Git
```cmd
git --version
```
If missing: https://git-scm.com/download/win

---

## Step-by-Step

### Step 1: Download Scripts

Get both Windows scripts:
- `install_harness.ps1` (PowerShell)
- `install_harness.bat` (Batch alternative)

Save to: `C:\Users\[YourUsername]\Downloads\`

### Step 2: Run Installation

**PowerShell** (Recommended):
```powershell
# Open PowerShell as Administrator
# Navigate to Downloads
cd Downloads

# First time only: Allow script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run installer
.\install_harness.ps1
```

**Command Prompt** (Alternative):
```cmd
# Open Command Prompt as Administrator
# Navigate to Downloads
cd Downloads

# Run installer
install_harness.bat
```

### Step 3: Wait for Completion

Installation shows progress:
```
✓ Repository cloned
✓ Harness SKILL.md verified
✓ Skill installed
✓ MCP server installed
✓ Claude Desktop configured
✓ Integration modules installed

Verification: 4/4 checks passed

[SUCCESS] Installation Complete!
```

### Step 4: Restart Claude Desktop

Close Claude Desktop completely, then reopen it.

### Step 5: Verify

Type in Claude:
```
/mcp
```

Should see:
```
Available MCP servers:
- harness [Connected]
```

### Step 6: Use Harness

```
/design_agent_team
/generate_skill_scaffold
/wix_app_agent_scaffold
/validate_team_architecture
```

Or just:
```
"Design a multi-agent team for product discovery"
"Create a SKILL.md for content analysis"
```

---

## What Gets Installed

| Item | Location | Auto-Configured |
|------|----------|-----------------|
| Harness repo | `%LOCALAPPDATA%\AI-Tools\harness` | ✓ Yes |
| MCP server | `%LOCALAPPDATA%\AI-Tools\mcp\harness_mcp_server.py` | ✓ Yes |
| Harness skill | `%LOCALAPPDATA%\Claude\skills\harness` | ✓ Yes |
| Claude config | `%APPDATA%\Claude\claude_desktop_config.json` | ✓ Yes |

---

## Configuration Created

**File**: `%APPDATA%\Claude\claude_desktop_config.json`

Automatically updated with:
```json
{
  "mcpServers": {
    "harness": {
      "command": "python",
      "args": ["C:\\..\\harness_mcp_server.py"],
      "env": {
        "HARNESS_DIR": "C:\\..\\harness"
      }
    }
  }
}
```

---

## Troubleshooting

### "ExecutionPolicy" Error
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
Type `Y` when prompted.

### "Python is not recognized"
1. Install from https://www.python.org/downloads/
2. **CHECK "Add Python to PATH"**
3. Restart Command Prompt

### "Git is not recognized"
1. Install from https://git-scm.com/download/win
2. Restart Command Prompt

### "Access Denied"
- Make sure running **as Administrator**
- Right-click and select "Run as Administrator"

### MCP Server Not Showing
1. Close Claude Desktop completely (not just minimize)
2. Wait 5 seconds
3. Reopen Claude Desktop
4. Wait 10 more seconds
5. Type `/mcp`

---

## File Locations (Expanded)

```
C:\Users\YourUsername\AppData\Local\AI-Tools\harness\
C:\Users\YourUsername\AppData\Local\AI-Tools\mcp\
C:\Users\YourUsername\AppData\Local\Claude\skills\harness\
C:\Users\YourUsername\AppData\Roaming\Claude\claude_desktop_config.json
```

View in File Explorer:
- Press `Windows + R`
- Type: `%APPDATA%\Claude`
- Press Enter

---

## Next Steps After Installation

### Use Harness in Claude

```
/harness_status                    # Check status
/design_agent_team                 # Design agents
/generate_skill_scaffold           # Create SKILL.md
/wix_app_agent_scaffold            # Design Wix features
/validate_team_architecture        # Verify designs
```

### Natural Language Prompts

```
"Design a multi-agent team for customer feedback analysis"
"Scaffold a Wix product catalog feature with multi-agent architecture"
"Create a SKILL.md for document analysis using agent team design"
```

---

## Common Commands After Installation

### PowerShell

```powershell
# View Harness repo
explorer $env:LOCALAPPDATA\AI-Tools\harness

# View Claude config
Get-Content $env:APPDATA\Claude\claude_desktop_config.json | ConvertFrom-Json

# View Harness skill
explorer $env:LOCALAPPDATA\Claude\skills\harness

# Check Python
python --version

# Check Git
git --version
```

### Command Prompt

```cmd
# View Harness repo
explorer %LOCALAPPDATA%\AI-Tools\harness

# View Claude config
type %APPDATA%\Claude\claude_desktop_config.json

# View Harness skill
explorer %LOCALAPPDATA%\Claude\skills\harness

# Check Python
python --version

# Check Git
git --version
```

---

## Uninstall

**PowerShell**:
```powershell
# Remove files
Remove-Item "$env:LOCALAPPDATA\AI-Tools\harness" -Recurse -Force
Remove-Item "$env:LOCALAPPDATA\Claude\skills\harness" -Recurse -Force

# Remove from config (edit manually or PowerShell)
```

**Command Prompt**:
```cmd
rmdir /s /q "%LOCALAPPDATA%\AI-Tools\harness"
rmdir /s /q "%LOCALAPPDATA%\Claude\skills\harness"
```

---

## Summary

| Step | Action |
|------|--------|
| 1 | Download `install_harness.ps1` or `.bat` |
| 2 | Right-click PowerShell/CMD, select "Run as Administrator" |
| 3 | Run the script |
| 4 | Wait ~2 minutes for completion |
| 5 | Restart Claude Desktop |
| 6 | Type `/mcp` to verify |
| 7 | Use Harness tools |

**Total time**: ~5 minutes  
**Configuration**: Automatic  
**Ready to use**: After restart  

All settings saved. Harness tools ready immediately.
