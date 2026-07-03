#!/usr/bin/env bash

# ============================================================================
# Harness v3.0.0 - Enterprise-Grade Multi-Agent Orchestration
# CORRECTED Cross-Platform Installation Script
# 
# Fixes Applied:
# 1. Correct MCP filename: harness_claude_advanced_mcp.py (not v2)
# 2. Fixed Python config environment variable passing
# 3. Updated to v3.0.0 and removed git clone (files are local)
# 4. Rust/LLVM compatibility workarounds for macOS
#
# Supports: macOS (Apple Silicon + Intel), Linux, Windows (WSL/Git Bash)
# Usage: bash install_harness_v3_corrected.sh
# ============================================================================

set -e

# ============================================================================
# CONFIGURATION
# ============================================================================

HARNESS_VERSION="3.0.0"

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
    
    echo ""
    
    if [ "$has_python" = false ]; then
        print_error "Missing Python 3"
        exit 1
    fi
}

# ============================================================================
# MACOS-SPECIFIC RUST/LLVM FIX
# ============================================================================

fix_rust_llvm_issues() {
    if [ "$OS" != "macos" ]; then
        return 0
    fi
    
    print_header "Applying macOS Rust/LLVM Compatibility Fixes"
    
    if command -v brew &> /dev/null; then
        print_info "Homebrew detected - checking for LLVM issues..."
        
        # Check if Rust is installed via Homebrew
        if [ -d "$(brew --prefix rust)" ]; then
            print_warning "Homebrew Rust detected - may have LLVM compatibility issues"
            print_info "Solution: Using pre-built wheels to avoid compilation"
            
            # These environment variables tell pip to use pre-built wheels
            export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
            export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1
        fi
    fi
    
    echo ""
}

# ============================================================================
# CREATE DIRECTORIES
# ============================================================================

create_directories() {
    print_header "Creating Installation Directories"
    
    mkdir -p "$HARNESS_DIR"
    mkdir -p "$MCP_DIR"
    mkdir -p "$SKILL_DIR"
    mkdir -p "$CONFIG_DIR"
    
    print_success "Directories created"
    print_info "Harness:   $HARNESS_DIR"
    print_info "MCP:       $MCP_DIR"
    print_info "Skills:    $SKILL_DIR"
    print_info "Config:    $CONFIG_FILE"
    
    echo ""
}

# ============================================================================
# INSTALL MCP SERVER (CORRECTED - Bug Fix #1)
# ============================================================================

install_mcp_server() {
    print_header "Installing MCP Server"
    
    # FIX #1: Use correct v3 filename (not harness_mcp_server_v2.py)
    local mcp_source=""
    local mcp_filename="harness_claude_advanced_mcp.py"
    
    if [ -f "./$mcp_filename" ]; then
        mcp_source="./$mcp_filename"
    elif [ -f "$mcp_filename" ]; then
        mcp_source="$mcp_filename"
    else
        print_error "Cannot find $mcp_filename"
        print_info "Expected in: $(pwd)/"
        print_warning "Please ensure the file is in the same directory as this script"
        return 1
    fi
    
    cp "$mcp_source" "$MCP_DIR/$mcp_filename"
    chmod +x "$MCP_DIR/$mcp_filename"
    print_success "MCP server installed: $MCP_DIR/$mcp_filename"
    
    echo ""
}

# ============================================================================
# INSTALL PYTHON DEPENDENCIES (WITH WORKAROUNDS)
# ============================================================================

install_dependencies() {
    print_header "Installing Python Dependencies"
    
    # Try to upgrade pip first
    print_info "Upgrading pip..."
    python3 -m pip install --upgrade pip --quiet 2>/dev/null || {
        print_warning "pip upgrade had issues, continuing..."
    }
    
    # For macOS with Homebrew Rust/LLVM issues, use special flags
    if [ "$OS" = "macos" ] && [ ! -z "$CRYPTOGRAPHY_DONT_BUILD_WHEEL" ]; then
        print_info "Installing mcp with pre-built wheels (avoiding Rust compilation)..."
        
        # Try pre-built wheels first
        python3 -m pip install \
            --only-binary :all: \
            --no-deps \
            mcp 2>/dev/null || {
            
            # If that fails, try with environment variables
            print_warning "Pre-built wheel unavailable, trying standard installation..."
            CRYPTOGRAPHY_DONT_BUILD_WHEEL=1 \
            CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1 \
            python3 -m pip install mcp --quiet || {
                print_error "Failed to install mcp"
                return 1
            }
        }
    else
        # Standard installation for non-macOS or systems without LLVM issues
        print_info "Installing mcp package..."
        python3 -m pip install mcp --quiet || {
            print_error "Failed to install mcp"
            return 1
        }
    fi
    
    print_success "Python dependencies installed"
    
    echo ""
}

# ============================================================================
# CONFIGURE CLAUDE DESKTOP (CORRECTED - Bug Fix #2)
# ============================================================================

