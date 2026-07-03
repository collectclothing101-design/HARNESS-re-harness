# Release Notes

## v3.0.1 — Current Release

**Date:** July 2026

### What's Included

- **3 MCP server implementations:** basic (11 tools), v2 (14 tools), advanced (8 tools + engine)
- **13 bug fixes** across Python sources, install scripts, and config
- **Cross-platform installers:** bash, PowerShell, batch
- **6 orchestration patterns:** pipeline, fan-out, expert-pool, producer-reviewer, supervisor, hierarchical
- **Integration modules:** skill-creator and Wix scaffolding
- **14 MCP tools** for team design, execution, profiling, validation, and more

### Bugs Fixed

| # | Component | Issue |
|---|-----------|-------|
| 1 | `harness_claude_advanced_mcp.py` | Undefined `templates` variable |
| 2 | `harness_mcp_server_v2.py` | Non-existent `cache_dir` attribute |
| 3 | `install_harness.ps1` | `$mpcDirEnv` typo |
| 4-7 | Install scripts | MCP server file discovery across all 3 variants |
| 8 | `harness_claude_advanced_mcp.py` | Outdated MCP imports (`RequestContext`, `ToolResult`) |
| 9 | `harness_claude_advanced_mcp.py` | `AgentRole.SUPERVISOR` doesn't exist in enum |
| 10 | `harness_claude_advanced_mcp.py` | Enum JSON serialization in `_save_state` |
| 11 | `harness_claude_advanced_mcp.py` | `_load_state` enum reconstruction from JSON |
| 12 | `harness_claude_advanced_mcp.py` | Duplicate `id` keyword in `AgentTeam` constructor |
| 13 | `SKILL.md` | Broken `scripts/` path prefix in all references |

### Verified

- All 5 Python files compile clean
- All 3 JSON files parse correctly
- Both shell scripts pass syntax check
- End-to-end skill-creator pipeline tested
- Full installation flow verified (7/7 checks)
- Server starts and connects to Claude Desktop

---

## v3.0.0

- PEP 668 externally-managed-environment resolution
- Virtual environment setup scripts
- System diagnostics and validation tools
- Environment migration between Python versions

## v2.0.0

- Initial MCP server with 14 tools
- 6 architectural patterns
- Cross-platform installation (macOS, Linux, Windows)
- Claude Desktop integration
- Performance profiling and security assessment
