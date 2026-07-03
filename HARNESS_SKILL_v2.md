# Harness: Multi-Agent Orchestration Skill for Claude

> **Enterprise-Grade AI Agent Team Design, Orchestration, Validation, and Deployment**

**Version**: 2.0 (Production)  
**Last Updated**: June 2026  
**Status**: ✓ Ready for Production

---

## Overview

Harness is a comprehensive framework for designing, validating, orchestrating, and deploying multi-agent AI systems within Claude. It provides:

- **Advanced Agent Design**: 12+ architectural patterns for agent composition
- **Team Orchestration**: Sophisticated team coordination and state management
- **Validation Framework**: Complete team architecture verification and quality gates
- **Performance Optimization**: Profiling, caching, resource pooling, and optimization
- **Security Hardening**: Input validation, isolation boundaries, privilege separation
- **Deployment Automation**: Cross-platform installation, CI/CD integration, rollback strategies
- **Observability**: Metrics, tracing, health monitoring, and performance dashboards
- **Integration Ecosystems**: Wix, skill-creator, custom MCP servers, external APIs
- **Recovery and Resilience**: Circuit breakers, retry strategies, graceful degradation

---

## Core Capabilities

### 1. Agent Architecture Patterns (12+)

**Sequential Pipeline**
```
Agent1 → Agent2 → Agent3 → Agent4 → Result
```
Linear information flow with ordered processing. Best for: workflows with clear dependencies.

**Parallel Fan-Out/Fan-In**
```
Input → {Agent1, Agent2, Agent3} → Aggregator → Output
```
Distribute work in parallel, collect results. Best for: independent tasks, performance-critical paths.

**Expert Pool**
```
Router → {Expert1, Expert2, ..., ExpertN} → Selector → Output
```
Multiple specialists, intelligent routing. Best for: decision trees, domain-specific analysis.

**Producer-Reviewer**
```
Producer → Review (Accept/Reject) → [Publish | Revise] → Result
```
Quality gate with feedback loop. Best for: content generation, code review, validation.

**Supervisor Pattern**
```
Supervisor → {Worker1, Worker2, ...} → Aggregator
     ↓
  [Monitor & Retry]
```
Central coordinator with health monitoring. Best for: complex workflows, error recovery.

**Hierarchical Composition**
```
       Top-Level Orchestrator
        /        |        \
    Team1      Team2      Team3
    / | \      / | \      / | \
   A1 A2 A3   B1 B2 B3   C1 C2 C3
```
Nested agent teams. Best for: large-scale systems, team-based organization.

**Debate/Consensus**
```
Agent1 ─┐
Agent2 ─┼→ Evaluator → Consensus
Agent3 ─┘
```
Multiple viewpoints, consensus building. Best for: complex decisions, adversarial validation.

**Layered Processing**
```
Layer1 (Parse) → Layer2 (Analyze) → Layer3 (Synthesize) → Result
```
Staged data transformation. Best for: NLP pipelines, multi-stage processing.

**Request-Response with Feedback Loop**
```
Request → Agent → Response → Feedback → [Accept | Refine]
```
Iterative refinement. Best for: creative work, user-facing systems.

**Event-Driven Orchestration**
```
Event Source → Event Bus → [Agent1, Agent2, Agent3] → Handlers
```
Async event processing. Best for: real-time systems, reactive architecture.

**Load-Balanced Routing**
```
Input → Load Balancer → {Agent1, Agent2, ...} with Health Checks
```
Dynamic workload distribution. Best for: high-throughput systems, auto-scaling.

**Adaptive Selection**
```
Analyzer → {Agent Selection Strategy} → Best Fit Agent → Output
```
Context-aware agent selection. Best for: dynamic routing, adaptive systems.

---

### 2. Team Design Framework

