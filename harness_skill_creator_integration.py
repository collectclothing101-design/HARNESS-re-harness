"""
Harness × Skill-Creator Integration

Generates SKILL.md and supporting reference documents from Harness agent team definitions.
Used by skill-creator to bootstrap new skills with progressive-disclosure structure.
"""

from pathlib import Path
from typing import Dict, List, Optional


class HarnessSkillScaffold:
    """Generate SKILL.md from Harness team architecture."""

    def __init__(
        self,
        skill_name: str,
        domain: str,
        use_case: str,
        agents: List[Dict],
        output_dir: Optional[Path] = None,
    ):
        self.skill_name = skill_name
        self.domain = domain
        self.use_case = use_case
        self.agents = agents
        self.output_dir = output_dir or Path.home() / ".skills" / skill_name

    def generate_skill_md(self) -> str:
        """Generate complete SKILL.md with progressive disclosure."""
        core_tools = [a.get("name") for a in self.agents if a.get("tier") == "core"]
        advanced_tools = [a.get("name") for a in self.agents if a.get("tier") == "advanced"]

        triggers = self._extract_triggers()
        references = self._extract_references()

        return f"""# {self.skill_name}

## Description

{self.domain} skill for {self.use_case}.

This skill uses a multi-agent Harness architecture with specialized agents:
{chr(10).join(f"- **{a.get('name')}**: {a.get('purpose')}" for a in self.agents)}

### When to Use

- {self.use_case}
- Complex {self.domain} tasks requiring specialist coordination
- Multi-step workflows with validation gates

### Why This Skill

Progressive-disclosure architecture: core agents for 80% of tasks, advanced agents for 20% edge cases.

---

## Trigger Patterns

Use this skill when:

{chr(10).join(f"- {t}" for t in triggers)}

---

## Core Tools

Primary agents for common {self.domain} workflows:

{chr(10).join(self._tool_definition(a) for a in self.agents if a.get('tier') == 'core')}

---

## Advanced Tools

Specialized agents for edge cases and optimization:

{chr(10).join(self._tool_definition(a) for a in self.agents if a.get('tier') == 'advanced')}

---

## Integration Points

### With Other Skills

[Define integrations with related skills]

### With MCP Servers

- harness: Agent orchestration and validation
- [Other relevant MCPs]

### With Orchestration

This skill integrates with the multi-agent orchestration layer:
1. Agent selection (router)
2. Parallel execution
3. Validation gates
4. Error recovery

---

## References

{chr(10).join(f"- {r}" for r in references)}

---

## Quick Start

1. Provide {self.domain} context
2. Select core or advanced path
3. Follow agent recommendations
4. Validate output with gates

---

## Implementation Examples

[Add real-world examples from references/]
"""

    def _extract_triggers(self) -> List[str]:
        """Extract trigger patterns from agent team."""
        return [
            a.get("trigger", f"{a.get('name')} needed for task")
            for a in self.agents[:3]
        ]

    def _extract_references(self) -> List[str]:
        """Extract reference files from agents."""
        refs = set()
        for agent in self.agents:
            refs.update(agent.get("references", []))
        return sorted(refs)

    def _tool_definition(self, agent: Dict) -> str:
        """Format agent as tool documentation."""
        return f"""### {agent.get('name')}

**Purpose**: {agent.get('purpose')}

**Input**: {agent.get('input_contract', 'See references')}

**Output**: {agent.get('output_contract', 'See references')}

**Handoff**: {agent.get('handoff', 'Next agent TBD')}
"""

    def generate_references(self) -> Dict[str, str]:
        """Generate reference documents for agents."""
        refs = {}

        for agent in self.agents:
            agent_name = agent.get("name", "Unknown").lower().replace(" ", "_")
            refs[f"{agent_name}_schema.json"] = self._agent_schema_doc(agent)
            refs[f"{agent_name}_examples.md"] = self._agent_examples_doc(agent)

        refs["orchestration.md"] = self._orchestration_doc()
        refs["validation_gates.md"] = self._validation_gates_doc()

        return refs

    def _agent_schema_doc(self, agent: Dict) -> str:
        """Generate input/output schema documentation."""
        return f"""# {agent.get('name')} Schema

## Input Contract

{agent.get('input_contract', 'Not specified')}

## Output Contract

{agent.get('output_contract', 'Not specified')}

## Examples

[Add examples from agent_examples.md]
"""

    def _agent_examples_doc(self, agent: Dict) -> str:
        """Generate examples for agent."""
        return f"""# {agent.get('name')} Examples

## Basic Usage

[Example 1]

## Advanced Usage

[Example 2]

## Error Handling

[How agent handles errors]
"""

    def _orchestration_doc(self) -> str:
        """Generate multi-agent orchestration documentation."""
        return f"""# Orchestration

## Agent Sequence

{chr(10).join(f"{i+1}. {a.get('name')}" for i, a in enumerate(self.agents))}

## Validation Gates

[Define gates between agents]

## Error Recovery

[Define failure modes and recovery]
"""

    def _validation_gates_doc(self) -> str:
        """Generate validation gates documentation."""
        return """# Validation Gates

## Gate 1: Input Validation
- Check: [specification]
- Failure: [recovery]

## Gate 2: Contract Verification
- Check: [specification]
- Failure: [recovery]

## Gate 3: Output Validation
- Check: [specification]
- Failure: [recovery]
"""

    def write_skill(self) -> Path:
        """Write SKILL.md and references to disk."""
        self.output_dir.mkdir(parents=True, exist_ok=True)
        ref_dir = self.output_dir / "references"
        ref_dir.mkdir(exist_ok=True)

        # Write SKILL.md
        skill_path = self.output_dir / "SKILL.md"
        skill_path.write_text(self.generate_skill_md(), encoding="utf-8")

        # Write references
        for filename, content in self.generate_references().items():
            (ref_dir / filename).write_text(content, encoding="utf-8")

        return self.output_dir


def generate_skill_from_team(
    team_definition: Dict,
    output_dir: Optional[Path] = None,
) -> Path:
    """
    High-level function: generate complete skill from Harness team definition.

    Input team_definition:
    {
        "skill_name": "wix-dashboard",
        "domain": "Wix app development",
        "use_case": "Dashboard page design and implementation",
        "agents": [
            {
                "name": "UIDesignAgent",
                "purpose": "Select components and layout",
                "tier": "core",
                "input_contract": "Feature requirements",
                "output_contract": "Component selection",
                "handoff": "APIContractAgent",
                "trigger": "Dashboard feature needed",
                "references": ["component_reference.md", "layout_patterns.md"]
            },
            ...
        ]
    }
    """
    scaffold = HarnessSkillScaffold(
        skill_name=team_definition.get("skill_name", "generated-skill"),
        domain=team_definition.get("domain", "Custom"),
        use_case=team_definition.get("use_case", "Task automation"),
        agents=team_definition.get("agents", []),
        output_dir=output_dir,
    )

    return scaffold.write_skill()
