# Fork Changes

[Compare upstream and fork](https://github.com/evil-morfar/RCLootCouncil2/compare/develop...andybergon:RCLootCouncil2:develop)

All changes made in this fork (`andybergon/RCLootCouncil2`) relative to upstream (`evil-morfar/RCLootCouncil2`).

| Feature | Status | Upstream | Fork | Notes |
|---------|--------|----------|------|-------|
| [Track all candidate selections](#track-all-candidate-selections) | Fork-only (WIP) | — | branch `feat/track-all-candidates` — [`5e89591a`](https://github.com/andybergon/RCLootCouncil2/commit/5e89591a) (2026-03-29), [`43542eec`](https://github.com/andybergon/RCLootCouncil2/commit/43542eec) (2026-03-31), [`8a355312`](https://github.com/andybergon/RCLootCouncil2/commit/8a355312) (2026-04-02) | History schema extension to record every candidate selection, not just the winner; plus gear item links. Still on feature branch, not merged to develop. |

This file and `CLAUDE.md` are also fork-only (project docs for Claude Code).

---

### Track all candidate selections

**Problem:** Upstream's loot history only records the winning candidate plus their response. Loot councils often want to review the full state of the voting frame at award time — who else was in the running, which items they had equipped, what response they picked — for post-raid analysis or disputes. That information is computed during a session but thrown away once the ML awards.

**Fix:** Three commits on `feat/track-all-candidates`:

1. **`5e89591a feat: track all candidate selections in loot history`** — extends the history record schema in `Modules/History/History.lua` to include a `candidates` table with per-candidate entries (name, class, response, roll, current gear slot links). Hooks the ML's award path to snapshot candidate state before the entry is written.

2. **`43542eec fix: capture candidates on council member side, not just ML`** — initial version only captured on the ML's client. Extended to council members by hooking the voting-frame-level events. Ensures everyone's history records the same candidate snapshot, not just whoever happened to be the ML.

3. **`8a355312 fix: cache voting frame data for non-ML candidate capture + store gear item links`** — on the council side, the voting frame's internal tables can get torn down before the history write happens. Fix caches the candidate data at session start so it survives frame cleanup. Also adds gear item links (as opposed to just item IDs) so the history view can show tooltips.

**Status:** Not yet opened as a PR upstream. Deliberate scope decision — upstream may not want the schema expansion, so keeping it fork-only until it's proven useful in practice.

**Files changed:** `Modules/History/History.lua`, `Modules/VotingFrame.lua`, `ml_core.lua`.
