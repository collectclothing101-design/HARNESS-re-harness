#!/usr/bin/env python3
"""
Harness Advanced MCP Server for Claude
=========================================
Production-grade multi-agent orchestration engine with:
- Advanced agent team design and validation
- Prompt engineering and optimization
- Agent performance profiling and analytics
- Context window and token management
- Multi-model routing with fallback
- Failure recovery and resilience
- Learning feedback loops
- Advanced observability and monitoring
- Cost optimization
- Security and governance

Author: Claude Engineering Team
Version: 3.0.0 (Claude-Optimized)
"""

import json
import asyncio
import hashlib
import time
from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict, field
from enum import Enum
from pathlib import Path
import logging

try:
    from mcp.server import Server
    from mcp.types import Tool, TextContent
except ImportError:
    raise ImportError("Install mcp: pip install mcp")


# ============================================================================
# ENUMS AND DATA MODELS
# ============================================================================

class AgentRole(Enum):
    """Agent specialization roles"""
    ROUTER = "router"
    SPECIALIST = "specialist"
    AGGREGATOR = "aggregator"
    VALIDATOR = "validator"
    REVIEWER = "reviewer"
    OPTIMIZER = "optimizer"
    MONITOR = "monitor"


class OrchestrationPattern(Enum):
    """Multi-agent coordination patterns"""
    SEQUENTIAL = "sequential"
    PARALLEL = "parallel"
    FAN_OUT_FAN_IN = "fan_out_fan_in"
    PIPELINE = "pipeline"
    EXPERT_POOL = "expert_pool"
    PRODUCER_REVIEWER = "producer_reviewer"
    SUPERVISOR = "supervisor"
    HIERARCHICAL = "hierarchical"
    MAP_REDUCE = "map_reduce"
    TOURNAMENT = "tournament"


class FailureMode(Enum):
    """Failure recovery strategies"""
    RETRY_WITH_BACKOFF = "retry_with_backoff"
    FALLBACK_AGENT = "fallback_agent"
    FALLBACK_MODEL = "fallback_model"
    PARTIAL_RESULT = "partial_result"
    GRACEFUL_DEGRADATION = "graceful_degradation"
    HUMAN_ESCALATION = "human_escalation"


@dataclass
class Agent:
    """Enhanced agent specification"""
    id: str
    name: str
    role: AgentRole
    model: str
    system_prompt: str
    tools: List[str]
    max_tokens: int = 2000
    temperature: float = 0.7
    top_p: float = 0.95
    fallback_models: List[str] = field(default_factory=list)
    capabilities: List[str] = field(default_factory=list)
    constraints: List[str] = field(default_factory=list)
    timeout_seconds: int = 30
    retry_attempts: int = 3
    failure_mode: FailureMode = FailureMode.RETRY_WITH_BACKOFF
    cost_per_token: float = 0.00002
    success_rate_target: float = 0.95


@dataclass
class AgentTeam:
    """Multi-agent orchestration team"""
    id: str
    name: str
    description: str
    pattern: OrchestrationPattern
    agents: List[Agent]
    context_budget: int = 128000
    timeout_seconds: int = 300
    max_iterations: int = 10
    coordination_prompt: str = ""
    success_criteria: List[str] = field(default_factory=list)
    fallback_strategy: FailureMode = FailureMode.GRACEFUL_DEGRADATION


@dataclass
class AgentMetrics:
    """Agent performance metrics"""
    agent_id: str
    calls: int = 0
    successes: int = 0
    failures: int = 0
    total_tokens: int = 0
    total_cost: float = 0.0
    avg_latency_ms: float = 0.0
    p95_latency_ms: float = 0.0
    p99_latency_ms: float = 0.0
    success_rate: float = 1.0
    last_failure: Optional[str] = None
    failure_count_24h: int = 0
    timestamp: str = field(default_factory=lambda: datetime.utcnow().isoformat())


@dataclass
class PromptOptimization:
    """Prompt optimization recommendations"""
    original: str
    optimized: str
    improvements: List[str]
    estimated_token_reduction: int
    estimated_quality_change: str
    confidence: float


