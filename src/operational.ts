import { readFile, mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import process from 'node:process';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { parse as parseJsonc } from 'jsonc-parser';
import { parse as parseToml } from 'smol-toml';
import { parse as parseYaml } from 'yaml';
import { runtimeConfig } from './compiler.js';
import type { Runtime } from './model.js';

type GeneratedReceipt = string | { path: string; sha256: string };
export type OperationalReceipt = { runtime: Runtime; config: string; generated: GeneratedReceipt[] };
type ServerDescriptor = { command: string; args: string[] };

function object(value: unknown, label: string): Record<string, unknown> {
  if (!value || typeof value !== 'object' || Array.isArray(value)) throw new Error(`${label} must be an object`);
  return value as Record<string, unknown>;
}

function serverDescriptor(value: unknown): ServerDescriptor {
  const server = object(value, 'MCP server descriptor');
  if (typeof server.command !== 'string' || !Array.isArray(server.args) || !server.args.every(arg => typeof arg === 'string')) {
    throw new Error('MCP server descriptor must contain a command and string args');
  }
  return { command: server.command, args: server.args as string[] };
}

function nested(value: Record<string, unknown>, first: string, second: string): unknown {
  return object(value[first], first)[second];
}

function installedDescriptor(runtime: Runtime, text: string): ServerDescriptor {
  const parsed = runtime === 'codex' ? object(parseToml(text), 'configuration')
    : runtime === 'hermes' ? object(parseYaml(text), 'configuration')
      : runtime === 'mimo' || runtime === 'opencode' ? object(parseJsonc(text), 'configuration')
        : object(JSON.parse(text), 'configuration');
  return serverDescriptor(runtime === 'codex' || runtime === 'hermes'
    ? nested(parsed, 'mcp_servers', 'harness')
    : runtime === 'mimo' || runtime === 'opencode'
      ? nested(parsed, 'mcp', 'harness')
      : nested(parsed, 'mcpServers', 'harness'));
}

function expectedDescriptor(runtime: Runtime): ServerDescriptor {
  const patch = runtimeConfig(runtime).patch;
  return serverDescriptor(runtime === 'codex' || runtime === 'hermes'
    ? nested(patch, 'mcp_servers', 'harness')
    : runtime === 'mimo' || runtime === 'opencode'
      ? nested(patch, 'mcp', 'harness')
      : nested(patch, 'mcpServers', 'harness'));
}

async function bounded<T>(operation: Promise<T>, milliseconds: number, label: string): Promise<T> {
  let timer: NodeJS.Timeout | undefined;
  try {
    return await Promise.race([
      operation,
      new Promise<never>((_, reject) => { timer = setTimeout(() => reject(new Error(`${label} timed out after ${milliseconds}ms`)), milliseconds); })
    ]);
  } finally {
    if (timer) clearTimeout(timer);
  }
}

function running(pid: number): boolean {
  try { process.kill(pid, 0); return true; }
  catch (error) {
    if ((error as NodeJS.ErrnoException).code === 'ESRCH') return false;
    throw error;
  }
}

async function waitForExit(pid: number, milliseconds: number): Promise<void> {
  const started = Date.now();
  while (running(pid)) {
    if (Date.now() - started >= milliseconds) throw new Error(`MCP server process ${pid} remained alive after shutdown`);
    await new Promise(resolve => setTimeout(resolve, 20));
  }
}

export type OperationalReport = {
  ok: boolean;
  server: { name: string; version: string };
  tools: string[];
  resources: string[];
  prompts: string[];
  validCall: boolean;
  invalidInputRejected: boolean;
  shutdown: boolean;
};

export async function verifyOperational(record: OperationalReceipt, timeoutMs: number): Promise<OperationalReport> {
  const installed = installedDescriptor(record.runtime, await readFile(record.config, 'utf8'));
  const expected = expectedDescriptor(record.runtime);
  if (installed.command !== expected.command || JSON.stringify(installed.args) !== JSON.stringify(expected.args)) {
    throw new Error('installed MCP descriptor does not match this package; refusing to execute it');
  }
  const manifestPath = record.generated.map(value => typeof value === 'string' ? value : value.path).find(path => path.endsWith('harness.manifest.json'));
  if (!manifestPath) throw new Error('installation receipt does not contain a canonical manifest');
  const manifest = JSON.parse(await readFile(manifestPath, 'utf8')) as unknown;
  const cwd = await mkdtemp(join(tmpdir(), 'hrh-operational-'));
  const transport = new StdioClientTransport({ command: installed.command, args: installed.args, cwd, stderr: 'pipe' });
  const client = new Client({ name: 'harness-operational-verify', version: '1.0.0' });
  let pid: number | null = null;
  let shutdown = false;
  try {
    await bounded(client.connect(transport), timeoutMs, 'MCP initialization');
    pid = transport.pid;
    const [toolResult, resourceResult, promptResult] = await bounded(Promise.all([
      client.listTools(), client.listResources(), client.listPrompts()
    ]), timeoutMs, 'MCP discovery');
    const valid = await bounded(client.callTool({ name: 'harness_validate', arguments: { manifest } }), timeoutMs, 'valid tool call');
    let invalidInputRejected = false;
    try {
      const invalid = await bounded(client.callTool({ name: 'harness_validate', arguments: {} }), timeoutMs, 'invalid tool call');
      invalidInputRejected = invalid.isError === true;
    } catch (error) {
      if (error instanceof Error && error.message.includes('timed out after')) throw error;
      invalidInputRejected = true;
    }
    const server = client.getServerVersion();
    if (!server) throw new Error('MCP server omitted server identity');
    const tools = toolResult.tools.map(tool => tool.name);
    const resources = resourceResult.resources.map(resource => resource.uri);
    const prompts = promptResult.prompts.map(prompt => prompt.name);
    const validCall = valid.isError !== true;
    const ok = tools.includes('harness_validate') && resources.includes('harness://capabilities') && prompts.includes('harness_plan') && validCall && invalidInputRejected;
    await bounded(client.close(), timeoutMs, 'MCP shutdown');
    if (pid !== null) await waitForExit(pid, timeoutMs);
    shutdown = true;
    return { ok, server, tools, resources, prompts, validCall, invalidInputRejected, shutdown };
  } finally {
    if (!shutdown) await transport.close().catch(() => undefined);
    await rm(cwd, { recursive: true, force: true });
  }
}
