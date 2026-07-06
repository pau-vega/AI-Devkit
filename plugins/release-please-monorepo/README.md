# release-please-monorepo

A plugin that sets up automated semantic versioning, changelogs, and per-package publishing in a pnpm/Turbo monorepo using [googleapis/release-please-action](https://github.com/googleapis/release-please-action) v4. Installable into Claude Code, Cursor, or OpenCode via `npx devkit-ai`.

## What it covers

- Conventional-Commits-driven releases: one Release Please PR accumulates version bumps + changelogs per package; merging it tags a release and triggers per-package publish jobs.
- Independent per-package versioning in a monorepo.
- The four files that live in `.github/`: `release-please-config.json`, `.release-please-manifest.json`, `workflows/release-please.yml`, plus commitlint/`.npmrc`/`package.json` prerequisites.
- Per-package publish jobs gated on `paths_released`, GitHub Packages auth, and floating major tags for composite actions.

## Components

### Skill: `release-please-monorepo`

Reference guide with the full setup recipe, workflow anatomy, gotchas, and verification steps. The assistant consults this automatically when asked to "add release please", "automate releases/versioning", "publish packages on push to main", or "set up release-please in a monorepo". Ships a `references/templates.md` with copy-paste templates for every file the setup needs.

This plugin ships no agents, no commands, and no hooks — it is a reference skill only.

## Installation

```bash
npx devkit-ai
```

The installer prompts for editor (Claude Code / OpenCode / Cursor), scope (project / project-local / user), and which plugins to install. To install release-please-monorepo into Claude Code without the installer:

```bash
git clone https://github.com/pau-vega/Devkit-AI.git
claude --plugin-dir ./Devkit-AI/plugins/release-please-monorepo
```

## License

MIT
