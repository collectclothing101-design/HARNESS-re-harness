# Architecture

The canonical manifest is the only semantic input. Zod validation checks shape, version compatibility, immutable upstream identity, and agent/skill/workflow references. The compiler compares requirements to a static capability matrix and emits runtime configuration plus native agent, skill, workflow, and canonical-manifest assets with deterministic downgrade records. The MCP server exposes the same validation/compiler functions, avoiding separate behavior between CLI and protocol paths.

Configuration mutation is deliberately separate from compilation. The CLI installer compiles new project-local files and modifies existing configuration only through `TransactionalConfig`, which provides validate-before-commit, atomic replacement, backup, rollback, and idempotency. An installation receipt enumerates generated files so uninstall is scoped and deterministic.

`WorkflowRunner` executes the canonical graph in topological order. Each transition is atomically persisted, retries are bounded, review gates require an explicit approval callback, and artifacts are recorded with their producing node. A failed or rejected run remains inspectable as a state document.

## Trust boundaries

- Manifest: untrusted data; validated before use.
- Adapter: trusted deterministic transform; does not execute manifest content.
- Config file: sensitive user data; never copied into logs or generated reports.
- MCP stdio: protocol-only stdout; errors are returned as MCP results.
- Upstream repository: untrusted/mutable until a reviewed commit SHA is recorded.
