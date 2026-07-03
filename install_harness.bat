@echo off
REM Harness MCP Server - Windows Installation Script (Batch)
REM Run as Administrator: Right-click Command Prompt, select "Run as Administrator"

setlocal enabledelayedexpansion

REM Color codes (Windows 10+)
cls

echo =====================================================
echo Harness MCP Server - Windows Setup
echo =====================================================
echo.

REM Check for Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script must be run as Administrator
    echo Please right-click Command Prompt and select "Run as Administrator"
    pause
    exit /b 1
)

REM Configuration
if defined HARNESS_DIR (
    set harness_dir=%HARNESS_DIR%
) else (
    set harness_dir=%LOCALAPPDATA%\AI-Tools\harness
)

if defined MCP_DIR (
    set mcp_dir=%MCP_DIR%
) else (
    set mcp_dir=%LOCALAPPDATA%\AI-Tools\mcp
)

if defined SKILL_DIR (
    set skill_dir=%SKILL_DIR%
) else (
    set skill_dir=%LOCALAPPDATA%\Claude\skills
)

set config_dir=%APPDATA%\Claude
set config_file=%config_dir%\claude_desktop_config.json

echo Configuration:
echo   Harness dir: %harness_dir%
echo   MCP dir:     %mcp_dir%
echo   Skills dir:  %skill_dir%
echo   Config dir:  %config_dir%
echo.

REM Step 1: Clone Harness Repository
echo Step 1: Cloning Harness Repository

if exist "%harness_dir%\.git" (
    echo   Updating existing repository...
    cd /d "%harness_dir%"
    git pull --ff-only
    if errorlevel 1 (
        echo   ERROR: Failed to update repository
        exit /b 1
    )
    echo   [OK] Repository updated
) else (
    echo   Cloning new repository...
    if not exist "%harness_dir%" mkdir "%harness_dir%"
    git clone https://github.com/revfactory/harness.git "%harness_dir%"
    if errorlevel 1 (
        echo   ERROR: Failed to clone repository
        echo   Make sure Git is installed: https://git-scm.com/download/win
        exit /b 1
    )
    echo   [OK] Repository cloned
)

if not exist "%harness_dir%\skills\harness\SKILL.md" (
    echo   ERROR: Harness SKILL.md not found
    exit /b 1
)
echo   [OK] Harness SKILL.md verified
echo.

REM Step 2: Copy Harness Skill
echo Step 2: Installing Harness Skill

if not exist "%skill_dir%" mkdir "%skill_dir%"

if exist "%skill_dir%\harness" (
    rmdir /s /q "%skill_dir%\harness"
)

xcopy /e /i /q "%harness_dir%\skills\harness" "%skill_dir%\harness"
if errorlevel 1 (
    echo   ERROR: Failed to copy skill
    exit /b 1
)
echo   [OK] Skill installed to %skill_dir%\harness
echo.

REM Step 3: Copy MCP Server Script
echo Step 3: Installing MCP Server

if not exist "%mcp_dir%" mkdir "%mcp_dir%"

REM Check for MCP server files (try advanced first, then v2, then basic)
set mcp_source=
if exist ".\harness_claude_advanced_mcp.py" (
    set mcp_source=.\harness_claude_advanced_mcp.py
) else if exist ".\harness_mcp_server_v2.py" (
    set mcp_source=.\harness_mcp_server_v2.py
) else if exist ".\harness_mcp_server.py" (
    set mcp_source=.\harness_mcp_server.py
) else if exist "%~dp0harness_claude_advanced_mcp.py" (
    set mcp_source=%~dp0harness_claude_advanced_mcp.py
) else if exist "%~dp0harness_mcp_server_v2.py" (
    set mcp_source=%~dp0harness_mcp_server_v2.py
) else if exist "%~dp0harness_mcp_server.py" (
    set mcp_source=%~dp0harness_mcp_server.py
) else (
    echo   WARNING: MCP server not found
    echo   Please ensure harness_claude_advanced_mcp.py is in the current directory
    exit /b 1
)

copy /y "!mcp_source!" "%mcp_dir%\harness_mcp_server.py"
if errorlevel 1 (
    echo   ERROR: Failed to copy MCP server
    exit /b 1
)
echo   [OK] MCP server installed to %mcp_dir%
echo.

