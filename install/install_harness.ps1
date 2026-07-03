# Harness MCP Server - Windows Installation Script
# Run this in PowerShell as Administrator

# Set error handling
$ErrorActionPreference = "Stop"

# Color output
function Write-Header { Write-Host $args[0] -ForegroundColor Cyan -BackgroundColor Black }
function Write-Success { Write-Host "  ✓ $($args[0])" -ForegroundColor Green }
function Write-Error { Write-Host "  ✗ $($args[0])" -ForegroundColor Red }
function Write-Warning { Write-Host "  ! $($args[0])" -ForegroundColor Yellow }
function Write-Info { Write-Host "  $($args[0])" -ForegroundColor White }

Write-Header "═════════════════════════════════════════════════════"
Write-Header "Harness MCP Server - Windows Setup"
Write-Header "═════════════════════════════════════════════════════"
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Error "This script must be run as Administrator"
    Write-Info "Right-click PowerShell and select 'Run as Administrator'"
    exit 1
}

# Configuration
$harnessDirEnv = $env:HARNESS_DIR
$mcpDirEnv = $env:MCP_DIR
$skillDirEnv = $env:SKILL_DIR

$harness_dir = if ($harnessDirEnv) { $harnessDirEnv } else { "$env:LOCALAPPDATA\AI-Tools\harness" }
$mcp_dir = if ($mcpDirEnv) { $mcpDirEnv } else { "$env:LOCALAPPDATA\AI-Tools\mcp" }
$skill_dir = if ($skillDirEnv) { $skillDirEnv } else { "$env:LOCALAPPDATA\Claude\skills" }
$config_dir = "$env:APPDATA\Claude"
$config_file = "$config_dir\claude_desktop_config.json"

Write-Host "Configuration:"
Write-Info "Harness dir: $harness_dir"
Write-Info "MCP dir:     $mcp_dir"
Write-Info "Skills dir:  $skill_dir"
Write-Info "Config dir:  $config_dir"
Write-Host ""

# Step 1: Clone Harness Repository
Write-Header "Step 1: Cloning Harness Repository"

$harness_git = Join-Path $harness_dir ".git"

try {
    if (Test-Path $harness_git) {
        Write-Info "Updating existing repository..."
        cd $harness_dir
        git pull --ff-only
        Write-Success "Repository updated"
    } else {
        Write-Info "Cloning new repository..."
        New-Item -ItemType Directory -Path $harness_dir -Force | Out-Null
        git clone https://github.com/revfactory/harness.git $harness_dir
        Write-Success "Repository cloned"
    }
} catch {
    Write-Error "Failed to clone repository: $_"
    Write-Info "Make sure Git is installed: https://git-scm.com/download/win"
    exit 1
}

# Verify Harness skill
$skill_md = Join-Path $harness_dir "skills\harness\SKILL.md"
if (-not (Test-Path $skill_md)) {
    Write-Error "Harness SKILL.md not found at: $skill_md"
    exit 1
}
Write-Success "Harness SKILL.md verified"
Write-Host ""

# Step 2: Copy Harness Skill
Write-Header "Step 2: Installing Harness Skill"

try {
    New-Item -ItemType Directory -Path $skill_dir -Force | Out-Null
    $harness_skill_src = Join-Path $harness_dir "skills\harness"
    $harness_skill_dst = Join-Path $skill_dir "harness"
    
    if (Test-Path $harness_skill_dst) {
        Remove-Item $harness_skill_dst -Recurse -Force
    }
    
    Copy-Item $harness_skill_src -Destination $harness_skill_dst -Recurse -Force
    Write-Success "Skill installed to $skill_dir\harness"
} catch {
    Write-Error "Failed to copy skill: $_"
    exit 1
}
Write-Host ""

# Step 3: Copy MCP Server Script
Write-Header "Step 3: Installing MCP Server"

try {
    New-Item -ItemType Directory -Path $mcp_dir -Force | Out-Null
    
    # Check for MCP server files (try advanced first, then v2, then basic)
    $mcp_source_locations = @(
        ".\harness_claude_advanced_mcp.py",
        ".\harness_mcp_server_v2.py",
        ".\harness_mcp_server.py",
        "$PSScriptRoot\harness_claude_advanced_mcp.py",
        "$PSScriptRoot\harness_mcp_server_v2.py",
        "$PSScriptRoot\harness_mcp_server.py"
    )
    
    $mcp_source = $null
    foreach ($loc in $mcp_source_locations) {
        if (Test-Path $loc) {
            $mcp_source = $loc
            break
        }
    }
    
    if (-not $mcp_source) {
        Write-Warning "harness_mcp_server.py not found in expected locations"
        Write-Info "Please download from outputs and place in current directory"
        Write-Info "Expected: $(Join-Path $mcp_dir 'harness_mcp_server.py')"
        exit 1
    }
    
    Copy-Item $mcp_source -Destination (Join-Path $mcp_dir "harness_mcp_server.py") -Force
    Write-Success "MCP server installed to $mcp_dir"
} catch {
    Write-Error "Failed to copy MCP server: $_"
    exit 1
}
Write-Host ""

# Step 4: Configure Claude Desktop
Write-Header "Step 4: Configuring Claude Desktop"

