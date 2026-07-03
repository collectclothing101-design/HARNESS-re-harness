# HARNESS v3.0.0 - TEAM DEPLOYMENT GUIDE

## Overview

This guide provides step-by-step instructions for deploying Harness v3.0.0 across a team or organization using the recommended production-grade virtual environment approach.

**Recommended for**: Teams of 2+, enterprise deployments, production environments

**Deployment method**: VENV_SETUP_RECOMMENDED.sh

**Total deployment time per machine**: 15-20 minutes

---

## Prerequisites

Before deploying to your team, verify:

### Team Lead / Admin
- [ ] macOS machines in your team (or Linux)
- [ ] Python 3 installed on each machine
- [ ] Claude Desktop installed on each machine
- [ ] All team members have admin access on their machines
- [ ] Read: `/mnt/user-data/outputs/00_START_HERE_INSTALLATION_GUIDE.md`

### Each Team Member
- [ ] Has their own machine with admin access
- [ ] Has Claude Desktop running
- [ ] Can open terminal/bash
- [ ] Has read access to deployment files
- [ ] Understood: What Harness is and why it's being deployed

---

## Deployment Phases

### Phase 0: Preparation (Team Lead)

**Duration**: 30 minutes (one-time)

1. **Copy deployment files to shared location** (choose one):
   ```bash
   # Option A: Git repository
   git clone <repo> /path/to/harness-deployment
   
   # Option B: Shared drive
   cp -r /mnt/user-data/outputs ~/Shared/harness-v3-deployment
   
   # Option C: Internal server
   scp -r /mnt/user-data/outputs deploy@server:/opt/harness-v3/
   ```

2. **Create deployment manifest** for your team:
   ```bash
   cat > TEAM_DEPLOYMENT_INFO.md << 'EOF'
   # Team Harness v3.0.0 Deployment
   
   Deployment Date: [DATE]
   Team: [TEAM_NAME]
   Deployed By: [ADMIN_NAME]
   
   ## Deployment Status
   
   | Team Member | Machine | Status | Date | Notes |
   |-------------|---------|--------|------|-------|
   | John Doe | MacBook Pro | Pending | - | - |
   | Jane Smith | iMac | Pending | - | - |
   | [Add more] | [Machine] | [Status] | [Date] | [Notes] |
   
   ## Support Contact
   
   Questions? Contact: [ADMIN_EMAIL]
   Issues? See: /mnt/user-data/outputs/TROUBLESHOOTING_AND_QUICK_REFERENCE.md
   EOF
   ```

3. **Send deployment email to team**:
   ```
   Subject: Harness v3.0.0 - Team Deployment Instructions
   
   Hi Team,
   
   We're deploying Harness v3.0.0 to improve our workflow.
   
   What: Harness MCP Server for Claude Desktop
   When: [DATE_RANGE]
   Time: 15 minutes per person
   
   Installation Steps:
   1. Download: [LINK_TO_DEPLOYMENT_FILES]
   2. Run: bash VENV_SETUP_RECOMMENDED.sh
   3. Restart Claude
   4. Verify: Check Settings → Integrations
   5. Test: Type @harness help
   
   Need help? See TROUBLESHOOTING_AND_QUICK_REFERENCE.md
   Questions? Email me
   
   [ADMIN_NAME]
   ```

---

### Phase 1: Individual Machine Deployment (Each Team Member)

**Duration**: 15 minutes per person

#### Step 1: Download deployment files
```bash
# Get files from shared location
# Option A: Clone from git
git clone <repo> ~/harness-deployment

# Option B: Copy from shared drive
cp -r ~/Shared/harness-v3-deployment ~/harness

# Option C: Download from server
scp -r deploy@server:/opt/harness-v3/ ~/harness
```

#### Step 2: Run installation script
```bash
# Navigate to deployment directory
cd ~/harness

# Make script executable
chmod +x VENV_SETUP_RECOMMENDED.sh

# Run installation (select Production path)
bash VENV_SETUP_RECOMMENDED.sh
```

