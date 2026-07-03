#!/bin/bash
# Harness v3.0.1 Fix - Execution Monitor

OUTPUTS_DIR="/mnt/user-data/outputs"
LOG_FILE="$HOME/Desktop/harness_fix_execution.log"

exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo "╔═════════════════════════════════════════════════════╗"
echo "║   HARNESS v3.0.1 FIX EXECUTION STARTED              ║"
echo "║   $(date)                           ║"
echo "╚═════════════════════════════════════════════════════╝"
echo ""

# Execute the complete fix script
bash "$OUTPUTS_DIR/COMPLETE_HARNESS_FIX.sh"

FIX_EXIT_CODE=$?

echo ""
echo "╔═════════════════════════════════════════════════════╗"

if [ $FIX_EXIT_CODE -eq 0 ]; then
    echo "║   ✅ FIX COMPLETED SUCCESSFULLY                     ║"
else
    echo "║   ❌ FIX ENCOUNTERED AN ERROR (code: $FIX_EXIT_CODE)   ║"
fi

echo "║   $(date)                           ║"
echo "╚═════════════════════════════════════════════════════╝"
echo ""

if [ $FIX_EXIT_CODE -eq 0 ]; then
    echo "═════════════════════════════════════════════════════"
    echo "NEXT STEPS"
    echo "═════════════════════════════════════════════════════"
    echo ""
    echo "1️⃣  RESTART CLAUDE DESKTOP"
    echo "   killall Claude && open /Applications/Claude.app"
    echo ""
    echo "2️⃣  VERIFY MCP CONNECTION"
    echo "   • Settings → Integrations"
    echo "   • Look for: harness [Connected] ✓"
    echo ""
    echo "3️⃣  TEST MCP"
    echo "   In Claude, type: @harness help"
    echo "   Should see command list"
    echo ""
    echo "4️⃣  TRIGGER SKILL"
    echo "   In Claude, type: Help me install Harness"
    echo "   Should load Harness Installation Skill v1.0.0"
    echo ""
    echo "═════════════════════════════════════════════════════"
    echo ""
    echo "Execution log saved: $LOG_FILE"
else
    echo "═════════════════════════════════════════════════════"
    echo "TROUBLESHOOTING"
    echo "═════════════════════════════════════════════════════"
    echo ""
    echo "Check the error above and review:"
    echo "1. Full log: $LOG_FILE"
    echo "2. MCP file: ~/Library/Application Support/AI-Tools/mcp/"
    echo "3. Skill dir: ~/Library/Application Support/Claude/skills/"
    echo ""
    echo "If directories don't exist, create manually:"
    echo "mkdir -p ~/Library/Application Support/AI-Tools/mcp"
    echo "mkdir -p ~/Library/Application Support/Claude/skills"
    echo ""
fi

exit $FIX_EXIT_CODE
