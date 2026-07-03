#!/usr/bin/env bash

# ============================================================================
# Harness v3.0.0 - Installation Verification Script
# ============================================================================
# Run this AFTER installation to verify everything is working correctly
# ============================================================================

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CHECKS_PASSED=0
CHECKS_TOTAL=0
WARNINGS=0

# Helper functions
print_check() {
    echo -e "${BLUE}→${NC} $1"
}

print_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((CHECKS_PASSED++))
    ((CHECKS_TOTAL++))
}

print_fail() {
    echo -e "${RED}✗${NC} $1"
    ((CHECKS_TOTAL++))
}

print_warn() {
    echo -e "${YELLOW}!${NC} $1"
    ((WARNINGS++))
}

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

# ============================================================================
# CHECKS
# ============================================================================

check_mcp_server_file() {
    print_header "Check 1: MCP Server File"
    
    local mcp_path="$HOME/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"
    
    print_check "Looking for MCP server at: $mcp_path"
    
    if [ -f "$mcp_path" ]; then
        print_pass "MCP server file exists"
        
        if [ -x "$mcp_path" ]; then
            print_pass "MCP server is executable"
        else
            print_warn "MCP server exists but is not executable (may still work)"
        fi
    else
        print_fail "MCP server file not found"
        echo "    Expected: $mcp_path"
        return 1
    fi
}

check_python_environment() {
    print_header "Check 2: Python Environment"
    
    print_check "Checking Python 3..."
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version 2>&1)
        print_pass "Python 3 found: $PYTHON_VERSION"
    else
        print_fail "Python 3 not found"
        echo "    Please install Python 3"
        return 1
    fi
    
    print_check "Checking pip..."
    if python3 -m pip --version &> /dev/null; then
        PIP_VERSION=$(python3 -m pip --version)
        print_pass "pip found: $PIP_VERSION"
    else
        print_fail "pip not found or not working"
        return 1
    fi
}

check_mcp_package() {
    print_header "Check 3: Python MCP Package"
    
    print_check "Attempting: import mcp"
    
    if python3 -c "import mcp" 2>/dev/null; then
        print_pass "mcp package is importable"
        
        # Try to get version
        if python3 -c "import importlib.metadata; print(importlib.metadata.version('mcp'))" 2>/dev/null; then
            MCP_VERSION=$(python3 -c "import importlib.metadata; print(importlib.metadata.version('mcp'))" 2>/dev/null)
            print_pass "mcp version: $MCP_VERSION"
        fi
    else
        print_warn "mcp package not importable (may need to run: python3 -m pip install mcp)"
        return 1
    fi
}

check_claude_config() {
    print_header "Check 4: Claude Desktop Configuration"
    
    local config_file="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
    
    print_check "Looking for config file: $config_file"
    
    if [ -f "$config_file" ]; then
        print_pass "Config file exists"
        
        print_check "Checking for harness MCP server entry..."
        if grep -q '"harness"' "$config_file" 2>/dev/null; then
            print_pass "harness entry found in config"
            
            # Try to validate JSON
            if python3 -c "import json; json.load(open('$config_file'))" 2>/dev/null; then
                print_pass "Config JSON is valid"
            else
                print_fail "Config JSON is malformed"
                return 1
            fi
        else
            print_fail "harness entry not found in config"
            echo "    Config may not have been updated correctly"
            return 1
        fi
    else
        print_fail "Config file not found"
        echo "    Expected: $config_file"
        return 1
    fi
}

check_claude_desktop_running() {
    print_header "Check 5: Claude Desktop Status"
    
    if pgrep -f "Claude" > /dev/null 2>&1; then
        print_warn "Claude Desktop is running"
        echo "    You may need to restart it for changes to take effect"
        echo "    Restart by: Quit Claude completely, then reopen"
    else
        print_pass "Claude Desktop is not running (good for installation)"
    fi
}

check_configuration_details() {
    print_header "Check 6: Configuration Details"
    
    local config_file="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
    
    if [ -f "$config_file" ]; then
        print_check "Claude config contents:"
        echo ""
        python3 -m json.tool < "$config_file" 2>/dev/null | head -30
        echo ""
    fi
}

check_permissions() {
    print_header "Check 7: File Permissions"
    
    local mcp_dir="$HOME/Library/Application Support/AI-Tools/mcp"
    
    print_check "Checking directory permissions: $mcp_dir"
    
    if [ -d "$mcp_dir" ]; then
        print_pass "MCP directory exists"
        
        # Check if we can read/write
        if [ -r "$mcp_dir" ] && [ -w "$mcp_dir" ]; then
            print_pass "MCP directory is readable and writable"
        else
            print_warn "MCP directory has permission issues"
        fi
        
        # List contents
        print_check "Contents of $mcp_dir:"
        ls -la "$mcp_dir" 2>/dev/null | tail -n +2
    else
        print_fail "MCP directory does not exist"
        return 1
    fi
}

check_system_info() {
    print_header "Check 8: System Information"
    
    print_check "Operating System:"
    uname -a
    
    print_check "Python Path:"
    which python3
    
    print_check "Homebrew Status (if available):"
    if command -v brew &> /dev/null; then
        brew --version
        
        # Check for Rust and LLVM
        if brew list rust &>/dev/null 2>&1; then
            print_warn "Homebrew Rust detected (may have LLVM compatibility issues)"
            echo "    If you see 'mcp' installation errors, try: brew reinstall rust"
        fi
    else
        echo "    Homebrew not found"
    fi
}

# ============================================================================
# FINAL SUMMARY
# ============================================================================

print_summary() {
    print_header "Installation Verification Summary"
    
    local percentage=$((($CHECKS_PASSED * 100) / $CHECKS_TOTAL))
    
    echo "Results: $CHECKS_PASSED/$CHECKS_TOTAL checks passed ($percentage%)"
    echo ""
    
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}Warnings: $WARNINGS (see above)${NC}"
    fi
    echo ""
    
    if [ $CHECKS_PASSED -eq $CHECKS_TOTAL ]; then
        echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}  ✓ Installation appears to be working correctly!${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
        echo ""
        echo "Next steps:"
        echo "  1. Restart Claude Desktop if it's running"
        echo "  2. Go to Settings > Integrations"
        echo "  3. Verify 'harness [Connected]' appears in MCP Servers"
        echo "  4. Try a Harness command in Claude:"
        echo "     'Design a multi-agent team for content analysis'"
        return 0
    else
        echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
        echo -e "${RED}  ✗ Some checks failed - see details above${NC}"
        echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
        echo ""
        echo "Troubleshooting steps:"
        echo "  1. See HARNESS_v3_INSTALLATION_FIX_GUIDE.md for detailed help"
        echo "  2. Check the error messages above for what's missing"
        echo "  3. Run the corrected installation script again:"
        echo "     bash install_harness_v3_corrected.sh"
        return 1
    fi
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Harness v3.0.0 - Installation Verification Script   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    check_mcp_server_file
    check_python_environment
    check_mcp_package
    check_claude_config
    check_claude_desktop_running
    check_configuration_details
    check_permissions
    check_system_info
    
    print_summary
}

# Run
main "$@"
