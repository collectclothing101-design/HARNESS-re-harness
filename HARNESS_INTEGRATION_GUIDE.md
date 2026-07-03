# Harness MCP Server Integration Guide

## Overview

**Harness** is a framework for designing domain-specific agent teams. This MCP server integrates Harness with Claude to enable:

1. **Multi-agent architecture design** - Design specialist agent teams for complex domains
2. **SKILL.md generation** - Create progressive-disclosure skills for agents
3. **Wix app feature scaffolding** - Multi-agent design for Wix app features
4. **Team validation** - Verify architecture completeness and consistency
5. **MCP server generation** - Output configuration for deploying teams

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                       Claude Chat                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Harness MCP Server (FastMCP)                    │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Core Tools                                          │   │
│  ├─ harness_status()                                    │   │
│  ├─ design_agent_team()                                 │   │
│  ├─ generate_skill_scaffold()                           │   │
│  ├─ validate_team_architecture()                        │   │
│  └─ orchestration_template()                            │   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Skill-Creator Integration                           │   │
│  ├─ HarnessSkillScaffold (generate SKILL.md)           │   │
│  └─ generate_skill_from_team() (write files)            │   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Wix Integration                                     │   │
│  ├─ WixFeatureHarness (multi-agent design)             │   │
│  └─ scaffold_wix_feature() (write files)                │   │
└─────────────────────────────────────────────────────────┘
        │              │              │
        ▼              ▼              ▼
    Skills        Wix Features    SKILL.md files
  generated       scaffolded      in references/
```

---

## Installation

### 1. Install Harness Repository

```bash
HARNESS_DIR=~/.local/share/ai-tools/harness
git clone https://github.com/revfactory/harness.git "$HARNESS_DIR"
```

### 2. Create MCP Server Script

Save `/home/claude/harness_mcp_server.py` (provided above) to your system.

### 3. Configure Claude Desktop

Add to `~/.config/claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "harness": {
      "command": "python3",
      "args": ["/home/claude/harness_mcp_server.py"],
      "env": {
        "HARNESS_DIR": "~/.local/share/ai-tools/harness"
      }
    }
  }
}
```

### 4. Restart Claude Desktop

Close and reopen Claude for Desktop to load the MCP server.

---

## Usage Patterns

### Pattern 1: Design Agent Team

**Goal**: Design specialist agents for a domain/task.

**Workflow**:

1. Call `design_agent_team()` with domain, objective, constraints
2. Specify preferred pattern (pipeline, fan-out/fan-in, expert-pool, etc.)
3. Claude designs team structure with:
   - Agent roles and responsibilities
   - Input/output contracts
   - Handoff dependencies
   - Skill requirements

**Example**:

```
User: "Design a multi-agent team for Wix e-commerce product page optimization"

Claude (using harness):
1. Calls design_agent_team() with:
   - domain: "Wix e-commerce"
   - objective: "Design and optimize product pages"
   - preferred_pattern: "expert-pool"

2. Returns team structure:
   - ProductDataAgent (fetch product data, images)
   - SEOOptimizationAgent (optimize metadata)
   - PerformanceAgent (page speed optimization)
   - ConversionAgent (optimize CTA and layout)
   - ValidationAgent (test on real Wix store)
```

### Pattern 2: Generate Skill from Team

**Goal**: Create a SKILL.md with progressive disclosure from agent team.

**Workflow**:

1. Design agent team (Pattern 1)
2. Call `generate_skill_scaffold()` to get SKILL.md structure
3. Claude fills in core/advanced tool sections
4. Reference documents generated in references/ directory

**Example**:

```
Claude generates:
  ~/.skills/product-page-optimization/
  ├── SKILL.md                    (progressive disclosure)
  └── references/
      ├── productdataagent_schema.json
      ├── productdataagent_examples.md
      ├── seoagent_schema.json
      ├── seoagent_examples.md
      ├── orchestration.md
      └── validation_gates.md
