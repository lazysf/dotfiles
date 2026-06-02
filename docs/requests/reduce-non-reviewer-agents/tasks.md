# Tasks

## 実装方針

`detailed-design.md` の `DD-001` から `DD-019` を、両 surface (`dot_claude/` / `dot_codex/`) の対称 path セットを 1 task = 1 単位とする粒度で分解する。順序は「(1) Phase 3 着手直前の commit hash 記録 (`DD-018`) -> (2) orchestrate / skill / scribe references の書き換え (`DD-002` から `DD-011`) -> (3) agent 物理削除 (`DD-001`) -> (4) ADR 新規作成・メタ更新 (`DD-015` から `DD-017`) -> (5) `docs/notes/` 追従 (`DD-012` から `DD-014`) -> (6) 検証 (`DD-019`)」とする。reference 側を agent 名から lead に書き換えてから agent file を削除することで、削除途中で停止しても runtime 発火しない安全状態を維持する (`detailed-design.md` Error Handling)。各 task で対応 `DD-*` / `REQ-*` / `AC-*`、変更境界、完了条件、確認方法を明示する。

## 実装タスク

- `TASK-001` (`DD-018` / `REQ-012` / `AC-010`): Phase 3 着手直前に `git log -1 --format=%H HEAD` で最新 commit hash を取得し、`basic-design.md` 末尾「未確認事項」直前に短い節として記録する。差分が detailed-design 対象行に影響する場合は `DD-002`〜`DD-014` の対象行番号を更新する。差分が Phase / Gate 構造に及ぶ場合は Phase 2 に差し戻す。
  - 変更境界: `docs/requests/reduce-non-reviewer-agents/basic-design.md`（必要時 `detailed-design.md`）。
  - 完了条件: commit hash 節が `basic-design.md` に記録され、行番号差分があれば `detailed-design.md` に反映済み。
  - 確認方法: `basic-design.md` を読み、commit hash が現行 HEAD と一致することを目視確認。

- `TASK-002` (`DD-002` / `DD-003` / `DD-004` / `BD-002` / `BD-003` / `REQ-003` / `REQ-004` / `REQ-006` / `AC-003` / `AC-004`): orchestrate tier reference (`full.md` / `standard.md` / `micro.md`) を Claude / Codex 両 surface で書き換える。各工程の `- agent:` を `lead` に統一し、進め方文を `detailed-design.md` `DD-002`〜`DD-004` の指定文へ置換。`repository maintenance` 工程を `Gate 3 前 docs 確認` 工程に置き換え、`agent: lead` / `扱い: 必要時` (micro は `任意`) と `lead が doc-followup skill を使う` 旨を書く。`repository-maintainer が blocked を返した場合` 行を削除。
  - 変更境界: `dot_claude/skills/orchestrate/references/{full,standard,micro}.md` と `dot_codex/skills/orchestrate/references/{full,standard,micro}.md`（計 6 ファイル）。
  - 完了条件: 6 ファイルすべてで削除対象 agent 名が `- agent:` 行から消え、`Gate 3 前 docs 確認` 工程が記述されている。両 surface 同名ファイル間で agent 列挙・工程構造が対称。
  - 確認方法: `Grep` で `architect|requirements-engineer|task-planner|implementer|repository-maintainer` を 6 ファイルに対し検索し 0 件。`diff` で両 surface 同名ファイルの工程構造差を目視。

- `TASK-003` (`DD-005` / `BD-005` / `REQ-009` / `AC-006`): orchestrate `handoff.md` を両 surface で書き換える。`Engineering Agent Output` 対象を `researcher` / `inspector` のみへ縮約、`Repository Maintenance Impact` block 全廃、`verifier_return_required` field **完全廃止**（Engineering Agent Output template 内の field 出力指示行も削除）、Rules 節の `verifier_return_required` / `Repository Maintenance Impact` 関連行も削除し、残る `repository-maintainer` 言及行は `detailed-design.md` `DD-005` の指定文へ置換。
  - 変更境界: `dot_claude/skills/orchestrate/references/handoff.md`、`dot_codex/skills/orchestrate/references/handoff.md`。
  - 完了条件: 両 surface で `Engineering Agent Output` 対象列挙が `researcher / inspector` のみ、`Repository Maintenance Impact` block が削除済み、`verifier_return_required` field が schema・Rules 共に 0 件。
  - 確認方法: 該当 2 ファイル目視 + `Grep` で `Repository Maintenance Impact` / `verifier_return_required` / `repository-maintainer` を 0 件確認。

