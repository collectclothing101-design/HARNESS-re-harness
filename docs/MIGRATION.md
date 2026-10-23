# Migration from Python compatibility patches

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