```

### Pattern 3: Scaffold Wix App Feature

**Goal**: Multi-agent design for Wix app feature.

**Workflow**:

1. Call `wix_app_agent_scaffold()` with feature name, app type, backend requirements
2. Claude designs agents for:
   - UI/component selection
   - API contracts
   - Validation rules
   - Backend implementation (optional)
   - Testing strategy

**Example**:

```
User: "Scaffold a multi-agent design for a Wix membership dashboard"

Claude (using harness + wix integration):
  Generated directory:
  membership-dashboard/
  ├── agents/
  │   ├── 1_UIDesignAgent.md      (WDS component selection)
  │   ├── 2_APIContractAgent.md   (Data schema)
  │   ├── 3_ValidationAgent.md    (Input validation)
  │   ├── 4_BackendAgent.md       (HTTP functions)
  │   └── 5_TestingAgent.md       (Test strategy)
  ├── orchestration.md            (Handoff sequence)
  ├── SKILL.md                    (Skill for skill-creator)
  └── references/
      ├── api_contract.openapi.json
      ├── data_model.json
      └── validation_rules.json
```

### Pattern 4: Validate Team Architecture

**Goal**: Verify agent team is complete and consistent before implementation.

**Workflow**:

1. Design agent team
2. Call `validate_team_architecture()` with team definition
3. Claude validates:
   - All agents have input/output contracts
   - Handoff dependencies are acyclic
   - Skills referenced exist
   - Validation gates comprehensive
   - File structure complete

**Example**:

```
Claude validation report:
✓ Agent input/output contracts: PASS
✓ Handoff dependency graph: PASS (no cycles)
✓ Skill references: PASS (all resolved)
✓ Validation gates: WARN (missing error recovery for agent 3)
✓ File structure: PASS
```

---

## Integration with Existing Skills

### Skill-Creator Integration

When creating a new skill with `skill-creator`:

1. **Use Harness to design team**:
   ```
   /harness_status
   /design_agent_team
     domain: "Your domain"
     objective: "Your objective"
   ```

2. **Generate SKILL.md scaffold**:
   ```
   /generate_skill_scaffold
     skill_name: "my-skill"
     domain: "Domain"
     use_case: "Use case"
   ```

3. **Write skill files**:
   - Claude uses `skill_creator_integration()` to generate config
   - Files written to `~/.skills/my-skill/SKILL.md`
   - References in `~/.skills/my-skill/references/`

4. **Register with skill-creator**:
   ```
   /register_skill ~/skills/my-skill
   ```

### Wix Integration

When building Wix app features:

1. **Design feature architecture**:
   ```
   /wix_app_agent_scaffold
     feature_name: "User Dashboard"
     app_type: "dashboard"
     backend_required: true
   ```

2. **Generate files**:
   - Agents: `~/.wix-harness/user-dashboard/agents/`
   - Orchestration: `orchestration.md`
   - API contract: `references/api_contract.openapi.json`
   - Test plan: `references/test_cases.md`

3. **Implement feature**:
   - Read `orchestration.md` for handoff sequence
   - Follow each agent's file (`1_UIDesignAgent.md`, etc.)
   - Implement in `src/` directory
   - Validate against gates

4. **Deploy to Wix**:
   - Test in preview via `wix:wix-manage`
   - Publish when ready

---

## Core Harness Patterns

### Pattern: Pipeline

Sequential agent execution: A → B → C → D

**When to use**: Linear workflows with clear dependencies

**Agents**: Ordered by responsibility

**Example**: Data extraction → validation → transformation → output

### Pattern: Fan-Out / Fan-In

Router → N parallel agents → Aggregator

**When to use**: N independent subtasks to parallelize

**Agents**: Router, specialists, aggregator

**Example**: Fetch data from 3 APIs in parallel → combine results

### Pattern: Expert Pool

Router → selection logic → chosen expert

**When to use**: Route to specialized expert based on input type

**Agents**: Router, N experts

**Example**: Route to SEO expert OR performance expert based on needs

### Pattern: Producer-Reviewer

Producer → validator/adjuster → final output

**When to use**: Generated content needs review and adjustment

**Agents**: Generator, validator, adjuster

**Example**: Generate content → review → refine

### Pattern: Supervisor

Supervisor → N subordinate agents + delegation logic

**When to use**: Complex coordination with one orchestrator

**Agents**: Supervisor, subordinates, escalation path

**Example**: Project manager → task workers → escalation to leadership

### Pattern: Hierarchical

Multi-level delegation: Top → middle → bottom teams

**When to use**: Large teams with sub-teams

**Agents**: Managers at each level, leaf workers

**Example**: Director → team leads → individual contributors

---

## Validation Gates

All Harness teams include validation gates:

### Gate 1: Input Validation
- **Responsibility**: First agent
- **Check**: All required inputs present
- **Failure**: Return error spec to requestor

### Gate 2: Contract Verification
- **Responsibility**: Between agents
- **Check**: Agent N output matches Agent N+1 input contract
- **Failure**: Return contract mismatch error

### Gate 3: Output Validation
- **Responsibility**: Last agent
- **Check**: Final output matches team objective
- **Failure**: Return validation error with details

### Gate 4: Integration Testing
- **Responsibility**: Harness orchestrator
- **Check**: Team works end-to-end
- **Failure**: Test failure report with reproduction steps

---

## Error Recovery

Each Harness team defines failure scenarios and recovery:

```markdown
## Scenario: API Unavailable

