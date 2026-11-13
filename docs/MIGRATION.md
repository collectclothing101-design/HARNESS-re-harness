# Migration from Python compatibility patches

## Upgrade from 1.4.0 to 1.5.0

The canonical schema, IR, adapter contract, migration number, receipt schema, journal schema, and runtime dependency pins remain unchanged. Update the manifest's `packageVersion` to `1.5.0`, validate it, and run the acceptance suite.

Version 1.5.0 adds `node dist/cli.js protocol-check --timeout-ms 5000`. Run it after building and before native-host promotion. It exercises the pinned v1 SDK's five supported legacy protocol revisions and the unsupported-version counteroffer path. It does not establish MCP SDK v2 modern-era compatibility.

## Upgrade from 1.3.0 to 1.4.0

The canonical schema, IR, adapter contract, migration number, receipt schema, and journal schema remain unchanged. Update the manifest's `packageVersion` to `1.4.0`, validate it, and run the acceptance suite.

Version 1.4.0 extends opt-in operational verification with cancellation over the installed stdio descriptor. The report now includes `cancellation`, `cancelledTaskTerminated`, and `postCancellationResponsive`; all must be true. The new `harness_status` tool proves the in-process cancellation-aware task count returns to zero before the liveness probe. It does not claim termination of an external worker process because HARNESS-re-harness does not currently spawn task workers.

Runtime dependencies are refreshed to `@modelcontextprotocol/sdk` 1.32.2, `smol-toml` 1.9.1, `yaml` 2.9.1, and `zod` 4.6.7. Recreate installations with `npm ci --ignore-scripts`; do not reuse a 1.3.0 `node_modules` tree.

## Upgrade from 1.2.0 to 1.3.0

The canonical schema, IR, adapter contract, migration number, receipt schema, and journal schema remain unchanged. Update the manifest's `packageVersion` to `1.3.0`, validate it, and run the acceptance suite.

Version 1.3.0 adds an opt-in operational verification mode. Run structural verification first, then execute `node dist/cli.js verify --project <root> --operational --timeout-ms 5000` on the destination host. The command fails closed if the configured executable or arguments differ from the current package; regenerate descriptors after moving the package or changing Node installations.

## Upgrade from 1.1.0 to 1.2.0

The canonical schema, IR, adapter contract, migration number, and receipt schema remain unchanged. Update the manifest's `packageVersion` to `1.2.0`, then validate it and run the acceptance suite.

Version 1.2.0 adds install journal schema 1 at `.harness-re-harness/transaction.json`. If that file remains after an interrupted install, run `node dist/cli.js recover --project <root>` before retrying. Recovery is idempotent. When it detects post-crash edits, it exits nonzero and intentionally retains the journal and `.hrh-backup`; review those files rather than deleting them automatically.

## Upgrade from 1.0.0 to 1.1.0

The canonical schema, IR, adapter contract, and migration number remain at `1.0.0`, `1.0.0`, `1.0.0`, and `1`. Update the manifest's `packageVersion` to `1.1.0`, then validate it and run the acceptance suite.

Version 1.1.0 uses receipt schema 2. It intentionally refuses to overwrite a 1.0.0 receipt or pre-existing generated assets. Uninstall the old project-scoped installation after reviewing its backup, then install 1.1.0. Retain `.hrh-backup` until the exact installed descriptor has started successfully in the target host.

The MCP boundary no longer imports `fastmcp`, `RequestContext`, `ServerRequestContext`, `ToolResult`, or `CallToolResult` from Python. Existing Python Harness generation may remain behind an adapter, but it must exchange canonical JSON with this package.

1. Export existing agents, skills, and workflows into the canonical manifest.
2. Replace vendor model names with `reasoning`, `balanced`, or `fast`.
3. Validate the manifest.
4. Compile each required runtime and review downgrade reports.
5. Start the MCP server and run the acceptance suite before changing active client configuration.
6. Apply active-config changes through the transactional API and retain backups until client startup is verified.

