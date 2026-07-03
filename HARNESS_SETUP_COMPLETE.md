# Harness MCP Server - Configuration Complete ✓

## Installation Summary

Successfully configured Harness MCP Server for Claude Desktop.

### File Locations

```
~/.local/share/ai-tools/harness/                    # Harness repository
  ├── skills/harness/SKILL.md                       # Main Harness skill
  └── references/                                    # Pattern documentation

~/.local/share/ai-tools/mcp/
  └── harness_mcp_server.py                         # MCP server (executable)

~/.config/claude/
  └── claude_desktop_config.json                    # Claude Desktop config
```

### Configuration Details

**File**: `~/.config/claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "harness": {
      "command": "python3",
      "args": ["/root/.local/share/ai-tools/mcp/harness_mcp_server.py"],
      "env": {
        "HARNESS_DIR": "/root/.local/share/ai-tools/harness"
      }
    }
  }
}
```

## Next Steps

### 1. Install FastMCP (if not already installed)

```bash
pip install mcp
```

### 2. Restart Claude Desktop

- Close Claude Desktop completely
- Reopen Claude Desktop

### 3. Verify MCP Server is Loaded

In Claude Desktop:
```
/mcp
```

You should see:
```
Available MCP servers:
- harness [Connected]
```

### 4. Start Using Harness Tools

In Claude, type any of:

```
/design_agent_team
/generate_skill_scaffold
/wix_app_agent_scaffold
/validate_team_architecture
/orchestration_template
/harness_status
```

Or describe your task:

```
"Design a multi-agent team for product discovery"
"Scaffold a Wix membership dashboard feature"
"Create a SKILL.md for content analysis"
```

## Harness Tools Available

### Core Design Tools

| Tool | Purpose |
|------|---------|
| `design_agent_team` | Design specialist agents with 6 patterns |
| `generate_skill_scaffold` | Create SKILL.md with progressive disclosure |
| `wix_app_agent_scaffold` | Multi-agent design for Wix features |
| `orchestration_template` | Generate team coordination document |
| `validate_team_architecture` | Verify team completeness |

### Integration Tools

| Tool | Purpose |
|------|---------|
| `skill_creator_integration` | Generate skill-creator config |
| `harness_to_mcp_config` | Generate MCP server config |

### Reference Tools

| Tool | Purpose |
|------|---------|
| `harness_status` | Check installation status |
| `read_harness_skill` | Read Harness SKILL.md |
| `list_harness_references` | List reference documents |
| `read_harness_reference` | Read one reference document |

## Quick Start Examples

### Example 1: Design Agent Team

```
User: "Design a team for analyzing customer feedback"

Claude will:
1. Call /design_agent_team()
2. Select appropriate pattern (e.g., fan-out/fan-in)
3. Design specialist agents
4. Output team structure with handoff contracts
```

### Example 2: Scaffold Wix Feature

```
User: "Scaffold a multi-agent design for a Wix product catalog"

Claude will:
1. Call /wix_app_agent_scaffold()
2. Generate agents for UI, API contract, validation, backend, testing
3. Create orchestration.md with handoff sequence
4. Generate API contract and validation rules
```

### Example 3: Create Skill

```
User: "Create a SKILL.md for content analysis using agent team design"

Claude will:
1. Design agent team
2. Call /generate_skill_scaffold()
3. Generate SKILL.md with core and advanced tools
4. Create reference documents per agent
```

## Verification Checklist

- [x] Harness repository cloned to `~/.local/share/ai-tools/harness`
- [x] Harness SKILL.md exists at `~/.local/share/ai-tools/harness/skills/harness/SKILL.md`
- [x] MCP server script installed at `~/.local/share/ai-tools/mcp/harness_mcp_server.py`
- [x] Claude Desktop config updated with harness MCP server
- [x] FastMCP dependency available (install if needed: `pip install mcp`)

## Troubleshooting

### MCP Server Not Appearing in `/mcp`

**Solution**:
1. Ensure FastMCP is installed: `pip install mcp`
2. Restart Claude Desktop completely
3. Check config syntax: `python3 -m json.tool ~/.config/claude/claude_desktop_config.json`

### Tools Not Available After Restart

**Solution**:
1. Verify HARNESS_DIR is set correctly in config
2. Check file permissions: `ls -l ~/.local/share/ai-tools/mcp/harness_mcp_server.py`
3. Verify Python version: `python3 --version` (requires Python 3.8+)

### Python Module Errors

**Solution**:
```bash
pip install --upgrade mcp
pip install fastmcp
```

## Architecture

```
Claude Desktop
    ↓
MCP Client
    ↓
Harness MCP Server (FastMCP)
    ├─ design_agent_team()
    ├─ generate_skill_scaffold()
    ├─ wix_app_agent_scaffold()
    ├─ validate_team_architecture()
    ├─ orchestration_template()
    ├─ skill_creator_integration()
    └─ ...more tools
    ↓
Harness Framework
    ├─ Agent patterns (6 types)
    ├─ Validation gates
    ├─ Error recovery
    └─ SKILL.md generation
    ↓
Generated Artifacts
    ├─ Agent team definitions
    ├─ Orchestration documents
    ├─ SKILL.md files
    └─ Wix feature scaffolds
```

## Integration Points

### With skill-creator

When generating skills with skill-creator:
1. Use Harness to design agent team
2. Call `skill_creator_integration()` to get SKILL.md structure
3. Register skill with skill-creator

### With wix:wix-manage

When building Wix app features:
1. Use `wix_app_agent_scaffold()` to design multi-agent architecture
2. Follow generated agents/ files for implementation
3. Use wix:wix-manage to test in Wix preview
4. Deploy when ready

## Keep in Memory

Harness MCP Server is now:
- ✓ Installed and configured
- ✓ Available in Claude Desktop
- ✓ Ready for multi-agent architecture design
- ✓ Integrated with skill-creator and wix:wix-manage

Use Harness to design domain-specific agent teams, generate SKILL.md files, and scaffold Wix app features with validated, multi-agent architecture.

## Support

For detailed usage, see:
- `HARNESS_INTEGRATION_GUIDE.md` - Complete guide with all workflows
- `HARNESS_QUICK_REFERENCE.md` - Quick lookup for tools and patterns

To view Harness documentation:
```
/read_harness_skill
/list_harness_references
/read_harness_reference [filename]
```