**Complete Team Specification**:
```yaml
Team:
  Name: "Product Discovery"
  Purpose: "Find optimal products based on user requirements"
  Members:
    - Name: "SemanticSearch"
      Role: "Information Retrieval"
      Responsibilities: ["Query expansion", "Document matching"]
      Dependencies: []
      Timeout: 30
      RetryPolicy: "exponential_backoff"
      
    - Name: "TrendAnalyzer"
      Role: "Market Intelligence"
      Responsibilities: ["Trend detection", "Popularity scoring"]
      Dependencies: ["SemanticSearch"]
      Timeout: 45
      RetryPolicy: "circuit_breaker"
      
    - Name: "UserBehaviorPredictor"
      Role: "User Analytics"
      Responsibilities: ["Purchase prediction", "Preference modeling"]
      Dependencies: []
      Timeout: 60
      RetryPolicy: "graceful_degradation"
      
    - Name: "ResultAggregator"
      Role: "Result Synthesis"
      Responsibilities: ["Merge results", "Rank products", "Format output"]
      Dependencies: ["SemanticSearch", "TrendAnalyzer", "UserBehaviorPredictor"]
      Timeout: 30
      RetryPolicy: "exponential_backoff"
      
  OrchestrationPattern: "Expert Pool with Aggregation"
  
  StateManagement:
    Type: "Distributed"
    Checkpointing: "Per-stage"
    RecoveryStrategy: "Full replay from last checkpoint"
    ConsistencyLevel: "Eventual"
    
  Constraints:
    MaxConcurrency: 4
    MaxMemoryPerAgent: "512MB"
    MaxDiskPerAgent: "1GB"
    MaxNetworkBandwidth: "100Mbps"
    
  SLA:
    AvailabilityTarget: "99.9%"
    LatencyTarget: "P95 < 2s"
    ThroughputTarget: "1000 req/s"
    
  Security:
    InputValidation: "Strict"
    SandboxIsolation: "Mandatory"
    PrivilegeLevel: "Least privilege"
    AuditLogging: "Full"
```

---

### 3. Validation Framework

**Comprehensive Validation Checks**:

1. **Architecture Validation**
   - ✓ No circular dependencies
   - ✓ All dependencies resolvable
   - ✓ Proper isolation boundaries
   - ✓ Clear data flow paths
   - ✓ No implicit state sharing

2. **Member Validation**
   - ✓ All members have clear roles
   - ✓ Responsibilities don't overlap
   - ✓ Dependencies are justified
   - ✓ Expertise matches role
   - ✓ No bottlenecks in critical path

3. **Communication Validation**
   - ✓ Message contracts defined
   - ✓ Schema versioning clear
   - ✓ Error handling complete
   - ✓ Timeout strategies defined
   - ✓ Retry logic appropriate

4. **Performance Validation**
   - ✓ Latency targets achievable
   - ✓ Throughput constraints met
   - ✓ Resource allocations realistic
   - ✓ Scaling strategy defined
   - ✓ Bottleneck analysis complete

5. **Security Validation**
   - ✓ All inputs validated
   - ✓ Privilege separation enforced
   - ✓ Data isolation maintained
   - ✓ Audit logging enabled
   - ✓ Threat model assessed

6. **Resilience Validation**
   - ✓ Failure modes identified
   - ✓ Recovery strategies defined
   - ✓ Graceful degradation possible
   - ✓ Health monitoring implemented
   - ✓ Rollback procedures clear

---

### 4. Advanced Features

#### State Management
- **Distributed State**: Share state across agents
- **Checkpointing**: Save progress at critical points
- **Versioning**: Track state evolution
- **Consistency Levels**: Strong, eventual, causal
- **Recovery**: Replay from checkpoints

#### Performance Optimization
- **Caching Layer**: Multi-level cache with TTL
- **Resource Pooling**: Reuse expensive resources
- **Lazy Evaluation**: Compute only when needed
- **Batch Processing**: Combine related operations
- **Circuit Breakers**: Prevent cascading failures
- **Rate Limiting**: Control resource usage
- **Load Balancing**: Distribute work evenly

#### Error Handling & Recovery
- **Exponential Backoff**: Intelligent retry strategy
- **Circuit Breaker Pattern**: Fail fast when degraded
- **Graceful Degradation**: Fallback to partial results
- **Error Categorization**: Transient vs. permanent
- **Health Checks**: Monitor agent status
- **Auto-Healing**: Self-recovery mechanisms

#### Observability & Monitoring
- **Distributed Tracing**: Track requests end-to-end
- **Metrics Collection**: Performance and health metrics
- **Logging**: Structured, contextual logging
- **Alerting**: Proactive issue detection
- **Health Dashboard**: Real-time system status
- **Performance Profiling**: Identify bottlenecks

