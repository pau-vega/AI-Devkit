#!/bin/bash
# Shared reader for the per-project settings file (.claude/<plugin>.local.md).
# Sourced by every hook script in this plugin so users can disable the whole
# plugin or individual rules per project without uninstalling.
#
# File format — YAML frontmatter, markdown body ignored:
#
#   ---
#   enabled: true
#   no_any: false
#   ---
#
# Semantics: missing file, missing key, or any value other than "false" means
# enabled. Only an explicit `false` disables, so defaults stay on.

# settings_rule_enabled <plugin-name> <rule-key>
# Returns 1 when the settings file disables the plugin (`enabled: false`) or
# the specific rule (`<rule-key>: false`); returns 0 otherwise.
settings_rule_enabled() {
  local plugin="$1" rule="$2"
  local file="${CLAUDE_PROJECT_DIR:-.}/.claude/${plugin}.local.md"
  [ -f "$file" ] || return 0

  local frontmatter
  frontmatter=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$file")

  local master rule_value
  master=$(printf '%s\n' "$frontmatter" | grep '^enabled:' | sed 's/enabled: *//; s/ *#.*//; s/[[:space:]]*$//; s/^"\(.*\)"$/\1/' || true)
  rule_value=$(printf '%s\n' "$frontmatter" | grep "^${rule}:" | sed "s/${rule}: *//; s/ *#.*//; s/[[:space:]]*\$//; s/^\"\(.*\)\"\$/\1/" || true)

  if [ "$master" = "false" ] || [ "$rule_value" = "false" ]; then
    return 1
  fi
  return 0
}
