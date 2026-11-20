import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { validateVersionAuthority } from '../dist/index.js';

test('distribution pins the reviewed upstream v1 commit', async () => {
  const manifest = JSON.parse(await readFile('manifest.json', 'utf8'));
  assert.equal(manifest.upstream.commit, 'cceac68ea1d0ad198ef4b7b906cd238375836387');
});

test('all release metadata agrees with the version authority', async () => {
  const report = await validateVersionAuthority(process.cwd());
  assert.equal(report.ok, true, JSON.stringify(report));
});

