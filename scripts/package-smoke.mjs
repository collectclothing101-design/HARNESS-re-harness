import { execFileSync } from 'node:child_process';
import { mkdtemp, readFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const output = execFileSync('npm', ['--cache', join(tmpdir(), 'hrh-npm-cache'), 'pack', '--ignore-scripts', '--json', '--pack-destination', await mkdtemp(join(tmpdir(), 'hrh-pack-'))], { encoding: 'utf8' });
const report = JSON.parse(output)[0];
const names = new Set(report.files.map(file => file.path));
for (const required of ['dist/cli.js','dist/server-entry.js','manifest.json','schemas/harness-manifest.schema.json','README.md']) {
  if (!names.has(required)) throw new Error(`package missing ${required}`);
}
if ((await readFile(new URL('../package-lock.json', import.meta.url), 'utf8')).includes('"version": "0.0.0"')) throw new Error('invalid lockfile version');
process.stdout.write(`${JSON.stringify({ packed: true, files: report.entryCount, bytes: report.size })}\n`);
