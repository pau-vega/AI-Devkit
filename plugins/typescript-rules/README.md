# typescript-rules

A plugin that enforces TypeScript coding conventions through real-time hooks, an on-demand review command, and a reviewer agent. Installable into Claude Code, Cursor, or OpenCode via `npx devkit-ai`.

## Rules Enforced

- No `any` — use generics, `unknown`, or overloads
- `interface extends` over `type A = X & Y` for inheritance
- No `enum` — use `as const` objects
- No default exports (unless a framework requires them)
- Top-level `import type { X }` over inline `import { type X }`
- `prop?: T` over `T | undefined` for optional props

## Components

### Skill: `typescript-conventions`

Reference guide with the full convention rules. The assistant consults this automatically when writing or reviewing TypeScript code.

### Command: `ts-review`

User-invoked review command:

```
/ts-review              # review changed files
/ts-review src/utils    # review a specific path
```

### Agent: `ts-reviewer`

Autonomous reviewer that triggers when you ask about TypeScript code quality (e.g., "review my TypeScript code", "check my changes against our rules"). Reports findings by file with Error/Warning/Suggestion severity. Available for Claude Code and OpenCode; Cursor has no portable agent file format.

### Hooks

PreToolUse hooks, Claude Code only — OpenCode does not consume `hooks.json`, and Cursor's hook schema differs:

- **On Bash**: enforce pnpm over npm/yarn (only in projects with a `pnpm-lock.yaml`), lint before commit, typecheck before commit (each skipped when the project has no matching `package.json` script)
- **On Write/Edit**: block `enum`, `any`, default exports, inline `import { type X }`, and direct `package.json` edits; a prompt-based hook validates the rules grep can't catch (intersection-type inheritance, `T | undefined` optional props)

## Configuration

Hooks can be disabled per project — entirely or rule by rule — without uninstalling the plugin. Create `.claude/typescript-rules.local.md` in the project root:

```markdown
---
enabled: true
no_any: false
lint_before_commit: false
---

The markdown body is ignored by the hooks — use it for notes.
```

Available keys (every key defaults to `true` when the file or key is absent; only an explicit `false` disables):

| Key | Hook |
|-----|------|
| `enabled` | Master switch for all command hooks below |
| `enforce_pnpm` | Block `npm`/`yarn` installs in pnpm projects (`pnpm-lock.yaml` present) |
| `lint_before_commit` | Run `pnpm lint` before `git commit` (skipped if no `lint` script) |
| `typecheck_before_commit` | Run `pnpm typecheck` before `git commit` (skipped if no `typecheck` script) |
| `no_package_json_edit` | Block direct `package.json` edits |
| `no_any` | Block `any` in `.ts`/`.tsx` writes |
| `no_enum` | Block `enum` declarations |
| `no_export_default` | Block default exports (config files and Storybook stories exempt) |
| `no_inline_import_type` | Block inline `import { type X }` |

The settings file is read on every hook invocation, so changes take effect immediately — no restart needed. Two caveats:

- The prompt-based validation hook cannot read project files, so it stays active regardless of this file. It covers only the intersection-inheritance and optional-prop rules, which no script rule duplicates.
- Settings are per-developer — add `.claude/*.local.md` to your `.gitignore`.

## Installation

```bash
npx devkit-ai
```

The installer prompts for editor (Claude Code / OpenCode / Cursor), scope (project / project-local / user), and which plugins to install. To install typescript-rules into Claude Code without the installer:

```bash
git clone https://github.com/pau-vega/Devkit-AI.git
claude --plugin-dir ./Devkit-AI/plugins/typescript-rules
```

## License

MIT
