# HARNESS CLAUDE: Multi-Agent Orchestration Skill

**Version**: 2.0.0  
**Status**: Production-Grade  
**Last Updated**: 2026-06-30  
**Author**: Principal Engineering Team  
**License**: MIT  

---

## Overview

Harness Claude is a production-grade multi-agent orchestration skill enabling Claude to design, deploy, monitor, and optimize distributed agent teams across complex workflows. Designed for:

- **Multi-agent system design** with 6 proven architectural patterns
- **Real-time orchestration** with adaptive execution and failover
- **Performance monitoring** with detailed profiling and telemetry
- **Dynamic skill generation** via skill-creator integration
- **Plugin ecosystem** with extensible agent registries
- **Enterprise-scale reliability** with distributed tracing and audit logging
- **Security enforcement** with RBAC and capability-based access control
- **Cost optimization** via caching, memoization, and intelligent scheduling

---

## Core Capabilities (80% Disclosure)

### 1. Agent Team Design
Design specialist agents using 6 architectural patterns:

- **Pipeline**: Sequential workflow (A → B → C)
- **Fan-out/Fan-in**: Parallel workers with aggregation
- **Expert Pool**: Router-based specialist selection
- **Producer-Reviewer**: Quality-gated workflows
- **Supervisor**: Autonomous team with oversight
- **Hierarchical**: Multi-level delegation trees

**Usage**:
```
"Design a 7-agent expert pool for product discovery with semantic search, trending, user behavior, and catalog specialists. Include router, aggregator, ranker."
```

**Output**: JSON team definition + validation report (6/6 checks).

### 2. Skill Scaffolding
Generate complete SKILL.md with progressive disclosure:

- **Core tier (80%)**: Essential tools for standard use cases
- **Advanced tier (20%)**: Specialized tools for power users
- **Reference implementations**: Working code examples
- **Validation**: Completeness checks, dependency verification
- **Documentation**: Usage patterns, troubleshooting guides

**Usage**:
```
"Create a content analysis skill with semantic parsing, sentiment analysis, entity extraction, summarization, and inference capabilities. Progressive disclosure: core 5 tools, advanced 2 tools."
```

**Output**: SKILL.md + reference docs + test fixtures.

### 3. Real-Time Orchestration
Execute agent teams with adaptive control:

- **Execution modes**: Sequential, parallel, conditional, retry-bounded
- **Dynamic routing**: Context-aware agent selection
- **Failover**: Automatic fallback with circuit breaking
- **Timeout management**: Per-agent SLA enforcement
- **State synchronization**: Distributed state via merkle trees
- **Message ordering**: FIFO with optional causal ordering

**Usage**:
```
"Execute the product discovery team on query='hiking boots under $100' with 10s timeout, 3 retries, and aggregation strategy='weighted-consensus'."
```

**Output**: Final result + execution trace + telemetry.

### 4. Performance Profiling
Analyze agent and system performance:

- **Call graph analysis**: Critical path, bottleneck identification
- **Latency histogram**: P50, P95, P99 latencies per agent
- **Memory profile**: Allocation patterns, peak usage
- **Network analysis**: Message count, payload sizes, round-trip latencies
- **Concurrency metrics**: Task queuing depth, scheduling delays
- **Flamegraph generation**: Visualization of execution hot paths

**Usage**:
```
"Profile the last 100 executions of the dashboard team. Show bottlenecks, latency distribution, and optimization recommendations."
```

**Output**: JSON telemetry + SVG flamegraph + recommendations.

### 5. Distributed Tracing
Track execution across agent boundaries:

- **Span correlation**: Trace ID propagation across calls
- **Distributed context**: Parent-child relationships, causality
- **Timing breakdown**: Execution time per agent, queuing, serialization
- **Error attribution**: Which agent failed, why, impact scope
- **Audit trail**: Immutable execution log with timestamps

**Usage**:
```
"Show distributed trace for execution 'exec-2026-06-30-abc123' with full span hierarchy and timing breakdown."
```

**Output**: JSON trace (Jaeger format) + rendered timeline.

### 6. Skill-Creator Integration
Generate skill manifests for agent teams:

- **Auto-detection**: Analyze team to extract canonical tools
- **Documentation generation**: Tool descriptions from agent designs
- **Versioning**: Semantic versioning, migration guides
- **Dependency resolution**: Transitive skill dependencies
- **Registration**: Ready for claude_desktop_config.json

