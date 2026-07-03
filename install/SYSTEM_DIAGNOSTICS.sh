#!/bin/bash
# SYSTEM_DIAGNOSTICS.sh
# Comprehensive Harness v3.0.0 environment audit
# Detects Python, Rust, LLVM, Node.js, PEP 668, virtualenv, and configuration issues
# Exit code 0 = all systems nominal; non-zero = issues detected

set -e
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
DIAGNOSTICS_LOG="/tmp/harness_diagnostics_${TIMESTAMP// /_}.log"

echo "🔍 HARNESS v3.0.0 SYSTEM DIAGNOSTICS" | tee "$DIAGNOSTICS_LOG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$DIAGNOSTICS_LOG"
echo "Timestamp: $TIMESTAMP" | tee -a "$DIAGNOSTICS_LOG"
echo "Hostname: $(hostname)" | tee -a "$DIAGNOSTICS_LOG"
echo "macOS: $(sw_vers -productVersion)" | tee -a "$DIAGNOSTICS_LOG"
echo "Arch: $(uname -m)" | tee -a "$DIAGNOSTICS_LOG"
echo "Log: $DIAGNOSTICS_LOG" | tee -a "$DIAGNOSTICS_LOG"
echo "" | tee -a "$DIAGNOSTICS_LOG"

ISSUE_COUNT=0
WARNING_COUNT=0

# Helper functions
log_section() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$DIAGNOSTICS_LOG"
    echo "📋 $1" | tee -a "$DIAGNOSTICS_LOG"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$DIAGNOSTICS_LOG"
}

log_pass() {
    echo "✅ $1" | tee -a "$DIAGNOSTICS_LOG"
}

log_warn() {
    echo "⚠️  $1" | tee -a "$DIAGNOSTICS_LOG"
    ((WARNING_COUNT++))
}

log_fail() {
    echo "❌ $1" | tee -a "$DIAGNOSTICS_LOG"
    ((ISSUE_COUNT++))
}

log_info() {
    echo "ℹ️  $1" | tee -a "$DIAGNOSTICS_LOG"
}

# ════════════════════════════════════════════════════════════════
# PYTHON DIAGNOSTICS
# ════════════════════════════════════════════════════════════════

log_section "PYTHON ENVIRONMENT"

# Check primary Python
if command -v python3 &>/dev/null; then
    PY3_PATH=$(command -v python3)
    PY3_VERSION=$(python3 --version 2>&1)
    log_pass "python3 found: $PY3_PATH"
    log_info "Version: $PY3_VERSION"
else
    log_fail "python3 not found in PATH"
fi

# Check secondary Python paths
PYTHON_PATHS=(
    "/opt/local/bin/python3"
    "/usr/local/bin/python3"
    "$(brew --prefix python@3.13 2>/dev/null)/bin/python3"
    "$(brew --prefix python@3.12 2>/dev/null)/bin/python3"
    "$HOME/.pyenv/versions/*/bin/python3"
)

log_info "Alternative Python paths:"
for path in "${PYTHON_PATHS[@]}"; do
    if [ -x "$path" ]; then
        version=$("$path" --version 2>&1)
        log_pass "  $path: $version"
    fi
done

# Check pip
if command -v pip3 &>/dev/null; then
    PIP_PATH=$(command -v pip3)
    PIP_VERSION=$(pip3 --version 2>&1)
    log_pass "pip3 found: $PIP_PATH"
    log_info "Details: $PIP_VERSION"
else
    log_fail "pip3 not found in PATH"
fi

# Check for PEP 668
log_info "Checking PEP 668 status..."
if python3 -m pip install --dry-run fake-package 2>&1 | grep -q "externally-managed-environment"; then
    log_warn "PEP 668 ACTIVE: pip install blocked at system level"
    log_info "RESOLUTION OPTIONS:"
    log_info "  1. Use virtual environment: python3 -m venv ~/harness_venv"
    log_info "  2. Use --break-system-packages: pip3 install --break-system-packages --user mcp"
    log_info "  3. Run QUICK_FIX_INSTALL_NOW.sh or VENV_SETUP_RECOMMENDED.sh"
else
    log_pass "PEP 668 not active (system pip install allowed)"
fi

# Check Python package manager
log_info "Checking for venv support..."
if python3 -m venv --help &>/dev/null; then
    log_pass "venv module available"
else
    log_warn "venv module not available"
fi

# Check if virtualenv installed
if python3 -m virtualenv --version &>/dev/null; then
    log_pass "virtualenv package installed"
