#!/bin/bash

# ============================================================================
# Harness v3.0.0 - Fixed Universal Installation Script
# ============================================================================
# Fixes:
# - Uses pre-built wheels to avoid Rust/LLVM compilation
# - Proper path handling for macOS and Linux
# - Correct MCP server file locations
# - Validates Python environment before installing
# ============================================================================

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# DETECT OPERATING SYSTEM
# ============================================================================

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        # Detect if Apple Silicon or Intel
        if [[ $(uname -m) == "arm64" ]]; then
            ARCH="arm64"
        else
            ARCH="x86_64"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        ARCH=$(uname -m)
    else
        OS="unknown"
        ARCH="unknown"
    fi
}

# ============================================================================
# SETUP PATHS
# ============================================================================

setup_paths() {
    if [[ "$OS" == "macos" ]]; then
        HARNESS_DIR="$HOME/Library/Application Support/AI-Tools/harness"
        MCP_DIR="$HOME/Library/Application Support/AI-Tools/mcp"
        SKILLS_DIR="$HOME/Library/Application Support/Claude/skills"
        CONFIG_FILE="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
    elif [[ "$OS" == "linux" ]]; then
        HARNESS_DIR="$HOME/.local/share/ai-tools/harness"
        MCP_DIR="$HOME/.local/share/ai-tools/mcp"
        SKILLS_DIR="$HOME/.local/share/Claude/skills"
        CONFIG_FILE="$HOME/.config/Claude/claude_desktop_config.json"
    fi
}

# ============================================================================
# LOGGING
# ============================================================================

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

# ============================================================================
# PYTHON ENVIRONMENT VALIDATION
# ============================================================================

check_python() {
    log_info "Checking Python environment..."
    
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 not found. Please install Python 3.9+"
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    log_success "Python 3 found: $PYTHON_VERSION"
    
    # Check pip
    if ! python3 -m pip --version &> /dev/null; then
        log_error "pip not found. Installing pip..."
        python3 -m ensurepip --upgrade || {
            log_error "Failed to install pip"
            exit 1
        }
    fi
    
    log_success "pip is available"
}

# ============================================================================
# FIX RUST/LLVM ISSUE
# ============================================================================

