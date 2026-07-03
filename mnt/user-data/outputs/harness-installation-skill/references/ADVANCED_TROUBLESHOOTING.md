# Harness v3.0.0 Advanced Troubleshooting Reference

## FAQ

### Q: Can I run multiple MCP servers on Claude Desktop?
**A**: Yes. Each entry in `mcpServers` JSON object is independent. Example:
```json
{
  "mcpServers": {
    "harness": { "command": "...", "args": [...] },
    "other-mcp": { "command": "...", "args": [...] }
  }
}
```

### Q: What is HARNESS_LOG_LEVEL?
**A**: Controls logging verbosity. Options: `DEBUG`, `INFO`, `WARNING`, `ERROR`. Default: `INFO`.

### Q: Does Harness v3.0.0 work with Claude.ai (web version)?
**A**: No. MCP servers only work with Claude Desktop (native macOS/Windows application). Claude.ai (web) does not support MCP.

### Q: Can I move the MCP server to a different directory?
**A**: Yes. Update path in `claude_desktop_config.json` to match new location, then restart Claude Desktop.

### Q: What if I have both v2 and v3 installed?
**A**: Uninstall v2 first to avoid naming conflicts. The corrected script handles v3.0.0 exclusively.

### Q: How often should I verify the installation?
**A**: Run `verify_harness_installation.sh` after any: Claude Desktop update, macOS update, Rust/Python upgrade, or if connection drops.

---

## Performance Diagnostics

### Slow MCP Response

1. Check logs for bottlenecks:
```bash
tail -50 ~/.../harness/logs/harness.log | grep -i "duration\|latency"
```

2. Monitor CPU/memory:
```bash
# Watch Harness MCP server process
ps aux | grep harness_claude_advanced_mcp.py
top -p $(pgrep -f harness_claude_advanced_mcp.py)
```

3. Test round-trip latency from Claude chat:
```
@harness latency-test
```

### Memory Leaks

If process memory grows unbounded:
```bash
# Restart via Claude Desktop settings or:
killall harness_claude_advanced_mcp.py
sleep 2
# Claude Desktop will restart MCP automatically
```

---

## Security Notes

### Config File Permissions
```bash
# Ensure config readable only by user
chmod 600 ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

### Secrets Management
- Never hardcode API keys in `claude_desktop_config.json`
- Use environment variables or macOS Keychain instead
- Example:
```json
{
  "env": {
    "HARNESS_API_KEY": "${HARNESS_API_KEY}"
  }
}
```
Then:
```bash
export HARNESS_API_KEY="your-key-here"
# Claude Desktop reads $HARNESS_API_KEY and substitutes
```

---

## Build System Integrity Checks

### Verify No File Corruption

```bash
# Check MCP server file size (should match original 33 KB)
ls -lh ~/.../mcp/harness_claude_advanced_mcp.py

# Verify Python syntax
python3 -m py_compile ~/.../mcp/harness_claude_advanced_mcp.py && echo "✓ Syntax OK"