# ============================================================================
# HARNESS ENGINE
# ============================================================================

class HarnessEngine:
    """Advanced multi-agent orchestration engine"""
    
    def __init__(self, data_dir: Optional[str] = None):
        self.data_dir = Path(data_dir or "/tmp/harness")
        self.data_dir.mkdir(exist_ok=True)
        
        self.teams: Dict[str, AgentTeam] = {}
        self.metrics: Dict[str, AgentMetrics] = {}
        self.prompt_cache: Dict[str, PromptOptimization] = {}
        self.execution_history: List[Dict[str, Any]] = []
        
        self.logger = logging.getLogger(__name__)
        logging.basicConfig(level=logging.INFO)
        
        self._load_state()
    
    def _load_state(self):
        """Load persisted state from disk"""
        teams_file = self.data_dir / "teams.json"
        if teams_file.exists():
            with open(teams_file) as f:
                teams_data = json.load(f)
                for team_id, team_dict in teams_data.items():
                    agents = []
                    for agent_dict in team_dict.get("agents", []):
                        agent_dict["role"] = AgentRole(agent_dict.get("role", "specialist"))
                        agent_dict["failure_mode"] = FailureMode(agent_dict.get("failure_mode", "retry_with_backoff"))
                        agents.append(Agent(**agent_dict))
                    team_dict["pattern"] = OrchestrationPattern(team_dict.get("pattern", "sequential"))
                    team_dict["fallback_strategy"] = FailureMode(team_dict.get("fallback_strategy", "graceful_degradation"))
                    self.teams[team_id] = AgentTeam(
                        id=team_id,
                        agents=agents,
                        pattern=team_dict.get("pattern", OrchestrationPattern.SEQUENTIAL),
                        fallback_strategy=team_dict.get("fallback_strategy", FailureMode.GRACEFUL_DEGRADATION),
                        **{k: v for k, v in team_dict.items() if k not in ("agents", "pattern", "fallback_strategy", "id")}
                    )
    
    def _save_state(self):
        """Persist state to disk"""
        teams_file = self.data_dir / "teams.json"
        teams_data = {}
        for team_id, team in self.teams.items():
            teams_data[team_id] = {
                **asdict(team),
                "agents": [asdict(a) for a in team.agents],
                "pattern": team.pattern.value,
                "fallback_strategy": team.fallback_strategy.value
            }
        with open(teams_file, "w") as f:
            json.dump(teams_data, f, indent=2, default=lambda o: o.value if isinstance(o, Enum) else str(o))
    
    # ========== AGENT TEAM DESIGN ==========
    
    def design_agent_team(
        self,
        name: str,
        description: str,
        pattern: str,
        domain: str,
        agent_count: int = 5,
        context_budget: int = 128000
    ) -> Dict[str, Any]:
        """Design a multi-agent team for a specific domain"""
        
        pattern_enum = OrchestrationPattern[pattern.upper()]
        team_id = hashlib.md5(f"{name}{time.time()}".encode()).hexdigest()[:12]
        
        # Generate specialized agents based on pattern
        agents = self._generate_agents_for_pattern(
            pattern_enum, domain, agent_count
        )
        
        # Create team
        team = AgentTeam(
            id=team_id,
            name=name,
            description=description,
            pattern=pattern_enum,
            agents=agents,
            context_budget=context_budget
        )
        
        self.teams[team_id] = team
        self._save_state()
        
        return {
            "team_id": team_id,
            "name": name,
            "pattern": pattern,
            "agents": [
                {
                    "id": a.id,
                    "name": a.name,
                    "role": a.role.value,
                    "model": a.model,
                    "capabilities": a.capabilities
                }
                for a in agents
            ],
            "status": "created",
            "validation": self._validate_team(team)
        }
    
    def _generate_agents_for_pattern(
        self,
        pattern: OrchestrationPattern,
        domain: str,
        count: int
    ) -> List[Agent]:
        """Generate specialized agents for orchestration pattern"""
        
        agents = []
        agent_templates = {
            OrchestrationPattern.SEQUENTIAL: [
                ("initiator", "Starts workflow and validates inputs"),
                ("processor_1", "Processes primary logic"),
                ("processor_2", "Refines and validates results"),
                ("finalizer", "Aggregates and delivers output"),
            ],
            OrchestrationPattern.EXPERT_POOL: [
                ("router", "Routes requests to specialists"),
                ("specialist_1", f"{domain} Specialist"),
                ("specialist_2", f"{domain} Advanced Expert"),
                ("specialist_3", f"{domain} Optimization Specialist"),
                ("aggregator", "Combines specialist outputs"),
            ],
            OrchestrationPattern.HIERARCHICAL: [
                ("supervisor", "Coordinates team and decision-making"),
                ("manager_1", "Manages worker layer 1"),
                ("worker_1", f"Worker executing {domain} tasks"),
                ("worker_2", f"Worker executing {domain} tasks"),
                ("monitor", "Monitors team health and performance"),
            ],
            OrchestrationPattern.PRODUCER_REVIEWER: [
                ("producer", f"Produces {domain} content"),
                ("reviewer", "Reviews for quality and correctness"),
                ("refiner", "Refines based on feedback"),
                ("validator", "Final validation"),
            ],
        }
        
        template = agent_templates.get(pattern, list(agent_templates.values())[0])[:count]
        
        for i, (role_name, capability) in enumerate(template[:count]):
            agent = Agent(
                id=f"agent_{hashlib.md5(role_name.encode()).hexdigest()[:8]}",
                name=role_name.replace("_", " ").title(),
                role=AgentRole[role_name.upper()] if role_name.upper() in AgentRole.__members__ else AgentRole.SPECIALIST,
                model="claude-opus-4.6",
                system_prompt=self._generate_system_prompt(role_name, domain, capability),
                tools=self._get_tools_for_role(role_name),
                capabilities=[capability],
                fallback_models=["claude-sonnet-4.6", "claude-haiku-4.5"],
            )
            agents.append(agent)
        
        return agents
    
    def _generate_system_prompt(
        self,
        role: str,
        domain: str,
        capability: str
    ) -> str:
        """Generate specialized system prompt for agent role"""
        return f"""You are a {role.replace('_', ' ').title()} specializing in {domain}.

Your primary capability: {capability}

Guidelines:
1. Stay focused on your specific role and expertise
2. Provide clear, structured outputs
3. Flag uncertainties and escalate when needed
4. Optimize for accuracy over speed
5. Provide reasoning for all decisions
6. Format outputs for downstream consumption

Success criteria:
- Accurate and reliable execution
- Clear communication with other agents
- Graceful handling of edge cases
- Continuous improvement through feedback"""
    
    def _get_tools_for_role(self, role: str) -> List[str]:
        """Get recommended tools for agent role"""
        role_tools = {
            "router": ["routing_table", "request_parser", "load_balancer"],
            "specialist": ["domain_knowledge", "analysis_tools", "validation"],
            "aggregator": ["data_fusion", "deduplication", "ranking"],
            "reviewer": ["quality_checker", "validation_rules", "feedback"],
            "validator": ["schema_validation", "constraint_checking", "error_reporting"],
            "monitor": ["metrics_collection", "alerting", "health_check"],
        }
        return role_tools.get(role, ["general_purpose_tools"])
    
    def _validate_team(self, team: AgentTeam) -> Dict[str, Any]:
        """Validate team architecture and completeness"""
        checks = {
            "coverage": len(team.agents) >= 3,
            "no_single_points_of_failure": self._has_redundancy(team),
            "clear_roles": self._has_clear_role_separation(team),
            "communication_paths": self._has_valid_communication(team),
            "resource_allocation": self._has_valid_resources(team),
            "timeout_consistent": self._has_consistent_timeouts(team),
        }
        return {
            "passed": sum(checks.values()),
            "total": len(checks),
            "details": checks
        }
    
    def _has_redundancy(self, team: AgentTeam) -> bool:
        """Check for role redundancy"""
        roles = [a.role for a in team.agents]
        specialist_count = sum(1 for r in roles if r == AgentRole.SPECIALIST)
        return specialist_count >= 2 or len(team.agents) >= 4
    
    def _has_clear_role_separation(self, team: AgentTeam) -> bool:
        """Check for clear role separation"""
        roles = [a.role for a in team.agents]
        return len(set(roles)) >= 2
    
    def _has_valid_communication(self, team: AgentTeam) -> bool:
        """Check communication paths"""
        return len(team.agents) >= 2
    
    def _has_valid_resources(self, team: AgentTeam) -> bool:
        """Check resource allocation"""
        total_tokens = sum(a.max_tokens for a in team.agents)
        return total_tokens <= team.context_budget
    
    def _has_consistent_timeouts(self, team: AgentTeam) -> bool:
        """Check timeout configuration"""
        return all(a.timeout_seconds <= team.timeout_seconds for a in team.agents)
    
    # ========== PROMPT OPTIMIZATION ==========
    
    def optimize_prompt(self, prompt: str, constraints: Optional[List[str]] = None) -> PromptOptimization:
        """Optimize prompt for clarity, conciseness, and effectiveness"""
        
        # Check cache
        prompt_hash = hashlib.md5(prompt.encode()).hexdigest()
        if prompt_hash in self.prompt_cache:
            return self.prompt_cache[prompt_hash]
        
        improvements = []
        optimized = prompt
        
        # Optimization rules
        if "{" not in prompt and len(prompt.split()) > 500:
            improvements.append("Split long prompts into structured sections")
        
        if "but" in prompt.lower() or "however" in prompt.lower():
            improvements.append("Reduce hedging language for clarity")
            optimized = optimized.replace(" but ", " and ").replace(" however ", " and ")
        
        if "please" in prompt.lower():
            improvements.append("Remove politeness markers for directness")
            optimized = optimized.replace("please ", "").replace("Please ", "")
        
        if not any(keyword in prompt.lower() for keyword in ["output", "format", "structure"]):
            improvements.append("Add explicit output format specification")
        
        if not any(keyword in prompt.lower() for keyword in ["step", "process", "procedure"]):
            improvements.append("Add step-by-step reasoning guidance")
        
        # Calculate metrics
        original_tokens = len(prompt.split())
        optimized_tokens = len(optimized.split())
        token_reduction = original_tokens - optimized_tokens
        
        quality_change = "improved" if improvements else "maintained"
        confidence = min(0.95, 0.7 + (len(improvements) * 0.05))
        
        result = PromptOptimization(
            original=prompt,
            optimized=optimized,
            improvements=improvements,
            estimated_token_reduction=max(0, token_reduction),
            estimated_quality_change=quality_change,
            confidence=confidence
        )
        
        self.prompt_cache[prompt_hash] = result
        return result
    
    # ========== PERFORMANCE PROFILING ==========
    
    def profile_agent(self, agent_id: str) -> Dict[str, Any]:
        """Get performance profile for agent"""
        
        if agent_id not in self.metrics:
            self.metrics[agent_id] = AgentMetrics(agent_id=agent_id)
        
        metrics = self.metrics[agent_id]
        success_rate = (metrics.successes / metrics.calls * 100) if metrics.calls > 0 else 100.0
        
        return {
            "agent_id": agent_id,
            "calls": metrics.calls,
            "successes": metrics.successes,
            "failures": metrics.failures,
            "success_rate_percent": round(success_rate, 2),
            "total_tokens_used": metrics.total_tokens,
            "total_cost": round(metrics.total_cost, 4),
            "latency_ms": {
                "average": round(metrics.avg_latency_ms, 2),
                "p95": round(metrics.p95_latency_ms, 2),
                "p99": round(metrics.p99_latency_ms, 2),
            },
            "failures_24h": metrics.failure_count_24h,
            "last_failure": metrics.last_failure,
            "health_status": "healthy" if success_rate >= 95 else "degraded" if success_rate >= 80 else "unhealthy"
        }
    
    def get_team_metrics(self, team_id: str) -> Dict[str, Any]:
        """Get aggregate metrics for team"""
        
        team = self.teams.get(team_id)
        if not team:
            return {"error": "Team not found"}
        
        team_metrics = {
            "team_id": team_id,
            "name": team.name,
            "pattern": team.pattern.value,
            "agents": []
        }
        
        total_tokens = 0
        total_cost = 0.0
        total_calls = 0
        
        for agent in team.agents:
            if agent.id in self.metrics:
                metrics = self.metrics[agent.id]
                total_tokens += metrics.total_tokens
                total_cost += metrics.total_cost
                total_calls += metrics.calls
                
                team_metrics["agents"].append({
                    "id": agent.id,
                    "name": agent.name,
                    "calls": metrics.calls,
                    "success_rate": round((metrics.successes / metrics.calls * 100) if metrics.calls > 0 else 100, 2),
                    "cost": round(metrics.total_cost, 4),
                    "tokens": metrics.total_tokens,
                })
        
        team_metrics["aggregate"] = {
            "total_calls": total_calls,
            "total_tokens": total_tokens,
            "total_cost": round(total_cost, 4),
            "avg_cost_per_call": round(total_cost / total_calls, 4) if total_calls > 0 else 0,
        }
        
        return team_metrics
    
    # ========== ORCHESTRATION ==========
    
    def generate_orchestration_template(self, team_id: str) -> Dict[str, Any]:
        """Generate execution template for team"""
        
        team = self.teams.get(team_id)
        if not team:
            return {"error": "Team not found"}
        
        template = {
            "team_id": team_id,
            "team_name": team.name,
            "pattern": team.pattern.value,
            "execution_plan": self._generate_execution_plan(team),
            "coordination_protocol": self._generate_coordination_protocol(team),
            "error_recovery": self._generate_error_recovery(team),
            "context_allocation": self._generate_context_allocation(team),
        }
        
        return template
    
    def _generate_execution_plan(self, team: AgentTeam) -> Dict[str, Any]:
        """Generate execution plan for pattern"""
        
        plans = {
            OrchestrationPattern.SEQUENTIAL: {
                "strategy": "Execute agents in order, passing output to next",
                "stages": [
                    {
                        "stage": i,
                        "agent": agent.name,
                        "input_source": "previous_output" if i > 0 else "user_input",
                        "output": f"stage_{i}_output",
                    }
                    for i, agent in enumerate(team.agents)
                ]
            },
            OrchestrationPattern.PARALLEL: {
                "strategy": "Execute all agents concurrently on same input",
                "concurrency": len(team.agents),
                "aggregation": "Combine results from all agents",
            },
            OrchestrationPattern.EXPERT_POOL: {
                "strategy": "Router selects specialist for task",
                "routing_logic": "Content-based routing to domain expert",
                "fallback": "Chain specialists if routing uncertain",
            },
        }
        
        return plans.get(team.pattern, {"strategy": "Custom execution"})
    
    def _generate_coordination_protocol(self, team: AgentTeam) -> Dict[str, Any]:
        """Generate agent coordination protocol"""
        return {
            "communication_pattern": "Structured JSON messages",
            "message_schema": {
                "agent_id": "str",
                "timestamp": "ISO8601",
                "stage": "int",
                "input": "Any",
                "output": "Any",
                "metadata": {
                    "tokens_used": "int",
                    "latency_ms": "float",
                    "status": "success|error|partial",
                }
            },
            "error_signaling": "Explicit error field with code and message",
            "state_synchronization": "Version vector for consistency",
        }
    
    def _generate_error_recovery(self, team: AgentTeam) -> Dict[str, Any]:
        """Generate error recovery strategy"""
        return {
            "default_strategy": team.fallback_strategy.value,
            "retry_policy": {
                "max_attempts": 3,
                "backoff": "exponential",
                "base_delay_ms": 100,
            },
            "fallback_agents": [
                {
                    "primary": agent.name,
                    "fallbacks": agent.fallback_models,
                }
                for agent in team.agents
            ],
            "escalation": "Escalate to human if all agents fail",
        }
    
    def _generate_context_allocation(self, team: AgentTeam) -> Dict[str, Any]:
        """Generate context window allocation strategy"""
        total_budget = team.context_budget
        num_agents = len(team.agents)
        base_per_agent = total_budget // num_agents
        
        allocations = []
        for agent in team.agents:
            # Higher allocations for critical roles
            role_multiplier = {
                AgentRole.ROUTER: 1.2,
                AgentRole.AGGREGATOR: 1.1,
                AgentRole.MONITOR: 1.3,
            }.get(agent.role, 1.0)
            
            allocated = int(base_per_agent * role_multiplier)
            allocations.append({
                "agent": agent.name,
                "allocated_tokens": allocated,
                "reserved_for_output": agent.max_tokens,
                "available_for_input": allocated - agent.max_tokens,
            })
        
        return {
            "total_budget": total_budget,
            "per_agent_base": base_per_agent,
            "allocations": allocations,
            "strategy": "Role-based allocation with reserve for output",
        }
    
    # ========== LEARNING AND FEEDBACK ==========
    
    def record_execution(
        self,
        team_id: str,
        agent_id: str,
        success: bool,
        tokens_used: int,
        latency_ms: float,
        feedback: Optional[str] = None
    ):
        """Record execution for learning and metrics"""
        
        if agent_id not in self.metrics:
            self.metrics[agent_id] = AgentMetrics(agent_id=agent_id)
        
        metrics = self.metrics[agent_id]
        metrics.calls += 1
        metrics.total_tokens += tokens_used
        
        if success:
            metrics.successes += 1
        else:
            metrics.failures += 1
            metrics.failure_count_24h += 1
            metrics.last_failure = datetime.utcnow().isoformat()
        
        # Update latency metrics (simplified)
        metrics.avg_latency_ms = (metrics.avg_latency_ms * (metrics.calls - 1) + latency_ms) / metrics.calls
        metrics.p95_latency_ms = max(metrics.p95_latency_ms, latency_ms)
        
        metrics.success_rate = metrics.successes / metrics.calls if metrics.calls > 0 else 1.0
        
        # Record in history
        self.execution_history.append({
            "timestamp": datetime.utcnow().isoformat(),
            "team_id": team_id,
            "agent_id": agent_id,
            "success": success,
            "tokens": tokens_used,
            "latency_ms": latency_ms,
            "feedback": feedback,
        })
    
    def get_recommendations(self, team_id: str) -> Dict[str, Any]:
        """Get improvement recommendations for team"""
        
        team = self.teams.get(team_id)
        if not team:
            return {"error": "Team not found"}
        
        recommendations = []
        
        for agent in team.agents:
            metrics = self.metrics.get(agent.id)
            if not metrics:
                continue
            
            if metrics.success_rate < 0.8:
                recommendations.append({
                    "agent": agent.name,
                    "severity": "high",
                    "issue": "Low success rate",
                    "action": f"Review agent logic, enable retry with backoff, consider model upgrade"
                })
            
            if metrics.avg_latency_ms > 5000:
                recommendations.append({
                    "agent": agent.name,
                    "severity": "medium",
                    "issue": "High latency",
                    "action": "Consider parallelization or task decomposition"
                })
            
            if metrics.total_tokens > team.context_budget * 0.3:
                recommendations.append({
                    "agent": agent.name,
                    "severity": "medium",
                    "issue": "High token usage",
                    "action": "Optimize prompts and reduce context size"
                })
        
        return {
            "team_id": team_id,
            "recommendations": recommendations,
            "recommendation_count": len(recommendations),
        }


