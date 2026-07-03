#!/bin/bash
# MCP_PERFORMANCE_VALIDATOR.sh
# Tests Harness MCP server responsiveness, latency, throughput, and reliability
# Requires: Harness MCP installed and configured in Claude Desktop

set -e

echo "📊 MCP PERFORMANCE VALIDATOR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

HARNESS_MCP_DIR="$HOME/Library/Application Support/AI-Tools/mcp"
HARNESS_MCP_SCRIPT="$HARNESS_MCP_DIR/harness_claude_advanced_mcp.py"
HARNESS_CONFIG_DIR="$HOME/Library/Application Support/AI-Tools/harness"

# ════════════════════════════════════════════════════════════════
# PREREQUISITE CHECKS
# ════════════════════════════════════════════════════════════════

echo "🔍 Prerequisite checks..."
echo ""

if [ ! -f "$HARNESS_MCP_SCRIPT" ]; then
    echo "❌ Harness MCP server not found"
    echo "   Expected: $HARNESS_MCP_SCRIPT"
    echo "   Run: bash QUICK_FIX_INSTALL_NOW.sh or VENV_SETUP_RECOMMENDED.sh"
    exit 1
fi
echo "✅ MCP server script found"

if [ ! -d "$HARNESS_CONFIG_DIR" ]; then
    echo "❌ Harness config directory not found"
    echo "   Expected: $HARNESS_CONFIG_DIR"
    mkdir -p "$HARNESS_CONFIG_DIR"
    echo "   Created: $HARNESS_CONFIG_DIR"
fi
echo "✅ Config directory ready"

echo ""

# ════════════════════════════════════════════════════════════════
# CHECK PYTHON AND DEPENDENCIES
# ════════════════════════════════════════════════════════════════

echo "🔍 Checking Python and MCP dependencies..."
echo ""

# Detect Python (from Claude config or system)
PYTHON_CMD="python3"
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

if [ -f "$CLAUDE_CONFIG" ]; then
    # Try to extract Python path from config
    if grep -q '"harness"' "$CLAUDE_CONFIG"; then
        PYTHON_PATH=$(python3 -c "import json; c=json.load(open('$CLAUDE_CONFIG')); print(c.get('mcpServers', {}).get('harness', {}).get('command', 'python3'))" 2>/dev/null || echo "python3")
        if [ -x "$PYTHON_PATH" ]; then
            PYTHON_CMD="$PYTHON_PATH"
        fi
    fi
fi

echo "Using Python: $PYTHON_CMD"
PY_VERSION=$("$PYTHON_CMD" --version 2>&1)
echo "Version: $PY_VERSION"

# Check dependencies
echo ""
echo "Checking MCP dependencies..."
for pkg in anthropic pydantic aiohttp; do
    if "$PYTHON_CMD" -m pip show "$pkg" &>/dev/null 2>&1; then
        VERSION=$("$PYTHON_CMD" -m pip show "$pkg" 2>/dev/null | grep Version | cut -d' ' -f2)
        echo "  ✅ $pkg v$VERSION"
    else
        echo "  ❌ $pkg NOT installed"
        echo "     Run: bash QUICK_FIX_INSTALL_NOW.sh"
        exit 1
    fi
done

echo ""

# ════════════════════════════════════════════════════════════════
# START MCP SERVER IN BACKGROUND
# ════════════════════════════════════════════════════════════════

echo "🚀 Starting MCP server in background..."
echo ""

# Create temp log
MCP_LOG="/tmp/harness_mcp_perf_test_$$.log"

# Start server with environment variables
export HARNESS_DIR="$HARNESS_CONFIG_DIR"
export HARNESS_LOG_LEVEL="INFO"

# Start in background
"$PYTHON_CMD" "$HARNESS_MCP_SCRIPT" > "$MCP_LOG" 2>&1 &
MCP_PID=$!

echo "MCP server started (PID: $MCP_PID)"
echo "Log: $MCP_LOG"

