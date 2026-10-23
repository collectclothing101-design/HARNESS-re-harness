import packageJson from '../package.json' with { type: 'json' };

export const VERSION = Object.freeze({
  package: packageJson.version,
  schema: '1.0.0',
  ir: '1.0.0',
  adapter: '1.0.0',
  migration: 1
});

