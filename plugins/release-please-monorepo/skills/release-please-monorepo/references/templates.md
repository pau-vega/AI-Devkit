# Release Please — File Templates

Copy-paste templates for a pnpm 10 / Turbo / tsup / Node 24+ monorepo publishing to GitHub Packages under a `@scope`. Adapt scope, package list, and paths.

## Table of contents

1. commitlint config
2. .npmrc (root)
3. package.json shape (per publishable package)
4. release-please-config.json
5. .release-please-manifest.json
6. release-please.yml (full workflow)
7. Floating major tag job (for composite actions)
8. Post-release comment job

---

## 1. commitlint config

`commitlint.config.ts` — enforces Conventional Commits. Release Please reads these types to decide bump level.

```ts
import type { UserConfig } from "@commitlint/types"

const configuration: UserConfig = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    "header-max-length": [2, "always", 100],
    "subject-max-length": [2, "always", 50],
    "type-enum": [
      2,
      "always",
      ["feat", "fix", "docs", "style", "refactor", "perf", "test", "chore"],
    ],
  },
}

export default configuration
```

Wire with Husky `commit-msg` hook only (no pre-commit):

```bash
pnpm add -Dw husky @commitlint/{cli,config-conventional,types}
pnpm exec husky init
echo 'pnpm exec commitlint --edit "$1"' > .husky/commit-msg
```

## 2. .npmrc (root)

Scope points at GitHub Packages. `publish-branch=main` blocks accidental publishes off-main.

```ini
@<scope>:registry=https://npm.pkg.github.com

# pnpm monorepo settings
manage-package-manager-versions=true
link-workspace-packages=false
save-workspace-protocol=rolling
publish-branch=main

# dependency resolution
strict-peer-dependencies=false
auto-install-peers=true
```

## 3. package.json shape (per publishable package)

`packages/<pkg>/package.json` — fields Release Please or publishing care about:

```json
{
  "name": "@<scope>/<pkg>",
  "version": "1.0.0",
  "license": "ISC",
  "type": "module",
  "private": false,
  "publishConfig": {
    "registry": "https://npm.pkg.github.com"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/<org>/<repo>.git",
    "directory": "packages/<pkg>"
  },
  "files": ["dist"],
  "sideEffects": false,
  "engines": { "node": ">=24" },
  "main": "./dist/index.cjs",
  "module": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "import": { "types": "./dist/index.d.ts", "default": "./dist/index.js" },
      "require": { "types": "./dist/index.d.cts", "default": "./dist/index.cjs" }
    }
  }
}
```

The `version` here MUST equal the value in `.release-please-manifest.json` before the first Release Please run.

## 4. release-please-config.json

`.github/release-please-config.json` — **the recipe**: declares every releaseable path, how to bump it, what to call it, and how to group commits in the changelog. Hand-edited when adding/removing a package. Read by the `release-please-action` step via `config-file:`.

### Full annotated example

Every package gets the **complete** `changelog-sections` block — the config format has no includes/inheritance, so copy it verbatim into each entry. Do not use `[]` shortcuts on packages you actually release; hidden sections (`style`, `test`, `ci`) still need to be listed so their commits don't leak into "Miscellaneous".

