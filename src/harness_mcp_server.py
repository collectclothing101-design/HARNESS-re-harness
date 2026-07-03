#!/usr/bin/env python3
"""
Harness MCP Server
Provides tools for designing domain-specific agent teams, selecting architecture patterns,
generating agent definitions, generating skills, and validating orchestration.

Integrates with:
- skill-creator: Generate SKILL.md with progressive disclosure structure
- wix:wix-manage: Scaffold Wix app extensions with agent-driven architecture
"""

from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any, Dict, List, Optional
from mcp.server.fastmcp import FastMCP

# Configuration
HARNESS_DIR = Path(os.environ.get("HARNESS_DIR", "~/.local/share/ai-tools/harness")).expanduser()
SKILL_DIR = HARNESS_DIR / "skills" / "harness"
SKILL_MD = SKILL_DIR / "SKILL.md"
REF_DIR = SKILL_DIR / "references"

mcp = FastMCP(
    "harness",
    instructions=(
        "Use Harness to design domain-specific agent teams, select architecture patterns, "
        "generate agent definitions, generate skills, and validate orchestration. "
        "Patterns: pipeline, fan-out/fan-in, expert-pool, producer-reviewer, supervisor, hierarchical. "
        "Output: structured team architecture with specialist agents, handoff contracts, and skill requirements."
    ),
)


def _safe_file(path: Path, root: Path) -> Path:
    """Prevent path traversal; verify file exists within root."""
    p = path.resolve()
    r = root.resolve()
    if not str(p).startswith(str(r)):
        raise ValueError(f"Path traversal blocked: {path}")
    if not p.is_file():
        raise FileNotFoundError(f"File not found: {p}")
    return p


@mcp.tool()
def harness_status() -> Dict[str, Any]:
    """Return local Harness installation status and key paths."""
    return {
        "harness_dir": str(HARNESS_DIR),
        "skill_dir": str(SKILL_DIR),
        "skill_md_exists": SKILL_MD.is_file(),
        "references_dir_exists": REF_DIR.is_dir(),
        "harness_ready": SKILL_MD.is_file() and REF_DIR.is_dir(),
    }


@mcp.tool()
def read_harness_skill() -> str:
    """Read the main Harness SKILL.md instructions."""
    return _safe_file(SKILL_MD, SKILL_DIR).read_text(encoding="utf-8", errors="replace")


@mcp.tool()
def list_harness_references() -> List[str]:
    """List available Harness reference documents."""
    if not REF_DIR.is_dir():
        return []
    return sorted(p.name for p in REF_DIR.iterdir() if p.is_file())


@mcp.tool()
def read_harness_reference(filename: str) -> str:
    """Read one Harness reference document by filename."""
    return _safe_file(REF_DIR / filename, REF_DIR).read_text(encoding="utf-8", errors="replace")


@mcp.tool()
def design_agent_team(
    domain: str,
    objective: str,
    constraints: Optional[str] = None,
    preferred_pattern: str = "auto",
) -> str:
    """
    Design a domain-specific agent team using Harness architecture patterns.
    
    Patterns:
    - pipeline: Sequential handoff (A→B→C)
    - fan-out/fan-in: Parallel specialists → aggregator
    - expert-pool: Router → specialized experts
    - producer-reviewer: Generator → validator → adjuster
    - supervisor: Orchestrator with subordinate agents
    - hierarchical: Multi-level delegation with escalation
    """
    return f"""Design Agent Team for Harness

Domain:
{domain}

Objective:
{objective}

Constraints:
{constraints or "None specified"}

Preferred Pattern:
{preferred_pattern}

Output format (REQUIRED):
1. **Pattern Selection**: Chosen pattern with justification
2. **Agent Roles**: List each specialist with:
   - Name and purpose
   - Input contract (what it expects)
   - Output contract (what it produces)
   - Handoff dependencies
3. **Skill Requirements**: List skills needed per agent
4. **Validation Gates**: Dry-run, trigger verification, failure handling
5. **File Structure**: agents/, skills/, references/, orchestration.md

Generate precise, executable team architecture.
"""


@mcp.tool()
def generate_skill_scaffold(
    skill_name: str,
    domain: str,
    use_case: str,
    audience: str = "agents",
) -> str:
    """
    Generate SKILL.md scaffold with progressive-disclosure structure.
    
    Output includes:
    - Description (what, when, why)
    - Trigger patterns (when to use)
    - Core tools (primary capabilities)
    - Advanced tools (optional, specialized)
    - References and examples
    """
    return f"""Generate SKILL.md Scaffold

Skill Name: {skill_name}
Domain: {domain}
Use Case: {use_case}
Audience: {audience}

Required structure:
```
# {skill_name}

## Description
[Concise: what this skill does, when to use it, why it matters]

## Trigger Patterns
[When Claude should use this skill]

## Core Tools
[Primary capabilities for {audience}]

## Advanced Tools
[Optional, specialized, rarely-used capabilities]

## References
[Context documents, examples, schemas, templates]

## Integration Points
[How this skill connects to other tools/skills]
```

Generate complete SKILL.md template with all sections.
"""


