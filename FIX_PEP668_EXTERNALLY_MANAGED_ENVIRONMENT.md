# FIX: PEP 668 Externally-Managed-Environment Error

## Problem Analysis

**Error**: `error: externally-managed-environment`  
**Source**: Homebrew Python enforcing PEP 668 isolation  
**Impact**: 🔴 pip install completely blocked system-wide  
**Status**: NEW BUG (environment-specific to Homebrew Python)

---

## Root Cause

```
Homebrew Python (from `brew install python@3.x`)
    ↓
Enforces PEP 668 (Python Enhancement Proposal 668)
    ↓
Prevents pip from installing packages globally
    ↓
Error: "This environment is externally managed"
    ↓
Installation blocked
```

**Why**: Homebrew protects system Python from pip conflicts. This is intentional security.

---

## Solution #1: Virtual Environment (RECOMMENDED ✅)

**Pros**: Cleanest, most portable, industry standard  
**Cons**: Requires one-time setup  
**Time**: ~2 minutes  

### Step 1: Create Virtual Environment

```bash
python3 -m venv ~/harness_venv
```

### Step 2: Activate Virtual Environment

```bash
source ~/harness_venv/bin/activate
```

You should see `(harness_venv)` in your terminal prompt.

### Step 3: Upgrade pip (in venv)

```bash
pip install --upgrade pip
```

### Step 4: Install MCP (in venv)

```bash
pip install mcp
```

### Step 5: Modify Claude Desktop Config

Update the path to use the venv Python:

**File**: `~/.config/Claude/claude_desktop_config.json` OR `~/Library/Application Support/Claude/claude_desktop_config.json`

**Change from**:
```json
{
  "mcpServers": {
    "harness": {
      "command": "python3",
      ...
```

**Change to**:
```json
{
  "mcpServers": {
    "harness": {
      "command": "/Users/johndoe/harness_venv/bin/python3",
      "args": ["/Users/johndoe/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"],
      ...
```

**Important**: Replace `/Users/johndoe/` with your actual username.

### Step 6: Verify venv Installation

```bash
# While venv is active:
python3 -c "import mcp; print('✓ MCP installed in venv')"

# Deactivate when done (optional):
deactivate
```

### Step 7: Restart Claude Desktop

```bash
killall Claude
open /Applications/Claude.app
```

**Result**: Claude uses the venv Python which has mcp installed.

---

## Solution #2: --break-system-packages (QUICK FIX)

**Pros**: Fastest, no venv setup  
**Cons**: Bypasses safety check (use with caution)  
**Safety**: Use `--user` flag to limit scope  
**Time**: ~30 seconds  

### Step 1: Install with --break-system-packages + --user

```bash
python3 -m pip install --break-system-packages --user mcp
```

**What this does**:
- `--break-system-packages` overrides PEP 668 restriction
- `--user` limits installation to user directory only (safe)
- Installs mcp to `~/.local/lib/python3.x/site-packages/`

### Step 2: Verify Installation

```bash
python3 -c "import mcp; print('✓ MCP installed')"
```

### Step 3: Restart Claude Desktop

```bash
killall Claude
open /Applications/Claude.app
```

**Result**: mcp is installed and available globally to Claude.

---

## Solution #3: pipx (For Python Applications)

**Pros**: Purpose-built for Python CLI tools  
**Cons**: More complex, overkill for library use  
**Time**: ~3 minutes  

### Step 1: Install pipx (if not present)

```bash
brew install pipx
pipx ensurepath
```

### Step 2: Install MCP via pipx

```bash
pipx install mcp
```

### Step 3: Verify

```bash
which mcp
python3 -c "import mcp; print('✓')"
```

### Step 4: Update Claude Config (if needed)

May need to use pipx-managed Python path.

**Result**: mcp installed in isolated pipx environment.

---

## Recommended Installation Path (ALL SOLUTIONS)

### Quick Setup Flow

**For fastest resolution**: Use **Solution #2** (--break-system-packages)

```bash
# 1. Set environment variables
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1

# 2. Install mcp with safety flags
python3 -m pip install --break-system-packages --user mcp

# 3. Verify
python3 -c "import mcp; print('✓ MCP ready')"

# 4. Run Harness install (will use existing MCP)
cd ~/Harness
bash install_harness_v3_corrected.sh

# 5. Restart Claude
killall Claude && open /Applications/Claude.app
```

**Total time**: ~1 minute

---

## For Production / Team Deployment: Use Solution #1 (Virtual Environment)

```bash
# Create shared venv
python3 -m venv ~/harness_venv

# Activate
source ~/harness_venv/bin/activate

# Install everything in venv
pip install --upgrade pip
pip install mcp

# Configure Claude to use venv Python
# (update claude_desktop_config.json with venv path)

# Deactivate when done
deactivate
```

**Benefits**: 
- Isolated from system Python
- Reproducible across machines
- No system modifications
- Easy to remove (just delete directory)

---

## Troubleshooting Each Solution

### Solution #1 Troubleshooting (venv)

**Problem**: `command not found: python3` after activation  
**Fix**: `which python3` should show venv path; if not, use `source ~/harness_venv/bin/activate` again

**Problem**: `import mcp` fails inside venv  
**Fix**: Verify: `pip list | grep mcp` should show mcp package

**Problem**: Claude config path not found  
**Fix**: Try both locations:
```bash
ls ~/.config/Claude/claude_desktop_config.json
ls ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

### Solution #2 Troubleshooting (--break-system-packages)

**Problem**: Error still shows after --break-system-packages  
**Fix**: Make sure you're using correct syntax:
```bash
# CORRECT:
python3 -m pip install --break-system-packages --user mcp

