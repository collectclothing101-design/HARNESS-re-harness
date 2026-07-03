# Architecture & Features

Harness is a production-grade multi-agent orchestration framework for Claude. It enables designing, executing, profiling, and validating distributed agent teams.

## MCP Tools

### Core (8)

| Tool | Purpose |
|------|---------|
| `harness_status` | Check installation and operational status |
| `harness_design_team` | Design agent teams using architectural patterns |
| `harness_execute_team` | Run teams with real-time orchestration |
| `harness_profile_execution` | Analyze performance metrics and bottlenecks |
| `harness_validate_team` | 6-point certification checklist |
| `harness_generate_skill` | Generate SKILL.md from team definition |
| `harness_list_teams` | List all designed teams |
| `harness_list_executions` | List execution history |

### Enhanced (6)

| Tool | Purpose |
|------|---------|
| `harness_list_patterns` | Describe all orchestration patterns |
| `harness_optimize_performance` | Generate optimization plans |
| `harness_assess_security` | STRIDE/PASTA/LINDDUN threat modeling |
| `harness_generate_template` | Implementation templates (Python/TypeScript/Go) |
| `harness_wix_scaffold` | Wix-specific feature scaffolds |
| `harness_diagnostics` | System health and connectivity check |

## Orchestration Patterns

| Pattern | Use Case | Latency |
|---------|----------|---------|
| Pipeline | Sequential: A -> B -> C | sum(agent_times) |
| Fan-Out/Fan-In | Parallel workers + aggregator | max(worker_times) |
| Expert Pool | Router selects specialist | router + selected |
| Producer-Reviewer | Quality-gated workflows | produce + review |
| Supervisor | Central coordinator + monitoring | supervisor + parallel |
| Hierarchical | Nested delegation trees | depth + work |

## Agent Roles

| Role | Description |
|------|-------------|
| Router | Routes requests to specialists |
| Specialist | Domain expert for specific tasks |
| Aggregator | Combines outputs from multiple agents |
| Validator | Checks schema, contracts, constraints |
| Reviewer | Quality and correctness checks |
| Optimizer | Performance and cost tuning |
| Monitor | Health checks and alerting |

## Team Validation (6-Point Certification)

1. **has_agents** — At least one agent defined
2. **has_edges** — Communication paths defined
3. **valid_pattern** — Uses a recognized orchestration pattern
4. **acyclic** — No circular dependencies
5. **no_orphans** — All agents connected to the graph
6. **resource_limits** — Timeout and retry budgets set

## Execution Flow

```
Input -> Team Design -> Agent Routing -> Execution -> Telemetry -> Output
                                |                        |
                          Trace Spans              Performance Profile
                          Error Capture            Recommendations
                          Retry Logic              Cost Tracking
```

## Integration Points

| Integration | Description |
|-------------|-------------|
| skill-creator | Auto-generate SKILL.md from teams |
| Claude Desktop | MCP plugin for native use |
| Wix | Dashboard, DataSync, Content, E-Commerce scaffolds |
| OpenTelemetry | Observability export |
| LangGraph/CrewAI/AutoGen | Implementation templates |

## File Structure

```
HARNESS-re-harness/
├── src/                # MCP server implementations
├── install/            # Cross-platform installers
├── docs/               # Documentation
├── examples/           # Example team designs
├── mnt/                # Skill package files
├── README.md           # Entry point
└── .gitignore
```
