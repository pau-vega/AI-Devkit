#!/bin/bash
INPUT=$(cat)

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/settings-lib.sh"
settings_rule_enabled "typescript-rules" "no_export_default" || exit 0

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

# Allow default exports where frameworks require them: Next.js app-router
# files, config files (vite/next/vitest/playwright/tailwind/...), and
# Storybook stories.
if echo "$FILE_PATH" | grep -qE '/(page|layout|loading|error|not-found|template|default)\.(ts|tsx)$|\.config\.(ts|mts|cts)$|\.stories\.(ts|tsx)$'; then
  exit 0
fi

if echo "$CONTENT" | grep -q 'export default'; then
  echo "Blocked: do not use 'export default' — use named exports instead" >&2
  exit 2
fi

exit 0
