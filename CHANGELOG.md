# Changelog

## [0.1.5](https://github.com/pau-vega/Devkit-AI/compare/devkit-ai-v0.1.4...devkit-ai-v0.1.5) (2026-07-06)


### Features

* **hooks:** add per-project settings file support ([19c0223](https://github.com/pau-vega/Devkit-AI/commit/19c02237dec7dd9e7d3629121a198919e8a32aa6))
* **hooks:** add per-project settings file support ([c06006f](https://github.com/pau-vega/Devkit-AI/commit/c06006f7be22eb85296330d536fe891335efcd40))
* **marketplace:** add release-please-monorepo plugin ([46e6277](https://github.com/pau-vega/Devkit-AI/commit/46e62779575ff30f446135361aa578c10789d010))
* **marketplace:** add release-please-monorepo plugin ([e4c10e3](https://github.com/pau-vega/Devkit-AI/commit/e4c10e3a1c87b6cb49444daa94927bb003230778))


### Bug Fixes

* **typescript-rules:** close hook gaps and false blocks ([e8ef213](https://github.com/pau-vega/Devkit-AI/commit/e8ef213483dcc75b8c36f0193714fd88d1f67d0c))
* **typescript-rules:** close hook gaps and false blocks ([d2be3a0](https://github.com/pau-vega/Devkit-AI/commit/d2be3a034b062fe87fc4dccd5e0b806b6c927c2f))

## [0.1.4](https://github.com/pau-vega/Devkit-AI/compare/devkit-ai-v0.1.3...devkit-ai-v0.1.4) (2026-06-08)


### Bug Fixes

* **ci:** remove npm cache since package-lock.json is gitignored ([651b23c](https://github.com/pau-vega/Devkit-AI/commit/651b23cc6786abd2a2931fcd711989f5b8e7020a))

## [0.1.3](https://github.com/pau-vega/Devkit-AI/compare/devkit-ai-v0.1.2...devkit-ai-v0.1.3) (2026-06-07)


### Bug Fixes

* **translator:** drop color field from agents for OpenCode ([a1395c3](https://github.com/pau-vega/Devkit-AI/commit/a1395c3f3b15bb2d99b5096f38b6ef04c78c89a0))
* **translator:** drop color field from agents for OpenCode ([8e29e64](https://github.com/pau-vega/Devkit-AI/commit/8e29e6433c2d22ed5fd279e579e0a92372fc592f))

## [0.1.2](https://github.com/pau-vega/Devkit-AI/compare/devkit-ai-v0.1.1...devkit-ai-v0.1.2) (2026-06-07)


### Features

* add commit-commands plugin with agents, skills, and commands ([98bff1d](https://github.com/pau-vega/Devkit-AI/commit/98bff1dca709ef8b579ed7601cac80306e45782b))
* Add commit-commands plugin with git workflow commands ([66bd740](https://github.com/pau-vega/Devkit-AI/commit/66bd7404f32583d7c5af9a8f117fa3b31d988c6a))
* Add commit-commands plugin with git workflow commands ([fa40f1e](https://github.com/pau-vega/Devkit-AI/commit/fa40f1e1018691250e715dc2139dfcb1c61514a7))

## [0.1.1](https://github.com/pau-vega/Devkit-AI/compare/devkit-ai-v0.1.0...devkit-ai-v0.1.1) (2026-06-04)


### Features

* translate agent and command files to OpenCode format on install ([bb3d08b](https://github.com/pau-vega/Devkit-AI/commit/bb3d08b87e321561c17874dd8b415bef2c50cf85))


### Bug Fixes

* **translator:** drop argument-hint, fix markdown in hint, remove Claude Code name leak ([f06b066](https://github.com/pau-vega/Devkit-AI/commit/f06b066690ad85d6f51b54bb87d3e1ecc2709720))

## 0.1.0 (2026-06-04)


### Features

* **01-01:** add YAML paths field to all 5 workflow-toolkit SKILL.md files ([bf605d3](https://github.com/pau-vega/Devkit-AI/commit/bf605d33e8f380dffe662ea0cd88298e3940762a))
* **01-01:** add YAML paths field to typescript-rules and jsdoc-standards SKILL.md ([b578bd5](https://github.com/pau-vega/Devkit-AI/commit/b578bd5c52893a17f5a636888976be9fea96594c))
* **01-02:** add .cursor/ to .gitignore and update build script with symlink generation ([3d75d63](https://github.com/pau-vega/Devkit-AI/commit/3d75d63377421b4ff97b5809006762ff171f740b))
* **01-02:** create .cursor/skills/ symlinks for typescript-rules and jsdoc-standards ([a4f5d70](https://github.com/pau-vega/Devkit-AI/commit/a4f5d7067a003a44044912055dae5416a57c1c3b))
* **01-03:** extend build script to generate workflow-toolkit cursor symlinks ([aabd3dd](https://github.com/pau-vega/Devkit-AI/commit/aabd3ddcc7d6429bc3bfc38f033fc553369aa07f))
* **260510-jtr:** implement installer CLI with @clack/prompts and per-file conflict handling ([c6b7341](https://github.com/pau-vega/Devkit-AI/commit/c6b7341d51788038249b86e0b537b13f633b36b2))
* **260510-jtr:** scaffold package.json + GitHub Packages publish workflow ([980a8f2](https://github.com/pau-vega/Devkit-AI/commit/980a8f2e58963158f4871592aecfe2d6a8864836))
* add /ts-review command ([7f0a7d2](https://github.com/pau-vega/Devkit-AI/commit/7f0a7d29cdd7b8509fcdc6c049b21f8a69271f91))
* add auto-generated marker above PLUGINS array ([4f5b656](https://github.com/pau-vega/Devkit-AI/commit/4f5b656c09964f95bcffc504ddd4d3c8694cc194))
* add build script skeleton with frontmatter parser ([996dc6d](https://github.com/pau-vega/Devkit-AI/commit/996dc6d1a84df8e36d7c171d54019d6de30bd8cd))
* add build step and expand path triggers in CI workflow ([b772f8f](https://github.com/pau-vega/Devkit-AI/commit/b772f8f2d0a64e5606ae40497bee36b56bc86eb7))
* add component discovery functions to build script ([a02be11](https://github.com/pau-vega/Devkit-AI/commit/a02be11c4b2419397244b7e8afa95ec00d35e7b8))
* add display fields to marketplace.json for build script ([a98490f](https://github.com/pau-vega/Devkit-AI/commit/a98490fab0917ebd36bf5cd49445242f7b9b00a4))
* add HTML injection and complete build script ([45d2b0f](https://github.com/pau-vega/Devkit-AI/commit/45d2b0fcc72250ae10b97c82d8487307aa222182))
* add lint and typecheck pre-commit hooks ([d3e292e](https://github.com/pau-vega/Devkit-AI/commit/d3e292e5072b20e4273defbe239c7bde53d6d50e))
* add lint and typecheck pre-commit hooks ([2892cd5](https://github.com/pau-vega/Devkit-AI/commit/2892cd575a49be8b22a1b87a2fb4b98675ce00cd))
* add main loop and JSON generation to build script ([d547d76](https://github.com/pau-vega/Devkit-AI/commit/d547d76d922bd26faa7a29eb1c01b23f0d009cf9))
* add marketplace and plugin manifests ([5255621](https://github.com/pau-vega/Devkit-AI/commit/5255621ba6e254edfb0ec8143b77fdb63141238b))
* add marketplace showcase page and screenshots ([03d5610](https://github.com/pau-vega/Devkit-AI/commit/03d561010ba3e9c6d9f1874ea9b8b18a94196d04))
* add marketplace showcase page and screenshots ([0d32568](https://github.com/pau-vega/Devkit-AI/commit/0d325681393fde382ac7008afe90f88da77385d1))
* add prompt hook for TypeScript validation on Write/Edit ([43b3166](https://github.com/pau-vega/Devkit-AI/commit/43b3166017d8c5b379c3ace5c32115a6fa56d612))
* add release-please workflow for automatic releases ([ee7c4ec](https://github.com/pau-vega/Devkit-AI/commit/ee7c4ec5aa3a73ddfa82175ff9559b91fec9b1da))
* add release-please workflow for automatic releases ([6e8e392](https://github.com/pau-vega/Devkit-AI/commit/6e8e3923ad095932b3750073ecca8def5d1fdf9f))
* add ts-reviewer agent for TypeScript code review ([46d113e](https://github.com/pau-vega/Devkit-AI/commit/46d113ed4bfa42c780a6edb84e29dd96a9be2790))
* add typescript-conventions skill with full rules ([351d180](https://github.com/pau-vega/Devkit-AI/commit/351d18027156821e2a780d969aa4cf3a9c6db99d))
* add workflow icon CSS class for workflow-toolkit plugin ([2596469](https://github.com/pau-vega/Devkit-AI/commit/2596469d88ad23b2d41549bbcc9dc289687dc28b))
* add workflow-toolkit plugin ([ec72708](https://github.com/pau-vega/Devkit-AI/commit/ec72708284e02424b3034e55ab5318621e8a5fbb))
* add workflow-toolkit plugin with developer workflow skills ([ed550a9](https://github.com/pau-vega/Devkit-AI/commit/ed550a9900e900ad19afa9925e38216d1461f46d))
* relocate hooks to plugin root, add jsdoc-standards plugin ([c6f2f95](https://github.com/pau-vega/Devkit-AI/commit/c6f2f950b9e68efbab53892f1018ac21d9d7095e))
* relocate hooks to plugin root, add jsdoc-standards plugin ([2cb8992](https://github.com/pau-vega/Devkit-AI/commit/2cb899290fe4186fd990c58e6d86096b92405801))
* restructure into multi-plugin marketplace ([14a1cb5](https://github.com/pau-vega/Devkit-AI/commit/14a1cb55dc171f2e191bc01db55f986bc2661eb2))
* restructure into multi-plugin marketplace with typescript-rules, jsdoc-standards, and workflow-toolkit ([e7cff56](https://github.com/pau-vega/Devkit-AI/commit/e7cff56283dd16dcfec97a476d999f659d3b3aa6))
* revamp marketplace UI and refine plugin metadata ([28f102b](https://github.com/pau-vega/Devkit-AI/commit/28f102bc1ec61c6a82d2c48ca673273cc8df0fbe))
* revamp marketplace UI and refine plugin metadata ([2c7ba85](https://github.com/pau-vega/Devkit-AI/commit/2c7ba85c6a7320625d10eaafafb5a146558b781a))


### Bug Fixes

* **260510-jtr:** address code-review BLOCKER + 2 warnings ([5db484d](https://github.com/pau-vega/Devkit-AI/commit/5db484d302d4639e77fca3c168796299b5a45323))
* add Node.js 24 env var for release-please action ([6a5877e](https://github.com/pau-vega/Devkit-AI/commit/6a5877e08f6228a0f0b335151ec4d7c471901840))
* add Node.js 24 env var for release-please action ([7b6ab6c](https://github.com/pau-vega/Devkit-AI/commit/7b6ab6cd3c4596d06bca8aeab7ac6d5ed81d8b60))
* align plugin with marketplace best practices ([6159c98](https://github.com/pau-vega/Devkit-AI/commit/6159c98c7ed6f2649d4b8c28b38e1d62dd3f4857))
* align version to 0.0.0 and add initial-version config ([a0caf07](https://github.com/pau-vega/Devkit-AI/commit/a0caf07cdcc68c8a22d18c337d06cde215adde4b))
* bump version down to 0.1.0 and normalize JSON formatting ([9072622](https://github.com/pau-vega/Devkit-AI/commit/9072622d198b036fa33e7d997860386219e6ef81))
* correct release-please config/manifest file paths ([b42e943](https://github.com/pau-vega/Devkit-AI/commit/b42e943c1c96801dfd602f2c200a5d763c7235e3))
* harden hooks and jsdoc-review command robustness ([1bb25b4](https://github.com/pau-vega/Devkit-AI/commit/1bb25b4e4664c271501f1eff1c4dc2f951f6c48d))
* move release-please config to top level, pin initial version ([1a6cef5](https://github.com/pau-vega/Devkit-AI/commit/1a6cef5ac4074af8817b1d1bb128c2850e7590d9))
* move release-please config to top level, pin initial version ([403aaa2](https://github.com/pau-vega/Devkit-AI/commit/403aaa2172d3fedfeb0539e0e010bb861b4e31d6))
* patch hook bugs, add .gitignore, update README ([148c9d4](https://github.com/pau-vega/Devkit-AI/commit/148c9d4ff9dfef08efc8d36f58bcf915dd42b639))
* prevent enforce-pnpm hook false positives on commit messages ([2102ea0](https://github.com/pau-vega/Devkit-AI/commit/2102ea01ba1f7f4e9951047ac6a16cb7c3dbac4f))
* prevent release-please from creating major versions ([379b73a](https://github.com/pau-vega/Devkit-AI/commit/379b73a5cbaf95716734a012a9136c6cd867d22d))
* remove release-as bootstrap to prevent premature 1.0.0 bump ([ab47193](https://github.com/pau-vega/Devkit-AI/commit/ab4719387727b2df55c3e14823a56f13ac7186d0))
* remove release-as bootstrap to prevent premature 1.0.0 bump ([e8acdf0](https://github.com/pau-vega/Devkit-AI/commit/e8acdf068ef90b0346392f1de1e7cbf7fb0726ed))
* remove release-as bootstrap to prevent premature 1.0.0 bump ([8ec78c4](https://github.com/pau-vega/Devkit-AI/commit/8ec78c4df4b740111ca225a451a907cc079b9ee0))
* revert release-please manifest to 0.0.0 ([4294586](https://github.com/pau-vega/Devkit-AI/commit/4294586c73d9b3542b1d59da9b6fa61809a8b168))
* set initial release version to 0.1.0 ([f72234e](https://github.com/pau-vega/Devkit-AI/commit/f72234e72c2da121ae43c51a6b9d4534cc392cea))
* use turborepo typecheck pipeline in pre-commit hook ([64e8a12](https://github.com/pau-vega/Devkit-AI/commit/64e8a12295aba82ab6fa5b63a10ca3b9aa4ce904))
* use turborepo typecheck pipeline in pre-commit hook ([bb91b1c](https://github.com/pau-vega/Devkit-AI/commit/bb91b1c95a9577bbc6950ee7a7db08123c61e443))
