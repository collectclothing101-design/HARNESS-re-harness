import { spawn } from 'node:child_process';
import { createInterface } from 'node:readline';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { LATEST_PROTOCOL_VERSION, SUPPORTED_PROTOCOL_VERSIONS } from '@modelcontextprotocol/sdk/types.js';
import { VERSION } from './version.js';

type JsonObject = Record<string, unknown>;
export type ProtocolProbe = { requested: string; negotiated: string; tools: string[]; shutdown: boolean };
export type ProtocolMatrixReport = {
  ok: boolean;
  supported: ProtocolProbe[];
  unsupported: ProtocolProbe & { counteroffer: boolean };
  shutdown: boolean;
};

function object(value: unknown, label: string): JsonObject {
  if (!value || typeof value !== 'object' || Array.isArray(value)) throw new Error(`${label} must be an object`);
  return value as JsonObject;
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

async function probe(requested: string, timeoutMs: number): Promise<ProtocolProbe> {
  const cli = resolve(dirname(fileURLToPath(import.meta.url)), 'cli.js');
  const child = spawn(process.execPath, [cli, 'serve'], { stdio: ['pipe', 'pipe', 'pipe'] });
  const lines = createInterface({ input: child.stdout });
  const pending = new Map<number, { resolve: (value: JsonObject) => void; reject: (error: Error) => void }>();
  let stderr = '';
  let exited = false;
  child.stderr.setEncoding('utf8');
  child.stderr.on('data', chunk => { stderr += String(chunk); });
  child.once('exit', code => {
    exited = true;
    if (pending.size > 0) {
      const error = new Error(`MCP server exited ${code} before completing a response: ${stderr.trim()}`);
      for (const item of pending.values()) item.reject(error);
      pending.clear();
    }
  });
  child.once('error', error => { for (const item of pending.values()) item.reject(error); pending.clear(); });
  lines.on('line', line => {
    let message: JsonObject;
    try { message = object(JSON.parse(line), 'MCP response'); }
    catch (error) { for (const item of pending.values()) item.reject(error as Error); pending.clear(); return; }
    if (typeof message.id !== 'number') return;
    const item = pending.get(message.id);
    if (!item) return;
    pending.delete(message.id);
    if (message.error) item.reject(new Error(`MCP request failed: ${JSON.stringify(message.error)}`));
    else item.resolve(object(message.result, 'MCP result'));
  });
  const request = (id: number, method: string, params?: JsonObject): Promise<JsonObject> => {
    const result = new Promise<JsonObject>((resolveRequest, reject) => pending.set(id, { resolve: resolveRequest, reject }));
    child.stdin.write(`${JSON.stringify({ jsonrpc: '2.0', id, method, ...(params ? { params } : {}) })}\n`);
    return bounded(result, timeoutMs, method);
  };
  try {
    const initialized = await request(1, 'initialize', {
      protocolVersion: requested,
      capabilities: {},
      clientInfo: { name: 'harness-protocol-check', version: VERSION.package }
    });
    if (typeof initialized.protocolVersion !== 'string') throw new Error('initialize result omitted protocolVersion');
    child.stdin.write(`${JSON.stringify({ jsonrpc: '2.0', method: 'notifications/initialized' })}\n`);
    const listed = await request(2, 'tools/list');
    if (!Array.isArray(listed.tools)) throw new Error('tools/list result omitted tools');
    const tools = listed.tools.map((value, index) => {
      const tool = object(value, `tools[${index}]`);
      if (typeof tool.name !== 'string') throw new Error(`tools[${index}] omitted name`);
      return tool.name;
    });
    child.stdin.end();
    await bounded(new Promise<void>((resolveExit, reject) => {
      if (exited) resolveExit();
      else {
        child.once('exit', code => code === 0 ? resolveExit() : reject(new Error(`MCP server exited ${code}: ${stderr.trim()}`)));
        child.once('error', reject);
      }
    }), timeoutMs, 'MCP shutdown');
    lines.close();
    return { requested, negotiated: initialized.protocolVersion, tools, shutdown: true };
  } finally {
    lines.close();
    for (const item of pending.values()) item.reject(new Error('MCP protocol probe closed'));
    pending.clear();
    if (!exited) {
      const forcedExit = new Promise<void>(resolveExit => child.once('exit', () => resolveExit()));
      child.kill('SIGKILL');
      await bounded(forcedExit, timeoutMs, 'forced MCP shutdown');
    }
  }
}

export async function verifyProtocolMatrix(timeoutMs = 5000): Promise<ProtocolMatrixReport> {
  const supported: ProtocolProbe[] = [];
  for (const version of SUPPORTED_PROTOCOL_VERSIONS) supported.push(await probe(version, timeoutMs));
  const unsupportedProbe = await probe('1900-01-01', timeoutMs);
  const unsupported = { ...unsupportedProbe, counteroffer: unsupportedProbe.negotiated === LATEST_PROTOCOL_VERSION };
  const shutdown = supported.every(item => item.shutdown) && unsupported.shutdown;
  const ok = supported.every(item => item.negotiated === item.requested && item.tools.includes('harness_validate'))
    && unsupported.counteroffer && unsupported.tools.includes('harness_validate') && shutdown;
  return { ok, supported, unsupported, shutdown };
}
