# 0040: orchestrate 時代の判断を一括退役する

- Status: Accepted
- Supersedes: 0020, 0023, 0027, 0033, 0034

ADR 0035 / 0036 で両 surface を軽量 LLM-native へ再設計した結果、`orchestrate` / `grill` / `architecture` / `implement` / `inspect` / `doc-followup` skill、`inspector` / `requirements-reviewer` / `design-reviewer` / `analyst` / `requirements-engineer` / `architect` / `task-planner` / `developer` / `verifier` / `repository-maintainer` agent、tier / Phase / Gate / request folder / SDLC artifact / traceability ID 体系は両 surface とも廃止された。現行構成は [docs/notes/lightweight-workflow.md](../notes/lightweight-workflow.md) を正本とする。

これにより次の ADR の判断は前提を失った。0036 本文の `Supersedes` リストは作成時点で明示されたものに限ったため、これらを補完する目的で本 ADR を起こす。

- **0020** (Claude SDLC workflow を Codex に逆輸入): import 対象の `orchestrate` skill、Phase 0〜3 / Gate 1〜3、request folder、specialist agent 群はすべて廃止。
- **0023** (`doc-followup` skill を追加): `doc-followup` skill は廃止。docs 追従の必要性判定は `scribe` SKILL.md「## doc 要否（silent skip 禁止）」に集約された。
- **0027** (Codex skill 名を Claude 基準に揃える): rename 対象の `implement` / `inspect` skill 自体が廃止された。両 surface 対称の原則は ADR 0036 で改めて確立されている。
- **0033** (`orchestrate` workflow agent 起動を事前許可): `orchestrate` skill 自体が廃止。read-only specialist agent (`researcher` / `quality-reviewer` / `security-reviewer`) の standing authorization は `dot_codex/AGENTS.md` / `dot_claude/CLAUDE.md` と root `AGENTS.md` に引き継ぎ済みで、本質は失われていない。
- **0034** (non-reviewer agent を researcher / inspector のみへ集約): `inspector` agent は廃止、現行の non-reviewer agent は `researcher` のみ。reviewer も 2 種（`quality-reviewer` / `security-reviewer`）に縮約された。

本 ADR は台帳状態の補正のみで、新たな判断は加えない。各 ADR 本文は履歴として保持する（ADR 0022）。