#### Security Hardening
- **Input Validation**: Strict input checking
- **Sandbox Isolation**: Agent isolation
- **Privilege Separation**: Minimal permissions
- **Audit Logging**: Complete audit trail
- **Threat Modeling**: STRIDE analysis
- **Vulnerability Scanning**: CVE detection
- **Rate Limiting**: DDoS protection

---

## Usage Patterns

### Pattern 1: Design Multi-Agent Team

```
"Design a multi-agent team for [domain/task]"

Harness provides:
- Architecture assessment
- Role identification
- Team composition
- Dependency mapping
- Validation report
- Optimization recommendations
```

### Pattern 2: Validate Team Architecture

```
"Validate this team architecture: [specification]"

Harness provides:
- Completeness check
- Dependency analysis
- Performance assessment
- Security review
- Risk identification
- Improvement suggestions
```

### Pattern 3: Scaffold Implementation

```
"Scaffold implementation for [team design]"

Harness provides:
- Agent interface definitions
- Message contracts
- State schemas
- Error handling templates
- Testing framework
- Deployment playbook
```

### Pattern 4: Optimize Performance

```
"Optimize this team for performance"

Harness provides:
- Bottleneck analysis
- Caching strategy
- Parallelization plan
- Resource optimization
- Load balancing
- Performance targets
```

### Pattern 5: Integrate with Platforms

```
"Create a Wix [feature] with multi-agent architecture"

Harness provides:
- Architecture design
- API contracts
- Integration points
- Security considerations
- Deployment strategy
- Testing approach
```

---

## Advanced Capabilities

### Orchestration Engine
- **Topology-Aware Scheduling**: Respects dependencies
- **Dynamic Routing**: Adapts to available agents
- **Adaptive Timeouts**: Learns from history
- **Intelligent Queuing**: Priority and fairness
- **Backpressure Handling**: Flow control
- **Resource Allocation**: Fair resource distribution

### State Management System
- **Distributed State**: Shared across agents
- **Consistency Guarantees**: Strong/eventual/causal
- **Snapshot Isolation**: MVCC implementation
- **Optimistic Locking**: Conflict detection
- **State Versioning**: History and rollback
- **Compaction**: Efficient storage

### Performance Profiler
- **Latency Analysis**: P50, P95, P99
- **Throughput Measurement**: Requests per second
- **Resource Monitoring**: CPU, memory, network
- **Bottleneck Identification**: Hotspot detection
- **Regression Detection**: Performance degradation
- **Recommendations**: Optimization suggestions

### Security Framework
- **Input Validation**: Type checking, bounds checking
- **Sanitization**: XSS, injection prevention
- **Privilege Verification**: Authorization checks
- **Audit Logging**: Immutable event log
- **Encryption**: Data in transit and at rest
- **Compliance**: GDPR, SOC2, ISO27001

### Integration Framework
- **MCP Server Support**: Custom MCP integrations
- **REST API Clients**: HTTP API communication
- **Message Queue Support**: Async messaging
- **Database Connectors**: Data persistence
- **Cache Integration**: Redis, Memcached
- **Monitoring Export**: Prometheus, Datadog

---

## API Reference

### Core Functions

#### design_agent_team
```python
def design_agent_team(
    domain: str,
    objectives: str,
    constraints: dict,
    budget: float = None
) -> TeamDesign:
    """
    Design optimal multi-agent team for domain.
    
    Args:
        domain: Problem domain (e.g., "product discovery")
        objectives: Team objectives and success criteria
        constraints: Resource, latency, cost constraints
        budget: Optional cost budget in tokens
        
    Returns:
        TeamDesign with architecture, members, and analysis
    """
```

#### validate_team_architecture
```python
def validate_team_architecture(
    team: TeamDesign,
    strictness: str = "moderate"
) -> ValidationReport:
    """
    Validate team architecture completeness.
    
    Args:
        team: Team design to validate
        strictness: "lenient", "moderate", "strict"
        
    Returns:
        ValidationReport with checks and recommendations
    """
```

#### optimize_team_performance
```python
def optimize_team_performance(
    team: TeamDesign,
    profile_data: dict = None
) -> OptimizationPlan:
    """
    Generate performance optimization plan.
    
    Args:
        team: Team design to optimize
        profile_data: Optional profiling data
        
    Returns:
        OptimizationPlan with recommendations
    """
```

