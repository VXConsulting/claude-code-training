#!/usr/bin/env bash
# Exercise 1: Block git push --force
#
# TODO: Complete this hook to block force push commands
#
# Input: JSON with tool_name and tool_input.command
# Output: JSON with permissionDecision: "deny" if force push detected

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')

# TODO: Check if tool is Bash
# TODO: Extract command from tool_input
# TODO: Check if command contains "push" and "--force" or "-f"
# TODO: If dangerous, output deny JSON
# TODO: Exit with code 0

exit 0