@mcp.tool()
def wix_app_agent_scaffold(
    feature_name: str,
    app_type: str,
    backend_required: bool = False,
) -> str:
    """
    Scaffold a Wix app feature using multi-agent Harness design.
    
    Integrates with wix:wix-manage to generate:
    - Dashboard page agent
    - Validation agent
    - Backend API agent (optional)
    - Testing agent
    
    Produces: agents/, orchestration.md, file structure ready for implementation.
    """
    agents = [
        "UIDesignAgent (dashboard layout, component selection)",
        "APIContractAgent (define request/response schema)",
        "ValidationAgent (input validation, edge cases)",
    ]
    if backend_required:
        agents.append("BackendImplementationAgent (API logic, data model)")
    agents.append("TestingAgent (test plan, coverage targets)")

    return f"""Scaffold Wix App Feature with Multi-Agent Harness

Feature: {feature_name}
App Type: {app_type}
Backend Required: {backend_required}

Agent Team:
{chr(10).join(f"- {a}" for a in agents)}

Output deliverables:
1. agents/ui-design-agent.md - Component selection, layout, styling
2. agents/api-contract-agent.md - Schema, request/response, error handling
3. agents/validation-agent.md - Input validation rules, edge cases
{f"4. agents/backend-implementation-agent.md - API logic, database schema" if backend_required else ""}
4. agents/testing-agent.md - Test strategy, coverage targets, test cases
5. orchestration.md - Agent handoff sequence, validation gates
6. file-structure.txt - Generated file layout for implementation

Each agent produces consumable SKILL.md for skill-creator integration.
"""


@mcp.tool()
def skill_creator_integration(
    skill_name: str,
    agent_team_json: str,
) -> Dict[str, Any]:
    """
    Generate skill-creator compatible configuration from Harness agent team.
    
    Returns TOML/JSON config for registering with skill-creator.
    """
    try:
        team = json.loads(agent_team_json)
    except json.JSONDecodeError:
        return {"error": "Invalid JSON in agent_team_json", "example": '{"agents": [...]}'}

    return {
        "skill_name": skill_name,
        "skill_type": "agent-orchestrated",
        "agents": team.get("agents", []),
        "skill_md_template": f"/mnt/skills/examples/{skill_name}/SKILL.md",
        "references_dir": f"/mnt/skills/examples/{skill_name}/references",
        "trigger_patterns": team.get("triggers", []),
        "core_tools": team.get("core_tools", []),
        "advanced_tools": team.get("advanced_tools", []),
        "integration_points": team.get("integrations", []),
        "config_path": f"~/.harness/{skill_name}/skill-creator.toml",
    }


@mcp.tool()
def validate_team_architecture(team_definition: str) -> Dict[str, Any]:
    """
    Validate Harness team architecture for completeness and consistency.
    
    Checks:
    - All agents have input/output contracts
    - Handoff dependencies are acyclic
    - Skills referenced by agents exist
    - Validation gates are comprehensive
    - File structure is complete
    """
    return {
        "validation_checks": [
            "agent_input_output_contracts",
            "handoff_dependency_graph_acyclic",
            "skill_references_resolved",
            "validation_gates_comprehensive",
            "file_structure_complete",
            "error_handling_specified",
        ],
        "status": "ready_to_validate",
        "prompt": f"""Validate this Harness team architecture:

{team_definition}

For each check, provide:
1. Status (pass/warn/fail)
2. Details or issues found
3. Remediation if needed
""",
    }


@mcp.tool()
def orchestration_template(
    team_name: str,
    num_agents: int,
    pattern: str,
) -> str:
    """
    Generate orchestration.md template for multi-agent coordination.
    
    Includes: agent roles, handoff sequence, validation gates, error recovery.
    """
    return f"""# {team_name} Orchestration

## Agent Team ({num_agents} agents)

Pattern: {pattern}

## Handoff Sequence

[Define agent execution order, inputs, outputs, dependencies]

## Validation Gates

### Gate 1: Input Validation
- Agent responsible: [name]
- Checks: [list]
- Failure mode: [fallback/retry/escalate]

### Gate 2: Contract Verification
- Agent responsible: [name]
- Checks: [list]
- Failure mode: [fallback/retry/escalate]

### Gate 3: Output Validation
- Agent responsible: [name]
- Checks: [list]
- Failure mode: [fallback/retry/escalate]

## Error Recovery

### Failure Scenario 1: [description]
Recovery: [steps]

### Failure Scenario 2: [description]
Recovery: [steps]

## Monitoring and Observability

- Logging points: [agents + checkpoints]
- Metrics: [latency, success rate, agent-specific]
- Alerts: [thresholds, escalation]

## Testing Strategy

- Unit tests per agent
- Integration tests for handoffs
- End-to-end team tests
- Fuzz testing for malformed inputs
"""


@mcp.tool()
def harness_to_mcp_config(
    mcp_server_name: str,
    skill_name: str,
    agent_team_json: str,
) -> str:
    """
    Generate MCP server configuration (claude_desktop_config.json fragment)
    from Harness agent team definition.
    """
    return f"""{{
  "mcpServers": {{
    "{mcp_server_name}": {{
      "command": "python3",
      "args": ["/path/to/{mcp_server_name}_mcp.py"],
      "env": {{
        "SKILL_NAME": "{skill_name}",
        "AGENT_TEAM": '{agent_team_json}',
        "ORCHESTRATION_MODE": "harness"
      }}
    }}
  }}
}}

# Add to ~/.config/claude/claude_desktop_config.json
# Restart Claude for Desktop to load the MCP server.
"""


if __name__ == "__main__":
    if not HARNESS_DIR.exists():
        raise SystemExit(
            f"HARNESS_DIR not found: {HARNESS_DIR}\n"
            "Install with: git clone https://github.com/revfactory/harness.git {HARNESS_DIR}"
        )
    mcp.run(transport="stdio")
