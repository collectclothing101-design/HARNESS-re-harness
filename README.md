# HARNESS-re-harness

A pinned, runtime-neutral compatibility distribution for `revfactory/harness`. It represents agents, skills, workflows, review gates, model tiers, tools, and artifacts in one canonical manifest, then generates explicit runtime assets for Claude, Codex, ChatGPT, MiMo, OpenCode, Hermes, F.R.A.N.K., and generic MCP clients.

This package does not track an upstream branch at runtime. The 1.0.x line is pinned to reviewed upstream commit `cceac68ea1d0ad198ef4b7b906cd238375836387`; user manifests reject branch names such as `main`. Proposed v2 behavior is isolated in `compat/upstream-v2.experimental.json` and is not a production pin.

## What is solved

| Former blocker | Implemented control |
|---|---|
| No immutable upstream release | Mandatory 40-character commit SHA and downstream package version |
| Missing local package | Complete npm package, lockfile, schema, CLI, MCP server, adapters, tests, and CI |
| Cross-runtime mismatch | Canonical IR, capability matrix, and emitted downgrade records |
| SDK import drift | TypeScript MCP SDK pinned exactly to `1.30.0`; no Python `RequestContext` or `ToolResult` imports |
| Unsafe config replacement | Atomic same-directory writes, parse-before-commit, one-time backup, rollback, JSONC comment preservation, and idempotent merge API |
| Divergent versions | `src/version.ts` reads the npm package version and defines schema/IR/adapter/migration versions together |
| Vendor-specific models | Symbolic `reasoning`, `balanced`, and `fast` tiers in the canonical schema |
| Global config risk | Project scope is default; global installation requires both `--global --allow-global` |
| Weak MCP validation | Real client/server tests for negotiation, discovery, calls, errors, concurrency, cancellation, and shutdown |
| Marker-only installer | Runtime-aware transactional `install`, `verify`, `rollback`, and `uninstall` commands with receipts |
| Config-only adapters | Runtime-local agent, skill, workflow, canonical-manifest, model-map, and configuration assets |
| Missing orchestration | Topological execution, persisted state, bounded retry, review gates, and artifact records |

## Install and verify

```sh
npm ci
npm run acceptance
node dist/cli.js doctor --json
```

Node.js 20.11 or later is required. `npm ci` uses the committed lockfile and exact dependency versions.

## Canonical workflow

Copy and edit the example:

```sh
cp templates/harness.manifest.example.json harness.manifest.json
node dist/cli.js validate harness.manifest.json
```

Generate runtime-local assets:

```sh
for runtime in claude codex chatgpt mimo opencode hermes frank generic; do
  node dist/cli.js compile harness.manifest.json --runtime "$runtime" --out generated
done
```

The compiler writes project-scoped paths under `generated/`. It never edits home-directory configuration. Any unsupported requirement appears in `<runtime>.downgrades.json`; it is never silently dropped.

Install into a project-scoped runtime config, verify it, and retain a rollback path:

```sh
node dist/cli.js install harness.manifest.json --runtime codex --project . --config .codex/config.toml
node dist/cli.js verify --project .
node dist/cli.js rollback --project .
node dist/cli.js uninstall --project .
```

The receipt is `.harness-re-harness/install.json`. Global mutation remains disabled unless both `--global` and `--allow-global` are supplied.

## MCP server

Run over stdio:

```sh
node dist/cli.js serve
```

Tools:

- `harness_validate`: validate the canonical manifest and cross-references.
- `harness_compile`: generate a runtime-specific result plus downgrade records.
- `harness_wait`: bounded cancellation/concurrency acceptance probe.

Resource: `harness://capabilities`. Prompt: `harness_plan`.

Stdio is reserved exclusively for JSON-RPC traffic. CLI diagnostics use stderr on failure; the server writes no banners to stdout.

## Runtime capability and downgrade policy

| Runtime | Native focus | Important fallback |
|---|---|---|
| Claude | Agents, teams, skills, workflows | None for the canonical feature set |
| Codex | Agents, skills, MCP, review gates | Team stages serialize through workflow handoffs |
| ChatGPT | Skills, tools, MCP, artifacts | Agent roles become parameterized MCP calls |
| MiMo | Agents, skills, MCP, workflows | Team stages serialize through workflow handoffs |
| OpenCode | Agents, skills, MCP, workflows | Review gates are enforced by the server |
| Hermes | Agents, skills, MCP, workflows | Review gates are enforced by the server |
| F.R.A.N.K. | Complete canonical feature set | None for the canonical feature set |
| Generic MCP | MCP tools and artifacts | Agents/skills/workflows are orchestrated server-side |

The canonical IR supports `workflow-orchestration`, `persistent-collaboration`, and `subagent-delegation`. It does not require Claude's former experimental Agent Teams flag. Other runtimes receive native assets or an explicit deterministic fallback.

## Transactional configuration API

`TransactionalConfig.merge(path, format, patch)` supports JSON, JSONC, TOML, and YAML. It:

1. Parses the existing file.
2. Deep-merges the requested keys without reading or emitting environment secrets.
3. Serializes and reparses the candidate.
4. Creates `<file>.hrh-backup` once.
5. Writes a mode-0600 sibling temporary file and atomically renames it.

`rollback(path)` restores the backup. Reapplying an identical patch returns `changed: false` and does not rewrite the target.

## Version and upstream policy

- Package: `1.0.0`
- Canonical schema: `1.0.0`
- IR: `1.0.0`
- Adapter contract: `1.0.0`
- Migration: `1`
- MCP SDK: exactly `1.30.0`

The production distribution is pinned to `cceac68ea1d0ad198ef4b7b906cd238375836387`. Change it only after reviewing a concrete replacement commit, then record imported paths and licenses in the same change. Never substitute a branch, pull request head, or mutable tag. `node dist/cli.js version-check` verifies package, schema, IR, adapter, migration, and MCP SDK metadata agree.

## Acceptance evidence

`npm run acceptance` performs:

- strict TypeScript compilation;
- canonical schema and cross-reference validation;
- generation for all eight runtimes;
- JSON/JSONC/TOML/YAML transactional merge tests;
- backup, rollback, idempotency, and failed-write preservation tests;
- MCP initialization and capability discovery;
- successful and structured-error tool calls;
- concurrent calls and abort propagation;
- spawned-process stdio framing and discovery;
- clean client/server shutdown;
- persisted workflow state, retry, review-gate, and artifact behavior;
- npm tarball content verification.

CI repeats this on Node 20, 22, and 24.

## Upstream import procedure

1. Select and review a concrete `revfactory/harness` commit.
2. Replace the existing immutable SHA in `manifest.json` and any canonical user manifest.
3. Import only required templates/assets through a dedicated adapter; do not make upstream Python modules part of the MCP protocol boundary.
4. Run `npm ci && npm run acceptance`.
5. Inspect generated downgrade reports and package contents.
6. Commit the SHA, imported paths, compatibility notes, and lockfile together.

The documented Claude marketplace command remains `/plugin install harness@harness-marketplace`, but it is optional and separate from this distribution. No installer guesses or rewrites marketplace identifiers.
