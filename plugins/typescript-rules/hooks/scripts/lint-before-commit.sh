#!/bin/bash
INPUT=$(cat)

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/settings-lib.sh"
settings_rule_enabled "typescript-rules" "lint_before_commit" || exit 0

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command' || true)

# Only intercept git commit commands
if ! echo "$COMMAND" | sed 's/&&/\n/g; s/||/\n/g; s/;/\n/g' | grep -qE '^\s*git\s+commit\b'; then
  exit 0
fi

# Skip projects that have no lint script (non-JS repo or different tooling) —
# otherwise `pnpm lint` fails and every commit is blocked.
PKG="${CLAUDE_PROJECT_DIR:-.}/package.json"
[ -f "$PKG" ] || exit 0
jq -e '.scripts.lint' "$PKG" >/dev/null 2>&1 || exit 0

# Run lint check before allowing the commit
LINT_OUTPUT=$(pnpm lint 2>&1)
LINT_EXIT=$?

if [ $LINT_EXIT -ne 0 ]; then
  echo "Blocked: lint check failed. Fix lint errors before committing:" >&2
  echo "$LINT_OUTPUT" >&2
  exit 2
fi

exit 0
