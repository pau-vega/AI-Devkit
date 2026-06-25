#!/bin/bash
INPUT=$(cat)

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/settings-lib.sh"
settings_rule_enabled "typescript-rules" "typecheck_before_commit" || exit 0

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command' || true)

# Only intercept git commit commands
if ! echo "$COMMAND" | sed 's/&&/\n/g; s/||/\n/g; s/;/\n/g' | grep -qE '^\s*git\s+commit\b'; then
  exit 0
fi

# Skip projects that have no typecheck script (non-TS repo or different
# tooling) — otherwise `pnpm typecheck` fails and every commit is blocked.
PKG="${CLAUDE_PROJECT_DIR:-.}/package.json"
[ -f "$PKG" ] || exit 0
jq -e '.scripts.typecheck' "$PKG" >/dev/null 2>&1 || exit 0

# Run typecheck before allowing the commit
TSC_OUTPUT=$(pnpm typecheck 2>&1)
TSC_EXIT=$?

if [ $TSC_EXIT -ne 0 ]; then
  echo "Blocked: typecheck failed. Fix type errors before committing:" >&2
  echo "$TSC_OUTPUT" >&2
  exit 2
fi

exit 0
