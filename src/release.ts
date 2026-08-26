import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { VERSION } from './version.js';

export type VersionAuthorityReport = { ok: boolean; expected: typeof VERSION; mismatches: string[] };

export async function validateVersionAuthority(root: string): Promise<VersionAuthorityReport> {
  const [pkg, distribution, schema] = await Promise.all([
    readFile(join(root, 'package.json'), 'utf8').then(JSON.parse),
    readFile(join(root, 'manifest.json'), 'utf8').then(JSON.parse),
    readFile(join(root, 'schemas/harness-manifest.schema.json'), 'utf8').then(JSON.parse)
  ]);
  const mismatches: string[] = [];
  if (pkg.version !== VERSION.package) mismatches.push('package.json version');
  if (distribution.packageVersion !== VERSION.package) mismatches.push('manifest packageVersion');
  if (distribution.schemaVersion !== VERSION.schema) mismatches.push('manifest schemaVersion');
  if (distribution.irVersion !== VERSION.ir) mismatches.push('manifest irVersion');
  if (distribution.adapterVersion !== VERSION.adapter) mismatches.push('manifest adapterVersion');
  if (distribution.migrationVersion !== VERSION.migration) mismatches.push('manifest migrationVersion');
  if (schema.properties?.packageVersion?.const !== VERSION.package) mismatches.push('schema packageVersion');
  if (schema.properties?.schemaVersion?.const !== VERSION.schema) mismatches.push('schema schemaVersion');
  if (pkg.dependencies?.['@modelcontextprotocol/sdk'] !== distribution.mcpSdk) mismatches.push('MCP SDK pin');
  return { ok: mismatches.length === 0, expected: VERSION, mismatches };
}