#### generate_orchestration_template
```python
def generate_orchestration_template(
    team: TeamDesign,
    language: str = "python",
    framework: str = "langgraph"
) -> ImplementationTemplate:
    """
    Generate implementation template for team.
    
    Args:
        team: Team design
        language: Programming language
        framework: Framework (langgraph, crewai, autogen, etc.)
        
    Returns:
        ImplementationTemplate with code scaffolds
    """
```

#### assess_team_security
```python
def assess_team_security(
    team: TeamDesign,
    threat_model: str = "stride"
) -> SecurityReport:
    """
    Assess team security and threat model.
    
    Args:
        team: Team design
        threat_model: "stride", "pasta", "linddun"
        
    Returns:
        SecurityReport with vulnerabilities and mitigations
    """
```

---

## Integration Points

### Wix Integration
```
/wix_app_agent_scaffold
  → Designs agent architecture for Wix apps
  → Integrates with Wix APIs (WDS, HTTP Functions, Data Collections)
  → Generates implementation templates
  → Includes Wix-specific patterns and examples
```

### skill-creator Integration
```
/skill_creator_integration
  → Converts team designs to SKILL.md
  → Generates trigger patterns
  → Creates progressive disclosure structure
  → Includes evaluation framework
```

### MCP Server Integration
```
/mcp_integration
  → Generates MCP server implementations
  → Creates tool definitions
  → Implements resource management
  → Generates Claude Desktop config
```

### Custom Extensions
```
/create_custom_extension
  → Define custom agent patterns
  → Register domain-specific tools
  → Implement specialized validators
  → Deploy custom orchestrators
```

---

## Advanced Examples

### Example 1: E-Commerce Recommendation Team

```
Design a multi-agent team for real-time product recommendations

Architecture: Expert Pool with Intelligent Router

Members:
  1. UserProfileAnalyzer
     - Analyzes user history, preferences, behavior
     - Outputs: User vector, preference model
     
  2. ProductSemanticSearcher
     - Semantic similarity matching
     - Outputs: Candidate products
     
  3. CollaborativeFilteringAgent
     - Item-item and user-user similarity
     - Outputs: Collaborative scores
     
  4. TrendDetector
     - Real-time trend detection
     - Outputs: Trending products, momentum
     
  5. InventoryChecker
     - Stock availability verification
     - Outputs: Available products subset
     
  6. PricingOptimizer
     - Price-demand elasticity analysis
     - Outputs: Optimal price point
     
  7. ResultRanker
     - Multi-factor ranking
     - Outputs: Ranked recommendations

Orchestration:
  1. UserProfileAnalyzer (parallel to semantic search)
  2. ProductSemanticSearcher (parallel to collaborative filtering)
  3. CollaborativeFilteringAgent
  4. TrendDetector (parallel)
  5. InventoryChecker (parallel)
  6. PricingOptimizer
  7. ResultRanker (aggregates all)

SLA:
  - Latency: P95 < 500ms
  - Availability: 99.95%
  - Accuracy: NDCG@10 > 0.75
```

### Example 2: Content Quality Assurance Team

```
Design a multi-agent team for content quality assurance

Architecture: Producer-Reviewer with Multi-Stage Pipeline

Pipeline:
  1. ContentParser → Extracts structure
  2. GrammarChecker → Syntax validation
  3. SemanticAnalyzer → Meaning verification
  4. FactChecker → Claim verification
  5. BiasDetector → Bias identification
  6. ToneAnalyzer → Appropriate tone
  7. ReviewAggregator → Consensus review
  8. AutoCorrect → Corrections suggestion
  9. HumanReview → Final approval (if needed)

Feedback Loop:
  - If AutoCorrect suggestions accepted → Update content
  - If HumanReview needed → Escalate
  - If failed → Return to author

Quality Gates:
  - Grammar score > 95%
  - Semantic coherence > 90%
  - Fact verification > 98%
  - Bias score < 5%
  - Tone match > 85%
```

### Example 3: Data Analysis & Reporting Team

```
Design a multi-agent team for intelligent data analysis

Architecture: Layered Processing with Feedback

Layer 1 - Data Ingestion:
  - DataFetcher
  - DataValidator
  - DataCleaner
  
Layer 2 - Analysis:
  - StatisticalAnalyzer
  - TrendAnalyzer
  - AnomalyDetector
  - CorrelationAnalyzer
  
Layer 3 - Synthesis:
  - InsightExtractor
  - StoryBuilder
  - VisualizationDesigner
  - ReportGenerator
  
Layer 4 - Review:
  - AnalysisValidator
  - ClarityChecker
  - RecommendationReviewer

Feedback Loop:
  - User questions/clarifications
  - Drill-down into details
  - Refinement of analysis
```