try {
    New-Item -ItemType Directory -Path $config_dir -Force | Out-Null
    
    # Create or load existing config
    $config = @{ mcpServers = @{} }
    
    if (Test-Path $config_file) {
        $config = Get-Content $config_file | ConvertFrom-Json
        if (-not $config.mcpServers) {
            $config | Add-Member -Name "mcpServers" -Value @{} -MemberType NoteProperty
        }
    }
    
    # Convert path to use forward slashes for JSON
    $mcp_server_path = (Join-Path $mcp_dir "harness_mcp_server.py") -replace '\\', '/'
    
    # Add or update harness MCP server
    $harness_config = @{
        command = "python"
        args = @($mcp_server_path)
        env = @{
            HARNESS_DIR = $harness_dir
        }
    }
    
    # Convert to PSCustomObject for proper JSON serialization
    $harness_config_obj = [PSCustomObject]$harness_config
    
    if ($config.mcpServers -is [PSCustomObject]) {
        $config.mcpServers | Add-Member -Name "harness" -Value $harness_config_obj -MemberType NoteProperty -Force
    } else {
        $config.mcpServers["harness"] = $harness_config_obj
    }
    
    # Save config
    $config | ConvertTo-Json -Depth 10 | Set-Content $config_file -Encoding UTF8
    Write-Success "Claude Desktop configured"
    Write-Info "Config saved: $config_file"
} catch {
    Write-Error "Failed to configure Claude Desktop: $_"
    exit 1
}
Write-Host ""

# Step 5: Copy Integration Modules
Write-Header "Step 5: Installing Integration Modules"

try {
    $integrations_dir = Join-Path $mcp_dir "integrations"
    New-Item -ItemType Directory -Path $integrations_dir -Force | Out-Null
    
    $integration_files = @(
        "harness_skill_creator_integration.py",
        "harness_wix_integration.py"
    )
    
    foreach ($file in $integration_files) {
        $file_source = $null
        $search_locations = @(
            ".\$file",
            "$PSScriptRoot\$file",
            "$env:TEMP\$file"
        )
        
        foreach ($loc in $search_locations) {
            if (Test-Path $loc) {
                $file_source = $loc
                break
            }
        }
        
        if ($file_source) {
            Copy-Item $file_source -Destination (Join-Path $integrations_dir $file) -Force
            Write-Success "$file installed"
        }
    }
} catch {
    Write-Warning "Failed to copy some integration modules: $_"
}
Write-Host ""

# Step 6: Verify Installation
Write-Header "Step 6: Verification"

$checks_passed = 0
$checks_total = 4

# Check 1: Harness repo
if (Test-Path (Join-Path $harness_dir ".git")) {
    Write-Success "Harness repository"
    $checks_passed++
} else {
    Write-Error "Harness repository"
}
$checks_total++

# Check 2: SKILL.md
if (Test-Path $skill_md) {
    Write-Success "Harness SKILL.md"
    $checks_passed++
} else {
    Write-Error "Harness SKILL.md"
}
$checks_total++

# Check 3: MCP server
$mcp_server_check = Join-Path $mcp_dir "harness_mcp_server.py"
if (Test-Path $mcp_server_check) {
    Write-Success "MCP server script"
    $checks_passed++
} else {
    Write-Error "MCP server script"
}
$checks_total++

# Check 4: Claude config
if (Test-Path $config_file) {
    $config_content = Get-Content $config_file -Raw
    if ($config_content -like "*harness*") {
        Write-Success "Claude Desktop config"
        $checks_passed++
    } else {
        Write-Error "Claude Desktop config (harness not found)"
    }
} else {
    Write-Error "Claude Desktop config (file missing)"
}
$checks_total++

Write-Host ""
Write-Host "Verification: $checks_passed/$checks_total checks passed" -ForegroundColor Cyan
Write-Host ""

# Step 7: Summary
Write-Header "═════════════════════════════════════════════════════"
Write-Header "✓ Installation Complete!" -ForegroundColor Green
Write-Header "═════════════════════════════════════════════════════"
Write-Host ""

Write-Host "File Locations:" -ForegroundColor Yellow
Write-Info "Harness repo:    $harness_dir"
Write-Info "MCP server:      $mcp_server_check"
Write-Info "Claude config:   $config_file"
Write-Info "Skill installed: $skill_dir\harness"
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Info "1. Restart Claude Desktop (close and reopen completely)"
Write-Info "2. Type: /mcp"
Write-Info "3. You should see 'harness' in the list"
Write-Info "4. Use Harness tools:"
Write-Info "   /design_agent_team"
Write-Info "   /generate_skill_scaffold"
Write-Info "   /wix_app_agent_scaffold"
Write-Info "   /validate_team_architecture"
Write-Host ""

Write-Host "To use Harness in Claude:" -ForegroundColor Yellow
Write-Info '"Design a multi-agent team for [domain]"'
Write-Info '"Scaffold a Wix [feature]"'
Write-Info '"Create a SKILL.md for [domain]"'
Write-Host ""

Write-Host "Documentation:" -ForegroundColor Yellow
Write-Info "View: $skill_dir\harness\SKILL.md"
Write-Info "View config: Get-Content $config_file | ConvertFrom-Json"
Write-Host ""

Write-Host "Installation script completed successfully!" -ForegroundColor Green