- `TASK-004` (`DD-006` / `BD-002` / `BD-005` / `AC-003`): orchestrate `gate-review.md` の `repository-maintainer` / `repository maintenance` 主語表現を `lead が doc-followup で` / `Gate 3 前 docs 確認` 表現へ揃える。両 surface で対称適用。
  - 変更境界: `dot_claude/skills/orchestrate/references/gate-review.md`、`dot_codex/skills/orchestrate/references/gate-review.md`。
  - 完了条件: 両ファイルから `repository-maintainer` 文字列が消え、`lead が doc-followup` 表現に置換済み。
  - 確認方法: `Grep` で `repository-maintainer` を 2 ファイルに対し 0 件確認。

- `TASK-005` (`DD-007` / `DD-008` / `BD-002` / `BD-004` / `REQ-005` / `REQ-007` / `AC-005`): orchestrate `SKILL.md` を両 surface で更新。(a) line 26 の `repository-maintainer、docs follow-up、Gate fail 修正でもこの境界を維持する。` を `Gate 3 前 docs 確認、Gate fail 修正でもこの境界を維持する。` に書き換え、(b) 「自走と確認 checkpoint」セクション末尾に「要件 / 設計 / task / 実装 / 検証 artifact は lead が scribe skill を使って書く。format reference (scribe/references/*-format.md) は正本として変更しない。」の 1 行を追加。
  - 変更境界: `dot_claude/skills/orchestrate/SKILL.md`、`dot_codex/skills/orchestrate/SKILL.md`。
  - 完了条件: 両ファイルで該当書き換えと追記が反映済み。
  - 確認方法: 目視 + `Grep` で `repository-maintainer` を 2 ファイルに 0 件、`scribe skill` 追記 1 件確認。

- `TASK-006` (`DD-009` / `DD-010` / `DD-011` / `BD-006` / `REQ-007` / `AC-002`): skill description / scribe template 注釈の主語書き換え。(a) `implement/SKILL.md` description の `implementer` 主語を `lead` 主体へ、(b) `architecture/SKILL.md` description の `architect` 主語を `lead` 主体へ、(c) `scribe/references/implementation-format.md` template 注釈の `implementer が実行した確認` を `lead または inspector が実行した確認` へ書き換える。両 surface 対称。`scribe/references/*-format.md` の章立て・ID 規則・記述順は変更しない。
  - 変更境界: `dot_claude/skills/implement/SKILL.md`、`dot_codex/skills/implement/SKILL.md`、`dot_claude/skills/architecture/SKILL.md`、`dot_codex/skills/architecture/SKILL.md`、`dot_claude/skills/scribe/references/implementation-format.md`、`dot_codex/skills/scribe/references/implementation-format.md`（計 6 ファイル）。
  - 完了条件: 6 ファイルで削除対象 agent 主語が消え、format の章立て diff が空。
  - 確認方法: 目視 + `Grep` で `architect|implementer` 主語表現を 6 ファイルに対し 0 件確認。

- `TASK-007` (`DD-001` / `BD-001` / `REQ-001` / `REQ-002` / `AC-001` / `AC-009`): 削除対象 agent 定義 10 ファイルを物理削除する。
  - 変更境界: `dot_claude/agents/{architect,requirements-engineer,task-planner,implementer,repository-maintainer}.md`、`dot_codex/agents/{architect,requirements-engineer,task-planner,implementer,repository-maintainer}.toml`。
  - 完了条件: 10 ファイルすべてが存在しない。残置 agent は両 surface とも `{researcher, inspector, requirements-reviewer, design-reviewer, security-reviewer, quality-reviewer}` の 6 個。
  - 確認方法: `Glob` で両 surface agents ディレクトリを列挙し、basename 集合が完全一致 + 6 個であることを確認。

- `TASK-008` (`DD-015` / `BD-008` / `REQ-010` / `REQ-011` / `AC-007` / `AC-008`): 新規 ADR `docs/adr/0034-reduce-non-reviewer-agents.md` を `scribe/references/adr-format.md` に従って作成。`Status: Accepted` / `Supersedes: 0024, 0028`、本文は背景・決定・影響の 3 節で折衷案採用、isolation / constraint enforcement トレードオフ、`stop-lines.md` カタログ + skill 境界 + lead 停止線による代替を記述。
  - 変更境界: `docs/adr/0034-reduce-non-reviewer-agents.md`（新規）。
  - 完了条件: ファイルが存在し、`Supersedes: 0024, 0028` と代替戦略が読み取れる。
  - 確認方法: ファイル目視 + `Grep` で `Supersedes: 0024, 0028` を 1 件確認。

- `TASK-009` (`DD-016` / `DD-017` / `BD-008` / `REQ-010` / `AC-007`): 既存 ADR 0024 / 0028 のメタ更新。`Status: Accepted` -> `Status: Superseded`、直下に `Superseded-By: 0034` を追加。本文は変更しない。
  - 変更境界: `docs/adr/0024-add-repository-maintainer-agent.md`、`docs/adr/0028-align-agent-names-with-skill-pairs.md`。
  - 完了条件: 両 ADR の Status が `Superseded`、`Superseded-By: 0034` が追加済み、本文 diff が status / relationship メタのみ。
  - 確認方法: 目視 + `Grep` で `Superseded-By: 0034` を 2 ファイルに対し各 1 件確認。

- `TASK-010` (`DD-012` / `BD-007` / `REQ-008` / `AC-002`): `docs/notes/runtime-surface-guidance.md` を `DD-012` 指定箇所（line 18 / 35 / 42 / 79）で書き換え、ADR 0034 リンクを追記。
  - 変更境界: `docs/notes/runtime-surface-guidance.md`。
  - 完了条件: 該当 4 箇所が `DD-012` 指定文に置換済み、ADR 0034 リンク追加済み。
  - 確認方法: `Grep` で `repository-maintainer` を当該ファイルに対し 0 件、`0034-reduce-non-reviewer-agents` を 1 件確認。

- `TASK-011` (`DD-013` / `BD-007` / `REQ-008` / `AC-002`): `docs/notes/harness-design-principles.md` を `DD-013` 指定箇所（line 72 / 100）で書き換え、ADR 0034 リンク追記。
  - 変更境界: `docs/notes/harness-design-principles.md`。
  - 完了条件: 該当 2 箇所が `DD-013` 指定文に置換済み、ADR 0034 リンク追加済み。
  - 確認方法: `Grep` で `repository-maintainer` を当該ファイルに対し 0 件、`0034-reduce-non-reviewer-agents` を 1 件確認。

- `TASK-012` (`DD-014` / `BD-007` / `REQ-008` / `AC-002`): `docs/notes/harness-regression-checks.md` を `DD-014` 指定箇所（line 122 / 125 / 129 / 186 / 189 / 242 / 286 / 324）で書き換え、ADR 0034 リンク追記。`architecture` skill 名参照（line 228–230）は維持。
  - 変更境界: `docs/notes/harness-regression-checks.md`。
  - 完了条件: 該当箇所が `DD-014` 指定文に置換済み、ADR 0034 リンク追加済み、skill 名 `architecture` は維持。
  - 確認方法: `Grep` で `repository-maintainer` を当該ファイルに対し 0 件、`0034-reduce-non-reviewer-agents` を 1 件確認。

- `TASK-014` (`DD-020` / `BD-011` / `REQ-013` / `AC-011`): `dot_claude/CLAUDE.md` line 32 と `dot_codex/AGENTS.md` line 55 の `agents/` 説明文を `DD-020` 指定文へ書き換える。前後の枠付け文（lead spawn / main セッション進行 / skill 参照）は維持。
  - 変更境界: `dot_claude/CLAUDE.md`、`dot_codex/AGENTS.md`。
  - 完了条件: 両ファイルから `要件・設計・実装・検証・repository maintenance の各役と review 入口` / `調査・要件・設計・実装・検証・repository maintenance の各役と review 入口` が消え、`調査・検証の specialist と review 入口` 相当に置換済み。
  - 確認方法: `Grep` で `repository maintenance` を両ファイルに対し 0 件確認。

- `TASK-015` (`DD-021` / `BD-012` / `REQ-014` / `AC-012`): `dot_claude/agents/security-reviewer.md` の line 20 / 27 / 46、`dot_codex/agents/security-reviewer.toml` の line 13 / 19 / 29 を `DD-021` 指定文へ書き換える。役割節の `repository maintenance がある場合は...` 前提分岐、Gate 3 入力一覧、確認項目を lead + `doc-followup` 主体に整合させる。security-reviewer 自体の責務範囲（read-only review、stop-lines）は変更しない。
  - 変更境界: `dot_claude/agents/security-reviewer.md`、`dot_codex/agents/security-reviewer.toml`。
  - 完了条件: 両ファイルから `repository-maintainer` / `security_ci_impact` / `repository maintenance` が消え、`DD-021` 指定文に置換済み。
  - 確認方法: `Grep` で `repository-maintainer` / `security_ci_impact` / `repository maintenance` を両ファイルに対し 0 件確認。

- `TASK-016` (`DD-022` / `BD-012` / `REQ-014` / `AC-012`): `dot_claude/agents/quality-reviewer.md` の line 3 / 17 / 22 / 27 / 29 / 43 / 47 / 49 / 58、`dot_codex/agents/quality-reviewer.toml` の line 2 / 11 / 16 / 20 / 24 / 34（および対称な対応行）を `DD-022` 指定文へ書き換える。description / 役割節 / 入力節 / 進め方節 / 停止線節の `repository maintenance` 工程語前提依存、`repository-maintainer handoff` / `behavior_delta` / `quality_gate_impact` / `verifier_return_required` 参照を lead + `doc-followup` 主体に整合させる。quality-reviewer 自体の責務範囲（read-only review、`modified_artifacts: none`、`external_io: none`、stop-lines、Reviewer Execution Boundary）は変更しない。
  - 変更境界: `dot_claude/agents/quality-reviewer.md`、`dot_codex/agents/quality-reviewer.toml`。
  - 完了条件: 両ファイルから `repository-maintainer` / `repository maintenance` / `behavior_delta` / `quality_gate_impact` / `verifier_return_required` が消え、`DD-022` 指定文に置換済み。
  - 確認方法: `Grep` で `repository-maintainer` / `repository maintenance` / `behavior_delta` / `quality_gate_impact` / `verifier_return_required` を両ファイルに対し 0 件確認。

- `TASK-013` (`DD-019` / `BD-010` / `REQ-002` / `AC-001` / `AC-002` / `AC-009` / `AC-011` / `AC-012`): 全体検証。(1) `Glob` で両 surface agents の basename 集合一致を確認、(2) `Grep` で `architect\b|requirements-engineer|task-planner|implementer|repository-maintainer` を `-g '!docs/adr/**' -g '!docs/requests/reduce-non-reviewer-agents/**' -g '!docs/requests/agent-skill-name-pair-alignment/**' -g '!docs/requests/claude-orchestrate-tier-display/**'` 除外で検索し 0 件（`architect\b` 語境界で skill 名 `architecture` を除外）、(3) 両 surface tier reference の Phase / Gate / 工程名 / `扱い` 値を目視で対称確認、(4) `verifier_return_required` / `behavior_delta` / `quality_gate_impact` / `security_ci_impact` が `dot_claude/skills/` / `dot_codex/skills/` / `dot_claude/agents/` / `dot_codex/agents/` 配下で 0 件確認（除外対象は過去 request handoff のみ）、(5) `CLAUDE.md` / `AGENTS.md` / `{security,quality}-reviewer.{md,toml}` で AC-011 / AC-012 確認、`requirements-reviewer` / `design-reviewer` も同 grep が 0 件。結果を `test.md` に記録（inspector 経路）。
  - 変更境界: `docs/requests/reduce-non-reviewer-agents/test.md`（新規・inspector 担当）。
  - 完了条件: 上記 5 観測がすべて pass、test.md に記録済み。
  - 確認方法: test.md の記録確認。

## 実装順序

1. `TASK-001`: commit hash 取得・記録。前提整合確認。
2. `TASK-002`: tier reference (full / standard / micro) を両 surface で書き換える。
3. `TASK-003`: handoff.md 両 surface 書き換え。
4. `TASK-004`: gate-review.md 両 surface 書き換え。
5. `TASK-005`: orchestrate SKILL.md 両 surface 書き換え・追記。
6. `TASK-006`: implement / architecture / scribe template の主語書き換え。
7. `TASK-007`: agent 定義 10 ファイル削除。reference 側書き換え完了後に行うことで、削除中に停止しても runtime 発火しない安全状態を保つ。
8. `TASK-008`: 新規 ADR 0034 作成。
9. `TASK-009`: ADR 0024 / 0028 メタ更新。
10. `TASK-010`: `runtime-surface-guidance.md` 追従。
11. `TASK-011`: `harness-design-principles.md` 追従。
12. `TASK-012`: `harness-regression-checks.md` 追従。
13. `TASK-014`: `CLAUDE.md` / `AGENTS.md` 「置き場」節書き換え。
14. `TASK-015`: `security-reviewer.{md,toml}` 書き換え。
15. `TASK-016`: `quality-reviewer.{md,toml}` 書き換え。
16. `TASK-013`: 検証 (`inspector`)。

依存関係: `TASK-002`〜`TASK-006`、`TASK-015` / `TASK-016` は `TASK-007` より先（残置 agent 定義側の書き換え）。`TASK-008` は `TASK-009` より先（`Supersedes` 側を先に作成）。`TASK-010`〜`TASK-012` は `TASK-008` 完了後（ADR 0034 リンク追記のため）。`TASK-014` / `TASK-015` / `TASK-016` は他 task と独立で並列可能。`TASK-013` は全 task 後。同一ファイルを触る task は順序付け済みで競合なし。

## 変更境界

- `dot_claude/agents/{architect,requirements-engineer,task-planner,implementer,repository-maintainer}.md`（削除）
- `dot_codex/agents/{architect,requirements-engineer,task-planner,implementer,repository-maintainer}.toml`（削除）
- `dot_claude/skills/orchestrate/SKILL.md`、`dot_codex/skills/orchestrate/SKILL.md`
- `dot_claude/skills/orchestrate/references/{full,standard,micro,handoff,gate-review}.md`、`dot_codex/skills/orchestrate/references/{full,standard,micro,handoff,gate-review}.md`
- `dot_claude/skills/implement/SKILL.md`、`dot_codex/skills/implement/SKILL.md`
- `dot_claude/skills/architecture/SKILL.md`、`dot_codex/skills/architecture/SKILL.md`
- `dot_claude/skills/scribe/references/implementation-format.md`、`dot_codex/skills/scribe/references/implementation-format.md`
- `docs/notes/runtime-surface-guidance.md`、`docs/notes/harness-design-principles.md`、`docs/notes/harness-regression-checks.md`
- `docs/adr/0034-reduce-non-reviewer-agents.md`（新規）、`docs/adr/0024-add-repository-maintainer-agent.md`、`docs/adr/0028-align-agent-names-with-skill-pairs.md`
- `dot_claude/CLAUDE.md`、`dot_codex/AGENTS.md`（「置き場」節 `agents/` 説明文）
- `dot_claude/agents/security-reviewer.md`、`dot_codex/agents/security-reviewer.toml`（`repository-maintainer` / `repository maintenance` 参照箇所）
- `dot_claude/agents/quality-reviewer.md`、`dot_codex/agents/quality-reviewer.toml`（`repository-maintainer` / `repository maintenance` / `behavior_delta` / `quality_gate_impact` / `verifier_return_required` 参照箇所）
- `docs/requests/reduce-non-reviewer-agents/{basic-design.md,detailed-design.md,test.md,implementation.md}`

## Scope 外にしたこと

- `researcher` / `inspector` / reviewer 4 agent の責務・frontmatter・本文の再設計（`security-reviewer` と `quality-reviewer` の `repository-maintainer` / `repository maintenance` 参照箇所のみ最小修正）。
- `orchestrate` の Phase / Gate 構造そのものの再設計。
- skill (`requirements`、`architecture`、`task-planning`、`implement`、`doc-followup` 等) の手順本体の再設計。
- root `AGENTS.md` / `CLAUDE.md` / `dot_claude/rules/` / `dot_codex/rules/` / `.chezmoiignore` の改変。
- `dot_claude/CLAUDE.md` / `dot_codex/AGENTS.md` の `agents/` 説明文以外の節の改変。
- `scribe/references/*-format.md` の章立て・ID 規則・記述順の変更。
- ADR 0024 / 0028 本文の書き換え（status / relationship メタのみ変更）。

## リスク

- reference 書き換えと agent 削除の順序を誤ると片側 surface だけ runtime 上の発火条件が残る。`TASK-007` を `TASK-002`〜`TASK-006` の後に置き、削除途中で停止しても reference 側で参照されない安全状態を保つ。
- 片側 surface のみ更新する漏れ。`TASK-013` の `Glob` basename 集合 diff と `Grep` で両 surface 同時検出する。
- `verifier_return_required` field は本要求で完全廃止する。schema 互換破棄は ADR 0034 の superseded 関係で記録し、過去 request handoff の出現は `AC-002` 除外対象として履歴維持。
- ADR メタ更新の双方向整合崩れ。`TASK-008` 完了後 `TASK-009` で `Superseded-By: 0034` を揃え、`TASK-013` で双方向確認。
- detailed-design の対象行番号が Phase 3 着手時点の HEAD で変動している場合、書き換え対象行がずれる。`TASK-001` で commit hash 差分を確認し、行番号差分を `detailed-design.md` に反映してから後続 task に進む。

## 未確認事項

- Phase 3 着手時点の最新 `orchestrate` 構成 commit hash と researcher handoff 取得時点 commit hash の差分。`TASK-001` で吸収する。
- Gate 2 design / security review の指摘（FINDING-001、FINDING-002、NB-S03）を Phase 2 内で取り込んだ（`TASK-014` / `TASK-015` 追加、`TASK-003` の field 廃止反映、`TASK-013` の検証手順拡充）。Gate 2 再実施で確認する。
