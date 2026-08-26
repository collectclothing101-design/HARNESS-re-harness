import { copyFile, mkdir, readFile, rename, stat, unlink, writeFile } from 'node:fs/promises';
import { dirname } from 'node:path';
import { applyEdits, modify, parse as parseJsonc } from 'jsonc-parser';
import { parse as parseToml, stringify as stringifyToml } from 'smol-toml';
import { parse as parseYaml, stringify as stringifyYaml } from 'yaml';

export type ConfigFormat = 'json' | 'jsonc' | 'toml' | 'yaml';

function object(value: unknown): Record<string, unknown> {
  if (!value || typeof value !== 'object' || Array.isArray(value)) throw new Error('configuration root must be an object');
  return value as Record<string, unknown>;
}
function deepMerge(left: Record<string, unknown>, right: Record<string, unknown>): Record<string, unknown> {
  const result = { ...left };
  for (const [key, value] of Object.entries(right)) {
    result[key] = value && typeof value === 'object' && !Array.isArray(value) && result[key] && typeof result[key] === 'object' && !Array.isArray(result[key])
      ? deepMerge(object(result[key]), object(value)) : value;
  }
  return result;
}
function parse(text: string, format: ConfigFormat): Record<string, unknown> {
  if (format === 'json') return object(JSON.parse(text));
  if (format === 'jsonc') return object(parseJsonc(text));
  if (format === 'toml') return object(parseToml(text));
  return object(parseYaml(text));
}
function serialize(base: string, format: ConfigFormat, merged: Record<string, unknown>, patch: Record<string, unknown>): string {
  if (format === 'json') return `${JSON.stringify(merged, null, 2)}\n`;
  if (format === 'toml') return stringifyToml(merged);
  if (format === 'yaml') return stringifyYaml(merged);
  let output = base;
  for (const [key, value] of Object.entries(patch)) output = applyEdits(output, modify(output, [key], value, { formattingOptions: { insertSpaces: true, tabSize: 2 } }));
  return output.endsWith('\n') ? output : `${output}\n`;
}

export class TransactionalConfig {
  async merge(path: string, format: ConfigFormat, patch: Record<string, unknown>): Promise<{ changed: boolean; backup: string }> {
    const original = await readFile(path, 'utf8');
    const merged = deepMerge(parse(original, format), patch);
    const output = serialize(original, format, merged, patch);
    parse(output, format);
    const backup = `${path}.hrh-backup`;
    try { await stat(backup); } catch { await copyFile(path, backup); }
    if (output === original) return { changed: false, backup };
    const temporary = `${path}.hrh-${process.pid}.tmp`;
    try {
      await mkdir(dirname(path), { recursive: true });
      await writeFile(temporary, output, { mode: 0o600 });
      await rename(temporary, path);
    } catch (error) {
      await unlink(temporary).catch(() => undefined);
      throw error;
    }
    return { changed: true, backup };
  }
  async rollback(path: string): Promise<void> {
    const backup = `${path}.hrh-backup`;
    await copyFile(backup, path);
  }
}
