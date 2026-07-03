#!/usr/bin/env bash

# ============================================================================
# Harness v3.0.0 - Quick Fix Commands
# ============================================================================
# Copy and paste these commands to fix installation issues
# ============================================================================

echo "═══════════════════════════════════════════════════════════"
echo "Harness v3.0.0 - Quick Fix Commands"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ============================================================================
# OPTION 1: Run the corrected installation script (RECOMMENDED)
# ============================================================================

echo "OPTION 1: Run Corrected Installation Script (RECOMMENDED)"
echo "───────────────────────────────────────────────────────────"
echo ""
echo "# Step 1: Copy the corrected script and MCP server file"
echo "cd ~"
echo "cp /mnt/user-data/outputs/install_harness_v3_corrected.sh ."
echo "cp /mnt/user-data/outputs/harness_claude_advanced_mcp.py ."
echo ""
echo "# Step 2: Run the corrected script"
echo "bash install_harness_v3_corrected.sh"
echo ""
echo "# Step 3: Restart Claude Desktop and verify"
echo ""
echo ""

# ============================================================================
# OPTION 2: Quick manual fix for cryptography compilation issue
# ============================================================================

echo "OPTION 2: Fix Cryptography Compilation Issue (macOS)"
echo "───────────────────────────────────────────────────────────"
echo ""
echo "# If pip install mcp fails with Rust errors, run this:"
echo ""
echo "export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1"
echo "export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1"
echo ""
echo "python3 -m pip install --upgrade pip"
echo "python3 -m pip install mcp"
echo ""
echo "# Or use pre-built wheels only:"
echo "python3 -m pip install --only-binary :all: --no-deps mcp"
echo ""
echo ""

# ============================================================================
# OPTION 3: Fix underlying Rust/LLVM issue
# ============================================================================

echo "OPTION 3: Fix Underlying Rust/LLVM Incompatibility (macOS)"
echo "───────────────────────────────────────────────────────────"
echo ""
echo "# Reinstall Rust to match current LLVM"
echo "brew reinstall rust"
echo ""
echo "# Then retry:"
echo "python3 -m pip install mcp"
echo ""
echo ""

# ============================================================================
# OPTION 4: Verify installation
# ============================================================================

echo "VERIFICATION COMMANDS"
echo "───────────────────────────────────────────────────────────"
echo ""
echo "# 1. Check MCP server file exists"
echo "ls -la ~/Library/Application\\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"
echo ""
echo "# 2. Check Python can import mcp"
echo "python3 -c \"import mcp; print('✓ mcp installed')\""
echo ""
echo "# 3. Check Claude config"
echo "cat ~/Library/Application\\ Support/Claude/claude_desktop_config.json | python3 -m json.tool"
echo ""
echo "# 4. Restart Claude Desktop and check Settings > Integrations"
echo "# You should see 'harness [Connected]'"
echo ""
echo ""

# ============================================================================
# OPTION 5: Full diagnostic
# ============================================================================

echo "DIAGNOSTICS"
echo "───────────────────────────────────────────────────────────"
echo ""
echo "# System info"
echo "uname -a"
echo "python3 --version"
echo "which python3"
echo ""
echo "# Installation paths"
echo "echo \"MCP Server: ~/Library/Application Support/AI-Tools/mcp/\""
echo "echo \"Config: ~/Library/Application Support/Claude/claude_desktop_config.json\""
echo ""
echo "# Check Homebrew Rust/LLVM"
echo "brew list | grep -E 'rust|llvm'"
echo "ls -la $(brew --prefix rust)/lib 2>/dev/null | grep rustc_driver"
echo "ls -la $(brew --prefix llvm)/lib 2>/dev/null | grep libLLVM"
echo ""
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "For detailed guide, see:"
echo "  /mnt/user-data/outputs/HARNESS_v3_INSTALLATION_FIX_GUIDE.md"
echo "═══════════════════════════════════════════════════════════"