fix_cryptography_issue() {
    log_info "Checking for Rust/LLVM compatibility issues..."
    
    # For macOS, try to resolve LLVM issues
    if [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            log_info "Detected Homebrew - checking for LLVM issues..."
            
            # Set environment variables to use pre-built wheels
            export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
            export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1
            
            log_warning "Using system OpenSSL for cryptography (avoiding Rust compilation)"
        fi
    fi
}

# ============================================================================
# CREATE DIRECTORIES
# ============================================================================

create_directories() {
    log_info "Creating installation directories..."
    
    mkdir -p "$HARNESS_DIR"
    mkdir -p "$MCP_DIR"
    mkdir -p "$SKILLS_DIR"
    mkdir -p "$(dirname "$CONFIG_FILE")"
    
    log_success "Directories created:"
    log_info "  Harness:   $HARNESS_DIR"
    log_info "  MCP:       $MCP_DIR"
    log_info "  Skills:    $SKILLS_DIR"
    log_info "  Config:    $CONFIG_FILE"
}

# ============================================================================
# COPY MCP SERVER
# ============================================================================

install_mcp_server() {
    log_info "Installing MCP server..."
    
    if [ -f "harness_claude_advanced_mcp.py" ]; then
        cp harness_claude_advanced_mcp.py "$MCP_DIR/"
        log_success "MCP server installed to $MCP_DIR/"
    elif [ -f "./harness_claude_advanced_mcp.py" ]; then
        cp ./harness_claude_advanced_mcp.py "$MCP_DIR/"
        log_success "MCP server installed to $MCP_DIR/"
    else
        log_error "harness_claude_advanced_mcp.py not found in current directory"
        log_warning "Make sure the MCP server file is in the same directory as this script"
        return 1
    fi
    
    # Make it executable
    chmod +x "$MCP_DIR/harness_claude_advanced_mcp.py"
    log_success "MCP server is executable"
}

# ============================================================================
# INSTALL PYTHON DEPENDENCIES
# ============================================================================

install_dependencies() {
    log_info "Installing Python dependencies..."
    
    # Upgrade pip first
    python3 -m pip install --upgrade pip --quiet || {
        log_warning "pip upgrade failed, continuing anyway..."
    }
    
    # Install mcp with pre-built wheels only
    log_info "Installing mcp package (pre-built wheels only)..."
    python3 -m pip install \
        --only-binary :all: \
        --no-deps \
        mcp 2>/dev/null || {
        
        # Fallback: try without restricting to pre-built wheels
        log_warning "Pre-built wheel installation failed, trying standard installation..."
        
        if [[ "$OS" == "macos" ]]; then
            # Try with environment variables set
            CRYPTOGRAPHY_DONT_BUILD_WHEEL=1 \
            CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1 \
            python3 -m pip install mcp --quiet || {
                log_error "Failed to install mcp package"
                exit 1
            }
        else
            python3 -m pip install mcp --quiet || {
                log_error "Failed to install mcp package"
                exit 1
            }
        fi
    }
    
    log_success "mcp package installed"
}

# ============================================================================
# CONFIGURE CLAUDE DESKTOP
# ============================================================================

configure_claude_desktop() {
    log_info "Configuring Claude Desktop..."
    
    # Check if config file exists
    if [ -f "$CONFIG_FILE" ]; then
        log_info "Claude Desktop config found, backing up..."
        cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
        log_success "Backup created: $CONFIG_FILE.bak"
    fi
    
    # Create or update config
    python3 << 'PYTHON_EOF'
import json
import os
from pathlib import Path

config_path = os.environ.get('CONFIG_FILE')
mcp_dir = os.environ.get('MCP_DIR')

if not config_path or not mcp_dir:
    print("Error: CONFIG_FILE or MCP_DIR not set")
    exit(1)

config_file = Path(config_path)
config_dir = config_file.parent
config_dir.mkdir(parents=True, exist_ok=True)

# Load existing config or create new one
if config_file.exists():
    with open(config_file, 'r') as f:
        config = json.load(f)
else:
    config = {"mcpServers": {}}

# Ensure mcpServers key exists
if "mcpServers" not in config:
    config["mcpServers"] = {}

# Add/update Harness MCP server
harness_mcp_path = os.path.join(mcp_dir, 'harness_claude_advanced_mcp.py')

config["mcpServers"]["harness"] = {
    "command": "python3",
    "args": [harness_mcp_path],
    "env": {
        "HARNESS_DIR": os.path.join(os.path.expanduser("~"), ".local/share/ai-tools/harness") if "linux" in os.uname().sysname.lower() else os.path.join(os.path.expanduser("~"), "Library/Application Support/AI-Tools/harness"),
        "HARNESS_LOG_LEVEL": "INFO"
    }
}

# Write config back
with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)

print(f"✓ Claude Desktop config updated: {config_file}")
print(f"  MCP Server: harness")
print(f"  Command: python3 {harness_mcp_path}")
PYTHON_EOF

    CONFIG_FILE="$CONFIG_FILE" MCP_DIR="$MCP_DIR" python3 -c "
import json
import os
from pathlib import Path

config_path = '$CONFIG_FILE'
mcp_dir = '$MCP_DIR'

config_file = Path(config_path)
config_dir = config_file.parent
config_dir.mkdir(parents=True, exist_ok=True)

if config_file.exists():
    with open(config_file, 'r') as f:
        config = json.load(f)
else:
    config = {'mcpServers': {}}

if 'mcpServers' not in config:
    config['mcpServers'] = {}

harness_mcp_path = os.path.join(mcp_dir, 'harness_claude_advanced_mcp.py')

config['mcpServers']['harness'] = {
    'command': 'python3',
    'args': [harness_mcp_path],
    'env': {
        'HARNESS_DIR': '$HARNESS_DIR',
        'HARNESS_LOG_LEVEL': 'INFO'
    }
}

with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)
" || {
        log_error "Failed to configure Claude Desktop"
        return 1
    }
    
    log_success "Claude Desktop configured"
    log_info "Config file: $CONFIG_FILE"
}

# ============================================================================
# VERIFY INSTALLATION
# ============================================================================

verify_installation() {
    log_info "Verifying installation..."
    
    local all_good=true
    
    # Check MCP server file
    if [ -f "$MCP_DIR/harness_claude_advanced_mcp.py" ]; then
        log_success "MCP server found: $MCP_DIR/harness_claude_advanced_mcp.py"
    else
        log_error "MCP server not found"
        all_good=false
    fi
    
    # Check Python can import mcp
    if python3 -c "import mcp" 2>/dev/null; then
        log_success "mcp Python package installed and importable"
    else
        log_warning "mcp Python package not importable (may need restart)"
    fi
    
    # Check config file
    if [ -f "$CONFIG_FILE" ]; then
        log_success "Claude Desktop config found: $CONFIG_FILE"
    else
        log_error "Claude Desktop config not found"
        all_good=false
    fi
    
    if [ "$all_good" = true ]; then
        log_success "Installation verified!"
        return 0
    else
        log_warning "Some checks failed, but installation may still work"
        return 1
    fi
}

# ============================================================================
# MAIN INSTALLATION FLOW
# ============================================================================

main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║         Harness v3.0.0 - Fixed Universal Installation         ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    detect_os
    log_info "Detected OS: $OS ($ARCH)"
    echo ""
    
    setup_paths
    log_info "Installation paths configured"
    echo ""
    
    check_python
    echo ""
    
    create_directories
    echo ""
    
    fix_cryptography_issue
    echo ""
    
    install_mcp_server
    echo ""
    
    install_dependencies
    echo ""
    
    configure_claude_desktop
    echo ""
    
    verify_installation
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                  Installation Complete!                        ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Next steps:"
    echo "  1. Restart Claude Desktop (if open)"
    echo "  2. Check Settings > Integrations to confirm Harness is listed"
    echo "  3. Run: harness_status() to verify connection"
    echo ""
}

main "$@"