**Expected output**:
```
✓ Python 3 found: Python 3.x.x
✓ Virtual environment created at ~/harness_venv
✓ pip upgraded
✓ mcp installed
✓ Directories created
✓ MCP server copied
✓ Claude config updated with venv Python path
✓ INSTALLATION COMPLETE
```

#### Step 3: Restart Claude Desktop
```bash
# Close Claude completely
killall Claude

# Wait 2 seconds
sleep 2

# Reopen Claude
open /Applications/Claude.app
```

#### Step 4: Verify installation
```bash
# Quick status check
bash /mnt/user-data/outputs/status.sh

# Should see:
# Python: ✓
# MCP Module: ✓
# MCP Server: ✓
# Config File: ✓
# Config Entry: ✓
# Claude Running: ✓
```

#### Step 5: Verify in Claude
1. Open Claude Settings (⚙️)
2. Go to "Integrations" tab
3. Look for: **"harness [Connected]"** (green ✓)

#### Step 6: Test Harness command
In Claude chat, type:
```
@harness help
```

Should see Harness help output and available commands.

---

### Phase 2: Team Verification (Each Team Member)

**Duration**: 5 minutes per person

#### Comprehensive verification
```bash
bash /mnt/user-data/outputs/verify_installation_comprehensive.sh
```

Should show: **"✓ Installation verified successfully!"**

#### Configuration validation
```bash
python3 /mnt/user-data/outputs/validate_claude_config.py
```

Should show: **"✓ Configuration is valid!"**

---

### Phase 3: Team Lead Verification & Reporting

**Duration**: 1 hour (team-wide)

#### Collect status from team
1. Ask each team member to report:
   - Installation completed (y/n)
   - Verification script result (pass/warning/fail)
   - Configuration validation (pass/fail)
   - "@harness help" command works (y/n)

2. Update deployment manifest:
   ```bash
   # Edit TEAM_DEPLOYMENT_INFO.md
   # Mark each person's status as:
   # ✓ Complete
   # ⚠ Complete with warnings
   # ✗ Failed (needs support)
   ```

3. Support failed deployments:
   - Share: TROUBLESHOOTING_AND_QUICK_REFERENCE.md
   - Try: Alternative installation method (QUICK_FIX)
   - Contact: Team lead for escalation

---

## Environment Standardization

### Standard directory structure (all machines)
```
~/harness_venv/                 # Virtual environment
  └── bin/python3              # Python interpreter
  └── lib/python3.x/site-packages/mcp  # MCP module

~/Library/Application Support/AI-Tools/
  ├── harness/                 # Harness data
  └── mcp/
      └── harness_claude_advanced_mcp.py  # MCP server

~/Library/Application Support/Claude/
  ├── claude_desktop_config.json    # Configuration
  └── skills/harness-installation/  # Skill package
```

### Standard configuration (all machines)
All machines should have this in their `claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "harness": {
      "command": "/Users/USERNAME/harness_venv/bin/python3",
      "args": ["/Users/USERNAME/Library/Application Support/AI-Tools/mcp/harness_claude_advanced_mcp.py"],
      "env": {
        "HARNESS_DIR": "/Users/USERNAME/Library/Application Support/AI-Tools/harness",
        "HARNESS_LOG_LEVEL": "INFO"
      }
    }
  }
}
```

**Note**: Replace `USERNAME` with actual username (auto-handled by script)

---

## Troubleshooting at Scale

### Scenario 1: Installation fails for one person
- [ ] Have them run: `bash status.sh`
- [ ] Share: TROUBLESHOOTING_AND_QUICK_REFERENCE.md
- [ ] Try alternative: QUICK_FIX_INSTALL_NOW.sh
- [ ] Escalate if both fail

### Scenario 2: Multiple people with same error
- [ ] Check if machine type is consistent (all Homebrew? all MacPorts?)
- [ ] Try different installation script
- [ ] Check if there's a system-wide Python issue
- [ ] Escalate to IT

### Scenario 3: Verification passes but "@harness help" fails
- [ ] Restart Claude completely: `killall Claude && open /Applications/Claude.app`
- [ ] Check: Settings → Integrations shows "harness [Connected]"
- [ ] Wait 10 seconds after restart
- [ ] Try command again
- [ ] If still fails: run `validate_claude_config.py`

