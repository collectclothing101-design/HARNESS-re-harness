#!/usr/bin/env bash

# Harness v2.0 - Enterprise-Grade Multi-Agent Orchestration
# Cross-Platform Installation Script
# 
# Supports: macOS, Linux, Windows (WSL/Git Bash)
# Installation: bash install_harness_universal.sh

set -e

# ============================================================================
# CONFIGURATION
# ============================================================================

HARNESS_VERSION="2.0.0"
HARNESS_REPO="https://github.com/revfactory/harness.git"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    LOCALAPPDATA="$HOME/Library/Application Support"
    APPDATA="$HOME/Library/Application Support"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    LOCALAPPDATA="$HOME/.local/share"
    APPDATA="$HOME/.config"
else
    OS="windows"
    LOCALAPPDATA="${LOCALAPPDATA:-$HOME/AppData/Local}"
    APPDATA="${APPDATA:-$HOME/AppData/Roaming}"
fi

# Configuration paths
HARNESS_DIR="${HARNESS_DIR:-$LOCALAPPDATA/AI-Tools/harness}"
MCP_DIR="${MCP_DIR:-$LOCALAPPDATA/AI-Tools/mcp}"
SKILL_DIR="${SKILL_DIR:-$LOCALAPPDATA/Claude/skills}"
CONFIG_DIR="$APPDATA/Claude"
CONFIG_FILE="$CONFIG_DIR/claude_desktop_config.json"

# ============================================================================
# COLOR OUTPUT
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${CYAN}═════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}═════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}! $1${NC}"
}

print_info() {
    echo -e "${CYAN}  $1${NC}"
}

# ============================================================================
# PREREQUISITE CHECKS
# ============================================================================

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local has_python=false
    local has_git=false
    
    # Check Python
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
        print_success "Python 3 found: $PYTHON_VERSION"
        has_python=true
    elif command -v python &> /dev/null; then
        PYTHON_VERSION=$(python --version 2>&1 | awk '{print $2}')
        print_success "Python found: $PYTHON_VERSION"
        has_python=true
    else
        print_error "Python 3 not found"
        echo "Install from: https://www.python.org/downloads/"
    fi
    
    # Check Git
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version | awk '{print $3}')
        print_success "Git found: $GIT_VERSION"
        has_git=true
    else
        print_error "Git not found"
        echo "Install from: https://git-scm.com/downloads"
    fi
    
    echo ""
    
    if [ "$has_python" = false ] || [ "$has_git" = false ]; then
        print_error "Missing prerequisites"
        exit 1
    fi
}

# ============================================================================
# INSTALLATION STEPS
# ============================================================================

step_clone_repository() {
    print_header "Step 1: Cloning Harness Repository"
    
    mkdir -p "$HARNESS_DIR"
    
    if [ -d "$HARNESS_DIR/.git" ]; then
        print_info "Updating existing repository..."
        cd "$HARNESS_DIR"
        git pull --ff-only > /dev/null 2>&1
        print_success "Repository updated"
    else
        print_info "Cloning new repository..."
        git clone "$HARNESS_REPO" "$HARNESS_DIR" > /dev/null 2>&1
        print_success "Repository cloned"
    fi
    
    # Verify SKILL.md
    if [ -f "$HARNESS_DIR/skills/harness/SKILL.md" ]; then
        print_success "Harness SKILL.md verified"
    else
        print_error "Harness SKILL.md not found"
        exit 1
    fi
    
    echo ""
}

step_install_skill() {
    print_header "Step 2: Installing Harness Skill"
    
    mkdir -p "$SKILL_DIR"
    
    if [ -d "$SKILL_DIR/harness" ]; then
        rm -rf "$SKILL_DIR/harness"
    fi
    
    cp -r "$HARNESS_DIR/skills/harness" "$SKILL_DIR/"
    print_success "Skill installed to $SKILL_DIR/harness"
    
    echo ""
}

step_install_mcp_server() {
    print_header "Step 3: Installing MCP Server"
    
    mkdir -p "$MCP_DIR"
    
    # Find MCP server script (try advanced first, then v2, then basic)
    local mcp_source=""
    if [ -f "./harness_claude_advanced_mcp.py" ]; then
        mcp_source="./harness_claude_advanced_mcp.py"
    elif [ -f "./harness_mcp_server_v2.py" ]; then
        mcp_source="./harness_mcp_server_v2.py"
    elif [ -f "./harness_mcp_server.py" ]; then
        mcp_source="./harness_mcp_server.py"
    elif [ -f "$HARNESS_DIR/harness_claude_advanced_mcp.py" ]; then
        mcp_source="$HARNESS_DIR/harness_claude_advanced_mcp.py"
    elif [ -f "$HARNESS_DIR/harness_mcp_server_v2.py" ]; then
        mcp_source="$HARNESS_DIR/harness_mcp_server_v2.py"
    else
        print_warning "MCP server not found in expected locations"
        print_info "Expected: harness_claude_advanced_mcp.py or harness_mcp_server_v2.py"
        mcp_source=""
    fi
    
    if [ -n "$mcp_source" ]; then
        cp "$mcp_source" "$MCP_DIR/harness_mcp_server_v2.py"
        chmod +x "$MCP_DIR/harness_mcp_server_v2.py"
        print_success "MCP server installed to $MCP_DIR"
    fi
    
    echo ""
}