**Detection**: Agent receives 503 response

**Recovery**:
1. Retry with exponential backoff (up to N times)
2. If all retries fail, escalate to supervisor
3. Supervisor decides: fail-safe or human escalation

## Scenario: Input Contract Mismatch

**Detection**: Agent N+1 receives invalid data from Agent N

**Recovery**:
1. Log contract mismatch with details
2. Ask Agent N to revalidate output
3. If validation fails, escalate to human review
```

---

## Orchestration Template

Use `orchestration_template()` to generate team orchestration document:

```markdown
# Team Orchestration

## Agent Sequence
1. Agent A: [responsibility]
   Input: [contract]
   Output: [contract]

2. Agent B: [responsibility]
   Input: [contract]
   Output: [contract]

## Validation Gates
[Define gates between agents]

## Error Recovery
[Define failure scenarios and recovery paths]

## Monitoring
- Logging: [checkpoints]
- Metrics: [latency, success rate]
- Alerts: [thresholds]

## Testing
- Unit tests per agent
- Integration tests for handoffs
- E2E tests for full team
```

---

## File Locations

After installation and use:

```
~/.local/share/ai-tools/harness/                    # Harness repo
  skills/harness/SKILL.md                           # Main skill doc
  references/                                        # Pattern docs

~/.config/claude/claude_desktop_config.json         # MCP config

~/.skills/my-skill/                                 # Generated skills
  SKILL.md
  references/

~/.wix-harness/my-feature/                          # Wix features
  agents/
  src/
  references/
  orchestration.md
  SKILL.md
```

---

## Tips and Tricks

### 1. Reuse Agent Definitions

Once you design an agent team, save the definition in JSON:

```json
{
  "skill_name": "my-team",
  "agents": [
    {"name": "Agent1", "purpose": "...", ...},
    {"name": "Agent2", "purpose": "...", ...}
  ]
}
```

Pass to `skill_creator_integration()` or `validate_team_architecture()` for reuse.

### 2. Customize Orchestration

Use `orchestration_template()` to generate a starting point, then customize:
- Add error recovery paths
- Define monitoring points
- Add escalation logic

### 3. Test Gates Early

Validate team architecture with `validate_team_architecture()` before implementing agents.

### 4. Progressive Disclosure in Skills

Generated SKILL.md uses progressive disclosure:
- **Description**: What, when, why
- **Core tools**: 80% of use cases
- **Advanced tools**: 20% edge cases
- **References**: Details for each agent

Users learn core first, advanced on demand.

---

## Summary

**Harness MCP Server** enables:

✓ Multi-agent architecture design  
✓ SKILL.md generation with progressive disclosure  
✓ Wix feature scaffolding with validated handoffs  
✓ Team architecture validation before implementation  
✓ MCP server generation for deployment  

**Integration with**:

✓ **skill-creator** - Generate new skills from teams  
✓ **wix:wix-manage** - Design Wix features with agents  

**Keep in memory** for future reference and use.
