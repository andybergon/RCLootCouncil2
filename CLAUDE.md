# RCLootCouncil2 - WoW Loot Council Addon

External repo owned by `evil-morfar`. We contribute via fork.

Pure-Lua WoW addon. No build system — edit and `/reload` in-game. The `Interface/AddOns/RCLootCouncil` symlink points at this repo so changes are live.

## Git Workflow (Fork + PR)

- `origin` = `andybergon/RCLootCouncil2` (our fork, full push access)
- `upstream` = `evil-morfar/RCLootCouncil2` (upstream, read-only)
- **Default branch is `develop`**, not `main` or `master`. Upstream maintains `master` as release branch and `develop` as integration branch.

**Development happens on `develop`.** Push freely to `origin/develop` — it's our fork. Fork-only work (like `CLAUDE.md`, `FORK_CHANGES.md`) lives directly on develop.

### Opening a PR to upstream

Each PR branch must contain **only the commits for that feature** — never include unrelated commits from our `develop` (like CLAUDE.md or other features).

1. Fetch upstream: `git fetch upstream`
2. Create a branch off **upstream's** develop: `git checkout -b feat/my-feature upstream/develop`
3. Cherry-pick only the relevant commit(s): `git cherry-pick <hash>`
4. Push to our fork: `git push -u origin feat/my-feature`
5. Open PR: `gh pr create --repo evil-morfar/RCLootCouncil2 --head andybergon:feat/my-feature --base develop`

**Never push `develop` directly to a PR branch** — `develop` has fork-only commits (CLAUDE.md, in-progress features) that shouldn't go upstream.

### Syncing with upstream

Use `/fork-sync` skill. We prefer `git merge upstream/develop` over rebase when the merge is heavy (many fork commits × files upstream also refactored). Fast-forwards from clean develop also work.

## Fork Changes Tracking

All fork changes are tracked in [`FORK_CHANGES.md`](FORK_CHANGES.md). Update it as part of every commit that adds or changes a fork feature.

## Repo Layout

- `core.lua` — addon entry, Ace3 setup, `RCLootCouncil` global
- `ml_core.lua` — master looter logic (session start, awarding)
- `Classes/` — OO-style class definitions (`Lib/Class` used here)
- `Modules/` — feature modules (History, Sync, Options, VotingFrame, etc.)
  - `Modules/History/` is where the fork's candidate-tracking work lives
- `Core/` — shared services (Comms, Events, Log, etc.)
- `UI/` — frames and widgets
- `Libs/` — vendored dependencies (Ace3, LibStub, etc. — all committed)
- `Patches/` — Blizzard API compatibility shims
- `__tests/` — Busted unit tests. Run with `busted` (needs Lua 5.1 + project's `.busted` config).
- `Locale/` — LibStub AceLocale-3.0 localization
- `embeds.xml` — Ace3 library XML embeds
- `changelog.md` — upstream's changelog; do NOT edit for fork-only changes

## Dev Setup

- No packager step. WoW reads the source directly via the symlink.
- Version in `RCLootCouncil.toc` is a literal number (e.g. `3.21.0`) — not a `@project-version@` template. After each upstream sync, the TOC version bumps and WowUp stops flagging the addon as outdated.
- Tests use Busted — run from repo root: `busted` (or `luarocks install busted` first).

## Key Concepts

### Sessions and the Master Looter (ML)

The ML starts a **session**: broadcasts a loot table to council members, collects responses, then awards. Many fork hooks sit in this flow — especially in `Modules/VotingFrame.lua` (council side) and `ml_core.lua` (ML side).

### Candidate tracking (fork feature)

Upstream records only the winning candidate. Fork extends `Modules/History/History.lua` schema to record **all** candidate selections (who clicked what) plus gear item links. See `FORK_CHANGES.md` → "Track all candidate selections".

### Taint and secret values

WoW 11.x (Midnight client) introduced `issecretvalue` protection on many APIs. Fork must guard calls — see upstream commit `f28b0844` (Fix trade target retrieval issues caused by secret values) for the pattern upstream adopted.

## PR Conventions

This is an external repo — always preview PR title/body for user review before submitting. Keep tone casual and human.

## Parallel Feature Development (Worktrees)

Multiple features can be developed in parallel via `claude -w <branch>`. Each session gets its own worktree under `.claude/worktrees/` (gitignored). The AddOns symlink can only point to one branch at a time — re-point before `/reload` testing.