**Usage**:
```
"Generate a skill manifest for the dashboard team. Include tool descriptions, parameters, and output schemas. Version 1.0.0."
```

**Output**: skill-creator YAML + JSON schema + registration snippet.

### 7. Plugin Ecosystem
Extend Harness with custom agent registries:

- **Plugin registry**: Discover registered agent plugins
- **Custom routing**: User-defined agent selectors
- **Type system**: Validated input/output schemas
- **Versioning**: Compatible plugin versions, deprecation tracking
- **Marketplace**: Community agent library (future)

**Usage**:
```
"List all registered plugins. Show agent count, versions, and compatibility with core Harness 2.0.0."
```

**Output**: Plugin inventory + compatibility matrix.

### 8. Cost & Quota Management
Optimize resource usage and enforce limits:

- **Cost tracking**: Per-agent, per-execution, aggregate costs
- **Quota enforcement**: Rate limiting, token budget
- **Caching strategy**: Memoization, request deduplication
- **Batch optimization**: Intelligent batching for cost reduction
- **Budget alerts**: Warning thresholds, cost forecasting

**Usage**:
```
"Analyze cost trends for dashboard team. Show cost per execution, identify expensive agents, recommend optimizations."
```

**Output**: Cost report + optimization recommendations.

### 9. Validation & Certification
Verify team architecture and compliance:

- **Completeness checks**: All required agents present (6 checks)
- **Schema validation**: Input/output type contracts
- **Circular dependency detection**: Acyclic graph enforcement
- **Performance regression**: Comparing to baseline profile
- **Security audit**: Entitlement minimization, capability analysis
- **Certification**: Ready-for-production sign-off

**Usage**:
```
"Validate the dashboard team against production SLAs: <100ms P50, <500ms P99, zero circular deps, all agents passing fuzz tests."
```

**Output**: Pass/fail report + remediation steps.

---

## Advanced Capabilities (20% Disclosure)

### 10. Multi-Level Hierarchical Teams
Nested agent structures with delegation:

- **Tree orchestration**: Parent-child agent relationships
- **Cascading context**: Automatic context propagation down tree
- **Delegation strategies**: Breadth-first, depth-first, balanced
- **Resource pooling**: Shared resources across tree nodes
- **Hierarchical monitoring**: Aggregate metrics by level

**Usage**:
```
"Design a 3-level hierarchy: Router → {Parser, Analyzer, Synthesizer} → {Semantic, Syntactic, Lexical} sub-agents. Use balanced delegation."
```

### 11. Adaptive Routing & Learning
ML-driven agent selection:

- **Contextual bandits**: Thompson sampling for agent selection
- **Online learning**: Update routing weights from execution results
- **Specialization scoring**: Agent competency per query type
- **Cold-start handling**: Prior distribution from design phase
- **Regret bounds**: Theoretical convergence guarantees

**Usage**:
```
"Enable adaptive routing for the product discovery team. Start with equal weights, learn from 500 queries, target 5% regret bound."
```

### 12. Distributed Execution
Scale across multiple processes/machines:

- **Agent placement**: Pin agents to machines, load balancing
- **RPC transport**: gRPC, QUIC, WebSocket protocols
- **Consensus**: Raft or Paxos for distributed state
- **Partition tolerance**: CAP theorem trade-offs explicit
- **Network timeouts**: Adaptive backoff with exponential jitter

**Usage**:
```
"Deploy dashboard team across 4 machines: machine-1 (Router, UI), machine-2 (API), machine-3 (DB), machine-4 (Cache). Use gRPC transport."
```

### 13. Advanced Scheduling
Intelligent task scheduling with constraints:

- **Resource constraints**: CPU, memory, bandwidth allocation
- **Priority levels**: Critical, high, normal, low scheduling
- **Deadlines**: Hard/soft deadlines with preemption
- **Affinity rules**: Co-schedule related agents, avoid anti-affinity
- **Backpressure handling**: Queue depth limits, rejection strategies

**Usage**:
```
"Schedule dashboard team execution: Router=critical, API=high, DB=normal. Hard deadline=5s. Co-schedule API+Cache on same machine."
```

### 14. Advanced Error Recovery
Sophisticated fault tolerance:

- **Bulkhead isolation**: Failure containment via compartments
- **Graceful degradation**: Partial results on agent failure
- **Self-healing**: Automatic restart with exponential backoff
- **Canary deployments**: 1% → 10% → 100% gradual rollout
- **Rollback triggers**: SLO violations trigger automatic rollback