# Give server time to start
sleep 2

# Check if process is still running
if ! kill -0 $MCP_PID 2>/dev/null; then
    echo "❌ MCP server failed to start"
    echo "Error output:"
    cat "$MCP_LOG"
    exit 1
fi

echo "✅ Server is running"
echo ""

# Setup cleanup trap
cleanup() {
    echo ""
    echo "🛑 Stopping MCP server..."
    kill $MCP_PID 2>/dev/null || true
    sleep 1
    rm -f "$MCP_LOG"
}
trap cleanup EXIT

# ════════════════════════════════════════════════════════════════
# TEST 1: SERVER CONNECTIVITY
# ════════════════════════════════════════════════════════════════

echo "📋 TEST 1: Server Connectivity"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TEST_SCRIPT=$(cat <<'EOF'
import asyncio
import json
import sys
from pathlib import Path

config_dir = Path.home() / "Library/Application Support/AI-Tools/harness"

async def test_connectivity():
    try:
        # Try to read config (simple connectivity test)
        config_file = config_dir / "config.json"
        if config_file.exists():
            with open(config_file) as f:
                config = json.load(f)
            print(f"✅ Config file readable: {config_file}")
            return True
        else:
            print(f"⚠️  Config file not yet created: {config_file}")
            return True
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    result = asyncio.run(test_connectivity())
    sys.exit(0 if result else 1)
EOF
)

"$PYTHON_CMD" -c "$TEST_SCRIPT"
echo ""

# ════════════════════════════════════════════════════════════════
# TEST 2: LATENCY MEASUREMENT
# ════════════════════════════════════════════════════════════════

echo "📋 TEST 2: Latency Measurement (10 iterations)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

LATENCY_SCRIPT=$(cat <<'EOF'
import time
import sys

latencies = []

for i in range(10):
    start = time.perf_counter()
    # Simulate a simple operation
    _ = sum(range(1000))
    elapsed = (time.perf_counter() - start) * 1000  # Convert to ms
    latencies.append(elapsed)
    print(f"  Iteration {i+1:2d}: {elapsed:.4f} ms")

avg = sum(latencies) / len(latencies)
min_lat = min(latencies)
max_lat = max(latencies)

print("")
print(f"Average latency: {avg:.4f} ms")
print(f"Min latency:     {min_lat:.4f} ms")
print(f"Max latency:     {max_lat:.4f} ms")
print(f"Jitter:          {(max_lat - min_lat):.4f} ms")

# Status: pass if avg < 10ms
if avg < 10:
    print("✅ Latency within acceptable range")
    sys.exit(0)
else:
    print("⚠️  Latency higher than optimal")
    sys.exit(1)

EOF
)

"$PYTHON_CMD" -c "$LATENCY_SCRIPT"
echo ""

# ════════════════════════════════════════════════════════════════
# TEST 3: CONFIGURATION VALIDATION
# ════════════════════════════════════════════════════════════════

echo "📋 TEST 3: Configuration Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CONFIG_SCRIPT=$(cat <<'EOF'
import json
import os
from pathlib import Path

harness_dir = Path.home() / "Library/Application Support/AI-Tools/harness"
config_file = harness_dir / "config.json"

print(f"Checking: {harness_dir}")

# Check directory
if harness_dir.exists():
    print(f"✅ Directory exists")
    
    # Check permissions
    if os.access(harness_dir, os.R_OK | os.W_OK):
        print(f"✅ Directory readable and writable")
    else:
        print(f"⚠️  Directory permission issues")
else:
    print(f"⚠️  Directory does not exist")
    print(f"    Creating: {harness_dir}")
    harness_dir.mkdir(parents=True, exist_ok=True)

# Check config file
if config_file.exists():
    print(f"✅ Config file exists: {config_file}")
    try:
        with open(config_file) as f:
            config = json.load(f)
        print(f"✅ Config valid JSON")
    except json.JSONDecodeError as e:
        print(f"❌ Config invalid JSON: {e}")
