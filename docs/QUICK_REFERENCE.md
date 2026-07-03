# Quick Reference

One-page reference for Harness MCP tools, commands, and common operations.

## Commands

```
harness status                              # Check system status
harness diagnostics                         # Full health check
harness list patterns                       # Show all orchestration patterns
harness list teams                          # Show designed teams
harness list executions                     # Show execution history
```

## Design a Team

```python
harness_design_team(
    pattern="pipeline",           # or expert_pool, fan-out-fan-in, etc.
    agent_count=5,                # 2-50 agents
    descriptions=[                # One per agent
        "Parse input data",
        "Analyze for issues",
        "Generate report"
    ]
)
```

## Execute a Team

```python
harness_execute_team(
    team_id="team-pipeline-xxx",
    input_data={"query": "..."},
    timeout_ms=30000,
    execution_mode="sequential"   # or parallel
)
```

## Validate a Team

```python
harness_validate_team(team_id="team-pipeline-xxx")
# Returns: 6/6 checks, certified: true/false
```

## Profile Execution

```python
harness_profile_execution(execution_id="exec-xxx")
# Returns: duration, latency percentiles, recommendations
```

## Generate Skill

```python
harness_generate_skill(team_id="team-pipeline-xxx", core_tools=5, advanced_tools=2)
# Returns: SKILL.md content + JSON schema
```

## Security Assessment

```python
harness_assess_security(team_id="team-pipeline-xxx", threat_model="stride")
# Models: stride, pasta, linddun
```

## Wix Scaffolding

```python
harness_wix_scaffold(feature="dashboard", complexity="medium")
# Features: dashboard, data_sync, content_analysis, e_commerce
```

## Common Patterns

| Need | Pattern | Agents |
|------|---------|--------|
| Data processing chain | Pipeline | 3-10 |
| Parallel batch work | Fan-Out/Fan-In | 3-20 |
| Multi-domain queries | Expert Pool | 3-12 |
| Quality assurance | Producer-Reviewer | 2-3 |
| Team coordination | Supervisor | 3-15 |
| Complex workflows | Hierarchical | 5-30 |

## Key Paths

| Platform | Config File |
|----------|-------------|
| macOS | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Linux | `~/.config/claude/claude_desktop_config.json` |
| Windows | `%APPDATA%\Claude\claude_desktop_config.json` |

## Environment Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `HARNESS_DIR` | Harness data directory | `~/.local/share/ai-tools/harness` |
| `MCP_DIR` | MCP server directory | `~/.local/share/ai-tools/mcp` |
| `HARNESS_LOG_LEVEL` | Logging verbosity | `INFO` |

## Quick Troubleshooting

| Problem | Fix |
|---------|-----|
| `pip install` fails with PEP 668 | `pip install --break-system-packages mcp` |
| Claude shows [Disconnected] | Restart Claude Desktop, check config paths |
| `ModuleNotFoundError: mcp` | `pip install mcp pydantic` |
| Server won't start | Check Python 3.9+: `python --version` |
