# HARNESS: Advanced Multi-Agent Orchestration Skill for Claude

**Version**: 3.0.0 (Claude-Optimized)  
**Category**: Agent Orchestration & Multi-Agent Systems  
**Status**: Production-Ready  
**Maintained by**: Claude Engineering Team

---

## SKILL SUMMARY

Harness is a production-grade **multi-agent orchestration engine** designed for Claude. It enables designing, deploying, and optimizing teams of specialized AI agents that work in coordinated patterns to solve complex problems at scale.

**Primary Use Cases**:
- Multi-agent team design and validation
- Advanced orchestration pattern implementation
- Prompt engineering and optimization
- Agent performance profiling and analytics
- Context window and token management
- Failure recovery and resilience
- Learning feedback loops

**Trigger Phrases**:
- "Design a multi-agent team"
- "Orchestrate agents for [task]"
- "Optimize this prompt"
- "Profile agent performance"
- "Create an agent workflow"
- "Set up team coordination"
- "Validate team architecture"
- "Get execution recommendations"

---

## CORE CAPABILITIES

### 1. Agent Team Design
**Tool**: `design_agent_team`

Design specialized multi-agent teams optimized for specific domains and orchestration patterns.

**Usage**:
```
design_agent_team(
  name="Product Discovery Engine",
  description="Multi-agent system for discovering relevant products",
  pattern="expert_pool",  # or: sequential, parallel, fan_out_fan_in, etc.
  domain="e-commerce",
  agent_count=5,
  context_budget=128000
)
```

**Supported Patterns**:
- `sequential`: Agents execute in order, passing output to next
- `parallel`: All agents process same input concurrently
- `fan_out_fan_in`: Distribute to many, gather results
- `pipeline`: Stream processing across agents
- `expert_pool`: Router directs to domain specialists
- `producer_reviewer`: Produce-review-refine workflow
- `supervisor`: Central coordinator with workers
- `hierarchical`: Multi-level management structure
- `map_reduce`: Distribute-process-reduce model
- `tournament`: Competitive selection mechanism

**Output Structure**:
```json
{
  "team_id": "abc123def456",
  "name": "Product Discovery Engine",
  "pattern": "expert_pool",
  "agents": [
    {
      "id": "agent_xyz",
      "name": "Semantic Search Specialist",
      "role": "specialist",
      "model": "claude-opus-4.6",
      "capabilities": ["semantic search", "relevance ranking"]
    }
  ],
  "status": "created",
  "validation": {
    "passed": 6,
    "total": 6,
    "details": {
      "coverage": true,
      "no_single_points_of_failure": true,
      "clear_roles": true,
      "communication_paths": true,
      "resource_allocation": true,
      "timeout_consistent": true
    }
  }
}
```

### 2. Prompt Optimization
**Tool**: `optimize_prompt`

Analyze and optimize prompts for clarity, efficiency, and effectiveness.

**Usage**:
```
optimize_prompt(
  prompt="Your prompt here",
  constraints=["max_tokens:500", "style:concise"]
)
```

**Optimizations Applied**:
- Clarity improvement: Remove hedging and politeness markers
- Conciseness: Reduce redundancy and wordiness
- Structure: Add explicit formatting and output specifications
- Effectiveness: Include step-by-step reasoning guidance
- Consistency: Normalize terminology and style

**Output Structure**:
```json
{
  "original": "...",
  "optimized": "...",
  "improvements": [
    "Remove hedging language for clarity",
    "Add explicit output format specification",
    "Add step-by-step reasoning guidance"
  ],
  "estimated_token_reduction": 42,
  "estimated_quality_change": "improved",
  "confidence": 0.92
}
```

### 3. Performance Profiling
**Tool**: `profile_agent`

Get detailed performance metrics for any agent.

**Usage**:
```
profile_agent(agent_id="agent_xyz")
```

**Metrics Tracked**:
- Call count and success rate
- Token usage and cost tracking
- Latency percentiles (avg, p95, p99)
- Failure tracking and recovery
- Health status classification

