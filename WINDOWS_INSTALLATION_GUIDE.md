# Harness MCP Server - Windows Installation Guide

## Quick Start

### Option 1: PowerShell (Recommended)

```powershell
# Right-click PowerShell, select "Run as Administrator", then:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install_harness.ps1
```

### Option 2: Batch Script

```cmd
# Right-click Command Prompt, select "Run as Administrator", then:
install_harness.bat
```

**Time**: ~2 minutes  
**Result**: Everything installed and configured automatically

---

## Prerequisites

### 1. Administrator Access
- Right-click PowerShell or Command Prompt
- Select "Run as Administrator"

### 2. Python 3 Installed
```cmd
python --version
```

If not installed: https://www.python.org/downloads/

**Important**: During Python installation, check "Add Python to PATH"

### 3. Git Installed
```cmd
git --version
```

If not installed: https://git-scm.com/download/win

---

## Installation Methods

### Method 1: PowerShell Script (Recommended)

**File**: `install_harness.ps1`

**Steps**:

1. **Download Script**
   - Save `install_harness.ps1` to your Downloads folder

2. **Open PowerShell as Administrator**
   - Right-click PowerShell
   - Select "Run as Administrator"

3. **Enable Script Execution** (First time only)
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
   - Type `Y` when prompted

4. **Run Script**
   ```powershell
   # Navigate to Downloads
   cd Downloads
   
   # Run installation
   .\install_harness.ps1
   ```

5. **Wait for Completion**
   - Script shows progress for each step
   - Shows ✓ for successful checks
   - Shows ✗ for any issues

**Output**:
```
═════════════════════════════════════════════════════
Harness MCP Server - Windows Setup
═════════════════════════════════════════════════════

Step 1: Cloning Harness Repository
  ✓ Repository cloned
  ✓ Harness SKILL.md verified

Step 2: Installing Harness Skill
  ✓ Skill installed

Step 3: Installing MCP Server
  ✓ MCP server installed

Step 4: Configuring Claude Desktop
  ✓ Claude Desktop configured

Step 5: Installing Integration Modules
  ✓ skill-creator integration installed
  ✓ wix:wix-manage integration installed

Step 6: Verification
  ✓ Harness repository
  ✓ Harness SKILL.md
  ✓ MCP server script
  ✓ Claude Desktop config

Verification: 4/4 checks passed

═════════════════════════════════════════════════════
✓ Installation Complete!
═════════════════════════════════════════════════════
```

---

### Method 2: Batch Script

**File**: `install_harness.bat`

**Steps**:

1. **Download Script**
   - Save `install_harness.bat` to your Downloads folder

2. **Open Command Prompt as Administrator**
   - Right-click Command Prompt
   - Select "Run as Administrator"

3. **Run Script**
   ```cmd
   cd Downloads
   install_harness.bat
   ```

4. **Watch Installation Progress**
   - Script shows `[OK]` for successful steps
   - Script shows `[ERROR]` for any issues

5. **Press Any Key to Exit**
   - Press any key when installation completes

---

## Installation Locations

After installation, files will be at:

| Component | Location |
|-----------|----------|
| Harness repo | `%LOCALAPPDATA%\AI-Tools\harness` |
| MCP server | `%LOCALAPPDATA%\AI-Tools\mcp\harness_mcp_server.py` |
| Harness skill | `%LOCALAPPDATA%\Claude\skills\harness` |
| Claude config | `%APPDATA%\Claude\claude_desktop_config.json` |

**Expanded Paths**:
```
C:\Users\[YourUsername]\AppData\Local\AI-Tools\harness
C:\Users\[YourUsername]\AppData\Local\AI-Tools\mcp
C:\Users\[YourUsername]\AppData\Local\Claude\skills\harness
C:\Users\[YourUsername]\AppData\Roaming\Claude\claude_desktop_config.json
```

---

## Configuration That Gets Saved

### Claude Desktop Config

**File**: `%APPDATA%\Claude\claude_desktop_config.json`

**Content**:
```json
{
  "mcpServers": {
    "harness": {
      "command": "python",
      "args": [
        "C:\\Users\\[YourUsername]\\AppData\\Local\\AI-Tools\\mcp\\harness_mcp_server.py"
      ],
      "env": {
        "HARNESS_DIR": "C:\\Users\\[YourUsername]\\AppData\\Local\\AI-Tools\\harness"
      }
    }
  }
}
```

**What it does**: Tells Claude Desktop where the MCP server is and how to run it.

---

## After Installation

### Step 1: Restart Claude Desktop

Close Claude Desktop completely:
- Click File → Exit
- Or click X to close all windows

Then reopen Claude Desktop.

### Step 2: Verify in Claude

Type in Claude:
```
/mcp
```

You should see:
```
Available MCP servers:
- harness [Connected]
```

### Step 3: Start Using Harness

Use any of these commands:

```
/design_agent_team
/generate_skill_scaffold
/wix_app_agent_scaffold
/validate_team_architecture
/orchestration_template
/harness_status
```

Or just describe what you need:

```
"Design a multi-agent team for product discovery"
"Create a SKILL.md for content analysis"
"Scaffold a Wix membership dashboard"
```

---

## Troubleshooting

### Issue: "Python is not recognized"

**Solution**:
1. Verify Python installed: https://www.python.org/downloads/
2. During installation, **check "Add Python to PATH"**
3. Restart Command Prompt after Python installation

**Check**:
```cmd
python --version
```

