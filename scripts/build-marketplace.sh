#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MARKETPLACE_JSON="$REPO_ROOT/.claude-plugin/marketplace.json"
MARKETPLACE_HTML="$REPO_ROOT/marketplace.html"

# Check dependencies
command -v jq >/dev/null 2>&1 || { echo "ERROR: jq is required but not installed" >&2; exit 1; }

# ── Helpers ──────────────────────────────────────────────────────────

# Parse YAML frontmatter from a markdown file.
# Outputs JSON: {"name": "...", "description": "...", "version": "..."}
# version defaults to null if not present.
parse_frontmatter() {
  local file="$1"
  local in_frontmatter=false
  local found_frontmatter=false
  local current_key=""
  local name="" description="" version=""

  while IFS= read -r line; do
    # Detect frontmatter boundaries
    if [[ "$line" == "---" ]]; then
      if $in_frontmatter; then
        break  # closing ---
      else
        in_frontmatter=true
        found_frontmatter=true
        continue
      fi
    fi

    $in_frontmatter || continue

    # Key: value line (not indented)
    if [[ "$line" =~ ^[a-zA-Z_-]+: ]] && [[ ! "$line" =~ ^[[:space:]] ]]; then
      current_key="${line%%:*}"
      local value="${line#*:}"
      # Strip leading space and trailing whitespace
      value="${value#"${value%%[![:space:]]*}"}"
      value="${value%"${value##*[![:space:]]}"}"

      case "$current_key" in
        name) name="$value" ;;
        version) version="$value" ;;
        description)
          if [[ "$value" == ">" || "$value" == "|" ]]; then
            description=""  # multi-line follows
          else
            description="$value"
            current_key=""  # single-line, done
          fi
          ;;
        *) current_key="" ;;  # skip unknown keys
      esac
      continue
    fi

    # Continuation line for multi-line description
    if [[ "$current_key" == "description" ]]; then
      # Stop at blank line or <example> tag
      if [[ -z "${line// /}" ]] || [[ "$line" == *"<example>"* ]]; then
        current_key=""
        continue
      fi
      # Strip leading whitespace (YAML indentation)
      local trimmed="${line#"${line%%[![:space:]]*}"}"
      if [[ -n "$description" ]]; then
        description="$description $trimmed"
      else
        description="$trimmed"
      fi
    fi
  done < "$file"

  if ! $found_frontmatter || [[ -z "$name" ]]; then
    echo "WARN: no valid frontmatter or missing name in $file" >&2
    return 1
  fi

  jq -n \
    --arg name "$name" \
    --arg desc "$description" \
    --arg ver "${version:-null}" \
    '{name: $name, description: $desc, version: (if $ver == "null" then null else $ver end)}'
}

# Read markdown body (content after closing frontmatter ---).
# If no frontmatter found, returns full file content.
read_body() {
  local file="$1"
  local in_fm=false found_end=false

  while IFS= read -r line; do
    if ! $found_end; then
      if [[ "$line" == "---" ]]; then
        if ! $in_fm; then
          in_fm=true
        else
          found_end=true
        fi
      fi
    else
      echo "$line"
    fi
  done < "$file"
}

# ── Component discovery ──────────────────────────────────────────────

