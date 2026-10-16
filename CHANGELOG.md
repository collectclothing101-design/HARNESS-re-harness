# Changelog

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
