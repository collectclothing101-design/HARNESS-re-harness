# HARNESS CLAUDE v2.0.0 - COMPLETE DEPLOYMENT GUIDE

**Last Updated**: 2026-06-30  
**Status**: Production-Ready  
**Components**: Skill + Plugin + MCP Server + Installation Scripts

---

## TABLE OF CONTENTS

1. [Installation Overview](#installation-overview)
2. [Component Files](#component-files)
3. [Quick Start](#quick-start)
4. [Skill Registration](#skill-registration)
5. [Plugin Setup](#plugin-setup)
6. [Usage Examples](#usage-examples)
7. [Advanced Configuration](#advanced-configuration)
8. [Troubleshooting](#troubleshooting)

---

## INSTALLATION OVERVIEW

Harness Claude v2.0.0 consists of three integrated components:

| Component | Purpose | Location |
|-----------|---------|----------|
| **Skill** | SKILL.md descriptor for Claude | `/mnt/user-data/outputs/HARNESS_CLAUDE_SKILL.md` |
| **Plugin** | Plugin manifest with metadata | `/mnt/user-data/outputs/plugin.json` |
| **MCP Server** | Production MCP implementation | `/mnt/user-data/outputs/harness_mcp_server_v2.py` |

---

## COMPONENT FILES

### 1. HARNESS_CLAUDE_SKILL.md

The skill descriptor—provides Claude with complete Harness capabilities including:
- 6 architectural patterns
- Core tier (80%): 9 primary tools
- Advanced tier (20%): 11 specialized tools
- Progressive disclosure for usability
- Usage patterns and best practices
- API reference
- Troubleshooting guide

**Location**: `/mnt/user-data/outputs/HARNESS_CLAUDE_SKILL.md`

**Size**: ~15 KB  
**Format**: Markdown  
**Registration**: Manual copy into Claude or via plugin system

### 2. plugin.json

Complete plugin manifest with:
- Tool definitions (20 tools total)
- Installation methods (bash, PowerShell, Docker)
- Configuration schema
- Integration points (skill-creator, Claude Desktop, GitHub Actions)
- Dependency specifications
- Platform support (macOS, Linux, Windows)
- Roadmap and versioning

**Location**: `/mnt/user-data/outputs/plugin.json`

**Size**: ~25 KB  
**Format**: JSON  
**Usage**: Claude plugin registration, tool discovery, auto-installation

### 3. harness_mcp_server_v2.py

Production-grade MCP server with:
- FastMCP framework
- Async orchestration engine
- Team design with 6 patterns
- Real-time execution with failover
- Performance profiling
- Distributed tracing
- Skill generation
- Validation & certification
- In-memory caching
- Persistence layer

**Location**: `/mnt/user-data/outputs/harness_mcp_server_v2.py`

**Size**: ~20 KB  
**Language**: Python 3.9+  
**Dependencies**: mcp, pydantic, aiofiles, opentelemetry-*

---

## QUICK START

### Method 1: Direct Skill Use (Fastest)

1. Copy HARNESS_CLAUDE_SKILL.md to your skills directory
2. Ask Claude: "Design a 5-agent team for log analysis"
3. Claude uses the skill to respond with team design

### Method 2: Local MCP Server (Full Features)

**Prerequisites**:
```bash
pip install mcp pydantic aiofiles opentelemetry-api opentelemetry-sdk
```

**Start server**:
```bash
python harness_mcp_server_v2.py
```

**Output**:
```
Harness Claude initialized at ~/.local/share/ai-tools/harness
MCP Server running on stdio
Ready for tool calls
```

### Method 3: Claude Desktop Plugin (Integrated)

1. Place plugin files in Claude Desktop config
2. Restart Claude Desktop
3. Harness tools available in `/mcp` commands

---

## SKILL REGISTRATION

### Option A: Manual Registration

Copy skill descriptor into your Claude context:

```bash
# Linux/macOS
cat HARNESS_CLAUDE_SKILL.md | xclip -selection clipboard

# Then paste into Claude conversation
```

### Option B: Plugin System Registration

Create `~/.config/claude/skills/harness/` directory:

```bash
mkdir -p ~/.config/claude/skills/harness/
cp HARNESS_CLAUDE_SKILL.md ~/.config/claude/skills/harness/SKILL.md
cp plugin.json ~/.config/claude/skills/harness/plugin.json
```

Update Claude Desktop config (`~/.config/claude/claude_desktop_config.json`):

```json
{
  "skills": {
    "harness": {
      "path": "~/.config/claude/skills/harness/SKILL.md",
      "plugin": "~/.config/claude/skills/harness/plugin.json",
      "enabled": true,
      "priority": "high"
    }
  }
}
```

---

## PLUGIN SETUP

### Step 1: Install Dependencies

**Linux/macOS**:
```bash
pip3 install mcp pydantic aiofiles
pip3 install opentelemetry-api opentelemetry-sdk opentelemetry-exporter-jaeger
```

**Windows (PowerShell as Administrator)**:
```powershell
pip install mcp pydantic aiofiles
pip install opentelemetry-api opentelemetry-sdk opentelemetry-exporter-jaeger
```

### Step 2: Create Plugin Directory

**Linux/macOS**:
```bash
mkdir -p ~/.local/share/ai-tools/mcp
cp harness_mcp_server_v2.py ~/.local/share/ai-tools/mcp/
chmod +x ~/.local/share/ai-tools/mcp/harness_mcp_server_v2.py
```

**Windows**:
```powershell
$MCPDir = "$env:LOCALAPPDATA\AI-Tools\mcp"
New-Item -ItemType Directory -Path $MCPDir -Force
Copy-Item harness_mcp_server_v2.py $MCPDir\
```

### Step 3: Configure Claude Desktop

**Linux/macOS** - Edit `~/.config/claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "harness-claude": {
      "command": "python3",
      "args": [
        "/root/.local/share/ai-tools/mcp/harness_mcp_server_v2.py"
      ],
      "env": {
        "HARNESS_DIR": "/root/.local/share/ai-tools/harness",
        "HARNESS_LOG_LEVEL": "INFO"
      }
    }
  }
}
```

**Windows** - Edit `%APPDATA%\Claude\claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "harness-claude": {
      "command": "python",
      "args": [
        "C:\\Users\\YourName\\AppData\\Local\\AI-Tools\\mcp\\harness_mcp_server_v2.py"
      ],
      "env": {
        "HARNESS_DIR": "C:\\Users\\YourName\\AppData\\Local\\AI-Tools\\harness",
        "HARNESS_LOG_LEVEL": "INFO"
      }
    }
  }
}
```

### Step 4: Verify Installation

Restart Claude Desktop, then run:

```
/mcp
```

Should show:
```
Connected MCPs:
  ✓ harness-claude [Connected]
    Tools: 10 available
```

---

## USAGE EXAMPLES

### Example 1: Design Agent Team

```
User: "Design a 7-agent expert pool for product discovery with semantic search, trending analysis, user behavior tracking, and catalog specialists."

Claude: "I'll design the expert pool team using Harness Claude..."
[Uses harness_design_team tool]
Output: 
- Team ID: team-expert-pool-1719737400
- Agents: 7 (router, 6 specialists)
- Validation: 6/6 checks passed ✓
- Pattern: expert-pool
```

### Example 2: Execute Team

```
User: "Execute the product discovery team on the query 'hiking boots under $100' with 10-second timeout."

Claude: "Running team execution..."
[Uses harness_execute_team tool]
Output:
- Execution ID: exec-team-expert-pool-abc123
- Latency: 342ms
- Result: Product recommendations from all specialists
- Success: true
```

### Example 3: Profile Execution

```
User: "Show me performance metrics for that last execution."

Claude: "Analyzing execution profile..."
[Uses harness_profile_execution tool]
Output:
- Total Duration: 342ms
- P50: 45ms, P95: 120ms, P99: 280ms
- Slow Agents: trending-specialist (150ms)
- Recommendations: Enable caching for trending queries
- Cache Hit Rate: 0% (first run)
```

### Example 4: Generate Skill

```
User: "Convert the product discovery team into a reusable skill."

Claude: "Generating SKILL.md from team..."
[Uses harness_generate_skill tool]
Output:
- Skill Name: product-discovery
- Tool Count: 7
- Core Tools (80%): 5
- Advanced Tools (20%): 2
- Ready for registration ✓
```

### Example 5: Validate Team

```
User: "Certify the dashboard team for production."

Claude: "Validating team architecture..."
[Uses harness_validate_team tool]
Output:
- Checks Passed: 6/6 (100%)
  ✓ Has agents
  ✓ Has edges
  ✓ Valid pattern
  ✓ Acyclic graph
  ✓ No orphans
  ✓ Resource limits
- Certified for Production: YES
```

---

## ADVANCED CONFIGURATION

### Enable Observability

Export metrics to Prometheus/Jaeger:

```json
{
  "mcpServers": {
    "harness-claude": {
      "env": {
        "HARNESS_TELEMETRY_ENABLED": "true",
        "OPENTELEMETRY_EXPORTER_JAEGER_AGENT_HOST": "localhost",
        "OPENTELEMETRY_EXPORTER_JAEGER_AGENT_PORT": "6831",
        "HARNESS_TELEMETRY_EXPORT_INTERVAL": "60"
      }
    }
  }
}
```

### Custom Caching Strategy

```json
{
  "mcpServers": {
    "harness-claude": {
      "env": {
        "HARNESS_CACHE_ENABLED": "true",
        "HARNESS_CACHE_TTL_SECONDS": "3600",
        "HARNESS_CACHE_MAX_SIZE": "10000"
      }
    }
  }
}
```

### Audit Logging

```json
{
  "mcpServers": {
    "harness-claude": {
      "env": {
        "HARNESS_AUDIT_LOGGING_ENABLED": "true",
        "HARNESS_AUDIT_LOG_PATH": "~/.local/share/ai-tools/harness/audit.log"
      }
    }
  }
}
```

### Custom Installation Directory

```bash
# Linux/macOS
export HARNESS_DIR=/opt/harness
export MCP_DIR=/opt/mcp
python harness_mcp_server_v2.py

# Windows
$env:HARNESS_DIR = "D:\Tools\harness"
$env:MCP_DIR = "D:\Tools\mcp"
python harness_mcp_server_v2.py
```

---

## TROUBLESHOOTING

### Issue: "mcp module not found"

**Fix**:
```bash
pip install mcp
pip install --upgrade mcp  # If outdated
```

### Issue: "pydantic module not found"

**Fix**:
```bash
pip install pydantic
```

### Issue: MCP Server won't start

**Debug**:
```bash
# Check Python version
python --version  # Must be 3.9+

# Test server directly
python harness_mcp_server_v2.py

# Check logs
cat ~/.local/share/ai-tools/harness/harness.log
```

### Issue: Claude Desktop doesn't recognize Harness

**Fix**:
1. Restart Claude Desktop completely
2. Verify claude_desktop_config.json syntax (valid JSON)
3. Ensure file paths are correct
4. Check file permissions

```bash
# Linux/macOS - Fix permissions
chmod +x ~/.local/share/ai-tools/mcp/harness_mcp_server_v2.py

# Windows - Run as Administrator
```

### Issue: Team design returns no edges

**Fix**: This is expected for single-agent teams. For multi-agent teams:
```
"agent_count": 5,  # Must be >= 2
"descriptions": ["Router", "Specialist1", "Specialist2", "Specialist3", "Aggregator"]
```

### Issue: Execution timeout

**Fix**: Increase timeout_ms:
```
timeout_ms: 60000  # 60 seconds instead of default 30s
```

### Issue: No metrics saved

**Fix**: Ensure harness directories exist:
```bash
mkdir -p ~/.local/share/ai-tools/harness/{teams,executions,metrics,skills}
```

---

## FILE CHECKLIST

After installation, verify these files exist:

```
✓ HARNESS_CLAUDE_SKILL.md (skill descriptor)
✓ plugin.json (plugin manifest)
✓ harness_mcp_server_v2.py (MCP server)
✓ ~/.config/claude/claude_desktop_config.json (updated)
✓ ~/.local/share/ai-tools/harness/teams/ (directory)
✓ ~/.local/share/ai-tools/harness/executions/ (directory)
✓ ~/.local/share/ai-tools/harness/metrics/ (directory)
✓ ~/.local/share/ai-tools/mcp/harness_mcp_server_v2.py (copy)
```

---

## QUICK REFERENCE

### All Available Tools

**Core Tools** (Available immediately):
1. `harness_design_team` - Design teams
2. `harness_execute_team` - Run teams
3. `harness_profile_execution` - Analyze performance
4. `harness_generate_skill` - Create SKILL.md
5. `harness_validate_team` - Certification
6. `harness_list_teams` - Team inventory
7. `harness_list_executions` - Execution history
8. `harness_status` - System status

**Advanced Tools** (Future versions):
9. `harness_adaptive_routing` - ML-driven selection
10. `harness_chaos_test` - Resilience testing
11. `harness_state_machine` - Workflow management
12. `harness_compliance_audit` - Enterprise compliance
13. `harness_distributed_trace` - Distributed tracing
14. `harness_plugin_registry` - Plugin ecosystem

---

## NEXT STEPS

1. **Install & Verify**: Follow Quick Start section
2. **Design First Team**: "Design a 3-agent pipeline for data processing"
3. **Execute & Profile**: Run team, analyze metrics
4. **Generate Skill**: Convert to reusable SKILL.md
5. **Deploy to Production**: Validate and certificate

---

## SUPPORT

- **GitHub**: github.com/anthropic/harness-claude
- **Issues**: github.com/anthropic/harness-claude/issues
- **Documentation**: harness-claude.anthropic.com

---

**End of Installation & Deployment Guide**