### Scenario 4: Harness commands work but slowly
- [ ] This is normal after first few calls
- [ ] MCP server startup takes 2-3 seconds
- [ ] Performance improves after Claude caches connection
- [ ] Not an issue if commands work

---

## Rollback Procedure

If you need to remove Harness from all team machines:

### Per machine (30 seconds):
```bash
# 1. Remove virtual environment
rm -rf ~/harness_venv

# 2. Remove MCP server
rm ~/Library/Application\ Support/AI-Tools/mcp/harness_claude_advanced_mcp.py

# 3. Remove harness entry from config
# Edit: ~/Library/Application Support/Claude/claude_desktop_config.json
# Delete the "harness" block from mcpServers

# 4. Restart Claude
killall Claude && open /Applications/Claude.app
```

### Team-wide rollback checklist:
- [ ] Send rollback email to team
- [ ] Provide rollback script
- [ ] Ask team to report when complete
- [ ] Verify all machines reverted
- [ ] Archive deployment documentation

---

## Deployment Success Criteria

✅ Deployment complete when:

- [ ] All team members have installed Harness
- [ ] All machines show "harness [Connected]" in Claude
- [ ] All "@harness help" commands work
- [ ] Verification scripts pass on all machines
- [ ] Team feels confident using Harness commands
- [ ] Issues resolved for any failed deployments

---

## Documentation for Team

Share these files with your team:

1. **00_IMMEDIATE_ACTION_SUMMARY.md** — Quick reference
2. **TROUBLESHOOTING_AND_QUICK_REFERENCE.md** — Error resolution
3. **INSTALLATION_CHECKLIST.md** — Verification steps
4. **status.sh** — Quick diagnostic

---

## Support & Escalation

### Level 1: Self-service
- TROUBLESHOOTING_AND_QUICK_REFERENCE.md
- status.sh and verify_installation_comprehensive.sh
- Try alternative installation script

### Level 2: Team lead support
- Review verification script output
- Guide through manual installation
- Share relevant documentation sections

### Level 3: Escalation
- Archive all logs and outputs
- Contact Harness support
- Share: DEPLOYMENT_MANIFEST.json

---

## Monitoring Ongoing

### Weekly health check
```bash
# Run on all machines
bash status.sh
```

If any machines show issues:
- Run comprehensive verification
- Check Claude logs
- Review configuration

### Monthly updates
- Check for new Harness versions
- Review team feedback
- Update documentation as needed

---

## Team Communication Template

### Deployment Kickoff Email
```
Subject: Harness v3.0.0 Team Deployment - [DATE]

Hi Team,

We're installing Harness v3.0.0 this week.

📋 What is Harness?
A tool that brings command-line power to Claude Desktop.

⏱️ Time commitment: 15 minutes per person

📦 Installation:
1. Download files from: [LINK]
2. Run: bash VENV_SETUP_RECOMMENDED.sh
3. Restart Claude
4. Test: @harness help
5. Report success

🆘 Questions?
- See: TROUBLESHOOTING_AND_QUICK_REFERENCE.md
- Email: [ADMIN]

[ADMIN_NAME]
```

### Weekly Status Check Email
```
Subject: Harness Deployment - Status Check

Team,

Quick check - everyone up and running?

To verify:
1. Claude → Settings → Integrations
2. Look for: "harness [Connected]"
3. Reply: ✓ Good | ⚠ Issue

If issues, run:
bash /mnt/user-data/outputs/status.sh

Let me know!
```

---

## Success Metrics

Track these metrics:

| Metric | Target | Current |
|--------|--------|---------|
| % Machines deployed | 100% | ___ % |
| % Verification passed | 100% | ___ % |
| % @harness working | 100% | ___ % |
| Avg time per machine | 15 min | ___ min |
| Support escalations | 0 | ___ |

---

**Version**: Harness v3.0.0  
**Deployment Method**: VENV_SETUP_RECOMMENDED.sh  
**Date**: 2026-07-01  
**Status**: Ready for team deployment