# Discover skills in {plugin_root}/skills/*/SKILL.md
# Outputs a JSON array of skill objects.
discover_skills() {
  local plugin_root="$1"
  local plugin_name="$2"
  local skills="[]"

  if [[ ! -d "$plugin_root/skills" ]]; then
    echo "[]"
    return
  fi

  for skill_file in "$plugin_root"/skills/*/SKILL.md; do
    [[ -f "$skill_file" ]] || continue
    local fm
    if ! fm=$(parse_frontmatter "$skill_file"); then
      continue
    fi
    local s_name s_desc s_ver s_cmd s_body
    s_name=$(echo "$fm" | jq -r '.name')
    s_desc=$(echo "$fm" | jq -r '.description')
    s_ver=$(echo "$fm" | jq -r 'if .version then .version else "0.0.1" end')
    s_cmd="/${plugin_name}:${s_name}"
    s_body=$(read_body "$skill_file")

    skills=$(echo "$skills" | jq \
      --arg n "$s_name" --arg d "$s_desc" --arg v "$s_ver" --arg c "$s_cmd" --arg body "$s_body" \
      '. + [{name: $n, version: $v, description: $d, command: $c, body: $body}]')
  done

  echo "$skills"
}

# Discover agents in {plugin_root}/agents/*.md
# Outputs a JSON array of agent objects.
discover_agents() {
  local plugin_root="$1"
  local agents="[]"

  if [[ ! -d "$plugin_root/agents" ]]; then
    echo "[]"
    return
  fi

  for agent_file in "$plugin_root"/agents/*.md; do
    [[ -f "$agent_file" ]] || continue
    local fm
    if ! fm=$(parse_frontmatter "$agent_file"); then
      continue
    fi
    local a_name a_desc a_body
    a_name=$(echo "$fm" | jq -r '.name')
    a_desc=$(echo "$fm" | jq -r '.description')
    a_body=$(read_body "$agent_file")

    agents=$(echo "$agents" | jq \
      --arg n "$a_name" --arg d "$a_desc" --arg body "$a_body" \
      '. + [{name: $n, description: $d, body: $body}]')
  done

  echo "$agents"
}

# Discover commands in {plugin_root}/commands/*.md
# Outputs a JSON array of command objects.
discover_commands() {
  local plugin_root="$1"
  local plugin_name="$2"
  local commands="[]"

  if [[ ! -d "$plugin_root/commands" ]]; then
    echo "[]"
    return
  fi

  for cmd_file in "$plugin_root"/commands/*.md; do
    [[ -f "$cmd_file" ]] || continue
    local fm
    if ! fm=$(parse_frontmatter "$cmd_file"); then
      continue
    fi
    local c_name c_desc c_cmd c_body
    c_name=$(echo "$fm" | jq -r '.name')
    c_desc=$(echo "$fm" | jq -r '.description')
    c_cmd="/${plugin_name}:${c_name}"
    c_body=$(read_body "$cmd_file")

    commands=$(echo "$commands" | jq \
      --arg n "$c_cmd" --arg d "$c_desc" --arg body "$c_body" \
      '. + [{name: $n, description: $d, body: $body}]')
  done

  echo "$commands"
}

# Discover hooks from {plugin_root}/hooks/hooks.json
# Outputs a JSON array of {event, rules} objects.
discover_hooks() {
  local plugin_root="$1"
  local hooks_file="$plugin_root/hooks/hooks.json"
  local result="[]"

  if [[ ! -f "$hooks_file" ]]; then
    echo "[]"
    return
  fi

  # Iterate over each event type (e.g., PreToolUse)
  local event_types
  event_types=$(jq -r '.hooks | keys[]' "$hooks_file" 2>/dev/null) || { echo "[]"; return; }

  for event_type in $event_types; do
    # Iterate over matcher groups within this event type
    local matcher_count
    matcher_count=$(jq -r ".hooks.\"$event_type\" | length" "$hooks_file")

    for (( i=0; i<matcher_count; i++ )); do
      local matcher
      matcher=$(jq -r ".hooks.\"$event_type\"[$i].matcher" "$hooks_file")
      local event_label="${event_type} (${matcher})"

      local command_rules="[]"
      local has_prompt=false

      # Process each hook in this matcher group
      local hook_count
      hook_count=$(jq -r ".hooks.\"$event_type\"[$i].hooks | length" "$hooks_file")

      for (( j=0; j<hook_count; j++ )); do
        local hook_type
        hook_type=$(jq -r ".hooks.\"$event_type\"[$i].hooks[$j].type" "$hooks_file")

        if [[ "$hook_type" == "command" ]]; then
          # Derive rule name from script filename
          local cmd_str
          cmd_str=$(jq -r ".hooks.\"$event_type\"[$i].hooks[$j].command" "$hooks_file")
          # Extract filename: last path component, remove .sh extension
          local filename="${cmd_str##*/}"
          filename="${filename%.sh}"
          # Replace hyphens with spaces, title-case each word (portable awk)
          local rule_name
          rule_name=$(echo "$filename" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')
          command_rules=$(echo "$command_rules" | jq --arg r "$rule_name" '. + [$r]')

        elif [[ "$hook_type" == "prompt" ]]; then
          has_prompt=true
        fi
      done

      # Add command hooks as one entry (if any)
      local cmd_rule_count
      cmd_rule_count=$(echo "$command_rules" | jq 'length')
      if (( cmd_rule_count > 0 )); then
        result=$(echo "$result" | jq \
          --arg ev "$event_label" \
          --argjson rules "$command_rules" \
          '. + [{event: $ev, rules: $rules}]')
      fi

      # Add prompt hook as a separate entry
      if $has_prompt; then
        local prompt_text
        prompt_text=$(jq -r ".hooks.\"$event_type\"[$i].hooks[] | select(.type==\"prompt\") | .prompt" "$hooks_file" | cut -c1-80)
        # Truncate at last complete word
        if (( ${#prompt_text} >= 80 )); then
          prompt_text="${prompt_text% *}..."
        fi
        local prompt_label="${event_label} — Prompt"
        result=$(echo "$result" | jq \
          --arg ev "$prompt_label" \
          --arg rule "$prompt_text" \
          '. + [{event: $ev, rules: [$rule]}]')
      fi
    done
  done

  echo "$result"
}

# ── Cursor symlinks ────────────────────────────────────────────

# Generate .cursor/skills/ symlinks for Cursor discovery
generate_cursor_symlinks() {
  local repo_root="$1"

  # Create .cursor/skills/ directory
  mkdir -p "$repo_root/.cursor/skills/typescript-rules"
  mkdir -p "$repo_root/.cursor/skills/jsdoc-standards"
  mkdir -p "$repo_root/.cursor/skills/commit-commands"

  # typescript-rules: symlink from .cursor/skills/typescript-rules/ to skills/typescript-conventions/
  # Use relative path so symlinks work regardless of clone location
  (cd "$repo_root/.cursor/skills/typescript-rules" && \
   ln -sf ../../../plugins/typescript-rules/skills/typescript-conventions/SKILL.md SKILL.md)

  # jsdoc-standards: symlink from .cursor/skills/jsdoc-standards/ to skills/jsdoc-conventions/
  (cd "$repo_root/.cursor/skills/jsdoc-standards" && \
   ln -sf ../../../plugins/jsdoc-standards/skills/jsdoc-conventions/SKILL.md SKILL.md)

  # commit-commands: symlink from .cursor/skills/commit-commands/ to skills/git-conventions/
  (cd "$repo_root/.cursor/skills/commit-commands" && \
   ln -sf ../../../plugins/commit-commands/skills/git-conventions/SKILL.md SKILL.md)

  # release-please-monorepo: symlink from .cursor/skills/release-please-monorepo/ to skills/release-please-monorepo/
  mkdir -p "$repo_root/.cursor/skills/release-please-monorepo"
  (cd "$repo_root/.cursor/skills/release-please-monorepo" && \
   ln -sf ../../../plugins/release-please-monorepo/skills/release-please-monorepo/SKILL.md SKILL.md)

  echo "Created .cursor/skills/ symlinks for typescript-rules, jsdoc-standards, commit-commands, and release-please-monorepo" >&2
}

# ── Main ─────────────────────────────────────────────────────────────

main() {
  if [[ ! -f "$MARKETPLACE_JSON" ]]; then
    echo "ERROR: marketplace.json not found at $MARKETPLACE_JSON" >&2
    exit 1
  fi

  if [[ ! -f "$MARKETPLACE_HTML" ]]; then
    echo "ERROR: marketplace.html not found at $MARKETPLACE_HTML" >&2
    exit 1
  fi

  # Generate .cursor/skills/ symlinks for Cursor compatibility
  generate_cursor_symlinks "$REPO_ROOT"

  local plugin_count
  plugin_count=$(jq '.plugins | length' "$MARKETPLACE_JSON")
  local plugins_array="[]"

  for (( idx=0; idx<plugin_count; idx++ )); do
    # Read fields from marketplace.json
    local p_name p_displayName p_version p_source p_category p_description
    local p_longDescription p_icon p_accentColor
    p_name=$(jq -r ".plugins[$idx].name" "$MARKETPLACE_JSON")
    p_displayName=$(jq -r ".plugins[$idx].displayName // empty" "$MARKETPLACE_JSON")
    p_version=$(jq -r ".plugins[$idx].version" "$MARKETPLACE_JSON")
    p_source=$(jq -r ".plugins[$idx].source" "$MARKETPLACE_JSON")
    p_category=$(jq -r ".plugins[$idx].category" "$MARKETPLACE_JSON")
    p_description=$(jq -r ".plugins[$idx].description" "$MARKETPLACE_JSON")
    p_longDescription=$(jq -r ".plugins[$idx].longDescription // empty" "$MARKETPLACE_JSON")
    p_icon=$(jq -r ".plugins[$idx].icon // empty" "$MARKETPLACE_JSON")
    p_accentColor=$(jq -r ".plugins[$idx].accentColor // empty" "$MARKETPLACE_JSON")

    # Validate required field
    if [[ -z "$p_displayName" ]]; then
      echo "ERROR: displayName is required for plugin '$p_name'" >&2
      exit 1
    fi

    # Resolve plugin root directory
    local plugin_root
    if [[ "$p_source" == "./" || "$p_source" == "." ]]; then
      plugin_root="$REPO_ROOT"
    else
      plugin_root="$REPO_ROOT/${p_source#./}"
    fi

    if [[ ! -d "$plugin_root" ]]; then
      echo "WARN: plugin directory not found: $plugin_root (skipping $p_name)" >&2
      continue
    fi

    # Use longDescription if available, else description
    local display_desc="${p_longDescription:-$p_description}"

    # Discover components
    local skills agents commands hooks
    skills=$(discover_skills "$plugin_root" "$p_name")
    agents=$(discover_agents "$plugin_root")
    commands=$(discover_commands "$plugin_root" "$p_name")
    hooks=$(discover_hooks "$plugin_root")

    # Build plugin JSON object
    local plugin_obj
    plugin_obj=$(jq -n \
      --arg id "$p_name" \
      --arg name "$p_displayName" \
      --arg version "$p_version" \
      --arg description "$display_desc" \
      --arg category "$p_category" \
      --arg icon "${p_icon:-}" \
      --arg accent "${p_accentColor:-#7c6aef}" \
      --arg source "$p_source" \
      --argjson skills "$skills" \
      --argjson agents "$agents" \
      --argjson hooks "$hooks" \
      --argjson commands "$commands" \
      '{
        id: $id,
        name: $name,
        version: $version,
        description: $description,
        category: $category,
        icon: $icon,
        accent: $accent,
        source: $source,
        skills: $skills,
        agents: $agents,
        hooks: $hooks,
        commands: $commands
      }')

    plugins_array=$(echo "$plugins_array" | jq --argjson p "$plugin_obj" '. + [$p]')
  done

  echo "$plugins_array"
}

# ── Injection ────────────────────────────────────────────────────────

inject_plugins() {
  local json_array="$1"

  # Format the JSON for embedding: indent 2 spaces (matching the existing style)
  # Remove the outer [ ] brackets so we inject just the array contents
  local formatted
  formatted=$(echo "$json_array" | jq '.' | sed '1d;$d' | sed 's/^/  /')

  # Find the line numbers for injection
  local start_line end_line
  start_line=$(grep -n 'const PLUGINS = \[' "$MARKETPLACE_HTML" | head -1 | cut -d: -f1)

  if [[ -z "$start_line" ]]; then
    echo "ERROR: could not find 'const PLUGINS = [' in $MARKETPLACE_HTML" >&2
    exit 1
  fi

  # Find the first ]; on its own line after start_line
  end_line=$(tail -n +"$((start_line + 1))" "$MARKETPLACE_HTML" | grep -n '^];$' | head -1 | cut -d: -f1)

  if [[ -z "$end_line" ]]; then
    echo "ERROR: could not find closing '];' after PLUGINS declaration" >&2
    exit 1
  fi

  # Adjust end_line to be absolute line number
  end_line=$((start_line + end_line))

  # Build the new file: head up to and including PLUGINS = [ line,
  # then formatted JSON, then from ]; line onward
  {
    head -n "$start_line" "$MARKETPLACE_HTML"
    echo "$formatted"
    tail -n +"$end_line" "$MARKETPLACE_HTML"
  } > "${MARKETPLACE_HTML}.tmp"

  mv "${MARKETPLACE_HTML}.tmp" "$MARKETPLACE_HTML"

  local plugin_count
  plugin_count=$(echo "$json_array" | jq 'length')
  echo "Injected $plugin_count plugins into marketplace.html" >&2
}

# ── Entry point ──────────────────────────────────────────────────────

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  plugins_json=$(main)
  inject_plugins "$plugins_json"
fi