REM Step 4: Configure Claude Desktop
echo Step 4: Configuring Claude Desktop

if not exist "%config_dir%" mkdir "%config_dir%"

REM Create configuration using PowerShell for JSON handling
powershell -Command ^
    "$config = @{ mcpServers = @{} }; " ^
    "if (Test-Path '%config_file%') { $config = Get-Content '%config_file%' | ConvertFrom-Json; } " ^
    "$mcp_path = (Join-Path '%mcp_dir%' 'harness_mcp_server.py').Replace('\\', '/'); " ^
    "$harness_config = @{ command = 'python'; args = @($mcp_path); env = @{ HARNESS_DIR = '%harness_dir%' } }; " ^
    "if ($config.mcpServers -is [PSCustomObject]) { $config.mcpServers | Add-Member -Name 'harness' -Value $harness_config -MemberType NoteProperty -Force } " ^
    "else { $config.mcpServers['harness'] = $harness_config } " ^
    "$config | ConvertTo-Json -Depth 10 | Set-Content '%config_file%' -Encoding UTF8"

if errorlevel 1 (
    echo   ERROR: Failed to configure Claude Desktop
    echo   Make sure PowerShell is available
    exit /b 1
)
echo   [OK] Claude Desktop configured
echo   Config saved: %config_file%
echo.

REM Step 5: Copy Integration Modules
echo Step 5: Installing Integration Modules

set integrations_dir=%mcp_dir%\integrations
if not exist "%integrations_dir%" mkdir "%integrations_dir%"

setlocal enabledelayedexpansion
for %%F in (harness_skill_creator_integration.py harness_wix_integration.py) do (
    if exist ".\%%F" (
        copy /y ".\%%F" "%integrations_dir%\%%F"
        if errorlevel 1 (
            echo   WARNING: Failed to copy %%F
        ) else (
            echo   [OK] %%F installed
        )
    )
)
echo.

REM Step 6: Verification
echo Step 6: Verification

set /a checks_passed=0
set /a checks_total=4

if exist "%harness_dir%\.git" (
    echo   [OK] Harness repository
    set /a checks_passed+=1
) else (
    echo   [FAIL] Harness repository
)
set /a checks_total+=1

if exist "%harness_dir%\skills\harness\SKILL.md" (
    echo   [OK] Harness SKILL.md
    set /a checks_passed+=1
) else (
    echo   [FAIL] Harness SKILL.md
)
set /a checks_total+=1

if exist "%mcp_dir%\harness_mcp_server.py" (
    echo   [OK] MCP server script
    set /a checks_passed+=1
) else (
    echo   [FAIL] MCP server script
)
set /a checks_total+=1

if exist "%config_file%" (
    findstr /m "harness" "%config_file%" >nul
    if !errorlevel! equ 0 (
        echo   [OK] Claude Desktop config
        set /a checks_passed+=1
    ) else (
        echo   [FAIL] Claude Desktop config (harness not found)
    )
) else (
    echo   [FAIL] Claude Desktop config (file missing)
)
set /a checks_total+=1

echo.
echo Verification: %checks_passed%/%checks_total% checks passed
echo.

REM Step 7: Summary
echo =====================================================
echo [SUCCESS] Installation Complete!
echo =====================================================
echo.

echo File Locations:
echo   Harness repo:    %harness_dir%
echo   MCP server:      %mcp_dir%\harness_mcp_server.py
echo   Claude config:   %config_file%
echo   Skill installed: %skill_dir%\harness
echo.

echo Next Steps:
echo   1. Restart Claude Desktop (close and reopen completely)
echo   2. Type: /mcp
echo   3. You should see 'harness' in the list
echo   4. Use Harness tools:
echo      /design_agent_team
echo      /generate_skill_scaffold
echo      /wix_app_agent_scaffold
echo      /validate_team_architecture
echo.

echo To use Harness in Claude:
echo   "Design a multi-agent team for [domain]"
echo   "Scaffold a Wix [feature]"
echo   "Create a SKILL.md for [domain]"
echo.

echo Documentation:
echo   View: %skill_dir%\harness\SKILL.md
echo   View config: type "%config_file%"
echo.

echo Installation script completed successfully!
echo.

pause
