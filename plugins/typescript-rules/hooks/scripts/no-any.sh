#!/bin/bash
INPUT=$(cat)

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/settings-lib.sh"
settings_rule_enabled "typescript-rules" "no_any" || exit 0

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')

# Only check .ts/.tsx files
if ! echo "$FILE_PATH" | grep -qE '\.(ts|tsx)$'; then
  exit 0
fi

# Get content based on tool type
TOOL=$(echo "$INPUT" | jq -r '.tool_name')
if [ "$TOOL" = "Write" ]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content')
else
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string')
fi

# Strip line comments so commented-out code and prose don't trigger the rule
CODE=$(echo "$CONTENT" | sed 's|//.*||')

# Match ': any', 'as any', '=> any', and 'any' in generic-argument or
# default position (e.g. Record<string, any>, <T = any>) — not words like
# "company" or "many"
if echo "$CODE" | grep -qE ':\s*any([^a-zA-Z0-9_]|$)|as any([^a-zA-Z0-9_]|$)|=>\s*any([^a-zA-Z0-9_]|$)|[<,=]\s*any\s*[>,)[]'; then
  echo "Blocked: do not use 'any' — use generics, 'unknown', or function overloads instead" >&2
  exit 2
fi

exit 0
