#!/usr/bin/env python3
"""
Harness Claude MCP Server - v3.0.1 (mcp 1.28.1 compatible)
Fixed RequestContext import issue
"""

import json
import sys
import logging
from typing import Any

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

try:
    from mcp.server import Server
    from mcp.types import Tool, TextContent, CallToolResult
except ImportError as e:
    logger.error(f"Failed to import mcp: {e}")
    logger.error("Install mcp: pip install mcp")
    sys.exit(1)

# Create server instance
server = Server("harness")

# Define tools
TOOLS = [
    {
        "name": "help",
        "description": "Show available Harness commands",
        "inputSchema": {
            "type": "object",
            "properties": {}
        }
    },
    {
        "name": "status",
        "description": "Get Harness installation status",
        "inputSchema": {
            "type": "object",
            "properties": {}
        }
    },
    {
        "name": "config",
        "description": "Show Harness configuration",
        "inputSchema": {
            "type": "object",
            "properties": {}
        }
    }
]

@server.list_tools()
async def list_tools() -> list[Tool]:
    """List available tools"""
    return [
        Tool(
            name=tool["name"],
            description=tool["description"],
            inputSchema=tool["inputSchema"]
        )
        for tool in TOOLS
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    """Handle tool calls"""
    
    if name == "help":
        return [TextContent(
            type="text",
            text="""Harness v3.0.0 - Available Commands

help     - Show this help message
status   - Installation status and diagnostic info
config   - Display current configuration

MCP Server: harness_claude_advanced_mcp.py v3.0.1
"""
        )]
    
    elif name == "status":
        import os
        harness_dir = os.path.expanduser("~/Library/Application Support/AI-Tools/harness")
        mcp_dir = os.path.expanduser("~/Library/Application Support/AI-Tools/mcp")
        
        return [TextContent(
            type="text",
            text=f"""Harness Status:
✓ MCP Server: Running (v3.0.1)
✓ Python: {sys.version.split()[0]}

Directories:
  Harness: {harness_dir} (exists: {os.path.isdir(harness_dir)})
  MCP:     {mcp_dir} (exists: {os.path.isdir(mcp_dir)})

Claude Desktop Config:
  Location: ~/Library/Application Support/Claude/claude_desktop_config.json
  Status: Check via Claude Desktop Settings > Integrations

To validate full installation:
  bash ~/Desktop/verify_harness_installation.sh
"""
        )]
    
    elif name == "config":
        import os
        config_path = os.path.expanduser("~/Library/Application Support/Claude/claude_desktop_config.json")
        
        try:
            with open(config_path) as f:
                config = json.load(f)
            harness_config = config.get("mcpServers", {}).get("harness", {})
            return [TextContent(
                type="text",
                text=f"""Claude Desktop Configuration:

{json.dumps(harness_config, indent=2)}

Config file: {config_path}
"""
            )]
        except Exception as e:
            return [TextContent(
                type="text",
                text=f"Error reading config: {e}\n\nFile: {config_path}"
            )]
    
    else:
        return [TextContent(
            type="text",
            text=f"Unknown command: {name}\n\nType 'help' for available commands"
        )]

async def main():
    """Main entry point"""
    logger.info("Starting Harness MCP Server v3.0.1")
    logger.info("Available tools: " + ", ".join(tool["name"] for tool in TOOLS))
    
    async with server:
        logger.info("Server running. Waiting for requests...")
        await server.wait()

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
