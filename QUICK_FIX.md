# Harness v3.0.0 - Quick Fix Guide

## Your Specific Issues & Solutions

### ✗ ERROR #1: Cryptography Compilation Failed
**You saw:** `Symbol not found: __ZN4llvm10PGOOptionsC1E...`

**Root cause:** Homebrew Rust/LLVM conflict on macOS

**IMMEDIATE FIX (< 2 minutes):**

```bash
# Set these environment variables
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1

# Now install mcp
python3 -m pip install mcp

# If that fails, use pre-built wheels only:
python3 -m pip install --only-binary :all: mcp anyio httpx jsonschema pydantic
```

---

### ✗ ERROR #2: "harness_mcp_server_v2.py not found"
**You saw:** `! harness_mcp_server_v2.py not found in expected locations`

**Root cause:** Installation script looks for wrong filename

**IMMEDIATE FIX:**

```bash
# The CORRECT file name (v3.0.0):
harness_claude_advanced_mcp.py

# Copy it manually to the right place:
mkdir -p ~/Library/Application\ Support/AI-Tools/mcp/

cp harness_claude_advanced_mcp.py \
   ~/Library/Application\ Support/AI-Tools/mcp/

chmod +x ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py
```

---

### ✗ ERROR #3: "No such file or directory: ''"
**You saw:** `FileNotFoundError: [Errno 2] No such file or directory: ''`

**Root cause:** Empty path variable in config setup

**IMMEDIATE FIX:**

```bash
# Use this Python script instead (handles paths correctly):
python3 << 'EOF'
import json
from pathlib import Path

# Correct path for macOS
config_path = Path.home() / "Library/Application Support/Claude/claude_desktop_config.json"
config_path.parent.mkdir(parents=True, exist_ok=True)

# Load or create
config = {}
if config_path.exists():
    with open(config_path) as f:
        config = json.load(f)
if "mcpServers" not in config:
    config["mcpServers"] = {}

# Add Harness
mcp_file = Path.home() / "Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"
harness_dir = Path.home() / "Library/Application Support/AI-Tools/harness"
harness_dir.mkdir(parents=True, exist_ok=True)

config["mcpServers"]["harness"] = {
    "command": "python3",
    "args": [str(mcp_file)],
    "env": {
        "HARNESS_DIR": str(harness_dir),
        "HARNESS_LOG_LEVEL": "INFO"
    }
}

# Save
with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print(f"✓ Config updated: {config_path}")
print(f"✓ MCP server: {mcp_file}")
EOF
```

---

### ✗ ERROR #4: "bash ./harness_claude_advanced_mcp.py"
**You ran:** `bash ./harness_claude_advanced_mcp.py`

**Error:** `./harness_claude_advanced_mcp.py: line 19: syntax error...`

**Root cause:** Python files need `python3`, not `bash`

**IMMEDIATE FIX:**

```bash
# WRONG:
bash ./harness_claude_advanced_mcp.py

# RIGHT:
python3 ./harness_claude_advanced_mcp.py
```

---

## One-Minute Installation (Copy & Paste)

If you want to start fresh, run this:

```bash
#!/bin/bash

# 1. Set environment for cryptography
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
export CRYPTOGRAPHY_USE_SYSTEM_OPENSSL=1

# 2. Install mcp
python3 -m pip install mcp --quiet

# 3. Create directories
mkdir -p ~/Library/Application\ Support/AI-Tools/mcp/
mkdir -p ~/Library/Application\ Support/AI-Tools/harness/

# 4. Copy MCP server (adjust path if file is elsewhere)
cp harness_claude_advanced_mcp.py ~/Library/Application\ Support/AI-Tools/mcp/
chmod +x ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py

# 5. Configure Claude Desktop
python3 << 'EOF'
import json
from pathlib import Path

config_path = Path.home() / "Library/Application Support/Claude/claude_desktop_config.json"
config_path.parent.mkdir(parents=True, exist_ok=True)

config = {}
if config_path.exists():
    with open(config_path) as f:
        config = json.load(f)
if "mcpServers" not in config:
    config["mcpServers"] = {}

mcp_file = Path.home() / "Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"
harness_dir = Path.home() / "Library/Application Support/AI-Tools/harness"
harness_dir.mkdir(parents=True, exist_ok=True)

config["mcpServers"]["harness"] = {
    "command": "python3",
    "args": [str(mcp_file)],
    "env": {
        "HARNESS_DIR": str(harness_dir),
        "HARNESS_LOG_LEVEL": "INFO"
    }
}

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print("✓ Installation complete!")
print(f"✓ Config: {config_path}")
EOF

# 6. Restart Claude Desktop and verify
echo "✓ Done! Restart Claude Desktop now."
```

---

## Verify It Works

```bash
# 1. Check MCP file exists and is executable
ls -la ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py

# 2. Test MCP import
python3 -c "from mcp.server import Server; print('✓ mcp works')"

# 3. Check config is valid
python3 -m json.tool < ~/Library/Application\ Support/Claude/claude_desktop_config.json

# 4. In Claude Desktop, run:
#    harness_status()
#    
#    Should return:
#    ✓ status: operational
#    ✓ version: 3.0.0
```

---

## If You Get Stuck

Run this diagnostic:

```bash
#!/bin/bash
echo "=== DIAGNOSTIC REPORT ==="
echo ""
echo "Python:"
python3 --version
which python3
echo ""
echo "MCP import:"
python3 -c "from mcp.server import Server; print('✓ OK')" 2>&1 || echo "✗ FAILED"
echo ""
echo "MCP file:"
ls -la ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py 2>&1 || echo "✗ NOT FOUND"
echo ""
echo "Config file:"
ls -la ~/Library/Application\ Support/Claude/claude_desktop_config.json 2>&1 || echo "✗ NOT FOUND"
echo ""
echo "Config content:"
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json 2>&1 | python3 -m json.tool || echo "✗ INVALID JSON"
echo ""
echo "=== END REPORT ==="
```

Copy & paste the output if you need help debugging.

---

## Path Reference (Copy Yours)

**macOS:**
```
MCP file:      ~/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py
Config file:   ~/Library/Application Support/Claude/claude_desktop_config.json
Harness data:  ~/Library/Application Support/AI-Tools/harness/
```

**Linux:**
```
MCP file:      ~/.local/share/ai-tools/mcp/harness_claude_advanced_mcp.py
Config file:   ~/.config/Claude/claude_desktop_config.json
Harness data:  ~/.local/share/ai-tools/harness/
```

---

## Next Steps After Installation

1. ✓ Restart Claude Desktop
2. ✓ Open Settings > Integrations
3. ✓ Confirm "harness" is listed
4. ✓ In Claude, run: `harness_status()`
5. ✓ Create first team: `design_agent_team(name="test", pattern="expert_pool", domain="testing")`

---

## Questions?

If it still doesn't work:

1. **Check the full diagnostic output** (run the diagnostic script above)
2. **Check Claude Desktop logs** (see INSTALLATION_FIXES.md)
3. **Try the fixed installer script** (install_harness_fixed.sh)
4. **Read INSTALLATION_FIXES.md** for detailed troubleshooting
