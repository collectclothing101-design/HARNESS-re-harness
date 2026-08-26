import type { Capability, HarnessManifest, Runtime } from './model.js';
import { validateManifest } from './model.js';

export type GeneratedFile = { path: string; content: string };
type Downgrade = { capability: Capability; strategy: string };
type ModelMapping = { symbolic: 'reasoning' | 'balanced' | 'fast'; runtime: string };
export type Compilation = { runtime: Runtime; files: GeneratedFile[]; downgrades: Downgrade[]; modelMappings: Record<string, ModelMapping> };

const support: Record<Runtime, ReadonlySet<Capability>> = {
  claude: new Set(['agents','teams','skills','tools','mcp','workflows','review-gates','artifacts']),
  codex: new Set(['agents','skills','tools','mcp','workflows','review-gates','artifacts']),
  chatgpt: new Set(['skills','tools','mcp','workflows','review-gates','artifacts']),
  mimo: new Set(['agents','skills','tools','mcp','workflows','review-gates','artifacts']),
  opencode: new Set(['agents','skills','tools','mcp','workflows','artifacts']),
  hermes: new Set(['agents','skills','tools','mcp','workflows','artifacts']),
  frank: new Set(['agents','teams','skills','tools','mcp','workflows','review-gates','artifacts']),
  generic: new Set(['tools','mcp','artifacts'])
};

const paths: Record<Runtime, string> = {
  claude: '.claude/settings.json', codex: '.codex/config.toml', chatgpt: '.chatgpt/harness.json',
  mimo: '.config/mimocode/mimocode.jsonc', opencode: '.config/opencode/opencode.jsonc',
  hermes: '.hermes/config.yaml', frank: '.frank/harness.json', generic: 'mcp/harness.json'
};

const roots: Record<Runtime, string> = {
  claude: '.claude', codex: '.codex', chatgpt: '.chatgpt', mimo: '.config/mimocode',
  opencode: '.config/opencode', hermes: '.hermes', frank: '.frank', generic: 'harness'
};

const modelNames: Record<Runtime, Record<ModelMapping['symbolic'], string>> = {
  claude: { reasoning: 'opus', balanced: 'sonnet', fast: 'sonnet' },
  codex: { reasoning: 'reasoning', balanced: 'balanced', fast: 'fast' },
  chatgpt: { reasoning: 'reasoning', balanced: 'balanced', fast: 'fast' },
  mimo: { reasoning: 'reasoning', balanced: 'balanced', fast: 'fast' },
  opencode: { reasoning: 'reasoning', balanced: 'balanced', fast: 'fast' },
  hermes: { reasoning: 'reasoning', balanced: 'balanced', fast: 'fast' },
  frank: { reasoning: 'reasoning', balanced: 'balanced', fast: 'fast' },
  generic: { reasoning: 'reasoning', balanced: 'balanced', fast: 'fast' }
};

export function capabilityMatrix(): Record<Runtime, Capability[]> {
  return Object.fromEntries(Object.entries(support).map(([runtime, values]) => [runtime, [...values]])) as Record<Runtime, Capability[]>;
}

export function compileRuntime(input: HarnessManifest, runtime: Runtime): Compilation {
  const manifest = validateManifest(input);
  const native = support[runtime];
  const downgrades = manifest.runtimeRequirements.filter(x => !native.has(x)).map(capability => ({
    capability,
    strategy: capability === 'teams' ? 'serialize team stages through workflow handoffs' :
      capability === 'agents' ? 'execute agent roles as parameterized MCP tool calls' :
      capability === 'skills' ? 'inline selected skill instructions into the workflow prompt' :
      `enforce ${capability} in the orchestration server`
  }));
  const modelMappings = Object.fromEntries(manifest.agents.map(agent => [agent.id, { symbolic: agent.modelTier, runtime: modelNames[runtime][agent.modelTier] }])) as Record<string, ModelMapping>;
  const payload = { generatedBy: '@frank/harness-re-harness', runtime, manifest, downgrades, modelMappings };
  const content = runtime === 'codex'
    ? `[mcp_servers.harness]\ncommand = "node"\nargs = ["dist/server.js"]\n\n[profiles.harness]\nmanifest = "harness.manifest.json"\n`
    : runtime === 'hermes'
      ? `mcp_servers:\n  harness:\n    command: node\n    args:\n      - dist/server.js\nharness_manifest: harness.manifest.json\n`
      : `${JSON.stringify(payload, null, 2)}\n`;
  const root = roots[runtime];
  const files: GeneratedFile[] = [
    { path: paths[runtime], content },
    { path: `${root}/harness.manifest.json`, content: `${JSON.stringify(manifest, null, 2)}\n` },
    ...manifest.agents.map(agent => ({
      path: `${root}/agents/${agent.id}.md`,
      content: `---\nid: ${agent.id}\nmodel: ${modelMappings[agent.id]!.runtime}\nmodel-tier: ${agent.modelTier}\n---\n\n# ${agent.id}\n\n${agent.role}\n\nSkills: ${agent.skills.join(', ') || 'none'}\nTools: ${agent.tools.join(', ') || 'none'}\n`
    })),
    ...manifest.skills.map(skill => ({
      path: `${root}/skills/${skill.id}/SKILL.md`,
      content: `---\nname: ${skill.id}\ndescription: ${JSON.stringify(skill.description)}\ntriggers: ${JSON.stringify(skill.triggers)}\n---\n\n# ${skill.id}\n\n${skill.description}\n`
    })),
    ...manifest.workflows.map(flow => ({ path: `${root}/workflows/${flow.id}.json`, content: `${JSON.stringify(flow, null, 2)}\n` }))
  ];
  return { runtime, files, downgrades, modelMappings };
}

export function runtimeConfig(runtime: Runtime): { path: string; format: 'json' | 'jsonc' | 'toml' | 'yaml'; patch: Record<string, unknown> } {
  const server = { command: 'node', args: ['dist/server.js'] };
  if (runtime === 'codex') return { path: paths[runtime], format: 'toml', patch: { mcp_servers: { harness: server }, profiles: { harness: { manifest: '.codex/harness.manifest.json' } } } };
  if (runtime === 'hermes') return { path: paths[runtime], format: 'yaml', patch: { mcp_servers: { harness: server }, harness_manifest: '.hermes/harness.manifest.json' } };
  if (runtime === 'mimo' || runtime === 'opencode') return { path: paths[runtime], format: 'jsonc', patch: { mcp: { harness: server } } };
  return { path: paths[runtime], format: 'json', patch: { mcpServers: { harness: server } } };
}
