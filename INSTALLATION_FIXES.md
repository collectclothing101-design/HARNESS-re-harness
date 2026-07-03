# Harness v3.0.0 Installation - Troubleshooting & Fixes

## Issues Encountered

Your installation encountered three common macOS issues. This guide fixes all of them.

---

## Issue #1: Cryptography Compilation Failure (Rust/LLVM Mismatch)

### Symptoms
```
error: Symbol not found: __ZN4llvm10PGOOptionsC1E...
Error running maturin: Command 'maturin pep517 write-dist-info' returned non-zero exit status 1
```

### Root Cause
Homebrew Rust and LLVM versions are incompatible. The `cryptography` package tries to compile from source and fails.

### Fix: Use Pre-Built Wheels

**Option A: Use the Fixed Installation Script (Recommended)**

```bash
# Download the fixed script
cd ~/Downloads
curl -O https://your-download-link/install_harness_fixed.sh
chmod +x install_harness_fixed.sh

# Run it
./install_harness_fixed.sh
```

**Option B: Manual Installation (If Option A fails)**

```bash
# 1. Set environment variables to use system OpenSSL
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1

# 2. Install mcp with pre-built wheels only
python3 -m pip install --only-binary :all: --no-deps mcp

# 3. Install remaining dependencies
python3 -m pip install anyio httpx jsonschema pydantic

# 4. Continue with manual MCP server setup (see below)
```

**Option C: Fix Homebrew Rust Issue**

If you want to fix the underlying issue:

```bash
# Uninstall conflicting versions
brew uninstall llvm
brew uninstall rust

# Reinstall Rust (uses system LLVM)
brew install rust
```

---

## Issue #2: MCP Server File Not Found

### Symptoms
```
! harness_mcp_server_v2.py not found in expected locations
  Please download from outputs
```

### Root Cause
Installation script looks for wrong filename or file isn't in the expected location.

### Fix

**The correct MCP server file is:**
```
harness_claude_advanced_mcp.py  (v3.0.0 - USE THIS ONE)
```

**Not:**
```
harness_mcp_server_v2.py  (outdated)
harness_mcp_server.py     (outdated)
```

**Steps to fix:**

1. **Download the correct file:**
   ```bash
   # From /mnt/user-data/outputs/:
   harness_claude_advanced_mcp.py
   ```

2. **Copy to MCP directory:**
   ```bash
   # macOS
   cp harness_claude_advanced_mcp.py \
     ~/Library/Application\ Support/AI-Tools/mcp/
   
   # Linux
   cp harness_claude_advanced_mcp.py \
     ~/.local/share/ai-tools/mcp/
   ```

3. **Make executable:**
   ```bash
   chmod +x ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py
   ```

---

## Issue #3: Python Config Path Error

### Symptoms
```
FileNotFoundError: [Errno 2] No such file or directory: ''
```

### Root Cause
The configuration path variable was empty, causing directory creation to fail.

### Fix

**Use the fixed script which handles paths correctly.**

If configuring manually:

```python
import json
import os
from pathlib import Path

# macOS
config_path = Path.home() / "Library/Application Support/Claude/claude_desktop_config.json"

# Linux
# config_path = Path.home() / ".config/Claude/claude_desktop_config.json"

# Ensure directory exists
config_path.parent.mkdir(parents=True, exist_ok=True)

# Load or create config
if config_path.exists():
    with open(config_path) as f:
        config = json.load(f)
else:
    config = {"mcpServers": {}}

# Add Harness server
config["mcpServers"]["harness"] = {
    "command": "python3",
    "args": [str(Path.home() / "Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py")],
    "env": {
        "HARNESS_DIR": str(Path.home() / "Library/Application Support/AI-Tools/harness"),
        "HARNESS_LOG_LEVEL": "INFO"
    }
}

# Save config
with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)
```

---

## Issue #4: Running Python File as Bash Script

### Symptoms
```bash
$ bash ./harness_claude_advanced_mcp.py
./harness_claude_advanced_mcp.py: line 19: $'\nHarness Advanced MCP Server...'
./harness_claude_advanced_mcp.py: line 21: import: command not found
```

### Root Cause
Tried to execute Python file with bash instead of python3.

### Fix

**Never run Python files with bash:**

```bash
# WRONG:
bash ./harness_claude_advanced_mcp.py

# RIGHT:
python3 ./harness_claude_advanced_mcp.py

# OR (if installed as MCP server):
mcp run harness
```

---

## Complete Fresh Installation

If the above fixes don't work, perform a clean installation:

### Step 1: Clean Up Previous Attempts

```bash
# Remove failed MCP installations
rm -rf ~/.local/share/ai-tools/mcp/ 2>/dev/null || true
rm -rf ~/Library/Application\ Support/AI-Tools/mcp/ 2>/dev/null || true

# Backup existing Claude config
cp ~/Library/Application\ Support/Claude/claude_desktop_config.json \
   ~/Library/Application\ Support/Claude/claude_desktop_config.json.backup
```

