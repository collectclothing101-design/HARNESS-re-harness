import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { capabilityMatrix, compileRuntime } from './compiler.js';
import { validateManifest, type Runtime } from './model.js';
import { VERSION } from './version.js';

export function createHarnessServer(): McpServer {
  const server = new McpServer({ name: 'harness-re-harness', version: VERSION.package });
  server.registerTool('harness_validate', { description: 'Validate a canonical Harness manifest', inputSchema: { manifest: z.unknown() } }, ({ manifest }) => {
    try { const value = validateManifest(manifest); return { content: [{ type: 'text', text: JSON.stringify({ valid: true, name: value.name }) }] }; }
    catch (error) { return { isError: true, content: [{ type: 'text', text: error instanceof Error ? error.message : String(error) }] }; }
  });
  server.registerTool('harness_compile', { description: 'Compile a manifest for a target runtime', inputSchema: { manifest: z.unknown(), runtime: z.enum(['claude','codex','chatgpt','mimo','opencode','hermes','frank','generic']) } }, ({ manifest, runtime }) => {
    try { return { content: [{ type: 'text', text: JSON.stringify(compileRuntime(validateManifest(manifest), runtime as Runtime)) }] }; }
    catch (error) { return { isError: true, content: [{ type: 'text', text: error instanceof Error ? error.message : String(error) }] }; }
  });
  server.registerTool('harness_wait', { description: 'Cancellation-aware concurrency probe', inputSchema: { milliseconds: z.number().int().min(0).max(5000) } }, async ({ milliseconds }, extra) => {
    await new Promise<void>((resolve, reject) => {
      const timer = setTimeout(resolve, milliseconds);
      const abort = () => { clearTimeout(timer); reject(new Error('request aborted')); };
      if (extra.signal.aborted) abort(); else extra.signal.addEventListener('abort', abort, { once: true });
    });
    return { content: [{ type: 'text', text: JSON.stringify({ waited: milliseconds }) }] };
  });
  server.registerResource('capabilities', 'harness://capabilities', { title: 'Runtime capability matrix', mimeType: 'application/json' }, async uri => ({ contents: [{ uri: uri.href, mimeType: 'application/json', text: JSON.stringify(capabilityMatrix()) }] }));
  server.registerPrompt('harness_plan', { description: 'Plan a portable Harness workflow', argsSchema: { goal: z.string() } }, ({ goal }) => ({ messages: [{ role: 'user', content: { type: 'text', text: `Design a runtime-neutral Harness workflow for: ${goal}` } }] }));
  return server;
}

export async function runStdioServer(): Promise<void> {
  await createHarnessServer().connect(new StdioServerTransport());
}