```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "include-component-in-tag": true,
  "packages": {
    "packages/decorators": {
      "release-type": "node",
      "package-name": "@tutellus/decorators",
      "component": "decorators",
      "changelog-sections": [
        { "type": "feat",     "section": "Features",                 "hidden": false },
        { "type": "fix",      "section": "Bug Fixes",                "hidden": false },
        { "type": "chore",    "section": "Miscellaneous",            "hidden": false },
        { "type": "docs",     "section": "Documentation",            "hidden": false },
        { "type": "style",    "section": "Styles",                   "hidden": true  },
        { "type": "refactor", "section": "Code Refactoring",         "hidden": false },
        { "type": "perf",     "section": "Performance Improvements", "hidden": false },
        { "type": "test",     "section": "Tests",                    "hidden": true  },
        { "type": "ci",       "section": "Continuous Integration",   "hidden": true  }
      ]
    },
    "packages/sentry": {
      "release-type": "node",
      "package-name": "@tutellus/sentry",
      "component": "sentry",
      "bump-minor-pre-major": true,
      "bump-patch-for-minor-pre-major": true,
      "changelog-sections": [
        { "type": "feat",     "section": "Features",                 "hidden": false },
        { "type": "fix",      "section": "Bug Fixes",                "hidden": false },
        { "type": "chore",    "section": "Miscellaneous",            "hidden": false },
        { "type": "docs",     "section": "Documentation",            "hidden": false },
        { "type": "style",    "section": "Styles",                   "hidden": true  },
        { "type": "refactor", "section": "Code Refactoring",         "hidden": false },
        { "type": "perf",     "section": "Performance Improvements", "hidden": false },
        { "type": "test",     "section": "Tests",                    "hidden": true  },
        { "type": "ci",       "section": "Continuous Integration",   "hidden": true  }
      ]
    },
    "actions/nordvpn-es": {
      "release-type": "simple",
      "package-name": "nordvpn-es",
      "component": "nordvpn-es",
      "release-as": "1.0.0",
      "changelog-sections": [
        { "type": "feat",     "section": "Features",                 "hidden": false },
        { "type": "fix",      "section": "Bug Fixes",                "hidden": false },
        { "type": "chore",    "section": "Miscellaneous",            "hidden": false },
        { "type": "docs",     "section": "Documentation",            "hidden": false },
        { "type": "style",    "section": "Styles",                   "hidden": true  },
        { "type": "refactor", "section": "Code Refactoring",         "hidden": false },
        { "type": "perf",     "section": "Performance Improvements", "hidden": false },
        { "type": "test",     "section": "Tests",                    "hidden": true  },
        { "type": "ci",       "section": "Continuous Integration",   "hidden": true  }
      ]
    }
  }
}
```

### Top-level fields

| Field | Type | Purpose |
|-------|------|---------|
| `$schema` | string | Editor autocomplete/validation against the official schema. Optional but cheap — keep it. |
| `include-component-in-tag` | bool | **Mandatory `true` for multi-package repos.** Tags become `<component>-v1.2.3` instead of bare `v1.2.3`, preventing tag collisions between packages. The floating-major-tag job and the comment job both rely on this `<component>-v<version>` shape. |
| `packages` | object | Map of **repo-relative path → package config**. The key is the path Release Please operates on; it must match the key in `.release-please-manifest.json` and the path checked by `contains(paths_released, ...)` in the workflow. |

### Per-package fields

| Field | Required | Purpose |
|-------|----------|---------|
| `release-type` | yes | `node` = bump `package.json#version` + write `CHANGELOG.md`. `simple` = generic SemVer + changelog only, no manifest file touched (use for composite `action.yml`). |
| `package-name` | yes | The published name (incl. scope, e.g. `@tutellus/decorators`). For npm packages this must match `package.json#name`. For `simple` releases it's a label only. |
| `component` | yes | The tag prefix. Produces tags like `decorators-v1.3.6`. Must be unique across all packages. Drives `paths_released` matching. |
| `changelog-sections` | yes | Maps Conventional Commit `type` → changelog heading. Same set across all packages (copy verbatim). `hidden: true` collapses that type out of the changelog entirely (commits still counted for bumping). |
| `bump-minor-pre-major` | no | For packages `<1.0`: a `feat` bumps `0.x.y → 0.(x+1).0` instead of jumping to `1.0.0`. Default Release Please behavior jumps to 1.0 on any `feat` below 1.0. |
| `bump-patch-for-minor-pre-major` | no | For packages `<1.0`: a `fix`/`chore` bumps `0.x.y → 0.x.(y+1)` (patch) instead of `0.(x+1).0` (minor). Pair with `bump-minor-pre-major`. |
| `release-as` | no | Pin the next release to a fixed version (e.g. `"1.0.0"` for initial release). **Remove after the pinned release ships** or every subsequent release re-pins to the same version. |

### changelog-sections field semantics

Each entry: `{ "type": "<conventional-type>", "section": "<heading>", "hidden": <bool> }`

- `type` must match a type in your `commitlint.config.ts` `type-enum`. Unknown types are silently ignored.
- `section` is the human-readable heading in `CHANGELOG.md` and the GitHub Release body.
- `hidden: true` → commits of that type still influence the version bump but don't appear in the changelog. Use for noise types (`style`, `test`, `ci`).
- `hidden: false` → commits appear under the heading.
- A type not listed in `changelog-sections` at all falls into Release Please's default handling — list every type from your commitlint enum to be explicit.

### How Release Please uses this file

