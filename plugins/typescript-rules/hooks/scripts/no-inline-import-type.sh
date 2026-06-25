#!/bin/bash
INPUT=$(cat)

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/settings-lib.sh"
settings_rule_enabled "typescript-rules" "no_inline_import_type" || exit 0

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

# Match inline 'import { type X }' — flatten newlines first so multi-line
# import blocks are caught. The good form 'import type { X }' has 'type'
# before the brace and does not match.
if echo "$CONTENT" | tr '\n' ' ' | grep -qE 'import\s*\{[^}]*\btype\s+[A-Za-z_]'; then
  echo "Blocked: use top-level 'import type { X }' instead of inline 'import { type X }'" >&2
  exit 2
fi

exit 0
