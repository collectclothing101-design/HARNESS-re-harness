# Advanced Troubleshooting Guide

Detailed root-cause analysis and solutions for Harness v3.0.0 installation issues.

## Table of Contents

1. [PEP 668 Deep Dive](#pep-668-deep-dive)
2. [Rust/LLVM ABI Mismatch](#rustllvm-abi-mismatch)
3. [Environment Variable Scoping](#environment-variable-scoping)
4. [MCP Server Startup Failures](#mcp-server-startup-failures)
5. [Claude Desktop Configuration Issues](#claude-desktop-configuration-issues)
6. [Virtual Environment Problems](#virtual-environment-problems)

---

## PEP 668 Deep Dive

### What is PEP 668?

**PEP 668** (Python 3.11+) enforces "externally-managed-environment" protection. Homebrew-installed Python prevents pip from installing to system site-packages.

### Three Solutions

#### Solution 1: `--break-system-packages --user` (Fastest)
```bash
pip install --break-system-packages --user harness-claude-advanced-mcp
```
- Installs to `~/.local/lib/python3.x/site-packages/`
- No venv needed
- Breaks PEP 668 intent

#### Solution 2: Virtual Environment (Recommended)
```bash
python3 -m venv ~/harness_venv
source ~/harness_venv/bin/activate
pip install harness-claude-advanced-mcp
```
- Isolated, future-proof
- PEP 668 doesn't apply inside venv
- Update Claude config to use venv Python

#### Solution 3: Manual venv with full config
See `references/claude_desktop_config.template.json` for venv path configuration.

---

## Rust/LLVM ABI Mismatch

### Symptom
```
SIGABRT during pip install
Building wheel for cryptography...
[1]    12345 abort      pip install ...
```

### Root Cause
Homebrew Rust and LLVM version mismatch when building cryptography wheels.

### Solution
```bash
export CRYPTOGRAPHY_DONT_BUILD_WHEEL=1
pip install --only-binary :all: harness-claude-advanced-mcp
```

---

## Environment Variable Scoping

### Problem
Environment variables must be explicitly passed to subprocess in Claude Desktop config.

### Wrong Config
```json
"env": { "HARNESS_DIR": "/path" }
// Not inherited by subprocess
```

### Correct Config
```json
"env": {
  "HARNESS_DIR": "/Users/johndoe/Library/Application Support/AI-Tools/harness",
  "HARNESS_LOG_LEVEL": "INFO"
}
```

Claude Desktop directly passes env dict to subprocess.

---

## MCP Server Startup Failures

### Debugging Checklist

#### 1. File Exists
```bash
ls -la "/Users/johndoe/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"
```

#### 2. Python Can Run It
```bash
python3 /Users/johndoe/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py --help
```

#### 3. Dependencies Installed
```bash
python3 -c "import anthropic; print('OK')"
```

#### 4. Config Valid JSON
```bash
python3 -c "import json; json.load(open('~/Library/Application Support/Claude/claude_desktop_config.json'))"
```

---

## Claude Desktop Configuration Issues

### Common Mistakes

**1. String instead of array**
```json
// WRONG
"args": "/path/to/harness.py"

// RIGHT
"args": ["/path/to/harness.py"]
```

**2. Unquoted paths**
```json
// WRONG
"args": [/path/to/harness.py]

// RIGHT
"args": ["/path/to/harness.py"]
```

**3. Home directory alias**
```json
// WRONG (~ doesn't expand in JSON)
"args": ["~/Library/.../harness.py"]

// RIGHT (full path)
"args": ["/Users/johndoe/Library/.../harness.py"]
```

---

## Virtual Environment Problems

### Wrong Approach
```json
"command": "source",
"args": ["~/harness_venv/bin/activate && python3", "harness.py"]
```
❌ `source` is a shell builtin, won't work in subprocess.

### Correct Approach
```json
"command": "/Users/johndoe/harness_venv/bin/python3",
"args": ["/path/to/harness_claude_advanced_mcp.py"]
```
✅ Direct path to venv Python. PYTHONPATH automatically set.

### Verify venv Python
```bash
~/harness_venv/bin/python3 --version
~/harness_venv/bin/python3 -c "import sys; print(sys.prefix)"
# Should show /Users/johndoe/harness_venv
```

---

## Debugging Checklist

1. **Baseline audit:** `bash ../scripts/SYSTEM_DIAGNOSTICS.sh`
2. **Auto-repair:** `bash ../scripts/VALIDATE_AND_FIX_CLAUDE_CONFIG.sh`
3. **Restart Claude:** `killall Claude && open /Applications/Claude.app`
4. **Check integrations:** Settings → Integrations → "harness"
5. **Test command:** `@harness help`

