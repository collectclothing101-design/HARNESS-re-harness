import { z } from 'zod';
import { VERSION } from './version.js';

const identifier = z.string().regex(/^[a-z][a-z0-9_-]*$/i);
const capability = z.enum(['agents', 'teams', 'skills', 'tools', 'mcp', 'workflows', 'review-gates', 'artifacts']);
const agent = z.object({
  id: identifier, role: z.string().min(1), modelTier: z.enum(['reasoning', 'balanced', 'fast']),
  skills: z.array(identifier).default([]), tools: z.array(identifier).default([])
});
const skill = z.object({ id: identifier, description: z.string().min(1), triggers: z.array(z.string().min(1)).min(1) });
const node = z.object({ id: identifier, agent: identifier });
const edge = z.object({ from: identifier, to: identifier, condition: z.string().optional() });
const executionMode = z.enum(['workflow-orchestration', 'persistent-collaboration', 'subagent-delegation']);
const workflow = z.object({
  id: identifier,
  pattern: z.enum(['pipeline', 'fan-out-fan-in', 'expert-pool', 'producer-reviewer', 'supervisor', 'hierarchical-delegation']),
  executionMode: executionMode.default('workflow-orchestration'),
  nodes: z.array(node).min(1), edges: z.array(edge), reviewGates: z.array(identifier)
});

export const ManifestSchema = z.object({
  schemaVersion: z.literal(VERSION.schema), packageVersion: z.literal(VERSION.package), name: identifier,
  upstream: z.object({ repository: z.string().url(), commit: z.string().regex(/^[a-f0-9]{40}$/i, 'upstream commit must be a 40-character immutable SHA') }),
  agents: z.array(agent).min(1), skills: z.array(skill), workflows: z.array(workflow).min(1),
  runtimeRequirements: z.array(capability)
}).superRefine((value, ctx) => {
  const agents = new Set(value.agents.map(x => x.id));
  const skills = new Set(value.skills.map(x => x.id));
  const duplicate = (items: Array<{ id: string }>, kind: string, path: string) => {
    const seen = new Set<string>();
    for (const item of items) if (seen.has(item.id)) ctx.addIssue({ code: 'custom', path: [path], message: `duplicate ${kind}: ${item.id}` }); else seen.add(item.id);
  };
  duplicate(value.agents, 'agent', 'agents');
  duplicate(value.skills, 'skill', 'skills');
  duplicate(value.workflows, 'workflow', 'workflows');
  for (const item of value.agents) for (const id of item.skills) if (!skills.has(id)) ctx.addIssue({ code: 'custom', path: ['agents', item.id, 'skills'], message: `unknown skill: ${id}` });
  for (const flow of value.workflows) {
    duplicate(flow.nodes, 'workflow node', 'workflows');
    const nodes = new Set(flow.nodes.map(item => item.id));
    for (const item of flow.nodes) if (!agents.has(item.agent)) ctx.addIssue({ code: 'custom', path: ['workflows', flow.id], message: `unknown agent: ${item.agent}` });
    for (const item of flow.edges) for (const id of [item.from, item.to]) if (!nodes.has(id)) ctx.addIssue({ code: 'custom', path: ['workflows', flow.id, 'edges'], message: `unknown edge node: ${id}` });
    for (const id of flow.reviewGates) if (!nodes.has(id)) ctx.addIssue({ code: 'custom', path: ['workflows', flow.id, 'reviewGates'], message: `unknown review gate: ${id}` });
  }
});

export type HarnessManifest = z.infer<typeof ManifestSchema>;
export type Runtime = 'claude' | 'codex' | 'chatgpt' | 'mimo' | 'opencode' | 'hermes' | 'frank' | 'generic';
export type Capability = z.infer<typeof capability>;
export type ExecutionMode = z.infer<typeof executionMode>;

export function validateManifest(input: unknown): HarnessManifest {
  return ManifestSchema.parse(input);
}