**Output Structure**:
```json
{
  "agent_id": "agent_xyz",
  "calls": 1250,
  "successes": 1187,
  "failures": 63,
  "success_rate_percent": 94.96,
  "total_tokens_used": 487650,
  "total_cost": 9.75,
  "latency_ms": {
    "average": 245.3,
    "p95": 1523.7,
    "p99": 2847.2
  },
  "failures_24h": 3,
  "last_failure": "2024-12-20T14:32:15Z",
  "health_status": "healthy"
}
```

### 4. Team Metrics Aggregation
**Tool**: `get_team_metrics`

Get aggregate performance metrics for entire team.

**Usage**:
```
get_team_metrics(team_id="abc123def456")
```

**Aggregated Insights**:
- Per-agent success rates and costs
- Team-wide token usage and spending
- Bottleneck identification
- Cost-effectiveness analysis

### 5. Orchestration Generation
**Tool**: `generate_orchestration`

Generate complete execution template for orchestration pattern.

**Usage**:
```
generate_orchestration(team_id="abc123def456")
```

**Output Includes**:
- Execution plan with staging
- Agent coordination protocol
- Error recovery strategy
- Context window allocation
- Message schema definition
- Communication patterns

### 6. Team Management
**Tool**: `list_teams`

List all designed and active teams.

**Usage**:
```
list_teams()
```

### 7. Recommendations Engine
**Tool**: `get_recommendations`

Get AI-powered improvement recommendations for team.

**Usage**:
```
get_recommendations(team_id="abc123def456")
```

**Recommendation Categories**:
- Success rate improvement
- Latency optimization
- Token usage reduction
- Cost efficiency
- Failure recovery enhancement
- Model selection optimization

---

## ADVANCED FEATURES

### Multi-Model Routing
Automatic fallback chain with secondary and tertiary models:
- Primary: `claude-opus-4.6` (best quality)
- Secondary: `claude-sonnet-4.6` (balanced)
- Tertiary: `claude-haiku-4.5` (fastest)

### Context Window Management
Intelligent allocation across team:
- Role-based allocation (supervisors get more)
- Reserved output space (prevents context overflow)
- Dynamic adjustment based on usage patterns

### Failure Recovery
Multiple recovery strategies:
- Exponential backoff retry (up to 3 attempts)
- Fallback to alternative model
- Graceful degradation (partial results)
- Human escalation (if all agents fail)

### Learning Feedback Loops
Continuous improvement through:
- Execution history tracking
- Metrics accumulation
- Performance trending
- Anomaly detection
- Recommendation generation

### Cost Optimization
- Per-token cost tracking
- Agent efficiency metrics
- Model-based cost comparison
- Spending forecasts

---

## INTEGRATION PATTERNS

### Pattern 1: Sequential Workflow
```python
# Design team for linear execution
team = design_agent_team(
  name="Document Processing Pipeline",
  pattern="sequential",
  domain="document analysis",
  agent_count=4
)

# Generates agents:
# 1. Initiator (validates input)
# 2. Parser (extracts structure)
# 3. Analyzer (processes content)
# 4. Finalizer (aggregates output)
```

### Pattern 2: Expert Pool
```python
# Design team with specialist routing
team = design_agent_team(
  name="Support Ticket Router",
  pattern="expert_pool",
  domain="customer support",
  agent_count=5
)

# Generates:
# Router agent directs to:
# - Technical Support Specialist
# - Billing Specialist
# - Account Specialist
# Aggregator combines responses
```

### Pattern 3: Producer-Reviewer
```python
# Design team with quality gate
team = design_agent_team(
  name="Content Generation Pipeline",
  pattern="producer_reviewer",
  domain="content creation",
  agent_count=4
)

# Generates:
# Producer → Reviewer → Refiner → Validator
```

### Pattern 4: Hierarchical
```python
# Design team with management structure
team = design_agent_team(
  name="Enterprise Decision System",
  pattern="hierarchical",
  domain="enterprise operations",
  agent_count=5
)

# Generates:
# Supervisor
#   ├─ Manager 1
#   │   ├─ Worker 1
#   │   └─ Worker 2
#   └─ Monitor
```