---

## Complete Workflow

### 1. Design Phase
```
User: "Design a team for X"
  ↓
Harness analyzes domain, constraints, objectives
  ↓
Generates 3-5 architecture options
  ↓
Recommends optimal architecture
  ↓
Provides team composition
  ↓
Outputs: TeamDesign object
```

### 2. Validation Phase
```
TeamDesign → Harness validation framework
  ↓
Runs 6 validation categories (Architecture, Members, Communication, etc.)
  ↓
Generates ValidationReport
  ↓
Identifies gaps and risks
  ↓
Outputs: Improvement recommendations
```

### 3. Optimization Phase
```
TeamDesign + Performance Profile → Optimization engine
  ↓
Analyzes bottlenecks
  ↓
Identifies optimization opportunities
  ↓
Generates OptimizationPlan
  ↓
Outputs: Specific improvements with impact estimates
```

### 4. Implementation Phase
```
TeamDesign → Template generator
  ↓
Generates implementation templates
  ↓
Creates agent interfaces
  ↓
Defines message contracts
  ↓
Provides test scaffolds
  ↓
Outputs: Ready-to-code templates
```

### 5. Deployment Phase
```
Implementation → Deployment orchestrator
  ↓
Generates deployment scripts
  ↓
Creates CI/CD pipelines
  ↓
Defines health checks
  ↓
Outputs: Production-ready deployment plans
```

---

## Evaluation Framework

### Design Quality Evaluation

```
Criteria (20 questions):

Architecture & Design (5 points):
1. Clear separation of concerns?
2. Proper dependency structure?
3. Scalable composition?
4. Future-proof extensibility?
5. Minimal coupling?

Team Composition (5 points):
6. Each agent has distinct expertise?
7. Roles are clearly defined?
8. No overlapping responsibilities?
9. Complementary skill sets?
10. Appropriate team size?

Communication & Integration (5 points):
11. Clear message contracts?
12. Async/sync coordination defined?
13. Error handling complete?
14. Timeout strategies defined?
15. State management clear?

Performance & Scalability (5 points):
16. Latency targets achievable?
17. Throughput targets realistic?
18. Resource constraints satisfied?
19. Scaling strategy defined?
20. Bottleneck analysis complete?
```

---

## Production Deployment

### System Requirements
- **Python**: 3.9+
- **Memory**: 2GB minimum (4GB recommended)
- **Disk**: 500MB minimum (1GB for caching)
- **Network**: Stable internet connection
- **Processor**: Modern multi-core (4+ cores)

### Supported Platforms
- Windows 10/11 (PowerShell or Batch)
- macOS 11+ (Bash)
- Linux (Bash)
- Docker (containerized)
- Kubernetes (orchestrated)
- Cloud (AWS, GCP, Azure)

### Deployment Options
1. **Local Development**: Single machine
2. **Docker**: Containerized deployment
3. **Kubernetes**: Orchestrated scaling
4. **Cloud Functions**: Serverless
5. **Distributed**: Multi-machine cluster

---

## Support & Resources

### Documentation
- Complete API reference
- Architecture patterns guide
- Integration guides (Wix, skill-creator, MCP)
- Performance optimization guide
- Security hardening guide
- Troubleshooting guide

### Examples
- 12+ complete agent team designs
- Implementation templates (Python, TypeScript, Go)
- Integration examples (Wix, REST APIs, databases)
- Performance benchmarks
- Security assessments

### Community
- GitHub repository: https://github.com/revfactory/harness
- Discussions: GitHub Discussions
- Issues: Bug reports and feature requests
- Contributions: Community extensions

---

## Version History

**v2.0** (Current)
- Complete redesign for production use
- 12+ architectural patterns
- Advanced validation framework
- Performance optimization engine
- Security hardening
- Cross-platform deployment
- Comprehensive documentation
- Integration ecosystems (Wix, skill-creator, MCP)

**v1.0** (Archive)
- Initial release
- Basic patterns
- Simple validation
- Local deployment only

---

## License & Attribution

**Harness** is open source and community-driven.

Designed for Claude and the AI agent ecosystem.

Status: Production Ready ✓
