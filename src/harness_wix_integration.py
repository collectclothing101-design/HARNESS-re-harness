"""
Harness × Wix:Wix-Manage Integration

Scaffolds Wix app features using multi-agent Harness design.
Integrates with wix:wix-manage to generate:
- Dashboard agents
- API contract agents
- Validation agents
- Backend implementation agents (optional)
- Testing agents

Produces: agents/, orchestration.md, validation gates, file structure.
"""

from pathlib import Path
from typing import Dict, List, Optional


class WixFeatureHarness:
    """Design multi-agent architecture for Wix app features."""

    FEATURE_TYPES = {
        "dashboard": ["UI Design", "API Contract", "Validation", "Testing"],
        "backend-api": ["API Contract", "Implementation", "Error Handling", "Testing"],
        "form": ["UI Design", "Validation", "API Contract", "Testing"],
        "extension": ["Extension Type Selection", "UI Integration", "Hook Setup", "Testing"],
        "ecommerce": ["Product Display", "Cart Logic", "Checkout", "Payment Integration"],
    }

    def __init__(
        self,
        feature_name: str,
        feature_type: str,
        app_context: Optional[str] = None,
        output_dir: Optional[Path] = None,
    ):
        self.feature_name = feature_name
        self.feature_type = feature_type
        self.app_context = app_context or "Wix app"
        self.output_dir = output_dir or Path.home() / ".wix-harness" / feature_name
        self.agents = self._design_team()

    def _design_team(self) -> List[Dict]:
        """Design agent team based on feature type."""
        base_agents = self.FEATURE_TYPES.get(self.feature_type, ["Generic Task Agent"])

        agents = []
        for i, agent_type in enumerate(base_agents, 1):
            agents.append(
                {
                    "id": i,
                    "name": f"{agent_type.replace(' ', '')}Agent",
                    "type": agent_type,
                    "purpose": f"Handle {agent_type.lower()} for {self.feature_name}",
                    "tier": "core" if i <= 2 else "advanced",
                    "input_contract": self._input_contract(agent_type),
                    "output_contract": self._output_contract(agent_type),
                    "handoff": base_agents[i] if i < len(base_agents) else None,
                    "wix_api_domain": self._wix_api_domain(agent_type),
                }
            )

        return agents

    def _input_contract(self, agent_type: str) -> str:
        """Define input contract per agent type."""
        contracts = {
            "UI Design": "Feature spec, design system, component library",
            "API Contract": "Feature requirements, data model",
            "Validation": "Input schema, business rules",
            "Implementation": "API contract, data model, error handling spec",
            "Testing": "Feature spec, implementation, edge cases",
            "Product Display": "Product data, pricing model",
            "Cart Logic": "Cart schema, tax/shipping rules",
            "Checkout": "Cart state, payment processor config",
            "Extension Type Selection": "Extension requirements, Wix APIs",
            "Hook Setup": "Hook type, handler signature",
        }
        return contracts.get(agent_type, "Context and requirements")

    def _output_contract(self, agent_type: str) -> str:
        """Define output contract per agent type."""
        contracts = {
            "UI Design": "Component selection, layout diagram, styling tokens",
            "API Contract": "OpenAPI/GraphQL schema, request/response examples",
            "Validation": "Validation rules in JSON Schema, error messages",
            "Implementation": "Backend service code, database schema",
            "Testing": "Test plan, test cases, coverage targets",
            "Product Display": "Component spec, data binding",
            "Cart Logic": "Cart state machine, calculation logic",
            "Checkout": "Checkout flow, payment integration code",
            "Extension Type Selection": "Selected extension type, required permissions",
            "Hook Setup": "Hook implementation, error handling",
        }
        return contracts.get(agent_type, "Validated output ready for next agent")

    def _wix_api_domain(self, agent_type: str) -> str:
        """Map agent type to Wix API domain."""
        domains = {
            "UI Design": "Wix Design System, WDS components",
            "API Contract": "Wix REST API, Wix GraphQL",
            "Validation": "Validation hooks, input validation",
            "Implementation": "Backend API, Data Collections, HTTP Functions",
            "Testing": "Wix Testing SDK, site operations",
            "Product Display": "Wix eCommerce API, Product API",
            "Cart Logic": "Cart API, calculations",
            "Checkout": "Checkout API, Payments API",
            "Extension Type Selection": "Wix Extensions, Extension IDs",
            "Hook Setup": "Wix Hooks, beforeSubmit, afterSubmit",
        }
        return domains.get(agent_type, "Wix Core APIs")

    def generate_agent_file(self, agent: Dict) -> str:
        """Generate markdown file for one agent."""
        return f"""# {agent['name']}

## Role

{agent['purpose']}

## API Domain

{agent['wix_api_domain']}

## Input Contract

{agent['input_contract']}

## Output Contract

{agent['output_contract']}

## Responsibilities

1. [Define specific tasks]
2. [Validation checkpoints]
3. [Error handling]

## Implementation Checklist

- [ ] Input validation
- [ ] Core logic
- [ ] Error recovery
- [ ] Output validation
- [ ] Handoff contract verification

## Next Agent

{agent['handoff'] or 'Merge to main branch'}

## References

- [Wix API docs for {agent['wix_api_domain']}]
- [Implementation examples]
- [Test cases]
"""

    def generate_orchestration_md(self) -> str:
        """Generate orchestration.md for feature team."""
        handoff_steps = []
        for i, agent in enumerate(self.agents, 1):
            handoff_steps.append(
                f"{i}. **{agent['name']}**: {agent['purpose']}\n"
                f"   - Input: {agent['input_contract']}\n"
                f"   - Output: {agent['output_contract']}\n"
                f"   - Wix API: {agent['wix_api_domain']}"
            )

        return f"""# {self.feature_name} Orchestration

## Feature Type

{self.feature_type}

## Application Context

{self.app_context}

## Agent Team

{len(self.agents)} specialist agents coordinating feature design and implementation.

## Handoff Sequence

{chr(10).join(handoff_steps)}

## Validation Gates

### Gate 1: Input Completeness
**Agent**: {self.agents[0]['name']}
- Check: All required inputs provided
- Inputs: {self.agents[0]['input_contract']}
- Failure: Return error spec to requestor

### Gate 2: Contract Verification
**Between agents**
- Check: Output from agent N matches input contract of agent N+1
- Failure: Error report with mismatch details

### Gate 3: Wix API Compliance
**Each agent**
- Check: Code follows Wix API patterns, permissions, sandbox rules
- Failure: Return API compliance report

### Gate 4: Integration Testing
**Final {self.agents[-1]['name']}**
- Check: Feature works end-to-end in Wix environment
- Failure: Test failure report with reproduction steps

## Error Recovery

### Scenario: API Key Missing
**Handling**: {self.agents[1]['name']} returns error spec with required credentials

### Scenario: Data Model Mismatch
**Handling**: API Contract agent revises schema, prior agent re-runs

### Scenario: Validation Rule Conflict
**Handling**: Validation agent updates rules, testing agent re-runs test suite

## Success Criteria

- [ ] All agents complete successfully
- [ ] Output passes all validation gates
- [ ] Integration test passes
- [ ] Code ready for pull request
- [ ] Wix preview environment works
- [ ] Test coverage >= {self._target_coverage()}%

## Team Status

**Pattern**: Sequential with feedback loops

**Timeline Estimate**: [based on feature complexity]

**Blockers**: None identified

**Dependencies**: [List Wix APIs, components, or features required]
"""

    def _target_coverage(self) -> int:
        """Target test coverage based on feature type."""
        coverage_map = {
            "dashboard": 70,
            "backend-api": 85,
            "form": 75,
            "extension": 80,
            "ecommerce": 90,
        }
        return coverage_map.get(self.feature_type, 75)

    def generate_file_structure(self) -> str:
        """Generate directory structure for feature."""
        feature_slug = self.feature_name.lower().replace(" ", "-")

        return f"""{feature_slug}/
├── agents/
│   ├── 1_ui-design-agent.md
│   ├── 2_api-contract-agent.md
│   ├── 3_validation-agent.md
│   └── 4_testing-agent.md
├── src/
│   ├── components/
│   │   └── [Component implementations]
│   ├── api/
│   │   └── [Backend HTTP Functions]
│   ├── hooks/
│   │   └── [Validation hooks]
│   └── tests/
│       └── [Test suite]
├── references/
│   ├── api_contract.openapi.json
│   ├── data_model.json
│   ├── validation_rules.json
│   └── test_cases.md
├── orchestration.md
├── SKILL.md
└── wix.toml
    [App extension config]

## Implementation Flow

1. Read orchestration.md
2. Execute agents sequentially per Handoff Sequence
3. Validate output at each gate
4. Implement src/ code
5. Run test suite
6. Integration test in Wix preview
7. Merge to main
"""

    def generate_skill_md(self) -> str:
        """Generate SKILL.md for this feature."""
        return f"""# {self.feature_name}

## Description

Wix {self.feature_type} feature for {self.app_context}.

This feature uses multi-agent Harness design:
{chr(10).join(f"- **{a['name']}**: {a['purpose']}" for a in self.agents)}

## When to Use

- Building {self.feature_type} feature for Wix app
- Need structured design → implementation flow
- Require validation gates and error recovery

## Trigger Patterns

- "Build a {self.feature_type} for [context]"
- "Design {self.feature_name} architecture"
- "Implement {self.feature_name} end-to-end"

## Core Tools

[Primary agents for 80% of tasks]

## Advanced Tools

[Specialized agents for edge cases]

## References

- orchestration.md - Full handoff sequence
- agents/ - Individual agent responsibilities
- references/ - Schemas, examples, test cases
- Wix Docs - https://www.wix.dev

## Integration with Wix

Uses:
- Wix Design System (WDS) components
- Wix REST API / GraphQL
- Wix Hooks API
- Wix Data Collections
- Wix HTTP Functions
"""

    def write_all(self) -> Path:
        """Write all generated files to disk."""
        self.output_dir.mkdir(parents=True, exist_ok=True)

        # Write agents
        agents_dir = self.output_dir / "agents"
        agents_dir.mkdir(exist_ok=True)
        for agent in self.agents:
            agent_file = agents_dir / f"{agent['id']}_{agent['name'].lower()}.md"
            agent_file.write_text(self.generate_agent_file(agent), encoding="utf-8")

        # Write orchestration
        (self.output_dir / "orchestration.md").write_text(
            self.generate_orchestration_md(), encoding="utf-8"
        )

        # Write SKILL.md
        (self.output_dir / "SKILL.md").write_text(self.generate_skill_md(), encoding="utf-8")

        # Write file structure
        (self.output_dir / "FILE_STRUCTURE.txt").write_text(
            self.generate_file_structure(), encoding="utf-8"
        )

        return self.output_dir


def scaffold_wix_feature(
    feature_name: str,
    feature_type: str,
    app_context: Optional[str] = None,
    output_dir: Optional[Path] = None,
) -> Path:
    """
    High-level function: scaffold complete Wix feature with multi-agent Harness.

    Args:
        feature_name: Name of feature (e.g., "User Dashboard")
        feature_type: Type from FEATURE_TYPES (dashboard, backend-api, form, extension, ecommerce)
        app_context: Context for feature (e.g., "membership app")
        output_dir: Output directory (default: ~/.wix-harness/[feature_name])

    Returns:
        Path to generated feature directory
    """
    harness = WixFeatureHarness(
        feature_name=feature_name,
        feature_type=feature_type,
        app_context=app_context,
        output_dir=output_dir,
    )

    return harness.write_all()
