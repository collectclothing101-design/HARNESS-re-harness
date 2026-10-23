# Security model

- Generated runtime configuration is project-scoped by default.
- Global mutation is rejected without explicit dual opt-in.
- Configuration writers preserve unrelated keys, never log values, validate candidates before atomic replacement, and retain a rollback backup.
- Manifests cannot execute commands; adapters emit data and fixed MCP launch entries.
- Upstream input must be pinned to a full commit SHA.
- Dependency versions and integrity hashes are locked by `package-lock.json`.

Report dependency or configuration-boundary vulnerabilities privately to the package maintainer. Do not include credentials or unsanitized configuration files in reports.