### Issue: "Git is not recognized"

**Solution**:
1. Install Git: https://git-scm.com/download/win
2. Choose "Git from Windows Command Prompt" during installation
3. Restart Command Prompt after Git installation

**Check**:
```cmd
git --version
```

### Issue: "ExecutionPolicy" error in PowerShell

**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then type `Y` when prompted.

### Issue: "Access Denied" error

**Solution**:
- Make sure running PowerShell or Command Prompt **as Administrator**
- Right-click and select "Run as Administrator"

### Issue: MCP Server not appearing in Claude

**Solution**:
1. Make sure Claude Desktop is **completely closed** (not just minimized)
2. Restart Claude Desktop
3. Wait 10 seconds for MCP server to load
4. Type `/mcp` to verify

### Issue: Config file not found

**Solution**:
The script creates it automatically. If missing:

```powershell
# Verify path
echo $env:APPDATA

# Open config directory
explorer $env:APPDATA\Claude
```

---

## Custom Installation Paths

### Using Custom Directories

Set environment variables before running:

```powershell
# PowerShell
$env:HARNESS_DIR = "D:\Tools\harness"
$env:MCP_DIR = "D:\Tools\mcp"
$env:SKILL_DIR = "D:\Claude\skills"
.\install_harness.ps1
```

Or in Command Prompt:

```cmd
set HARNESS_DIR=D:\Tools\harness
set MCP_DIR=D:\Tools\mcp
set SKILL_DIR=D:\Claude\skills
install_harness.bat
```

---

## Manual Installation (If Scripts Fail)

If the scripts don't work, you can install manually:

### 1. Clone Repository

```cmd
git clone https://github.com/revfactory/harness.git "%LOCALAPPDATA%\AI-Tools\harness"
```

### 2. Create MCP Directory

```cmd
mkdir "%LOCALAPPDATA%\AI-Tools\mcp"
```

### 3. Copy Files

```cmd
# Copy MCP server script
copy harness_mcp_server.py "%LOCALAPPDATA%\AI-Tools\mcp\"

# Copy Harness skill
xcopy /e /i harness\skills\harness "%LOCALAPPDATA%\Claude\skills\harness"
```

### 4. Create Config Manually

Create file: `%APPDATA%\Claude\claude_desktop_config.json`

Content:
```json
{
  "mcpServers": {
    "harness": {
      "command": "python",
      "args": ["C:\\Users\\[YourUsername]\\AppData\\Local\\AI-Tools\\mcp\\harness_mcp_server.py"],
      "env": {
        "HARNESS_DIR": "C:\\Users\\[YourUsername]\\AppData\\Local\\AI-Tools\\harness"
      }
    }
  }
}
```

Replace `[YourUsername]` with your actual Windows username.

---

## Verification

### Check Installation

**PowerShell**:
```powershell
# Check Harness repo
Test-Path "$env:LOCALAPPDATA\AI-Tools\harness\skills\harness\SKILL.md"

# Check MCP server
Test-Path "$env:LOCALAPPDATA\AI-Tools\mcp\harness_mcp_server.py"

# Check config
Get-Content "$env:APPDATA\Claude\claude_desktop_config.json" | ConvertFrom-Json
```

**Command Prompt**:
```cmd
# Check Harness repo
dir "%LOCALAPPDATA%\AI-Tools\harness\skills\harness\SKILL.md"

# Check MCP server
dir "%LOCALAPPDATA%\AI-Tools\mcp\harness_mcp_server.py"

# Check config
type "%APPDATA%\Claude\claude_desktop_config.json"
```

---

## Uninstall

### Remove Harness

**PowerShell**:
```powershell
# Remove installed files
Remove-Item "$env:LOCALAPPDATA\AI-Tools\harness" -Recurse -Force
Remove-Item "$env:LOCALAPPDATA\Claude\skills\harness" -Recurse -Force

# Remove from Claude config
$config = Get-Content "$env:APPDATA\Claude\claude_desktop_config.json" | ConvertFrom-Json
$config.mcpServers.PSObject.Properties.Remove('harness')
$config | ConvertTo-Json | Set-Content "$env:APPDATA\Claude\claude_desktop_config.json"
```

**Command Prompt**:
```cmd
# Remove installed files
rmdir /s /q "%LOCALAPPDATA%\AI-Tools\harness"
rmdir /s /q "%LOCALAPPDATA%\Claude\skills\harness"

# Remove from Claude config (edit manually or use PowerShell)
```

---

## Idempotent Installation

Both scripts are **idempotent** - safe to run multiple times:

```powershell
# Run once
.\install_harness.ps1

# Run again (updates if needed)
.\install_harness.ps1

# Run a third time (verifies)
.\install_harness.ps1
```

Each run:
- ✓ Updates Harness repository
- ✓ Verifies all components
- ✓ Updates configuration as needed

---

## File Sizes

Installation uses:
- Harness repo: ~50-100 MB
- MCP server script: ~50 KB
- Harness skill: ~5-10 MB
- **Total**: ~150-200 MB disk space

---

## Summary

**PowerShell**: `.\install_harness.ps1` (Recommended)  
**Batch**: `install_harness.bat` (Alternative)  
**Time**: ~2 minutes  
**Admin required**: Yes  
**Configuration saved**: Automatic  

After installation:
1. Restart Claude Desktop
2. Type `/mcp`
3. See `harness [Connected]`
4. Use Harness tools

All configuration is saved automatically. Ready to use after restart.