# WRONG (missing flags):
python3 -m pip install mcp
```

**Problem**: `import mcp` fails  
**Fix**: Verify user install path:
```bash
python3 -m site --user-site
ls ~/.local/lib/python3.*/site-packages/ | grep mcp
```

### Solution #3 Troubleshooting (pipx)

**Problem**: `pipx: command not found`  
**Fix**: Install pipx first: `brew install pipx`

**Problem**: MCP not importable  
**Fix**: pipx creates isolated environments; use pipx-managed Python:
```bash
pipx run python3 -c "import mcp"
```

---

## Updated Installation Script Fix

The main `install_harness_v3_corrected.sh` needs this patch:

```bash
# ADD THIS SECTION after pip detection:

echo "═════════════════════════════════════════════════════"
echo "Detecting pip environment type..."
echo "═════════════════════════════════════════════════════"

# Check if Homebrew Python (PEP 668 enforced)
if python3 -c "import sys; sys.exit(0 if '/usr/local/opt/python' in sys.prefix or 'Homebrew' in sys.prefix else 1)" 2>/dev/null; then
    echo "! Homebrew Python detected (PEP 668 enforced)"
    echo ""
    echo "  Solution: Use virtual environment OR --break-system-packages"
    echo ""
    echo "  Option A (Recommended): Virtual Environment"
    echo "    python3 -m venv ~/harness_venv"
    echo "    source ~/harness_venv/bin/activate"
    echo "    pip install mcp"
    echo "    # Update claude_desktop_config.json with venv path"
    echo ""
    echo "  Option B (Quick): --break-system-packages"
    echo "    python3 -m pip install --break-system-packages --user mcp"
    echo ""
    echo "  Option C (Advanced): pipx"
    echo "    brew install pipx"
    echo "    pipx install mcp"
    echo ""
    exit 1
fi

# If MacPorts Python (no PEP 668):
if python3 -c "import sys; sys.exit(0 if '/opt/local' in sys.prefix else 1)" 2>/dev/null; then
    echo "✓ MacPorts Python detected (no PEP 668 restriction)"
    python3 -m pip install mcp
fi
```

---

## Permanent Fix: Edit pip.conf (Optional)

To make `--break-system-packages` permanent (not recommended but possible):

```bash
# Create/edit pip config
nano ~/.config/pip/pip.conf

# Add this section:
[global]
break-system-packages = true
```

**Warning**: Only do this if you understand the implications.

---

## Environment Detection Comparison

| Environment | Python Source | PEP 668 | Solution |
|-------------|---------------|---------|----------|
| MacPorts | `/opt/local/bin/python3` | ❌ No | Direct pip install works |
| Homebrew | `/usr/local/opt/python@3.x/bin/python3` | ✅ Yes | Use venv or --break-system-packages |
| System | `/usr/bin/python3` | ✅ Yes (Monterey+) | Use venv or --break-system-packages |
| pyenv | `~/.pyenv/versions/*/bin/python3` | ❌ No | Direct pip install works |
| Conda | `~/miniconda3/bin/python3` | ❌ No | Direct pip install works |

---

## User's Current Situation

```
System: macOS (Homebrew environment)
Python: /usr/local/opt/python@3.x/bin/python3
Status: PEP 668 enforced ✅
Fix: Need venv OR --break-system-packages
```

---

## Step-by-Step Recovery (For User)

### IMMEDIATE ACTION (Choose one):

**Option A (Best for long-term)**:
```bash
# 1. Create venv
python3 -m venv ~/harness_venv

# 2. Activate
source ~/harness_venv/bin/activate

# 3. Install
pip install mcp

# 4. Run Harness install
cd ~/Harness
bash install_harness_v3_corrected.sh

# 5. Update config with venv path

# 6. Restart Claude
killall Claude && open /Applications/Claude.app
```

**Option B (Fastest)**:
```bash
# 1. Install with safety flags
python3 -m pip install --break-system-packages --user mcp

# 2. Run Harness install
cd ~/Harness
bash install_harness_v3_corrected.sh

# 3. Restart Claude
killall Claude && open /Applications/Claude.app
```

---

## Why This Happened

This is **NOT a bug in the script** — it's an **environment difference**:

- **Previous session environment**: MacPorts Python (`/opt/local/bin/python3`)
  - MacPorts doesn't enforce PEP 668
  - pip install worked directly

- **Current session environment**: Homebrew Python  
  - Homebrew enforces PEP 668
  - pip install blocked globally

The script correctly detected this but needs a user decision on how to proceed.

---

## Updated SKILL.md Entry

Add to troubleshooting section:

### Error: "error: externally-managed-environment"

**Root Cause**: Homebrew Python enforces PEP 668, blocking system-wide pip installs

**Fix Option A (Recommended)**: Virtual Environment
```bash
python3 -m venv ~/harness_venv
source ~/harness_venv/bin/activate
pip install mcp
# Update claude_desktop_config.json with venv Python path
```

**Fix Option B (Quick)**: Use --break-system-packages
```bash
python3 -m pip install --break-system-packages --user mcp
```

**Fix Option C (Advanced)**: Use pipx
```bash
brew install pipx
pipx install mcp
```

---

## Summary

| Issue | Cause | Fix | Time |
|-------|-------|-----|------|
| PEP 668 error | Homebrew Python isolation | Use venv or --break-system-packages | 1-2 min |
| Global pip blocked | Security by Homebrew | Virtual environment (recommended) | 2 min |
| System package conflict | No isolation | Use --break-system-packages --user | 30 sec |

**Recommendation**: Use **virtual environment (Option A)** for production, **--break-system-packages (Option B)** for quick testing.