### Step 2: Set Up Environment

```bash
# Clear any old Python environment variables
unset PYTHONPATH
unset PYTHONHOME

# Create installation directory
mkdir -p ~/Library/Application\ Support/AI-Tools/mcp/
mkdir -p ~/Library/Application\ Support/AI-Tools/harness/
```

### Step 3: Fix Cryptography Issue

```bash
# Set environment variables permanently
echo 'export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1' >> ~/.zshrc
echo 'export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1' >> ~/.zshrc

# Apply immediately
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1

# Reload shell
source ~/.zshrc
```

### Step 4: Install Dependencies

```bash
# Upgrade pip
python3 -m pip install --upgrade pip

# Install mcp with pre-built wheels
python3 -m pip install --only-binary :all: mcp

# Verify installation
python3 -c "from mcp.server import Server; print('✓ mcp installed')"
```

### Step 5: Install Harness MCP Server

```bash
# Copy MCP server file
cp harness_claude_advanced_mcp.py \
   ~/Library/Application\ Support/AI-Tools/mcp/

# Make executable
chmod +x ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py

# Test it
python3 ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py
```

### Step 6: Configure Claude Desktop

**Edit**: `~/Library/Application Support/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "harness": {
      "command": "python3",
      "args": ["/Users/johndoe/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"],
      "env": {
        "HARNESS_DIR": "/Users/johndoe/Library/Application Support/AI-Tools/harness",
        "HARNESS_LOG_LEVEL": "INFO"
      }
    }
  }
}
```

**Replace `/Users/johndoe` with your actual username:**

```bash
# Get your username
whoami
```

### Step 7: Restart Claude Desktop

1. Quit Claude Desktop completely
2. Wait 3 seconds
3. Reopen Claude Desktop
4. Check Settings > Integrations

---

## Verification Checklist

After installation, verify everything works:

- [ ] MCP server file exists: `~/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py`
- [ ] File is executable: `ls -la` shows `x` permissions
- [ ] Python can import mcp: `python3 -c "import mcp"`
- [ ] Config file exists: `~/Library/Application Support/Claude/claude_desktop_config.json`
- [ ] Config has harness entry: `grep -i harness`
- [ ] Claude Desktop shows Harness in Integrations (Settings)

---

## Testing the Installation

Once installed, test in Claude Desktop:

```
Run this command:
  harness_status()

Expected response:
  ✓ status: operational
  ✓ version: 3.0.0
  ✓ teams: 0
  ✓ agents_tracked: 0
```

---

## Common Path Issues by OS

### macOS Paths
```
Config:    ~/Library/Application Support/Claude/claude_desktop_config.json
MCP:       ~/Library/Application Support/AI-Tools/mcp/
Harness:   ~/Library/Application Support/AI-Tools/harness/
```

### Linux Paths
```
Config:    ~/.config/Claude/claude_desktop_config.json
MCP:       ~/.local/share/ai-tools/mcp/
Harness:   ~/.local/share/ai-tools/harness/
```

### Windows (WSL2) Paths
```
Config:    /mnt/c/Users/{username}/AppData/Roaming/Claude/claude_desktop_config.json
MCP:       ~/.local/share/ai-tools/mcp/
Harness:   ~/.local/share/ai-tools/harness/
```

---

## If Installation Still Fails

**Try the minimal setup:**

```bash
# 1. Ensure Python3 is available
python3 --version

# 2. Install mcp package only
python3 -m pip install mcp --quiet

# 3. Copy MCP server to correct location
mkdir -p ~/Library/Application\ Support/AI-Tools/mcp/
cp harness_claude_advanced_mcp.py ~/Library/Application\ Support/AI-Tools/mcp/
chmod +x ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py

# 4. Test directly
cd ~/Library/Application\ Support/AI-Tools/mcp/
python3 harness_claude_advanced_mcp.py
```

If it prints usage info, installation is working!

---

## Environment Variables Reference

### For Cryptography/Rust Issues
```bash
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1
```

### For Harness Runtime
```bash
export HARNESS_DIR=~/.local/share/ai-tools/harness
export HARNESS_LOG_LEVEL=INFO
```

### For MCP
```bash
export MCP_LOG_LEVEL=INFO
```

---

## Getting Help

If none of these fixes work:

1. Check the Claude log file:
   ```bash
   tail -f ~/Library/Logs/Claude.log
   ```

2. Try running the MCP server directly:
   ```bash
   python3 ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py
   ```

3. Verify Python path:
   ```bash
   which python3
   python3 -m pip list | grep mcp
   ```

4. Check Claude config syntax:
   ```bash
   python3 -m json.tool < ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```
