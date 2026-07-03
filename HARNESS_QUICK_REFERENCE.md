# Harness MCP Quick Reference

## Available Tools

### Core Design

| Tool | Purpose | Input | Output |
|------|---------|-------|--------|
| `design_agent_team()` | Design specialist agent team | domain, objective, pattern | Team structure with agents |
| `generate_skill_scaffold()` | Create SKILL.md structure | skill_name, domain, use_case | Progressive-disclosure template |
| `wix_app_agent_scaffold()` | Multi-agent Wix feature design | feature_name, app_type, backend_required | Agents, orchestration, file structure |
| `orchestration_template()` | Generate team coordination doc | team_name, num_agents, pattern | orchestration.md template |

### Integration

| Tool | Purpose | Input | Output |
|------|---------|-------|--------|
| `skill_creator_integration()` | Generate skill-creator config | skill_name, team_json | TOML/JSON config for registration |
| `harness_to_mcp_config()` | Generate MCP server config | mcp_server_name, skill_name, team_json | claude_desktop_config.json fragment |

### Validation

| Tool | Purpose | Input | Output |
|------|---------|-------|--------|
| `validate_team_architecture()` | Check team completeness | team_definition | Validation report with issues |
| `harness_status()` | Check installation | None | Status and key paths |
| `read_harness_skill()` | Read Harness SKILL.md | None | Full skill documentation |
| `list_harness_references()` | List reference docs | None | Filenames in references/ |
| `read_harness_reference()` | Read one reference doc | filename | Document content |

---

## Quick Workflows

### Workflow A: Design → Skill → Register

**Goal**: Design agent team, create skill, register with skill-creator

**Steps**:

1. **Design team**
   ```
   User: "Design a team for [domain]"
   Claude: /design_agent_team(domain, objective, pattern)
   Output: Team structure with N agents
   ```

2. **Create SKILL.md**
   ```
   Claude: /generate_skill_scaffold(skill_name, domain, use_case)
   Claude: /skill_creator_integration(skill_name, team_json)
   Output: SKILL.md in ~/.skills/skill_name/
   ```

3. **Register**
   ```
   User: "/register_skill ~/.skills/skill_name"
   Output: Skill available in Claude
   ```

---

### Workflow B: Design → Wix Feature → Implement

**Goal**: Design Wix feature with multi-agent architecture, generate implementation tasks

**Steps**:

1. **Scaffold feature**
   ```
   User: "Design multi-agent architecture for [Wix feature]"
   Claude: /wix_app_agent_scaffold(feature_name, feature_type, backend_required)
   Output: agents/, orchestration.md, API contract, test plan
   ```

2. **Generate implementation tasks**
   ```
   Claude: Reads orchestration.md, generates tasks per agent
   User: Follows each agent's file (1_UIDesignAgent.md, etc.)
   ```

3. **Implement and test**
   ```
   User: Implements src/ code following agent specs
   User: Runs tests from validation gates
   User: Tests in Wix preview via wix:wix-manage
   ```

---

### Workflow C: Validate Team

**Goal**: Check team architecture before implementing

**Steps**:

1. **Design team**
   ```
   Claude: /design_agent_team(...)
   Output: Team structure
   ```

2. **Validate**
   ```
   Claude: /validate_team_architecture(team_definition)
   Output: Validation report with issues
   ```

3. **Fix issues**
   ```
   User: Requests adjustments to team
   Claude: Updates team definition
   Claude: Re-validates
   ```

4. **Proceed**
   ```
   Validation passes → Design → Skill → Implementation
   ```

---

## Common Use Cases

### Use Case 1: Multi-Step Content Analysis

Pattern: Pipeline

```
Design: TextParser → Analyzer → Summarizer → Formatter

Agents:
- TextParserAgent: Extract sections
- AnalysisAgent: Analyze each section
- SummaryAgent: Synthesize summary
- FormatterAgent: Format output
```

### Use Case 2: Route to Specialist

Pattern: Expert Pool