---

## USAGE EXAMPLES

### Example 1: Design and Deploy Product Discovery Team
```
# Step 1: Design the team
team = design_agent_team(
  name="Product Discovery System",
  description="Multi-specialist product discovery for e-commerce",
  pattern="expert_pool",
  domain="e-commerce product discovery",
  agent_count=5,
  context_budget=128000
)

# Output: team_id = "abc123"

# Step 2: Get orchestration template
orchestration = generate_orchestration(team_id="abc123")

# Step 3: Monitor performance
metrics = get_team_metrics(team_id="abc123")

# Step 4: Get improvement recommendations
recommendations = get_recommendations(team_id="abc123")
```

### Example 2: Optimize Complex Prompt
```
# Original prompt (too verbose)
original = """
You are tasked with analyzing the following document. 
Please carefully review the content and, if possible, 
extract the key points. However, if you find that the 
document is unclear, please do your best to interpret 
the intent. Thank you for your attention to this matter.
"""

# Optimize it
result = optimize_prompt(prompt=original)

# Output includes:
# - Optimized version (clearer, 15% shorter)
# - Specific improvements made
# - Estimated quality change
```

### Example 3: Profile Agent Performance
```
# Get detailed metrics for specific agent
profile = profile_agent(agent_id="agent_semantic_search")

# Reveals:
# - Success rate: 94.96%
# - Average latency: 245ms
# - P99 latency: 2847ms (potential timeout issue)
# - Recommendation: Consider parallelization
```

### Example 4: Design Domain-Specific Team
```
team = design_agent_team(
  name="Financial Analysis Team",
  description="Multi-agent system for financial document analysis",
  pattern="hierarchical",
  domain="financial analysis",
  agent_count=6,
  context_budget=256000  # Larger budget for complex docs
)

# Validates and returns specialized agents:
# - Supervisor (orchestration)
# - Financial Analyst (primary analysis)
# - Risk Analyst (risk assessment)
# - Compliance Analyst (regulatory check)
# - Quality Monitor (output validation)
```

---

## CONFIGURATION AND CUSTOMIZATION

### Custom Context Budget
```python
# Large budget for complex tasks (256K tokens)
team = design_agent_team(
  name="Large Document Analysis",
  pattern="sequential",
  domain="legal document analysis",
  context_budget=256000
)

# Small budget for quick tasks (64K tokens)
team = design_agent_team(
  name="Quick Response System",
  pattern="parallel",
  domain="customer response",
  context_budget=64000
)
```

### Agent Customization
Agents are customized by:
- Role (router, specialist, aggregator, validator, etc.)
- Domain (e-commerce, finance, legal, healthcare, etc.)
- Capabilities (derived from role and domain)
- Model selection (claude-opus-4.6 recommended)
- Fallback chains (automatic secondary models)

---

## LIMITATIONS AND CONSTRAINTS

- **Team Size**: Recommended 3-7 agents (3 minimum, 9 maximum)
- **Context Budget**: Total tokens allocated across all agents
- **Timeout**: Maximum execution time per team (default: 300 seconds)
- **Max Iterations**: Maximum coordination rounds (default: 10)
- **Agent Timeout**: Per-agent timeout (default: 30 seconds)

---

## ERROR HANDLING AND RECOVERY

### Automatic Recovery
- Retry with exponential backoff (100ms base)
- Fallback to secondary model if primary fails
- Graceful degradation (partial results if possible)
- Human escalation if all recovery fails

### Manual Recovery
```python
# Check team health
metrics = get_team_metrics(team_id="abc123")

# If degraded, get recommendations
recommendations = get_recommendations(team_id="abc123")

# Follow recommendations for repair
```

---

## PERFORMANCE OPTIMIZATION

### Prompt Optimization
Use `optimize_prompt` to reduce token usage by 10-25% while improving clarity.

