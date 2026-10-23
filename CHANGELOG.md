# Changelog

## 1.2.0 — 2026-10-23

- Write a complete install transaction journal before configuration mutation.
- Add an idempotent `recover` command for interrupted project-scoped installs.
- Exercise hard kills in separate child processes after backup, configuration replacement, asset creation, and receipt creation.
- Restore byte-identical original configuration and remove only hash-owned generated assets during recovery.
- Preserve post-crash user edits and retain the journal and backup for manual resolution.
- Reject post-crash symlink swaps before recovery mutates any path.

## 1.1.0 — 2026-10-16

- Emit absolute, working MCP launch descriptors for all eight runtime adapters.
- Exercise the exact installed descriptors from an unrelated working directory.
- Reject generated-asset collisions, existing receipts, stale backups, unsafe replacement, and symlink escapes before configuration mutation.
- Record SHA-256 ownership for generated assets in receipt schema 2.
- Preserve externally modified generated assets during uninstall and report them.
- Remove completed configuration backups during uninstall.
- Record the merged upstream Harness v2.1.0 source commit as experimental compatibility metadata without changing the production pin.

## 1.0.0 — 2026-08-26

- Initial clean-room runtime-neutral distribution.