step_configure_claude() {
    print_header "Step 4: Configuring Claude Desktop"
    
    mkdir -p "$CONFIG_DIR"
    
    # Create config using Python for JSON handling
    python3 << 'EOF'
import json
import os

config_file = os.path.expandvars("$CONFIG_FILE")
config_dir = os.path.dirname(config_file)
os.makedirs(config_dir, exist_ok=True)

mcp_server_path = os.path.expandvars("$MCP_DIR/harness_mcp_server_v2.py")
harness_dir = os.path.expandvars("$HARNESS_DIR")

config = {"mcpServers": {}}

if os.path.exists(config_file):
    try:
        with open(config_file, 'r') as f:
            config = json.load(f)
    except:
        pass

if "mcpServers" not in config:
    config["mcpServers"] = {}

config["mcpServers"]["harness"] = {
    "command": "python3",
    "args": [mcp_server_path],
    "env": {
        "HARNESS_DIR": harness_dir
    }
}

with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)

EOF
    
    print_success "Claude Desktop configured"
    print_info "Config saved: $CONFIG_FILE"
    
    echo ""
}

step_install_integrations() {
    print_header "Step 5: Installing Integration Modules"
    
    local integrations_dir="$MCP_DIR/integrations"
    mkdir -p "$integrations_dir"
    
    local files=("harness_skill_creator_integration.py" "harness_wix_integration.py" "harness_advanced_diagnostics.py")
    
    for file in "${files[@]}"; do
        if [ -f "./$file" ]; then
            cp "./$file" "$integrations_dir/"
            print_success "$file installed"
        fi
    done
    
    echo ""
}

step_verify_installation() {
    print_header "Step 6: Verification"
    
    local checks_passed=0
    local checks_total=4
    
    # Check 1: Repository
    if [ -d "$HARNESS_DIR/.git" ]; then
        print_success "Harness repository"
        ((checks_passed++))
    else
        print_error "Harness repository"
    fi
    
    # Check 2: SKILL.md
    if [ -f "$SKILL_DIR/harness/SKILL.md" ]; then
        print_success "Harness SKILL.md"
        ((checks_passed++))
    else
        print_error "Harness SKILL.md"
    fi
    
    # Check 3: MCP server
    if [ -f "$MCP_DIR/harness_mcp_server_v2.py" ]; then
        print_success "MCP server script"
        ((checks_passed++))
    else
        print_error "MCP server script"
    fi
    
    # Check 4: Claude config
    if [ -f "$CONFIG_FILE" ] && grep -q "harness" "$CONFIG_FILE"; then
        print_success "Claude Desktop config"
        ((checks_passed++))
    else
        print_error "Claude Desktop config"
    fi
    
    echo ""
    echo "Verification: $checks_passed/$checks_total checks passed"
    echo ""
    
    if [ $checks_passed -lt $checks_total ]; then
        print_warning "Some checks failed. Review above."
    fi
}

# ============================================================================
# SUMMARY
# ============================================================================

print_summary() {
    print_header "Installation Complete!"
    echo ""
    echo "File Locations:"
    print_info "Harness repo:    $HARNESS_DIR"
    print_info "MCP server:      $MCP_DIR/harness_mcp_server_v2.py"
    print_info "Claude config:   $CONFIG_FILE"
    print_info "Skill installed: $SKILL_DIR/harness"
    echo ""
    
    echo "Next Steps:"
    print_info "1. Restart Claude Desktop (close and reopen completely)"
    print_info "2. Type: /mcp"
    print_info "3. You should see 'harness [Connected]'"
    print_info "4. Use Harness tools:"
    print_info "   /design_agent_team"
    print_info "   /validate_team_architecture"
    print_info "   /optimize_team_performance"
    print_info "   /generate_skill_scaffold"
    print_info "   /create_wix_agent_scaffold"
    echo ""
    
    echo "Documentation:"
    print_info "View: $SKILL_DIR/harness/SKILL.md"
    print_info "Docs: https://github.com/revfactory/harness"
    echo ""
    
    echo "To use Harness in Claude:"
    print_info '"Design a multi-agent team for [domain]"'
    print_info '"Validate this architecture: [spec]"'
    print_info '"Optimize team performance"'
    echo ""
    
    print_success "Installation script completed successfully!"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    print_header "Harness v$HARNESS_VERSION - Universal Installation"
    print_info "Detected OS: $OS"
    print_info "Installation paths:"
    print_info "  Harness:   $HARNESS_DIR"
    print_info "  MCP:       $MCP_DIR"
    print_info "  Skills:    $SKILL_DIR"
    print_info "  Config:    $CONFIG_FILE"
    echo ""
    
    check_prerequisites
    step_clone_repository
    step_install_skill
    step_install_mcp_server
    step_configure_claude
    step_install_integrations
    step_verify_installation
    print_summary
}

# Run main
main
