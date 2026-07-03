# HARNESS

Production-grade multi-agent orchestration framework for Claude.

## Quick Start

```bash
# macOS / Linux
bash install/install_harness_universal.sh

# Windows (PowerShell as Admin)
.\install\install_harness.ps1
```

Then restart Claude Desktop and type `/mcp` — confirm `harness [Connected]`.

## What It Does

Design, execute, and validate multi-agent teams in Claude:

```
"Design a 5-agent pipeline for code review"
"Execute the team on this diff"
"Validate the architecture"
```

## 14 MCP Tools

| Tool | Description |
|------|-------------|
| `harness_status` | System status |
| `harness_design_team` | Design agent teams |
| `harness_execute_team` | Run teams |
| `harness_profile_execution` | Performance analysis |
| `harness_validate_team` | 6-point certification |
| `harness_generate_skill` | Create SKILL.md |
| `harness_list_teams` | List teams |
| `harness_list_executions` | Execution history |
| `harness_list_patterns` | Orchestration patterns |
| `harness_optimize_performance` | Optimization plans |
| `harness_assess_security` | Threat modeling |
| `harness_generate_template` | Code templates |
| `harness_wix_scaffold` | Wix features |
| `harness_diagnostics` | Health check |

## 6 Orchestration Patterns

| Pattern | Description |
|---------|-------------|
| Pipeline | Sequential: A -> B -> C |
| Fan-Out/Fan-In | Parallel workers + aggregator |
| Expert Pool | Router selects specialist |
| Producer-Reviewer | Quality-gated workflows |
| Supervisor | Central coordinator |
| Hierarchical | Nested delegation |

## Documentation

| Document | Description |
|----------|-------------|
| [Installation](docs/INSTALLATION.md) | Complete install guide for all platforms |
| [Architecture](docs/ARCHITECTURE.md) | Features, patterns, tools, file structure |
| [Troubleshooting](docs/TROUBLESHOOTING.md) | Error fixes and diagnostics |
| [Quick Reference](docs/QUICK_REFERENCE.md) | Commands, paths, cheat sheet |
| [Release Notes](docs/RELEASE_NOTES.md) | Version history and changelog |
| [Windows](docs/WINDOWS.md) | Windows-specific installation |
| [Examples](examples/) | Example team designs |

## Structure

```
HARNESS/
├── src/            # MCP server Python files
├── install/        # Cross-platform install scripts
├── docs/           # Documentation
├── examples/       # Example team designs
├── mnt/            # Skill packages
└── README.md       # This file
```

## License

MIT
