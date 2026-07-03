#!/bin/bash

##############################################################################
# HARNESS v3.0.0 - Installation Method Selector
# Interactive menu to help users choose the right installation method
##############################################################################

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

clear

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║     Harness v3.0.0 - Installation Method Selector             ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

echo "Select your installation scenario:"
echo ""
echo "  1) I just want to test Harness quickly (30 seconds)"
echo "  2) I'm setting up for production / team use (2 minutes)"
echo "  3) I have a CI/CD pipeline (automated)"
echo "  4) I want to understand what's happening (manual)"
echo "  5) I'm not sure - help me choose"
echo "  6) Exit"
echo ""
read -p "Enter your choice (1-6): " choice

case $choice in
  1)
    echo ""
    echo -e "${GREEN}✓ Selected: Quick Testing${RESET}"
    echo ""
    echo "You've chosen the fastest installation method."
    echo ""
    echo "Script: QUICK_FIX_INSTALL_NOW.sh"
    echo "Time: ~30 seconds"
    echo "Method: pip override with --break-system-packages --user"
    echo ""
    read -p "Run installation now? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
      bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh
    else
      echo "To run later: bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh"
    fi
    ;;
  
  2)
    echo ""
    echo -e "${GREEN}✓ Selected: Production Setup${RESET}"
    echo ""
    echo "You've chosen the recommended production installation method."
    echo ""
    echo "Script: VENV_SETUP_RECOMMENDED.sh"
    echo "Time: ~2 minutes"
    echo "Method: Python virtual environment (isolated & safe)"
    echo ""
    read -p "Run installation now? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
      bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh
    else
      echo "To run later: bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh"
    fi
    ;;
  
  3)
    echo ""
    echo -e "${GREEN}✓ Selected: CI/CD Automation${RESET}"
    echo ""
    echo "You've chosen the automation-friendly installation method."
    echo ""
    echo "Script: install_harness_v3_PEP668_AWARE.sh"
    echo "Time: ~1 minute"
    echo "Method: Auto-detecting Python environment"
    echo ""
    read -p "Run installation now? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
      bash /mnt/user-data/outputs/install_harness_v3_PEP668_AWARE.sh
    else
      echo "To run later: bash /mnt/user-data/outputs/install_harness_v3_PEP668_AWARE.sh"
    fi
    ;;
  
  4)
    echo ""
    echo -e "${GREEN}✓ Selected: Manual Setup${RESET}"
    echo ""
    echo "You want to run each step manually."
    echo ""
    echo "Please read: TROUBLESHOOTING_AND_QUICK_REFERENCE.md"
    echo "Section: SOLUTION 3 - MANUAL OVERRIDE"
    echo ""
    echo "File path: /mnt/user-data/outputs/TROUBLESHOOTING_AND_QUICK_REFERENCE.md"
    echo ""
    read -p "Open documentation? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
      less /mnt/user-data/outputs/TROUBLESHOOTING_AND_QUICK_REFERENCE.md || cat /mnt/user-data/outputs/TROUBLESHOOTING_AND_QUICK_REFERENCE.md | head -100
    fi
    ;;
  
  5)
    echo ""
    echo -e "${BLUE}Help me choose...${RESET}"
    echo ""
    echo "Answer these questions:"
    echo ""
    read -p "1. Are you a solo developer or in a team? (solo/team): " q1
    read -p "2. Is this for production or testing? (production/testing): " q2
    read -p "3. Is this in a CI/CD pipeline? (yes/no): " q3
    
    echo ""
    
    if [ "$q3" = "yes" ]; then
      echo -e "${GREEN}✓ Recommendation: CI/CD Automation${RESET}"
      echo "  Script: install_harness_v3_PEP668_AWARE.sh"
      echo "  Reason: Auto-detects environment and handles errors gracefully"
    elif [ "$q2" = "production" ] && [ "$q1" = "team" ]; then
      echo -e "${GREEN}✓ Recommendation: Production Setup${RESET}"
      echo "  Script: VENV_SETUP_RECOMMENDED.sh"
      echo "  Reason: Safest, most maintainable for teams"
    elif [ "$q2" = "testing" ]; then
      echo -e "${GREEN}✓ Recommendation: Quick Testing${RESET}"
      echo "  Script: QUICK_FIX_INSTALL_NOW.sh"
      echo "  Reason: Fastest, works immediately"
    else
      echo -e "${GREEN}✓ Recommendation: Production Setup${RESET}"
      echo "  Script: VENV_SETUP_RECOMMENDED.sh"
      echo "  Reason: Safe choice for any scenario"
    fi
    
    echo ""
    read -p "Run this installation now? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
      if [ "$q3" = "yes" ]; then
        bash /mnt/user-data/outputs/install_harness_v3_PEP668_AWARE.sh
      elif [ "$q2" = "testing" ]; then
        bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh
      else
        bash /mnt/user-data/outputs/VENV_SETUP_RECOMMENDED.sh
      fi
    fi
    ;;
  
  6)
    echo "Exiting."
    exit 0
    ;;
  
  *)
    echo "Invalid choice. Please run again and select 1-6."
    exit 1
    ;;
esac

echo ""
echo -e "${BLUE}──────────────────────────────────────────────────────────────${RESET}"
echo ""
echo "Next steps:"
echo "  1. If script completed: Restart Claude"
echo "     killall Claude && open /Applications/Claude.app"
echo ""
echo "  2. Verify installation: Settings → Integrations → 'harness [Connected]'"
echo ""
echo "  3. Test command: Type '@harness help' in Claude chat"
echo ""
echo "  4. For detailed verification:"
echo "     bash /mnt/user-data/outputs/verify_installation_comprehensive.sh"
echo ""