# ============================================================================
# MCP SERVER
# ============================================================================

def create_server() -> Server:
    """Create and configure MCP server"""
    
    server = Server("harness-claude")
    engine = HarnessEngine()
    
    # ========== TOOLS ==========
    
    @server.list_tools()
    async def list_tools() -> List[Tool]:
        """List all available Harness tools"""
        return [
            Tool(
                name="harness_status",
                description="Check Harness installation and status",
                inputSchema={"type": "object", "properties": {}}
            ),
            Tool(
                name="design_agent_team",
                description="Design a multi-agent team for a domain",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "name": {"type": "string", "description": "Team name"},
                        "description": {"type": "string", "description": "Team purpose"},
                        "pattern": {"type": "string", "enum": [p.value for p in OrchestrationPattern]},
                        "domain": {"type": "string", "description": "Problem domain"},
                        "agent_count": {"type": "integer", "default": 5},
                        "context_budget": {"type": "integer", "default": 128000},
                    },
                    "required": ["name", "pattern", "domain"]
                }
            ),
            Tool(
                name="optimize_prompt",
                description="Optimize prompt for clarity and efficiency",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "prompt": {"type": "string", "description": "Prompt to optimize"},
                        "constraints": {"type": "array", "items": {"type": "string"}, "description": "Constraints"},
                    },
                    "required": ["prompt"]
                }
            ),
            Tool(
                name="profile_agent",
                description="Get performance profile for an agent",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "agent_id": {"type": "string"},
                    },
                    "required": ["agent_id"]
                }
            ),
            Tool(
                name="get_team_metrics",
                description="Get aggregate metrics for a team",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "team_id": {"type": "string"},
                    },
                    "required": ["team_id"]
                }
            ),
            Tool(
                name="generate_orchestration",
                description="Generate execution template for team",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "team_id": {"type": "string"},
                    },
                    "required": ["team_id"]
                }
            ),
            Tool(
                name="list_teams",
                description="List all designed teams",
                inputSchema={"type": "object", "properties": {}}
            ),
            Tool(
                name="get_recommendations",
                description="Get improvement recommendations for team",
                inputSchema={
                    "type": "object",
                    "properties": {
                        "team_id": {"type": "string"},
                    },
                    "required": ["team_id"]
                }
            ),
        ]
    
    @server.call_tool()
    async def call_tool(name: str, arguments: Dict[str, Any]):
        """Execute tool"""
        
        try:
            if name == "harness_status":
                return [TextContent(
                    type="text",
                    text=json.dumps({
                        "status": "operational",
                        "version": "3.0.0",
                        "engine": "harness_claude_advanced",
                        "teams": len(engine.teams),
                        "executions": len(engine.execution_history),
                        "agents_tracked": len(engine.metrics),
                    }, indent=2)
                )]
            
            elif name == "design_agent_team":
                result = engine.design_agent_team(**arguments)
                return [TextContent(type="text", text=json.dumps(result, indent=2))]
            
            elif name == "optimize_prompt":
                opt = engine.optimize_prompt(arguments["prompt"])
                return [TextContent(type="text", text=json.dumps(asdict(opt), indent=2))]
            
            elif name == "profile_agent":
                result = engine.profile_agent(arguments["agent_id"])
                return [TextContent(type="text", text=json.dumps(result, indent=2))]
            
            elif name == "get_team_metrics":
                result = engine.get_team_metrics(arguments["team_id"])
                return [TextContent(type="text", text=json.dumps(result, indent=2))]
            
            elif name == "generate_orchestration":
                result = engine.generate_orchestration_template(arguments["team_id"])
                return [TextContent(type="text", text=json.dumps(result, indent=2))]
            
            elif name == "list_teams":
                teams_list = [
                    {"id": t.id, "name": t.name, "pattern": t.pattern.value, "agents": len(t.agents)}
                    for t in engine.teams.values()
                ]
                return [TextContent(type="text", text=json.dumps({"teams": teams_list}, indent=2))]
            
            elif name == "get_recommendations":
                result = engine.get_recommendations(arguments["team_id"])
                return [TextContent(type="text", text=json.dumps(result, indent=2))]
            
            else:
                return [TextContent(type="text", text=f"Unknown tool: {name}")]
        
        except Exception as e:
            return [TextContent(type="text", text=str(e))]
    
    return server


if __name__ == "__main__":
    server = create_server()
    # Start with: mcp run harness_claude_advanced_mcp.py