else
    log_warn "virtualenv package not installed (optional)"
fi

# ════════════════════════════════════════════════════════════════
# RUST & CARGO
# ════════════════════════════════════════════════════════════════

log_section "RUST TOOLCHAIN"

if command -v rustc &>/dev/null; then
    RUSTC_VERSION=$(rustc --version 2>&1)
    log_pass "rustc found"
    log_info "$RUSTC_VERSION"
else
    log_fail "rustc not found"
fi

if command -v cargo &>/dev/null; then
    CARGO_PATH=$(command -v cargo)
    CARGO_VERSION=$(cargo --version 2>&1)
    log_pass "cargo found: $CARGO_PATH"
    log_info "$CARGO_VERSION"
else
    log_fail "cargo not found in PATH"
fi

# Check Rust target
if command -v rustc &>/dev/null; then
    RUST_TARGET=$(rustc --print cfg 2>&1 | grep target_arch | head -1)
    log_info "Rust target: $RUST_TARGET"
fi

# Check for Rust nightly (required by some builds)
if rustup toolchain list 2>/dev/null | grep -q "nightly"; then
    log_pass "Rust nightly toolchain installed"
else
    log_warn "Rust nightly not installed (may be needed for some features)"
fi

# ════════════════════════════════════════════════════════════════
# LLVM & CLANG
# ════════════════════════════════════════════════════════════════

log_section "LLVM & CLANG"

if command -v clang &>/dev/null; then
    CLANG_PATH=$(command -v clang)
    CLANG_VERSION=$(clang --version 2>&1 | head -1)
    log_pass "clang found: $CLANG_PATH"
    log_info "$CLANG_VERSION"
else
    log_warn "clang not found (required for cryptography builds)"
fi

# Check Homebrew LLVM
if [ -d "/usr/local/Cellar/llvm" ]; then
    LLVM_VERSIONS=$(ls /usr/local/Cellar/llvm 2>/dev/null || echo "none")
    log_info "Homebrew LLVM versions: $LLVM_VERSIONS"
fi

# Check system LLVM
if [ -d "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain" ]; then
    log_pass "Xcode LLVM toolchain available"
fi

# ════════════════════════════════════════════════════════════════
# NODE.JS & NPM
# ════════════════════════════════════════════════════════════════

log_section "NODE.JS ENVIRONMENT"

if command -v node &>/dev/null; then
    NODE_VERSION=$(node --version 2>&1)
    log_pass "node found"
    log_info "$NODE_VERSION"
else
    log_warn "node not found (needed for some build tools)"
fi

if command -v npm &>/dev/null; then
    NPM_VERSION=$(npm --version 2>&1)
    log_pass "npm found"
    log_info "npm version $NPM_VERSION"
else
    log_warn "npm not found"
fi

if command -v nvm &>/dev/null; then
    log_pass "nvm (Node Version Manager) available"
fi

# ════════════════════════════════════════════════════════════════
# XCODE & BUILD TOOLS
# ════════════════════════════════════════════════════════════════

log_section "XCODE & BUILD TOOLS"

if command -v xcode-select &>/dev/null; then
    XCODE_PATH=$(xcode-select -p 2>&1)
    log_pass "Xcode Command Line Tools installed"
    log_info "Path: $XCODE_PATH"
else
    log_fail "Xcode Command Line Tools not found"
fi

if [ -d "/Applications/Xcode.app" ]; then
    XCODE_VERSION=$(mdls -name kMDItemVersion /Applications/Xcode.app 2>/dev/null | cut -d' ' -f3)
    log_pass "Xcode.app installed: version $XCODE_VERSION"
else
    log_warn "Xcode.app not installed (development only)"
fi

# ════════════════════════════════════════════════════════════════
# HARNESS INSTALLATION STATE
# ════════════════════════════════════════════════════════════════

log_section "HARNESS INSTALLATION"

HARNESS_MCP_DIR="$HOME/Library/Application Support/AI-Tools/mcp"
HARNESS_CONFIG_DIR="$HOME/Library/Application Support/AI-Tools/harness"
HARNESS_VENV="$HOME/harness_venv"

if [ -d "$HARNESS_MCP_DIR" ]; then
    log_pass "Harness MCP directory exists: $HARNESS_MCP_DIR"
    if [ -f "$HARNESS_MCP_DIR/harness_claude_advanced_mcp.py" ]; then
        log_pass "MCP server script found"
    else
        log_warn "MCP server script not found"
    fi
