#!/bin/bash
INPUT=$(cat)

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/settings-lib.sh"
settings_rule_enabled "typescript-rules" "enforce_pnpm" || exit 0

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command' || true)

# Only enforce pnpm in projects that actually use it — a repo with an npm or
# yarn lockfile is not a pnpm project and should keep its package manager.
[ -f "${CLAUDE_PROJECT_DIR:-.}/pnpm-lock.yaml" ] || exit 0

# Split chained commands (&&, ||, ;) into separate lines and check if any
# starts with npm/yarn. This avoids false positives when "npm" appears
# inside arguments (e.g., git commit messages).
if echo "$COMMAND" | sed 's/&&/\n/g; s/||/\n/g; s/;/\n/g' | grep -qE '^\s*npm\s+(install|i|add|ci|uninstall|remove|rm|un|update|up)\b|^\s*yarn\s+(add|install|remove|upgrade)\b|^\s*yarn\s*$'; then
  echo "Blocked: this is a pnpm project (pnpm-lock.yaml) — use pnpm instead of npm/yarn" >&2
  exit 2
fi

exit 0