**Usage**:
```
"Configure dashboard team with: bulkhead isolation, degrade to cached results on API failure, canary deploy new version to 10%, rollback if P99>500ms."
```

### 15. State Machine Workflows
Explicit workflow state management:

- **State diagram**: Define all possible states and transitions
- **Entry/exit actions**: Hooks for setup/cleanup per state
- **Guard conditions**: Conditional transitions based on data
- **History states**: Shallow/deep history for complex workflows
- **Orthogonal regions**: Concurrent sub-workflows

**Usage**:
```
"Define dashboard team workflow: [Idle] --[request]--> [Loading] --[success/error]--> [Done] --[refresh]--> [Idle]. Include entry/exit hooks."
```

### 16. Observability Stack Integration
Connect to external observability systems:

- **OpenTelemetry**: Traces, metrics, logs in standard format
- **Prometheus**: Metrics scraping, alerting rules
- **Jaeger**: Distributed tracing with retention
- **ELK Stack**: Structured logging, visualization
- **Grafana**: Dashboards, alerting, on-call integration

**Usage**:
```
"Export dashboard team metrics to Prometheus. Create Grafana dashboard with: execution count, P50/P95/P99 latency, error rate, cost per execution."
```

### 17. Compliance & Audit Logging
Enterprise compliance requirements:

- **Immutable audit log**: Timestamped, signed execution record
- **Data lineage**: Track data through all transformations
- **Retention policies**: GDPR, HIPAA, SOC 2 compliance
- **Access control**: Role-based access with audit trail
- **Encryption**: At-rest and in-transit encryption

**Usage**:
```
"Enable SOC 2 compliance: immutable audit log, 90-day retention, encrypt at rest with AES-256, track data lineage, RBAC enforcement."
```

### 18. Advanced Caching & Memoization
Intelligent caching at multiple layers:

- **Content-addressed cache**: Hash-based deduplication
- **TTL & invalidation**: Time-based and event-based cache busting
- **Distributed cache**: Redis/Memcached integration
- **Cache warming**: Proactive pre-computation
- **Hitrate analytics**: Cache performance metrics

**Usage**:
```
"Configure caching for dashboard team: query results cache (TTL=3600s), schema cache (TTL=86400s), warm cache on startup, track hitrate per agent."
```

### 19. Chaos Engineering & Resilience Testing
Deliberate failure injection:

- **Fault injection**: Agent timeout, network partition, resource exhaustion
- **Scenario templates**: Standard failure scenarios
- **Blast radius**: Isolation levels, blast radius bounds
- **Recovery verification**: Automated validation of recovery
- **Report generation**: Resilience score with recommendations

**Usage**:
```
"Run chaos test: inject 50ms latency on API agent, simulate network partition on DB agent, verify dashboard team recovers within 2s, maintain 95% availability."
```

### 20. Cost Optimization Engine
Automated cost reduction:

- **Query optimization**: Rewrite queries to use cheaper agents
- **Batch processing**: Combine multiple requests, reduce per-request overhead
- **Smart sampling**: Approximate answers with reduced computation
- **Agent consolidation**: Merge similar agents to reduce overhead
- **Time-of-use pricing**: Schedule work during off-peak hours

**Usage**:
```
"Optimize dashboard team for cost: identify expensive agent pairs, recommend consolidation, suggest batch processing for queries, estimate 30% cost reduction."
```

---

## Usage Patterns

### Pattern 1: Quick Team Design
```
User: "Design a 5-agent team for log analysis: parser, filter, classify, aggregate, export."
Harness: Outputs JSON team + validation (5/6 checks) + recommendations.
User: "Run on this logfile.txt with 30s timeout."
Harness: Executes, returns structured logs + export.
```

### Pattern 2: Skill Generation Pipeline
```
User: "Create a content moderation skill from the expert pool design I just made."
Harness: Auto-analyzes team, generates SKILL.md with 8 core tools + 3 advanced tools.
User: "Register it with Claude Desktop."
Harness: Updates claude_desktop_config.json, restarts Claude Desktop.
```

### Pattern 3: Production Deployment
```
User: "Deploy dashboard team to production: 3 replicas, load balanced, 99.9% SLA, budget $500/month."
Harness: Designs distributed deployment, provisions infrastructure, monitors SLAs.
User: "Show cost breakdown and performance dashboard."
Harness: Generates Grafana dashboard, cost report, optimization recommendations.
```

