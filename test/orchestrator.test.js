import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { WorkflowRunner } from '../dist/index.js';

const manifest = {
  schemaVersion: '1.0.0', packageVersion: '1.3.0', name: 'runner-demo',
  upstream: { repository: 'https://github.com/revfactory/harness', commit: 'cceac68ea1d0ad198ef4b7b906cd238375836387' },
  agents: [{ id: 'builder', role: 'implementation', modelTier: 'balanced', skills: [], tools: [] }],
  skills: [],
  workflows: [{ id: 'flow', pattern: 'pipeline', executionMode: 'workflow-orchestration', nodes: [{ id: 'build', agent: 'builder' }, { id: 'review', agent: 'builder' }], edges: [{ from: 'build', to: 'review' }], reviewGates: ['review'] }],
  runtimeRequirements: ['workflows', 'review-gates', 'artifacts']
};

test('workflow runner persists state, retries nodes, records artifacts, and enforces review gates', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-run-'));
  let buildAttempts = 0;
  const runner = new WorkflowRunner({ stateDirectory: dir, retries: 1, review: async () => true });
  const state = await runner.run(manifest, 'flow', async ({ node }) => {
    if (node.id === 'build' && buildAttempts++ === 0) throw new Error('transient');
    return { output: `${node.id}-done`, artifacts: [{ name: `${node.id}.txt`, uri: `artifact://${node.id}` }] };
  });
  assert.equal(state.status, 'completed');
  assert.equal(state.nodes.build.attempts, 2);
  assert.equal(state.nodes.review.review, 'approved');
  assert.equal(state.artifacts.length, 2);
  assert.equal(JSON.parse(await readFile(join(dir, `${state.runId}.json`), 'utf8')).status, 'completed');
});

test('workflow runner stops on rejected review', async () => {
  const dir = await mkdtemp(join(tmpdir(), 'hrh-run-'));
  const runner = new WorkflowRunner({ stateDirectory: dir, review: async () => false });
  await assert.rejects(runner.run(manifest, 'flow', async () => ({ output: 'done' })), /rejected/);
});