else
    log_info "Harness MCP directory not yet created"
fi

if [ -d "$HARNESS_CONFIG_DIR" ]; then
    log_pass "Harness config directory exists: $HARNESS_CONFIG_DIR"
else
    log_info "Harness config directory not yet created"
fi

if [ -d "$HARNESS_VENV" ]; then
    log_pass "Harness virtualenv found: $HARNESS_VENV"
    if [ -f "$HARNESS_VENV/bin/python3" ]; then
        VENV_PY_VERSION=$("$HARNESS_VENV/bin/python3" --version 2>&1)
        log_pass "Virtualenv Python: $VENV_PY_VERSION"
    fi
else
    log_info "Harness virtualenv not yet created"
fi

# ════════════════════════════════════════════════════════════════
# CLAUDE DESKTOP CONFIGURATION
# ════════════════════════════════════════════════════════════════

log_section "CLAUDE DESKTOP CONFIGURATION"

CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

if [ -f "$CLAUDE_CONFIG" ]; then
    log_pass "Claude Desktop config found: $CLAUDE_CONFIG"
    
    if grep -q "harness" "$CLAUDE_CONFIG"; then
        log_pass "Harness MCP configured in claude_desktop_config.json"
        
        # Extract Python command
        if grep -q "python3" "$CLAUDE_CONFIG"; then
            PYTHON_CMD=$(grep -A5 '"command"' "$CLAUDE_CONFIG" | grep -o 'python[^"]*' | head -1)
            log_info "Configured Python: $PYTHON_CMD"
        fi
    else
        log_warn "Harness MCP NOT configured in claude_desktop_config.json"
        log_info "Run QUICK_FIX_INSTALL_NOW.sh or VENV_SETUP_RECOMMENDED.sh to configure"
    fi
else
    log_info "Claude Desktop config not yet created"
fi

# ════════════════════════════════════════════════════════════════
# MCP DEPENDENCIES
# ════════════════════════════════════════════════════════════════

log_section "MCP PYTHON DEPENDENCIES"

REQUIRED_PACKAGES=(
    "anthropic"
    "pydantic"
    "aiohttp"
)

for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if python3 -m pip show "$pkg" &>/dev/null 2>&1; then
        VERSION=$(python3 -m pip show "$pkg" 2>/dev/null | grep Version | cut -d' ' -f2)
        log_pass "$pkg installed (v$VERSION)"
    else
        log_warn "$pkg NOT installed"
    fi
done

# ════════════════════════════════════════════════════════════════
# ENVIRONMENT VARIABLES
# ════════════════════════════════════════════════════════════════

log_section "ENVIRONMENT VARIABLES"

log_info "PATH:"
echo "$PATH" | tr ':' '\n' | sed 's/^/  /' | tee -a "$DIAGNOSTICS_LOG"

if [ -n "$HARNESS_DIR" ]; then
    log_pass "HARNESS_DIR set: $HARNESS_DIR"
else
    log_info "HARNESS_DIR not set"
fi

if [ -n "$CONFIG_FILE" ]; then
    log_pass "CONFIG_FILE set: $CONFIG_FILE"
else
    log_info "CONFIG_FILE not set"
fi

# ════════════════════════════════════════════════════════════════
# SUMMARY
# ════════════════════════════════════════════════════════════════

log_section "DIAGNOSTIC SUMMARY"

echo "" | tee -a "$DIAGNOSTICS_LOG"
echo "📊 Results:" | tee -a "$DIAGNOSTICS_LOG"
echo "   Issues found: $ISSUE_COUNT" | tee -a "$DIAGNOSTICS_LOG"
echo "   Warnings: $WARNING_COUNT" | tee -a "$DIAGNOSTICS_LOG"
echo "" | tee -a "$DIAGNOSTICS_LOG"

if [ $ISSUE_COUNT -eq 0 ]; then
    if [ $WARNING_COUNT -eq 0 ]; then
        log_pass "✨ All systems nominal!"
        EXIT_CODE=0
    else
        log_warn "System ready with minor warnings"
        EXIT_CODE=1
    fi
else
    log_fail "⚠️  Critical issues detected"
    EXIT_CODE=2
fi

echo "" | tee -a "$DIAGNOSTICS_LOG"
echo "Full diagnostics saved to: $DIAGNOSTICS_LOG" | tee -a "$DIAGNOSTICS_LOG"
echo "Review with: cat $DIAGNOSTICS_LOG" | tee -a "$DIAGNOSTICS_LOG"

exit $EXIT_CODE
