#!/usr/bin/env bash
# Solution: Block git push --force

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')

# Only process Bash commands
if [[ "$tool_name" != "Bash" ]]; then
    exit 0
fi

command=$(echo "$input" | jq -r '.tool_input.command')

# Check for force push patterns
if [[ "$command" == *"git push"* ]] && [[ "$command" == *"--force"* || "$command" == *" -f"* ]]; then
    jq -n '{
        "hookSpecificOutput": {
            "permissionDecision": "deny",
            "permissionDecisionReason": "Force push is blocked. Use --force-with-lease if necessary."
        }
    }'
    exit 0
fi

exit 0
