import test from 'node:test';
import assert from 'node:assert/strict';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import { createHarnessServer } from '../dist/index.js';

test('MCP negotiates, discovers tools/resources/prompts, invokes, errors, and shuts down', async () => {
  const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
  const server = createHarnessServer();
  const client = new Client({ name: 'acceptance', version: '1.0.0' });
  await Promise.all([server.connect(serverTransport), client.connect(clientTransport)]);
  assert.ok((await client.listTools()).tools.some(t => t.name === 'harness_validate'));
  assert.ok((await client.listResources()).resources.some(r => r.uri === 'harness://capabilities'));
  assert.ok((await client.listPrompts()).prompts.some(p => p.name === 'harness_plan'));
  const result = await client.callTool({ name: 'harness_validate', arguments: { manifest: { name: 'bad' } } });
  assert.equal(result.isError, true);
  await client.close();
  await server.close();
});

test('MCP handles concurrent calls and propagates cancellation', async () => {
  const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
  const server = createHarnessServer();
  const client = new Client({ name: 'concurrency', version: '1.0.0' });
  await Promise.all([server.connect(serverTransport), client.connect(clientTransport)]);
  const calls = await Promise.all([10, 5, 1].map(ms => client.callTool({ name: 'harness_wait', arguments: { milliseconds: ms } })));
  assert.equal(calls.length, 3);
  assert.ok(calls.every(result => result.isError !== true));
  const controller = new AbortController();
  const pending = client.callTool({ name: 'harness_wait', arguments: { milliseconds: 1000 } }, undefined, { signal: controller.signal });
  controller.abort();
  await assert.rejects(pending, /abort/i);
  await client.close();
  await server.close();
});

test('MCP works over a spawned stdio process with clean protocol framing', async () => {
  const transport = new StdioClientTransport({ command: process.execPath, args: ['dist/cli.js', 'serve'], cwd: process.cwd(), stderr: 'pipe' });
  const client = new Client({ name: 'stdio-acceptance', version: '1.0.0' });
  await client.connect(transport);
  assert.ok((await client.listTools()).tools.some(tool => tool.name === 'harness_compile'));
  const result = await client.callTool({ name: 'harness_wait', arguments: { milliseconds: 1 } });
  assert.notEqual(result.isError, true);
  await client.close();
});