# Dry-run import test
python3 -c "
import sys
sys.path.insert(0, '~/.../mcp')
import importlib.util
spec = importlib.util.spec_from_file_location('harness', '~/.../mcp/harness_claude_advanced_mcp.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
print('✓ Module loads without error')
"
```

---

## Common Installation Paths (macOS)

| Component | Expected Path |
|-----------|----------------|
| Claude Desktop config | `~/.config/Claude/claude_desktop_config.json` OR `~/Library/Application Support/Claude/claude_desktop_config.json` |
| MCP server deployment | `~/Library/Application Support/AI-Tools/mcp/` |
| Harness state | `~/Library/Application Support/AI-Tools/harness/` |
| Harness logs | `~/Library/Application Support/AI-Tools/harness/logs/` |
| Python binary | `/opt/local/bin/python3` (MacPorts) OR `/usr/local/bin/python3` (Homebrew) |
| Rust toolchain | `~/.cargo/bin/cargo` |

---

## Command-Line Testing

### Direct MCP Server Invocation (Advanced)

```bash
# Test MCP server directly without Claude Desktop
python3 ~/.../mcp/harness_claude_advanced_mcp.py --help

# Run with environment variables
HARNESS_DIR="/path/to/harness" \
HARNESS_LOG_LEVEL="DEBUG" \
python3 ~/.../mcp/harness_claude_advanced_mcp.py
```

### JSON Config Validation

```bash
# Validate config structure
python3 -m json.tool ~/Library/Application\ Support/Claude/claude_desktop_config.json > /dev/null && echo "✓ Valid JSON"

# Pretty-print for review
python3 -m json.tool ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

---

## Rollback Procedure

### If Installation Breaks Claude Desktop

```bash
# Step 1: Remove Harness from config
# Edit: ~/Library/Application Support/Claude/claude_desktop_config.json
# Delete the entire "harness" entry under "mcpServers"

# Step 2: Restart Claude Desktop
killall Claude
open /Applications/Claude.app

# Step 3: Verify other MCPs still work (if any)

# Step 4: Retry installation or get help
```

### Complete Uninstall

```bash
# Remove MCP server
rm ~/.../AI-Tools/mcp/harness_claude_advanced_mcp.py

# Remove Harness state (optional, preserves logs for debugging)
rm -rf ~/.../AI-Tools/harness/

# Remove config entry (see Rollback Step 1)

# Restart Claude Desktop
killall Claude
open /Applications/Claude.app
```

---

## Environment Variable Reference

| Variable | Purpose | Example |
|----------|---------|---------|
| `HARNESS_DIR` | Root directory for Harness data, logs, config | `/Users/johndoe/.../AI-Tools/harness` |
| `HARNESS_LOG_LEVEL` | Logging verbosity | `INFO` |
| `CRYPTOGRAPHY_DONT_BUILD_WHEEL` | Prevent cryptography source build (Rust/LLVM fix) | `1` |
| `CRYPTOGRAPHY_USE_SYSTEM_OPENSSL` | Use system OpenSSL, not vendored | `1` |

---

## Network & Connectivity

### Firewall Considerations

Harness MCP runs locally (localhost only). No firewall rules needed.

### DNS/Proxy

If Claude Desktop uses a proxy for external APIs:
- Harness MCP communication is local (no proxy needed)
- Configure proxy at Claude Desktop level if needed for other MCPs

---

## Integration with Other Tools

### Using Harness with Other Claude Features

- ✅ Web search (enabled independently)
- ✅ File uploads (works with Harness commands)
- ✅ Code execution (if Harness MCP provides that capability)
- ✅ Multiple MCP servers (side-by-side)

### Bash Aliases for Common Commands

```bash
# ~/.zprofile or ~/.bash_profile

alias install-harness="bash ~/Harness/install_harness_v3_corrected.sh"
alias verify-harness="bash ~/Harness/verify_harness_installation.sh"
alias harness-logs="tail -f ~/.../harness/logs/harness.log"
alias harness-config="cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | python3 -m json.tool"
```

---

## Maintenance Schedule

| Task | Frequency | Command |
|------|-----------|---------|
| Verify installation | After Claude/macOS update | `bash verify_harness_installation.sh` |
| Check logs for errors | Weekly | `grep "ERROR\|CRITICAL" ~/.../harness/logs/*.log` |
| Restart MCP server | As needed | `killall harness_claude_advanced_mcp.py` |
| Update Rust toolchain | Quarterly | `brew upgrade rust` |
| Backup Harness config | Monthly | `cp -r ~/.../AI-Tools/harness ~/Backups/` |

---

## Getting Help

1. **Check logs first**: `tail -100 ~/.../harness/logs/harness.log`
2. **Run verification**: `bash verify_harness_installation.sh`
3. **Test environment**: Review "System Environment" section in main SKILL.md
4. **Check FAQ**: See top of this file
5. **Review transcript history**: `/mnt/transcripts/journal.txt`
