import { mkdir, rename, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { randomUUID } from 'node:crypto';
import { validateManifest, type HarnessManifest } from './model.js';

export type ArtifactRecord = { name: string; uri: string; node: string };
export type NodeRunState = { status: 'pending' | 'running' | 'completed' | 'failed'; attempts: number; output?: string; error?: string; review?: 'approved' | 'rejected' };
export type WorkflowRunState = {
  runId: string; workflow: string; status: 'running' | 'completed' | 'failed';
  startedAt: string; updatedAt: string; nodes: Record<string, NodeRunState>; artifacts: ArtifactRecord[];
};
export type NodeResult = { output?: string; artifacts?: Array<{ name: string; uri: string }> };
export type NodeHandler = (context: { manifest: HarnessManifest; workflow: HarnessManifest['workflows'][number]; node: HarnessManifest['workflows'][number]['nodes'][number]; agent: HarnessManifest['agents'][number] }) => Promise<NodeResult>;
export type RunnerOptions = { stateDirectory: string; retries?: number; review?: (context: { state: WorkflowRunState; node: HarnessManifest['workflows'][number]['nodes'][number]; result: NodeResult }) => Promise<boolean> };

function order(flow: HarnessManifest['workflows'][number]): HarnessManifest['workflows'][number]['nodes'] {
  const nodes = new Map(flow.nodes.map(node => [node.id, node]));
  const incoming = new Map(flow.nodes.map(node => [node.id, 0]));
  const outgoing = new Map(flow.nodes.map(node => [node.id, [] as string[]]));
  for (const edge of flow.edges) {
    if (!nodes.has(edge.from) || !nodes.has(edge.to)) throw new Error(`workflow edge references unknown node: ${edge.from} -> ${edge.to}`);
    incoming.set(edge.to, incoming.get(edge.to)! + 1);
    outgoing.get(edge.from)!.push(edge.to);
  }
  const queue = flow.nodes.filter(node => incoming.get(node.id) === 0);
  const result: typeof flow.nodes = [];
  while (queue.length) {
    const node = queue.shift()!; result.push(node);
    for (const next of outgoing.get(node.id)!) { incoming.set(next, incoming.get(next)! - 1); if (incoming.get(next) === 0) queue.push(nodes.get(next)!); }
  }
  if (result.length !== flow.nodes.length) throw new Error(`workflow ${flow.id} contains a cycle`);
  return result;
}

export class WorkflowRunner {
  constructor(private readonly options: RunnerOptions) {}

  private async persist(state: WorkflowRunState): Promise<void> {
    await mkdir(this.options.stateDirectory, { recursive: true });
    state.updatedAt = new Date().toISOString();
    const path = join(this.options.stateDirectory, `${state.runId}.json`);
    const temporary = `${path}.${process.pid}.tmp`;
    await writeFile(temporary, `${JSON.stringify(state, null, 2)}\n`, { mode: 0o600 });
    await rename(temporary, path);
  }

  async run(input: HarnessManifest, workflowId: string, handler: NodeHandler): Promise<WorkflowRunState> {
    const manifest = validateManifest(input);
    const workflow = manifest.workflows.find(flow => flow.id === workflowId);
    if (!workflow) throw new Error(`unknown workflow: ${workflowId}`);
    const timestamp = new Date().toISOString();
    const state: WorkflowRunState = {
      runId: randomUUID(), workflow: workflow.id, status: 'running', startedAt: timestamp, updatedAt: timestamp,
      nodes: Object.fromEntries(workflow.nodes.map(node => [node.id, { status: 'pending', attempts: 0 }])), artifacts: []
    };
    await this.persist(state);
    try {
      for (const node of order(workflow)) {
        const nodeState = state.nodes[node.id]!;
        const agent = manifest.agents.find(item => item.id === node.agent)!;
        let result: NodeResult | undefined;
        for (let attempt = 0; attempt <= (this.options.retries ?? 0); attempt++) {
          nodeState.status = 'running'; nodeState.attempts++; delete nodeState.error; await this.persist(state);
          try { result = await handler({ manifest, workflow, node, agent }); break; }
          catch (error) { nodeState.error = error instanceof Error ? error.message : String(error); if (attempt === (this.options.retries ?? 0)) throw error; }
        }
        result ??= {};
        if (result.output !== undefined) nodeState.output = result.output;
        for (const artifact of result.artifacts ?? []) state.artifacts.push({ ...artifact, node: node.id });
        if (workflow.reviewGates.includes(node.id)) {
          if (!this.options.review) throw new Error(`review callback required for gate: ${node.id}`);
          const approved = await this.options.review({ state, node, result });
          nodeState.review = approved ? 'approved' : 'rejected';
          if (!approved) throw new Error(`review gate rejected: ${node.id}`);
        }
        nodeState.status = 'completed'; await this.persist(state);
      }
      state.status = 'completed'; await this.persist(state); return state;
    } catch (error) {
      state.status = 'failed';
      const running = Object.values(state.nodes).find(node => node.status === 'running');
      if (running) { running.status = 'failed'; running.error = error instanceof Error ? error.message : String(error); }
      await this.persist(state); throw error;
    }
  }
}
