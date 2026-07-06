---
name: release-please-monorepo
description: Set up automated semantic versioning, changelogs, and per-package publishing in a pnpm/Turbo monorepo using googleapis/release-please-action v4. Use when the user asks to "add release please", "automate releases/versioning", "publish packages on push to main", "set up release-please in a monorepo", or wants Conventional Commits-driven releases with independent per-package versions. Covers config + manifest files, the release workflow, per-package publish jobs gated on `paths_released`, GitHub Packages auth, and floating major tags for composite actions.
---

# Release Please for pnpm/Turbo Monorepos

Automated, Conventional-Commits-driven releases: one Release Please PR accumulates version bumps + changelogs per package; merging it tags a release and triggers per-package publish jobs. Each package versions independently.

## Prerequisites (must exist first)

1. **Conventional Commits enforced.** Release Please reads commit types (`feat`, `fix`, …) to decide bump level. Enforce via commitlint + Husky `commit-msg` hook. Allowed types map to changelog sections in the release-please config. See `references/templates.md` → "commitlint config".
2. **One `package.json` per publishable package** with `name`, `version` (synced with manifest), `publishConfig.registry`, `repository.directory`, `files`, `private: false`. See `references/templates.md` → "package shape".
3. **Registry auth wiring.** For GitHub Packages: root `.npmrc` sets `@scope:registry=https://npm.pkg.github.com`; CI uses `NODE_AUTH_TOKEN` + `setup-node` `registry-url` + `scope`. See `references/templates.md` → ".npmrc".

Skip any of the above and releases will mis-bump, fail to publish, or publish to the wrong registry.

## Files to create

Four files live in `.github/`. Full contents in `references/templates.md`:

| File | Purpose | Hand-edited? |
|------|---------|--------------|
| `.github/release-please-config.json` | Per-package config: release-type, package-name, component, changelog-sections. | Yes, when adding a package. |
| `.github/.release-please-manifest.json` | Source of truth for each package's current version. | No — Release Please updates it on release. Seed once per package. |
| `.github/workflows/release-please.yml` | The workflow: one release-please job + N publish jobs + optional post-release job. | Yes, when adding a package's publish job. |

## Workflow anatomy

Single workflow, one release-please job + one publish job per package. Pattern from `references/templates.md` → "workflow":

```
release-please (runs on every push to main)
  → outputs: release_created, releases_created, tag_name, version, paths_released
publish-<pkg>  (needs: release-please, if: contains(paths_released, '<pkg-path>'))
  → checkout (fetch-depth: 1) → pnpm setup → setup-node (registry-url, scope, cache: pnpm)
  → cache .turbo → pnpm install --frozen-lockfile --filter=<pkg>...
  → pnpm turbo build --filter=<pkg>
  → pnpm config set registry auth  (or rely on setup-node env)
  → cd packages/<pkg> && pnpm publish --no-git-checks
```

Key invariants:
- **Gate publish jobs on `paths_released`**, not `release_created`. `release_created` is true if *any* package released; `paths_released` is the comma-list of paths that actually bumped. Without the `contains()` check, every push-to-main release publishes every package.
- **`--no-git-checks` on `pnpm publish`** — Release Please already committed the version bump; the working tree is clean but pnpm's git checks trip on shallow checkout (`fetch-depth: 1`).
- **Install with `--filter=<pkg>...`** (the `...` includes transitive workspace deps) and build with `--filter=<pkg>` (no `...`, just the package). Keeps CI fast.
- **`GITHUB_TOKEN` is enough** for both Release Please and npm publish to GitHub Packages — no PAT needed. Permissions block must grant `contents: write`, `pull-requests: write`, `packages: write`.
- **`concurrency: release-${{ github.ref }}`, `cancel-in-progress: false`** — never cancel a release mid-publish.

## Adding a new package to an existing setup

1. Add an entry to `release-please-config.json` under `packages` with `release-type: node`, `package-name`, `component`, and the shared `changelog-sections` block.
2. Seed `.release-please-manifest.json` with `"<pkg-path>": "<initial-version>"` (usually the version already in its `package.json`).
3. Copy a publish job in `release-please.yml`, rename it, swap the path filter + `--filter=` + `cd` target.
4. If the package has a post-release side effect (e.g. floating major tag for a composite action), add a dedicated job gated on its path — see `references/templates.md` → "floating major tag job".

## release-type cheat sheet

- `node` — anything with a `package.json` (npm packages, CLI tools, tsup-built libs). Bumps `package.json#version`.
- `simple` — no manifest file; generic SemVer + changelog only. Use for composite GitHub Actions (`action.yml`) or non-node artifacts. Pair with a `tag-floating-major` job if consumers pin `@v1`.

## Gotchas

- **`include-component-in-tag: true`** (top of config) — tags become `<component>-v1.2.3` instead of `v1.2.3`. Mandatory for multi-package repos to avoid tag collisions.
- **Manifest version must match `package.json#version`** before first run. Release Please assumes they're in sync; drift causes a no-op release.
- **`bump-minor-pre-major: true` + `bump-patch-for-minor-pre-major: true`** for any package still below `1.0` — surfaces `0.x` bumps as `0.(x+1).0` / `0.x.(y+1)` instead of jumping to `1.0.0` on a `feat`.
- **`release-as`** pins the next version for one release (used in the config for initial releases). Remove after the pin lands or it'll re-pin every release.
- **`fetch-depth: 0` required for the floating-major-tag job** (needs git history to force-move the tag). All publish jobs use `fetch-depth: 1`.
- **Composite-action consumers pin `@<major>`** via a floating tag you force-move on each release (`git tag -f v1 <sha> && git push --force`). The `tag-floating-major` job in `references/templates.md` does this.
- **`pnpm publish` reads `.npmrc` `publish-branch=main`** — only publishes from `main`. Fine here since the workflow runs on `push` to `main`.
- **No pre-commit hook**, only `commit-msg`. Conventional-commit enforcement happens at commit message time, not on staged content.

## Verification after setup

1. Make a `feat:` commit on a branch → open PR → merge to main.
2. Release Please opens a "chore(main): release" PR listing the bumped package + new version.
3. Merge the release PR → check the Actions tab: `release-please` job succeeds, the matching `publish-<pkg>` job runs (others skip), the GitHub Release appears with the changelog body.
4. Confirm the published version on the GitHub Packages page matches `manifest.json`.
5. For composite actions: confirm the floating `v<major>` tag moved to the release commit SHA (`git ls-remote origin refs/tags/v1`).

## Resources

- **`references/templates.md`** — copy-paste templates for: commitlint config, `.npmrc`, `package.json` shape, `release-please-config.json`, `.release-please-manifest.json`, the full `release-please.yml` workflow (release job + publish job + floating-tag job + comment job). Read when implementing or adding a package.