1. On each push to `main`, reads `packages/*` keys → scans commits since the last release tag for each path.
2. Classifies commits by `type` → decides bump (none/patch/minor/major) per package using `release-type` rules + the pre-major flags.
3. Opens/updates a single "chore(main): release" PR per package with the bumped version, updated `CHANGELOG.md`, and the new version written into `.release-please-manifest.json` (and `package.json#version` for `node` type).
4. When that PR merges → creates the git tag `<component>-v<version>`, creates the GitHub Release, emits `paths_released` containing the paths that actually bumped.

## 5. .release-please-manifest.json

`.github/.release-please-manifest.json` — **the state**: the current released version of each package. Plain `path → version` map. The leading dot is convention (Release Please looks for it; some editors hide it).

### Full example

```json
{
  "packages/decorators": "1.3.6",
  "packages/eslint-config": "1.2.8",
  "packages/sentry": "1.5.5",
  "packages/tsconfig": "1.0.2",
  "packages/vite-polyfills": "1.0.4",
  "actions/nordvpn-es": "1.0.0"
}
```

### Rules

- **Keys must exactly match the keys in `release-please-config.json` `packages`.** Same paths, same strings. A mismatch causes Release Please to treat the package as unreleased or to no-op.
- **Values are plain SemVer strings** — no `v` prefix, no leading `^`. Just `1.3.6`.
- **Seed each entry once** with the version currently in the package's `package.json` (for `node` type) or the desired initial version (for `simple` type). After that, **never hand-edit** — Release Please bumps these values on each release PR.
- **The value MUST equal `package.json#version` before the first Release Please run.** Drift = Release Please sees the manifest version, assumes that release already happened, and produces a no-op. Fix by syncing the two before the first run.
- **The leading dot** (`.release-please-manifest.json`) is the filename Release Please's `manifest-file:` input expects by default; keep it. The file is committed to the repo, not generated.

### Lifecycle (the two files together)

```
config.json (recipe)    manifest.json (state)     package.json (artifact)
─────────────────       ───────────────────       ──────────────────────
hand-edited             hand-seeded once          hand-edited initially
  │                       │                         │
  │  release PR merges    │                         │
  └──────────────────────►│  version bumped ◄────────┘  (node type only:
                          │                              RP writes package.json#version too)
                          │
                          ▼
                    git tag <component>-v<version>
                    GitHub Release created
                    workflow publish jobs fire (gated on paths_released)
```

- `config.json` says *how* to release. `manifest.json` says *what version we're at*. `package.json#version` is the npm-publishable artifact of the manifest value (kept in sync by Release Please for `node` releases).
- `paths_released` (workflow output) is derived from which manifest keys actually changed in the merged release PR — that's why the publish-job `if:` checks `contains(paths_released, '<path>')` using the **same path string** as the config/manifest keys.

## 6. release-please.yml (full workflow)

`.github/workflows/release-please.yml` — single workflow: release job + one publish job per package + optional floating-tag and comment jobs.

```yaml
name: Release Please

on:
  push:
    branches:
      - main
  workflow_dispatch:
    inputs:
      force_release:
        description: 'Force release even if no changes detected'
        required: false
        default: false
        type: boolean

concurrency:
  group: release-${{ github.ref }}
  cancel-in-progress: false

permissions:
  contents: write
  pull-requests: write
  packages: write
  id-token: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    outputs:
      release_created: ${{ steps.release.outputs.release_created }}
      releases_created: ${{ steps.release.outputs.releases_created }}
      tag_name: ${{ steps.release.outputs.tag_name }}
      version: ${{ steps.release.outputs.version }}
      paths_released: ${{ steps.release.outputs.paths_released }}
    steps:
      - name: Run Release Please
        id: release
        uses: googleapis/release-please-action@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          config-file: .github/release-please-config.json
          manifest-file: .github/.release-please-manifest.json

  publish-<pkg>:
    needs: release-please
    runs-on: ubuntu-latest
    if: contains(needs.release-please.outputs.paths_released, 'packages/<pkg>')
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 1

      - uses: pnpm/action-setup@v5

      - uses: actions/setup-node@v6
        with:
          node-version: 24
          registry-url: https://npm.pkg.github.com
          cache: pnpm
          scope: '@<scope>'
        env:
          NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Setup Turbo cache
        uses: actions/cache@v5
        with:
          path: .turbo
          key: turbo-${{ runner.os }}-${{ hashFiles('**/turbo.json', '**/pnpm-lock.yaml') }}
          restore-keys: |
            turbo-${{ runner.os }}-

      - name: Install dependencies
        run: pnpm install --frozen-lockfile --filter=@<scope>/<pkg>...

      - name: Build package
        run: pnpm turbo build --filter=@<scope>/<pkg>

      - name: Configure pnpm for GitHub Packages
        run: |
          pnpm config set //npm.pkg.github.com/:_authToken ${{ secrets.GITHUB_TOKEN }}
          pnpm config set @<scope>:registry https://npm.pkg.github.com

      - name: Publish package
        run: cd packages/<pkg> && pnpm publish --no-git-checks
```