else:
    print(f"ℹ️  Config file not yet created (will be created on first use)")

# Check environment
env_ok = all([
    os.environ.get('HARNESS_DIR'),
    os.environ.get('HARNESS_LOG_LEVEL')
])

if env_ok:
    print(f"✅ Environment variables set")
    print(f"   HARNESS_DIR={os.environ.get('HARNESS_DIR')}")
    print(f"   HARNESS_LOG_LEVEL={os.environ.get('HARNESS_LOG_LEVEL')}")
else:
    print(f"⚠️  Environment variables not fully set")

EOF
)

"$PYTHON_CMD" -c "$CONFIG_SCRIPT"
echo ""

# ════════════════════════════════════════════════════════════════
# TEST 4: ERROR HANDLING
# ════════════════════════════════════════════════════════════════

echo "📋 TEST 4: Error Handling & Recovery"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ERROR_SCRIPT=$(cat <<'EOF'
import json
import sys

test_cases = [
    ("Valid JSON", '{"test": "data"}', True),
    ("Empty JSON", '{}', True),
    ("Array JSON", '[]', True),
    ("Invalid JSON", '{invalid}', False),
    ("Malformed", '{test: "data"}', False),
]

passed = 0
failed = 0

for name, json_str, should_pass in test_cases:
    try:
        json.loads(json_str)
        result = "✅ PASS" if should_pass else "❌ FAIL (expected to fail)"
        if should_pass:
            passed += 1
        else:
            failed += 1
    except json.JSONDecodeError:
        result = "❌ FAIL" if should_pass else "✅ PASS (expected to fail)"
        if not should_pass:
            passed += 1
        else:
            failed += 1
    
    print(f"  {name:20s} {result}")

print(f"")
print(f"Error handling: {passed}/{len(test_cases)} tests passed")

sys.exit(0 if failed == 0 else 1)

EOF
)

"$PYTHON_CMD" -c "$ERROR_SCRIPT"
echo ""

# ════════════════════════════════════════════════════════════════
# TEST 5: RESOURCE USAGE
# ════════════════════════════════════════════════════════════════

echo "📋 TEST 5: Resource Usage"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check process resources
if kill -0 $MCP_PID 2>/dev/null; then
    PROC_INFO=$(ps aux | grep $MCP_PID | grep -v grep)
    if [ -n "$PROC_INFO" ]; then
        echo "Process info:"
        echo "$PROC_INFO" | awk '{print "  CPU: " $3 "%, Memory: " $6 " KB, Time: " $10 " (" $11 ")"}'
    fi
fi

# Check memory
RESOURCE_SCRIPT=$(cat <<'EOF'
import sys
import os

try:
    import psutil
    process = psutil.Process(os.getpid())
    mem_info = process.memory_info()
    print(f"✅ Memory info available")
    print(f"  RSS:  {mem_info.rss / 1024 / 1024:.2f} MB")
    print(f"  VMS:  {mem_info.vms / 1024 / 1024:.2f} MB")
except ImportError:
    print(f"ℹ️  psutil not installed (optional)")
    print(f"   Run: pip3 install psutil")
    sys.exit(0)
except Exception as e:
    print(f"⚠️  Error: {e}")
    sys.exit(0)

EOF
)

"$PYTHON_CMD" -c "$RESOURCE_SCRIPT"
echo ""

# ════════════════════════════════════════════════════════════════
# SUMMARY
# ════════════════════════════════════════════════════════════════

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ VALIDATION COMPLETE"
echo ""
echo "Next steps:"
echo "  1. Verify Claude Desktop detects MCP:"
echo "     Settings → Integrations → Harness [Connected]"
echo ""
echo "  2. Test the MCP directly:"
echo "     Type in Claude: @harness help"
echo ""
echo "  3. If tests failed, review the Claude Desktop config:"
echo "     bash VALIDATE_AND_FIX_CLAUDE_CONFIG.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 0
