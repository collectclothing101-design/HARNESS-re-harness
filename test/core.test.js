import test from 'node:test';
import assert from 'node:assert/strict';
import { validateManifest, compileRuntime, VERSION } from '../dist/index.js';

const manifest = {
  schemaVersion: '1.0.0', packageVersion: '1.2.0', name: 'demo',
  upstream: { repository: 'https://github.com/revfactory/harness', commit: '0123456789abcdef0123456789abcdef01234567' },
  agents: [{ id: 'builder', role: 'implementation', modelTier: 'balanced', skills: ['coding'], tools: ['filesystem'] }],
  skills: [{ id: 'coding', description: 'Implement code', triggers: ['implement'] }],
  workflows: [{ id: 'flow', pattern: 'producer-reviewer', nodes: [{ id: 'build', agent: 'builder' }], edges: [], reviewGates: [] }],
  runtimeRequirements: ['agents', 'skills', 'tools']
};

test('single version authority matches package', () => {
  assert.equal(VERSION.package, '1.2.0');
  assert.equal(VERSION.schema, manifest.schemaVersion);
});

test('manifest accepts immutable upstream SHA and rejects branches', () => {
  assert.equal(validateManifest(manifest).name, 'demo');
  assert.throws(() => validateManifest({ ...manifest, upstream: { ...manifest.upstream, commit: 'main' } }), /40-character/);
});

test('manifest rejects duplicate identifiers and dangling workflow graph references', () => {
  const duplicate = structuredClone(manifest);
  duplicate.agents.push(structuredClone(duplicate.agents[0]));
  assert.throws(() => validateManifest(duplicate), /duplicate agent/);
  const dangling = structuredClone(manifest);
  dangling.workflows[0].edges.push({ from: 'build', to: 'missing' });
  assert.throws(() => validateManifest(dangling), /unknown edge node/);
  const gate = structuredClone(manifest);
  gate.workflows[0].reviewGates.push('missing');
  assert.throws(() => validateManifest(gate), /unknown review gate/);
});

test('compiler emits native assets and explicit downgrades', () => {
  const codex = compileRuntime(manifest, 'codex');
  assert.equal(codex.runtime, 'codex');
  assert.ok(codex.files.some(f => f.path === '.codex/config.toml'));
  const generic = compileRuntime(manifest, 'generic');
  assert.ok(generic.downgrades.some(d => d.capability === 'agents'));
});

test('compiler emits agents, skills, workflows, canonical manifest and model mappings', () => {
  for (const runtime of ['claude','codex','chatgpt','mimo','opencode','hermes','frank','generic']) {
    const result = compileRuntime(manifest, runtime);
    assert.ok(result.files.some(file => file.path.endsWith('harness.manifest.json')), `${runtime}: canonical manifest`);
    assert.ok(result.files.some(file => file.path.includes('/agents/') || file.path.startsWith('agents/')), `${runtime}: agents`);
    assert.ok(result.files.some(file => file.path.endsWith('/SKILL.md')), `${runtime}: skills`);
    assert.ok(result.files.some(file => file.path.includes('/workflows/')), `${runtime}: workflows`);
    assert.equal(result.modelMappings.builder.symbolic, 'balanced');
  }
  assert.equal(compileRuntime(manifest, 'claude').modelMappings.builder.runtime, 'sonnet');
});

test('workflow execution modes support upstream v2 without vendor coupling', () => {
  for (const executionMode of ['workflow-orchestration', 'persistent-collaboration', 'subagent-delegation']) {
    const candidate = structuredClone(manifest);
    candidate.workflows[0].executionMode = executionMode;
    assert.equal(validateManifest(candidate).workflows[0].executionMode, executionMode);
  }
});