Critical points (see SKILL.md "Workflow anatomy" + "Gotchas"):
- Gate each publish job on `contains(paths_released, '<path>')`, not `release_created`.
- `fetch-depth: 1` is fine for publish jobs; use `fetch-depth: 0` only for the floating-tag job below.
- `--no-git-checks` is required (shallow checkout + Release Please's commit).
- Install with `--filter=<pkg>...` (transitive workspace deps), build with `--filter=<pkg>` (just the package).
- `GITHUB_TOKEN` suffices for both Release Please and npm publish to GitHub Packages.

## 7. Floating major tag job (for composite actions)

Consumers of a composite action pin `@v<major>`. Force-move that tag on each release so `@v1` always points at the latest `1.x.y`. Gated on the action's path; uses `fetch-depth: 0` and `persist-credentials: true`.

```yaml
  tag-floating-major:
    needs: release-please
    runs-on: ubuntu-latest
    if: contains(needs.release-please.outputs.paths_released, 'actions/<composite-action>')
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 0
          persist-credentials: true

      - name: Force-move floating major tag
        env:
          VERSION: ${{ needs.release-please.outputs.version }}
          RELEASE_TAG: ${{ needs.release-please.outputs.tag_name }}
        run: |
          set -euo pipefail
          if [[ -z "${VERSION}" ]]; then
            echo "::error::release-please did not emit a version"
            exit 1
          fi
          MAJOR="v${VERSION%%.*}"
          echo "Release tag:  ${RELEASE_TAG}"
          echo "Floating tag: ${MAJOR} -> ${GITHUB_SHA}"
          git config user.name  "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git tag -f "${MAJOR}" "${GITHUB_SHA}"
          git push origin "${MAJOR}" --force
```

## 8. Post-release comment job

Optional. Appends a "Published Packages" section to the GitHub Release body, mapping `paths_released` → package names. Runs last, gated on `releases_created`, `if: always()` so it runs even if a publish job failed.

```yaml
  comment-on-release:
    needs: [release-please, publish-<pkg-a>, publish-<pkg-b>, tag-floating-major]
    runs-on: ubuntu-latest
    if: always() && needs.release-please.outputs.releases_created
    steps:
      - name: Update release with published packages
        uses: actions/github-script@v9
        with:
          script: |
            const pathsReleased = '${{ needs.release-please.outputs.paths_released }}'
            const version = '${{ needs.release-please.outputs.version }}'
            const packages = pathsReleased.split(',')
            const packageNames = packages.map(path => {
              if (path.includes('<pkg-a>')) return '@<scope>/<pkg-a>'
              if (path.includes('<pkg-b>')) return '@<scope>/<pkg-b>'
              if (path.includes('actions/<composite-action>')) return '<org>/<repo>/actions/<composite-action>@<component>-v' + version
              return null
            }).filter(Boolean)

            const releaseTag = '${{ needs.release-please.outputs.tag_name }}'
            const commitSha = context.sha

            const publishedPackages = `\n\n## 📦 Published Packages\n\n${packageNames.map(pkg => `- \`${pkg}@${version}\``).join('\n')}\n\n🔍 Trigger SHA: \`${commitSha}\``

            const releases = await github.rest.repos.listReleases({
              owner: context.repo.owner,
              repo: context.repo.repo,
              per_page: 10
            })

            const release = releases.data.find(r => r.tag_name === releaseTag)
            if (release) {
              await github.rest.repos.updateRelease({
                owner: context.repo.owner,
                repo: context.repo.repo,
                release_id: release.id,
                body: release.body + publishedPackages
              })
            }
```

The `<component>-v<version>` tag-name shape for composite actions comes from `include-component-in-tag: true` + the `component` field in the config.