### Agent Profiling
Use `profile_agent` to identify bottlenecks:
- High latency → parallelization
- High token usage → prompt optimization
- Low success rate → model upgrade or retry strategy

### Team-Level Optimization
Use `get_recommendations` for system-wide improvements.

---

## SECURITY AND GOVERNANCE

### Built-in Controls
- Per-agent timeout enforcement
- Context window limits
- Token usage tracking
- Cost attribution
- Failure tracking and alerting
- Audit logging of all executions

### Best Practices
1. Start with small teams (3-4 agents)
2. Validate team architecture before deployment
3. Monitor metrics continuously
4. Act on recommendations proactively
5. Test with small context budgets first

---

## MAINTENANCE AND MONITORING

### Metrics Tracking
- Call counts and success rates
- Token usage and costs
- Latency distributions
- Failure tracking
- Health status

### Recommendations
Generated for:
- Low success rates (<80%)
- High latency (>5 seconds)
- High token usage (>30% budget)

### Alerting
Automatic alerts when:
- Success rate drops below 95%
- P99 latency exceeds threshold
- Token usage exceeds forecast
- Cost per call increases

---

## INTEGRATION WITH CLAUDE

### In Claude.ai
Use with `/skill harness` to access all capabilities.

### In Claude Desktop
Use via MCP server integration for seamless agent orchestration.

### In Claude API
Call tools directly via model_tools interface.

---

## IMPLEMENTATION CHECKLIST

- [ ] Review all 9 orchestration patterns
- [ ] Design initial team for primary use case
- [ ] Validate team architecture (6/6 checks)
- [ ] Generate orchestration template
- [ ] Set up performance monitoring
- [ ] Configure fallback strategies
- [ ] Establish metrics baseline
- [ ] Document team specifications
- [ ] Train team on domain specifics
- [ ] Deploy and monitor

---

## SUPPORT AND TROUBLESHOOTING

### Issue: Low Success Rate
**Solution**: 
1. Profile agent with `profile_agent`
2. Optimize prompt with `optimize_prompt`
3. Review recommendations with `get_recommendations`
4. Consider model upgrade to claude-opus-4.6

### Issue: High Latency
**Solution**:
1. Check p95/p99 percentiles with `profile_agent`
2. Consider parallel execution pattern
3. Reduce context budget per agent
4. Check for network/system issues

### Issue: Context Overflow
**Solution**:
1. Get team metrics with `get_team_metrics`
2. Optimize prompts with `optimize_prompt`
3. Reduce context budget
4. Split large tasks into subtasks

### Issue: High Cost
**Solution**:
1. Profile agents for token efficiency
2. Optimize prompts
3. Consider model downgrade (sonnet → haiku)
4. Reduce team size or context budget

---

## ROADMAP AND FUTURE ENHANCEMENTS

- [ ] Visual team designer
- [ ] Real-time collaboration features
- [ ] Advanced cost forecasting
- [ ] Custom agent templates
- [ ] Integration with vector databases
- [ ] Advanced caching strategies
- [ ] Custom metrics and KPIs
- [ ] Team versioning and rollback
- [ ] Export to production systems

---

## REFERENCES AND RESOURCES

- **MCP Specification**: https://spec.modelcontextprotocol.io/
- **Claude Documentation**: https://docs.anthropic.com
- **Advanced Prompting**: https://docs.anthropic.com/claude/guides/prompt-engineering
- **Agent Design Patterns**: See companion guide "Multi-Agent Architecture Patterns"

---

## SKILL METADATA

| Property | Value |
|----------|-------|
| Skill Name | `harness` |
| Version | 3.0.0 |
| Language | Python 3.10+ |
| Category | Agent Orchestration |
| Complexity | Advanced |
| Estimated Learning Time | 30 minutes |
| Typical Setup Time | 5 minutes |
| Dependencies | mcp, anthropic-sdk |
| Production Ready | Yes |
| Maintained | Yes |

---

**Last Updated**: 2024-12-20  
**Status**: Stable - Production Ready  
**Support Level**: Enterprise