```
Design: Router → {TechnicalExpert, BusinessExpert, SecurityExpert}

Agents:
- RouterAgent: Classify request type
- TechnicalExpert: Handle technical queries
- BusinessExpert: Handle business queries
- SecurityExpert: Handle security queries
```

### Use Case 3: Wix Dashboard Feature

Pattern: Sequential + Validation

```
Agents:
1. UIDesignAgent: Select WDS components
2. APIContractAgent: Define data schema
3. ValidationAgent: Input validation rules
4. BackendAgent: HTTP functions
5. TestingAgent: Test strategy
```

### Use Case 4: Content Generation + Review

Pattern: Producer-Reviewer

```
Agents:
- GeneratorAgent: Create content
- ReviewerAgent: Validate quality
- AdjusterAgent: Fix issues
- FinalValidationAgent: Output check
```

---

## Agent Team Patterns

| Pattern | Flow | Use Case |
|---------|------|----------|
| Pipeline | A→B→C | Linear workflows |
| Fan-out/Fan-in | Router→{A,B,C}→Aggregator | Parallel subtasks |
| Expert Pool | Router→SelectExpert→Expert | Route to specialist |
| Producer-Reviewer | Producer→Reviewer→Adjuster | Generated content needs review |
| Supervisor | Supervisor→{A,B,C} | Orchestrator + subordinates |
| Hierarchical | Top→Middle→Bottom | Large teams with sub-teams |

---

## Validation Gates

Every team includes:

1. **Input Validation** - First agent validates inputs
2. **Contract Verification** - Between-agent handoff validation
3. **Output Validation** - Last agent validates final output
4. **Integration Testing** - End-to-end team test

---

## Error Recovery Scenarios

**Common failures + recovery**:

- **API Unavailable** → Retry with backoff + escalate
- **Input Missing** → Return error spec to requestor
- **Contract Mismatch** → Log, re-validate, escalate
- **Output Invalid** → Validation agent re-runs checks
- **Agent Fails** → Supervisor escalates to human
- **Timeout** → Supervisor moves to next task

---

## File Structure Template

```
my-feature/
├── agents/
│   ├── 1_FirstAgent.md
│   ├── 2_SecondAgent.md
│   └── 3_ThirdAgent.md
├── src/
│   └── [Implementation code]
├── references/
│   ├── api_contract.json
│   ├── data_model.json
│   ├── validation_rules.json
│   └── examples.md
├── orchestration.md        [Handoff sequence]
├── SKILL.md               [Skill documentation]
└── validation_gates.md    [Gate specifications]
```

---

## Tips

1. **Start simple** - Design 3-agent team first
2. **Use templates** - `orchestration_template()` generates structure
3. **Validate early** - Check team before implementing
4. **Document contracts** - Clear input/output prevents handoff errors
5. **Add error recovery** - Define failure scenarios upfront
6. **Test gates** - Validate gates catch issues early
7. **Reuse patterns** - Save successful team definitions in JSON

---

## MCP Server Configuration

Add to `~/.config/claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "harness": {
      "command": "python3",
      "args": ["/path/to/harness_mcp_server.py"],
      "env": {
        "HARNESS_DIR": "~/.local/share/ai-tools/harness"
      }
    }
  }
}
```

Then restart Claude Desktop.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Tool not found | Restart Claude Desktop (MCP server loading) |
| HARNESS_DIR not set | Set env var in MCP config |
| Skill path invalid | Use absolute paths in config |
| Agent handoff broken | Verify output contract matches input contract |
| Validation gate fails | Check gate specification in orchestration.md |

---

## Keep in Memory

These tools are available in Claude:

✓ Design specialist agent teams  
✓ Generate SKILL.md with progressive disclosure  
✓ Scaffold Wix app features with multi-agent architecture  
✓ Validate team completeness before implementation  
✓ Generate orchestration and validation gate documentation  

**Three modules**:
1. `harness_mcp_server.py` - Core MCP server
2. `harness_skill_creator_integration.py` - SKILL.md generation
3. `harness_wix_integration.py` - Wix feature scaffolding

Use them together for end-to-end agent team design and skill creation.