### Pattern 4: Continuous Optimization
```
User: "Profile the dashboard team over last 7 days. Identify optimizations."
Harness: Analyzes 10k executions, generates flamegraph, cost breakdown, latency distribution.
Harness: Recommends: consolidate 2 agents, enable caching, adjust timeouts.
User: "Apply recommended optimizations."
Harness: Updates team config, reruns baseline, confirms 25% cost reduction.
```

---

## Configuration Reference

### Team Definition (JSON Schema)
```json
{
  "name": "dashboard-team",
  "version": "1.0.0",
  "agents": [
    {
      "id": "router",
      "type": "router",
      "input_schema": { "type": "object" },
      "output_schema": { "type": "object" },
      "timeout_ms": 1000,
      "retry_budget": 3,
      "required": true
    }
  ],
  "edges": [
    { "from": "router", "to": ["api", "cache"] }
  ],
  "constraints": {
    "max_depth": 3,
    "max_agents": 10,
    "timeout_ms": 30000
  }
}
```

### Execution Configuration
```json
{
  "team_id": "dashboard-team",
  "execution_mode": "parallel",
  "timeout_ms": 10000,
  "retry_strategy": "exponential",
  "max_retries": 3,
  "telemetry": {
    "enabled": true,
    "sample_rate": 1.0,
    "export_format": "opentelemetry"
  },
  "caching": {
    "enabled": true,
    "ttl_ms": 3600000
  }
}
```

---

## API Reference

### Primary Tools

| Tool | Purpose | Input | Output |
|------|---------|-------|--------|
| `harness_design_team()` | Design agent teams | pattern, agent_count, descriptions | team JSON + validation |
| `harness_execute_team()` | Run team on input | team_id, input, config | result + trace + telemetry |
| `harness_profile_execution()` | Analyze performance | execution_id, metrics | JSON profile + flamegraph |
| `harness_generate_skill()` | Create SKILL.md | team_id, tier_split | SKILL.md + schema + tests |
| `harness_validate_team()` | Certification | team_id, sla_config | pass/fail + remediation |
| `harness_export_metrics()` | Observability | team_id, format, filters | metrics in requested format |
| `harness_optimize_cost()` | Cost reduction | team_id, timeframe | recommendations + impact |
| `harness_deploy_distributed()` | Scale execution | team_id, machines, strategy | deployment config + status |

### Advanced Tools

| Tool | Purpose |
|------|---------|
| `harness_adaptive_routing()` | ML-driven agent selection |
| `harness_chaos_test()` | Failure injection testing |
| `harness_state_machine()` | Workflow state management |
| `harness_compliance_audit()` | Enterprise compliance |
| `harness_distributed_trace()` | Cross-boundary tracing |
| `harness_plugin_registry()` | Extension ecosystem |

---

## Best Practices

1. **Team Design**: Start with pipeline, graduate to expert pool for complex cases
2. **Testing**: Always run validation checks before production deployment
3. **Monitoring**: Enable OpenTelemetry for all production teams
4. **Cost Control**: Review cost reports weekly, set budget alerts
5. **Security**: Minimize agent entitlements, enable audit logging
6. **Resilience**: Configure bulkhead isolation, test chaos scenarios
7. **Documentation**: Auto-generate SKILL.md, keep examples updated

---

## Troubleshooting

**Issue**: Agent timeout on large inputs  
**Fix**: Increase timeout_ms, enable batching, or split input across multiple executions

**Issue**: High memory usage  
**Fix**: Enable caching to reduce recomputation, profile allocations, consider streaming

**Issue**: Circular dependency detected  
**Fix**: Review team graph, break cycles with intermediate agents or message queues

**Issue**: Cost higher than expected  
**Fix**: Run cost optimization, enable caching, batch requests, use cheaper agent alternatives

---

## Integration Points

- **Skill-Creator**: Auto-generate skill manifests from teams
- **Claude Desktop**: Register as MCP plugin
- **GitHub Actions**: Deploy teams via CI/CD
- **DataRobot**: Integrate with model deployment
- **Wix**: Multi-agent scaffolding for site builders
- **OpenTelemetry**: Observability export
- **Kubernetes**: Distributed deployment

---

## Support & Resources

- **Repository**: github.com/anthropic/harness-claude
- **Issues**: github.com/anthropic/harness-claude/issues
- **Discussions**: github.com/anthropic/harness-claude/discussions
- **Docs**: harness-claude.anthropic.com
- **Discord**: discord.gg/harness-claude

---

**End of HARNESS CLAUDE SKILL.md**
