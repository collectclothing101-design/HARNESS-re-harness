#!/usr/bin/env python3

##############################################################################
# HARNESS v3.0.0 - Claude Configuration Validator
# Validates the claude_desktop_config.json file
##############################################################################

import json
import os
import sys
from pathlib import Path

class ConfigValidator:
    def __init__(self):
        self.errors = []
        self.warnings = []
        self.passes = []
        self.config_file = os.path.expanduser(
            "~/Library/Application Support/Claude/claude_desktop_config.json"
        )
    
    def print_header(self):
        print("╔════════════════════════════════════════════════════════════════╗")
        print("║     Harness v3.0.0 - Claude Configuration Validator           ║")
        print("╚════════════════════════════════════════════════════════════════╝")
        print()
    
    def print_section(self, title):
        print(f"\n{title}")
        print("─" * 66)
    
    def check_file_exists(self):
        """Check if config file exists"""
        self.print_section("CHECK 1: Configuration File")
        
        if not os.path.exists(self.config_file):
            self.errors.append(f"Configuration file not found: {self.config_file}")
            return False
        
        self.passes.append("Configuration file found")
        size = os.path.getsize(self.config_file)
        print(f"✓ Configuration file found")
        print(f"  Location: {self.config_file}")
        print(f"  Size: {size} bytes")
        return True
    
    def check_json_syntax(self):
        """Validate JSON syntax"""
        self.print_section("CHECK 2: JSON Syntax")
        
        try:
            with open(self.config_file, 'r') as f:
                self.config = json.load(f)
            self.passes.append("JSON syntax is valid")
            print("✓ JSON syntax is valid")
            return True
        except json.JSONDecodeError as e:
            self.errors.append(f"Invalid JSON syntax: {e}")
            print(f"✗ Invalid JSON: {e}")
            return False
        except Exception as e:
            self.errors.append(f"Error reading config: {e}")
            print(f"✗ Error reading config: {e}")
            return False
    
    def check_harness_entry(self):
        """Check if harness MCP entry exists"""
        self.print_section("CHECK 3: Harness MCP Entry")
        
        if "mcpServers" not in self.config:
            self.errors.append("No 'mcpServers' key in config")
            print("✗ No 'mcpServers' key found")
            return False
        
        mcp_servers = self.config["mcpServers"]
        
        if "harness" not in mcp_servers:
            self.warnings.append("Harness MCP server not configured")
            print("⚠ Harness MCP server not found in mcpServers")
            return False
        
        self.passes.append("Harness MCP server entry found")
        print("✓ Harness MCP server entry found")
        return True
    
    def validate_harness_config(self):
        """Validate harness server configuration"""
        self.print_section("CHECK 4: Harness Configuration Structure")
        
        if "harness" not in self.config.get("mcpServers", {}):
            print("⊘ Skipping (harness not configured)")
            return False
        
        harness = self.config["mcpServers"]["harness"]
        
        # Check required fields
        required_fields = ["command"]
        for field in required_fields:
            if field not in harness:
                self.errors.append(f"Missing required field: {field}")
                print(f"✗ Missing required field: {field}")
            else:
                self.passes.append(f"Field '{field}' present: {harness[field]}")
                print(f"✓ Field '{field}': {harness[field]}")
        
        # Check args
        if "args" in harness:
            args = harness["args"]
            if not isinstance(args, list):
                self.errors.append("'args' must be a list")
                print(f"✗ 'args' must be a list, got: {type(args).__name__}")
            else:
                print(f"✓ Arguments: {len(args)} argument(s)")
                for i, arg in enumerate(args):
                    # Validate path if it looks like a path
                    if arg.startswith("/") or arg.startswith("~"):
                        expanded = os.path.expanduser(arg)
                        if not os.path.exists(expanded):
                            self.warnings.append(f"Argument path does not exist: {arg}")
                            print(f"  ⚠ [{i}] Path not found: {arg}")
                        else:
                            self.passes.append(f"Argument path exists: {arg}")
                            print(f"  ✓ [{i}] {arg} (exists)")
                    else:
                        print(f"  ✓ [{i}] {arg}")
        else:
            self.warnings.append("No 'args' field in harness config")
            print("⚠ No 'args' field found")
        
        return len(self.errors) == 0
    
    def validate_python_command(self):
        """Validate python command"""
        self.print_section("CHECK 5: Python Command Validation")
        
        if "harness" not in self.config.get("mcpServers", {}):
            print("⊘ Skipping (harness not configured)")
            return False
        
        command = self.config["mcpServers"]["harness"].get("command", "")
        
        print(f"Python command: {command}")
        
        # Check if it's python3 or full path
        if command == "python3":
            print("✓ Using system python3 (will use PATH)")
            self.passes.append("Python command is 'python3'")
        elif "/python3" in command or "/python" in command:
            expanded = os.path.expanduser(command)
            if os.path.exists(expanded):
                self.passes.append(f"Python path exists: {command}")
                print(f"✓ Python path exists: {expanded}")
            else:
                self.errors.append(f"Python path not found: {command}")
                print(f"✗ Python path not found: {expanded}")
        else:
            self.warnings.append(f"Unknown python command format: {command}")
            print(f"⚠ Unknown format: {command}")
        
        return len([e for e in self.errors if "Python" in e]) == 0
    
    def validate_mcp_server_path(self):
        """Validate MCP server file path"""
        self.print_section("CHECK 6: MCP Server Path")
        
        if "harness" not in self.config.get("mcpServers", {}):
            print("⊘ Skipping (harness not configured)")
            return False
        
        args = self.config["mcpServers"]["harness"].get("args", [])
        
        if not args:
            self.errors.append("No args found for MCP server path")
            print("✗ No arguments found")
            return False
        
        server_path = args[0]
        expanded_path = os.path.expanduser(server_path)
        
        print(f"Server path: {server_path}")
        
        if os.path.exists(expanded_path):
            self.passes.append(f"MCP server file exists: {server_path}")
            print(f"✓ File exists: {expanded_path}")
            
            # Check file type
            if expanded_path.endswith(".py"):
                print("✓ File is Python (.py)")
            
            # Check file size
            size = os.path.getsize(expanded_path)
            print(f"✓ File size: {size} bytes")
            
            return True
        else:
            self.errors.append(f"MCP server file not found: {server_path}")
            print(f"✗ File not found: {expanded_path}")
            return False
    
    def validate_environment_variables(self):
        """Validate environment variables if present"""
        self.print_section("CHECK 7: Environment Variables")
        
        if "harness" not in self.config.get("mcpServers", {}):
            print("⊘ Skipping (harness not configured)")
            return False
        
        env = self.config["mcpServers"]["harness"].get("env", {})
        
        if not env:
            print("⊘ No environment variables set (optional)")
            return True
        
        print(f"Environment variables: {len(env)}")
        
        for key, value in env.items():
            if value.startswith("~"):
                expanded = os.path.expanduser(value)
                if os.path.exists(expanded):
                    print(f"✓ {key}: {value} (exists)")
                else:
                    self.warnings.append(f"Env path not found: {key}={value}")
                    print(f"⚠ {key}: {value} (path not found)")
            else:
                print(f"✓ {key}: {value}")
        
        return True
    
    def validate_json_formatting(self):
        """Validate JSON formatting"""
        self.print_section("CHECK 8: JSON Formatting")
        
        try:
            with open(self.config_file, 'r') as f:
                content = f.read()
            
            # Try pretty-printing
            pretty = json.dumps(json.loads(content), indent=2)
            
            if pretty == content:
                self.passes.append("JSON is properly formatted")
                print("✓ JSON is properly formatted")
            else:
                self.warnings.append("JSON formatting could be improved")
                print("⚠ JSON could be reformatted for readability")
                print("\nSuggested formatting:")
                print(pretty[:500] + "..." if len(pretty) > 500 else pretty)
            
            return True
        except Exception as e:
            self.errors.append(f"Formatting check failed: {e}")
            print(f"✗ Formatting check failed: {e}")
            return False
    
    def display_config_summary(self):
        """Display a summary of the configuration"""
        self.print_section("Current Configuration")
        
        print(json.dumps(self.config, indent=2))
    
    def print_summary(self):
        """Print validation summary"""
        print()
        print("╔════════════════════════════════════════════════════════════════╗")
        print("║                    VALIDATION SUMMARY                          ║")
        print("╚════════════════════════════════════════════════════════════════╝")
        print()
        
        print(f"Passed:   {len(self.passes)}")
        print(f"Warnings: {len(self.warnings)}")
        print(f"Errors:   {len(self.errors)}")
        print()
        
        if self.errors:
            print("ERRORS:")
            for i, error in enumerate(self.errors, 1):
                print(f"  {i}. {error}")
            print()
        
        if self.warnings:
            print("WARNINGS:")
            for i, warning in enumerate(self.warnings, 1):
                print(f"  {i}. {warning}")
            print()
        
        if not self.errors:
            print("✓ Configuration is valid!")
            print()
            print("NEXT STEPS:")
            print("  1. Restart Claude Desktop: killall Claude && open /Applications/Claude.app")
            print("  2. Check Settings → Integrations → 'harness [Connected]'")
            print("  3. Test with: @harness help")
        else:
            print("✗ Configuration has errors that need fixing.")
            print()
            print("SOLUTIONS:")
            print("  1. Run installation script again:")
            print("     bash /mnt/user-data/outputs/QUICK_FIX_INSTALL_NOW.sh")
            print("  2. Or manually fix config file:")
            print(f"     nano '{self.config_file}'")
        
        return len(self.errors) == 0
    
    def run(self):
        """Run all validation checks"""
        self.print_header()
        
        if not self.check_file_exists():
            self.print_summary()
            return False
        
        if not self.check_json_syntax():
            self.print_summary()
            return False
        
        self.check_harness_entry()
        self.validate_harness_config()
        self.validate_python_command()
        self.validate_mcp_server_path()
        self.validate_environment_variables()
        self.validate_json_formatting()
        
        print()
        self.display_config_summary()
        
        return self.print_summary()


if __name__ == "__main__":
    validator = ConfigValidator()
    success = validator.run()
    sys.exit(0 if success else 1)