configure_claude_desktop() {
    print_header "Configuring Claude Desktop"
    
    mkdir -p "$CONFIG_DIR"
    
    # FIX #2: Properly pass environment variables to Python
    # Export variables so Python subprocess can access them
    export CONFIG_FILE="$CONFIG_FILE"
    export MCP_DIR="$MCP_DIR"
    export HARNESS_DIR="$HARNESS_DIR"
    
    python3 << 'PYTHON_CONFIG_EOF'
import json
import os
from pathlib import Path

# FIX #2: Get environment variables directly from os.environ
config_file = os.environ.get("CONFIG_FILE")
mcp_dir = os.environ.get("MCP_DIR")
harness_dir = os.environ.get("HARNESS_DIR")

# Validate that variables were set
if not config_file or not mcp_dir or not harness_dir:
    print(f"Error: Environment variables not properly set")
    print(f"  CONFIG_FILE: {config_file}")
    print(f"  MCP_DIR: {mcp_dir}")
    print(f"  HARNESS_DIR: {harness_dir}")
    exit(1)

# Create config directory if needed
config_path = Path(config_file)
config_path.parent.mkdir(parents=True, exist_ok=True)

# Load existing config or create new
try:
    if config_path.exists():
        with open(config_path, 'r') as f:
            config = json.load(f)
    else:
        config = {"mcpServers": {}}
except Exception as e:
    print(f"Error reading config: {e}")
    config = {"mcpServers": {}}

# Ensure mcpServers key exists
if "mcpServers" not in config:
    config["mcpServers"] = {}

# Build full path to MCP server
harness_mcp_path = os.path.join(mcp_dir, 'harness_claude_advanced_mcp.py')

# Add Harness MCP server configuration
config["mcpServers"]["harness"] = {
    "command": "python3",
    "args": [harness_mcp_path],
    "env": {
        "HARNESS_DIR": harness_dir,
        "HARNESS_LOG_LEVEL": "INFO"
    }
}

# Write config back to file
try:
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)
    print(f"Config written successfully: {config_file}")
except Exception as e:
    print(f"Error writing config: {e}")
    exit(1)
PYTHON_CONFIG_EOF
    
    if [ $? -eq 0 ]; then
        print_success "Claude Desktop configured"
        print_info "Config file: $CONFIG_FILE"
    else
        print_error "Failed to configure Claude Desktop"
        return 1
    fi
    
    echo ""
}

# ============================================================================
# VERIFICATION
# ============================================================================

verify_installation() {
    print_header "Verifying Installation"
    
    local checks_passed=0
    local checks_total=3
    
    # Check 1: MCP server file exists
    if [ -f "$MCP_DIR/harness_claude_advanced_mcp.py" ]; then
        print_success "MCP server file"
        ((checks_passed++))
    else
        print_error "MCP server file not found at $MCP_DIR/harness_claude_advanced_mcp.py"
    fi
    
    # Check 2: Python can import mcp
    if python3 -c "import mcp" 2>/dev/null; then
        print_success "Python mcp package"
        ((checks_passed++))
    else
        print_warning "Python mcp package not importable (may need pip install or restart)"
    fi
    
    # Check 3: Claude config exists
    if [ -f "$CONFIG_FILE" ] && grep -q "harness" "$CONFIG_FILE" 2>/dev/null; then
        print_success "Claude Desktop config"
        ((checks_passed++))
    else
        print_error "Claude Desktop config not found or missing harness entry"
    fi
    
    echo ""
    echo "Verification: $checks_passed/$checks_total checks passed"
    echo ""
    
    if [ $checks_passed -lt $checks_total ]; then
        print_warning "Some checks failed - review output above"
        return 1
    fi
}

# ============================================================================
# SUMMARY AND NEXT STEPS
# ============================================================================

print_summary() {
    print_header "Installation Complete!"
    echo ""
    echo "Installation Locations:"
    print_info "MCP Server:    $MCP_DIR/harness_claude_advanced_mcp.py"
    print_info "Config File:   $CONFIG_FILE"
    echo ""
    
    echo "Next Steps:"
    print_info "1. Restart Claude Desktop completely (quit and reopen)"
    print_info "2. Open Settings > Integrations"
    print_info "3. Verify 'harness' appears in the MCP servers list"
    print_info "4. Start using Harness commands in Claude"
    echo ""
    
    echo "Example Usage in Claude:"
    print_info 'Ask: "Design a multi-agent team for content analysis"'
    print_info 'Ask: "Validate this architecture specification"'
    print_info 'Ask: "Optimize team performance"'
    echo ""
    
    echo "Documentation:"
    print_info "Main guide: /mnt/user-data/outputs/HARNESS_v3_QUICK_START.md"
    print_info "Config: $CONFIG_FILE"
    echo ""
    
    print_success "Ready to use Harness v$HARNESS_VERSION!"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    print_header "Harness v$HARNESS_VERSION - Universal Installation (CORRECTED)"
    print_info "Detected OS: $OS"
    echo ""
    
    check_prerequisites
    fix_rust_llvm_issues
    create_directories
    install_mcp_server || exit 1
    install_dependencies
    configure_claude_desktop || exit 1
    verify_installation
    print_summary
}

# Run main function
main "$@"
