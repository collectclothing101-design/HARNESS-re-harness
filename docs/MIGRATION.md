# Migration from Python compatibility patches

The MCP boundary no longer imports `fastmcp`, `RequestContext`, `ServerRequestContext`, `ToolResult`, or `CallToolResult` from Python. Existing Python Harness generation may remain behind an adapter, but it must exchange canonical JSON with this package.

1. Export existing agents, skills, and workflows into the canonical manifest.
2. Replace vendor model names with `reasoning`, `balanced`, or `fast`.
3. Validate the manifest.
4. Compile each required runtime and review downgrade reports.
5. Start the MCP server and run the acceptance suite before changing active client configuration.
6. Apply active-config changes through the transactional API and retain backups until client startup is verified.
