# Implementation

## 対応タスク / 対応範囲

- `TASK-001` (`DD-018` / `REQ-012` / `AC-010`): Phase 3 着手直前の commit hash `909858230f70ffdc4f674c6c1e485a60ab1952aa` を `basic-design.md` 末尾「未確認事項」直前に記録。detailed-design `DD-002`〜`DD-014` の対象行番号は本 hash 時点の構成で確認済み、行番号差分なし。
- `TASK-002` (`DD-002` / `DD-003` / `DD-004`): orchestrate tier reference `full.md` / `standard.md` / `micro.md` を両 surface で書き換え。削除対象 agent 名を `lead` に統一、進め方を skill 直叩き表現に置換、`repository maintenance` 工程を `Gate 3 前 docs 確認` に置き換え、`repository-maintainer が blocked を返した場合` 行を削除。
- `TASK-003` (`DD-005` / `REQ-009` / `AC-006`): orchestrate `handoff.md` を両 surface で書き換え。`Engineering Agent Output` 対象を `researcher` / `inspector` のみへ縮約、`Repository Maintenance Impact` block 全廃、`verifier_return_required` field 完全廃止、Rules 節の関連行 3 行を 1 行に整合書き換え。
- `TASK-004` (`DD-006`): orchestrate `gate-review.md` の Gate 3 Pass 条件節を両 surface で書き換え。`repository-maintainer` / `repository maintenance` 主語を `lead が doc-followup` / `Gate 3 前 docs 確認` 表現に置換。
- `TASK-005` (`DD-007` / `DD-008` / `AC-005`): orchestrate `SKILL.md` を両 surface で更新。`Request Artifact 境界` 節の `repository-maintainer` 言及を `Gate 3 前 docs 確認` に書き換え、「自走と確認 checkpoint」末尾に「要件 / 設計 / task / 実装 / 検証 artifact は lead が scribe skill を使って書く」の 1 行を追加。
- `TASK-006` (`DD-009` / `DD-010` / `DD-011`): `implement/SKILL.md` description の `implementer` 主語、`architecture/SKILL.md` description の `architect` 主語、`scribe/references/implementation-format.md` line 40 の `implementer が実行した確認` を `lead`/`lead または inspector` 主体へ書き換え。Claude 側 4 ファイルが対象、Codex 側 `implement/SKILL.md` / `architecture/SKILL.md` は既に lead 主体表現なので変更不要、`scribe/references/implementation-format.md` のみ書き換え。
- `TASK-007` (`DD-001` / `AC-001` / `AC-009`): 両 surface の agent 定義 10 ファイル (`architect` / `requirements-engineer` / `task-planner` / `implementer` / `repository-maintainer` × `.md` + `.toml`) を物理削除。残置は両 surface とも `{researcher, inspector, requirements-reviewer, design-reviewer, security-reviewer, quality-reviewer}` の 6 個。
- `TASK-008` (`DD-015` / `AC-007` / `AC-008`): 新規 ADR `docs/adr/0034-reduce-non-reviewer-agents.md` を作成。`Status: Accepted`、`Supersedes: 0024, 0028`、背景 / 決定 / 影響の 3 節構成。constraint enforcement 喪失と `stop-lines.md` カタログ + skill 境界 + lead 自走停止線による代替戦略を本文に記載。`docs/README.md` ADR 一覧にも追加。
- `TASK-009` (`DD-016` / `DD-017`): ADR 0024 / 0028 の `Status: Accepted` を `Status: Superseded` に変更、直下に `Superseded-By: 0034` を追加。本文は変更なし。
- `TASK-010` (`DD-012`): `docs/notes/runtime-surface-guidance.md` の line 18 / 35 / 42 を `DD-012` 指定文に書き換え、line 79 直下に ADR 0034 リンクを追記。
- `TASK-011` (`DD-013`): `docs/notes/harness-design-principles.md` の line 72 を `DD-013` 指定文に書き換え、line 100 直下に ADR 0034 リンクを追記。
- `TASK-012` (`DD-014`): `docs/notes/harness-regression-checks.md` の line 122 / 125 / 129 / 186 / 189 / 242 / 286 を `DD-014` 指定文に書き換え、line 324 直下に ADR 0034 リンクを追記。skill 名 `architecture` への言及（line 228-230）は維持。
- `TASK-014` (`DD-020`): `dot_claude/CLAUDE.md` line 32 と `dot_codex/AGENTS.md` line 55 の `agents/` 説明文を 6 agent 構成 (`調査・検証の specialist と review 入口`) に書き換え。
- `TASK-015` (`DD-021`): `dot_claude/agents/security-reviewer.md` の line 20 / 27 / 46 と対応する `dot_codex/agents/security-reviewer.toml` 行を `DD-021` 指定文に書き換え。`repository-maintainer` / `security_ci_impact` / `repository maintenance` を除去し、lead + `doc-followup` 主体に整合。
- `TASK-016` (`DD-022`): `dot_claude/agents/quality-reviewer.md` の description / 役割節 / 入力節 / 進め方節 / 停止線節と対応する `dot_codex/agents/quality-reviewer.toml` 行を `DD-022` 指定文に書き換え。`repository-maintainer` / `behavior_delta` / `quality_gate_impact` / `verifier_return_required` / `repository maintenance` を除去し、lead + `doc-followup` 主体に整合。
- `TASK-013` は別 agent (`inspector`) が検証する範囲のため、本 handoff では実装報告のみ。

## 変更内容

- 削除対象 5 種 agent 定義の物理削除を両 surface で対称適用し、残置 agent を 6 種 (`researcher` / `inspector` / reviewer 4 種) に揃えた。
- orchestrate tier reference 3 種 (`full` / `standard` / `micro`) の各工程 `agent:` 行を `lead` に統一し、進め方を「lead が `<skill>` skill を使う」表現に置換。`repository maintenance` 工程を `Gate 3 前 docs 確認` (lead が `doc-followup`) に置き換え。
- handoff schema から `Repository Maintenance Impact` block を完全削除し、`verifier_return_required` field を schema・Rules 共に廃止。`Engineering Agent Output` 対象を `researcher` / `inspector` のみへ縮約。
- gate-review.md の Gate 3 Pass 条件を「lead が `doc-followup` で行った確認結果」「全変更セット」表現に整合させた。
- orchestrate SKILL.md に lead + `scribe` による artifact 作成主体を明文化する 1 行を追加。
- implement / architecture / scribe template の主語表現を lead 主体に揃え、`scribe/references/*-format.md` の章立て・ID 規則・記述順は維持。
- ADR 0034 を新規追加し、ADR 0024 / 0028 を `Superseded` に変更。双方向の `Supersedes` / `Superseded-By` メタを整合。`docs/README.md` ADR 一覧にも 0034 を追記。
- `docs/notes/{runtime-surface-guidance,harness-design-principles,harness-regression-checks}.md` の関連箇所を lead + `doc-followup` 表現に追従更新し、ADR 0034 リンクを各関連文書に追記。
- `dot_claude/CLAUDE.md` / `dot_codex/AGENTS.md` の `agents/` 説明文を 6 agent 構成に整合。
- `security-reviewer` / `quality-reviewer` 両 surface の `repository-maintainer` / `repository maintenance` / `security_ci_impact` / `behavior_delta` / `quality_gate_impact` / `verifier_return_required` 参照を除去し、Gate 3 入力 / 役割節 / 進め方節 / 停止線節を lead + `doc-followup` 主体に整合。reviewer 自体の責務範囲（read-only review、`modified_artifacts: none`、`external_io: none`、Reviewer Execution Boundary、停止線）は変更なし。

## 変更ファイル

削除 (10 ファイル):

- `dot_claude/agents/architect.md`
- `dot_claude/agents/requirements-engineer.md`
- `dot_claude/agents/task-planner.md`
- `dot_claude/agents/implementer.md`
- `dot_claude/agents/repository-maintainer.md`
- `dot_codex/agents/architect.toml`
- `dot_codex/agents/requirements-engineer.toml`
- `dot_codex/agents/task-planner.toml`
- `dot_codex/agents/implementer.toml`
- `dot_codex/agents/repository-maintainer.toml`

新規 (1 ファイル):

- `docs/adr/0034-reduce-non-reviewer-agents.md`

編集 (orchestrate tier / SKILL / handoff / gate-review 計 12 ファイル):

- `dot_claude/skills/orchestrate/SKILL.md`
- `dot_codex/skills/orchestrate/SKILL.md`
- `dot_claude/skills/orchestrate/references/full.md`
- `dot_codex/skills/orchestrate/references/full.md`
- `dot_claude/skills/orchestrate/references/standard.md`
- `dot_codex/skills/orchestrate/references/standard.md`
- `dot_claude/skills/orchestrate/references/micro.md`
- `dot_codex/skills/orchestrate/references/micro.md`
- `dot_claude/skills/orchestrate/references/handoff.md`
- `dot_codex/skills/orchestrate/references/handoff.md`
- `dot_claude/skills/orchestrate/references/gate-review.md`
- `dot_codex/skills/orchestrate/references/gate-review.md`

編集 (implement / architecture / scribe 計 4 ファイル + Codex 側 1 ファイル):

- `dot_claude/skills/implement/SKILL.md`
- `dot_claude/skills/architecture/SKILL.md`
- `dot_claude/skills/scribe/references/implementation-format.md`
- `dot_codex/skills/scribe/references/implementation-format.md`
- (Codex 側 `implement/SKILL.md` / `architecture/SKILL.md` は既存 description に `implementer` / `architect` の主語表現がなく、書き換え不要を確認)

編集 (ADR メタ更新 2 ファイル + README 1 ファイル):

- `docs/adr/0024-add-repository-maintainer-agent.md`
- `docs/adr/0028-align-agent-names-with-skill-pairs.md`
- `docs/README.md`

編集 (docs/notes 追従 3 ファイル):

- `docs/notes/runtime-surface-guidance.md`
- `docs/notes/harness-design-principles.md`
- `docs/notes/harness-regression-checks.md`

編集 (CLAUDE.md / AGENTS.md 「置き場」節 2 ファイル):

- `dot_claude/CLAUDE.md`
- `dot_codex/AGENTS.md`

編集 (reviewer agent 4 ファイル):

- `dot_claude/agents/security-reviewer.md`
- `dot_codex/agents/security-reviewer.toml`
- `dot_claude/agents/quality-reviewer.md`
- `dot_codex/agents/quality-reviewer.toml`

編集 (request folder):

- `docs/requests/reduce-non-reviewer-agents/basic-design.md` (`TASK-001`: commit hash 節追加)
- `docs/requests/reduce-non-reviewer-agents/implementation.md` (本ファイル)

## Scope 外

- `researcher` / `inspector` / reviewer 4 agent の責務再設計は行わない。`security-reviewer` / `quality-reviewer` への変更は `DD-021` / `DD-022` で明示された箇所のみで、責務範囲・編集権限・Reviewer Execution Boundary は維持。
- `orchestrate` の Phase / Gate 構造の再設計は行わない。tier reference の Phase / Gate セクション順、Notes 節、Tier Map 表は変更なし。
- skill 本体 (`requirements`、`architecture`、`task-planning`、`implement`、`doc-followup` 等) の手順本文は変更なし。description / template 注釈のみ書き換え。
- `scribe/references/*-format.md` の章立て・ID 規則・記述順は変更なし。`implementation-format.md` は line 40 のみ書き換え。
- ADR 0024 / 0028 本文は履歴として保持。status / relationship メタのみ変更。
- root `AGENTS.md` / `CLAUDE.md` / `dot_claude/rules/` / `dot_codex/rules/` / `.chezmoiignore` は変更なし。
- `dot_claude/CLAUDE.md` / `dot_codex/AGENTS.md` の `agents/` 説明文以外の節は変更なし。
- `dot_claude/settings.json` は requirements / detailed-design 共に対象範囲に明示されておらず、本実装では touch していない。詳細は「実装中に判明した事項」「未確認事項」を参照。

## 実装中に判明した事項

- `dot_claude/settings.json` の `permissions.allow` リストに、削除した agent 5 種への `Agent(...)` permission descriptor が残っている (`Agent(architect)`、`Agent(implementer)`、`Agent(repository-maintainer)`、`Agent(requirements-engineer)`、`Agent(task-planner)`)。これは `AC-002` の grep pattern (`architect\b|requirements-engineer|task-planner|implementer|repository-maintainer`) でヒットする。requirements / detailed-design / tasks のいずれも settings.json を対象範囲に含めていないため、本実装では touch していない。
- `dot_claude/skills/orchestrate/references/full.md` Gate 3 完了レビュー進め方文中の「repository maintenance 後の全変更セット」表現、`standard.md` Notes 節 line 128 の「repository maintenance handoff」表現、`runtime-surface-guidance.md` line 12 / line 22 の「repository maintenance」工程語ベース表現は、`DD-002`〜`DD-014` の指示行に含まれていない。creative writing を避け制約「detailed-design.md の指示文をそのまま書き換え後文言として使う」に従い、これらは書き換えていない。`AC-002` grep pattern は `repository-maintainer` のハイフン形式のみ対象のため当該表現はヒットしない。
- Codex 側 `implement/SKILL.md` / `architecture/SKILL.md` description は既に lead 主体表現で、`implementer` / `architect` の主語が無く、`DD-009` / `DD-010` の対称適用は不要であることを確認した。

## 実行した確認

- 全 task 完了直後に `rg -n 'architect\b|requirements-engineer|task-planner|implementer|repository-maintainer' dot_claude dot_codex docs/notes docs/README.md` を実行。ヒットは以下のみで、いずれも `AC-002` validation 上の妥当な残置:
  - `docs/README.md:40` および `docs/notes/{runtime-surface-guidance,harness-design-principles,harness-regression-checks}.md` の `ADR 0024-add-repository-maintainer-agent.md` リンク (ADR file 名は履歴として保持、ADR 0034 link 追記済み)。
  - `dot_claude/settings.json` の `Agent(architect)` / `Agent(implementer)` / `Agent(repository-maintainer)` / `Agent(requirements-engineer)` / `Agent(task-planner)` (5 行)。Scope 外のため未対応。
- `rg -n 'verifier_return_required|behavior_delta|quality_gate_impact|security_ci_impact|Repository Maintenance Impact' dot_claude dot_codex docs/notes` で 0 件確認 (handoff schema field / block の完全廃止が完了)。
- 両 surface agent ディレクトリの basename 集合が `{design-reviewer, inspector, quality-reviewer, requirements-reviewer, researcher, security-reviewer}` の 6 個ずつで完全一致することを `ls dot_claude/agents/ dot_codex/agents/` で確認 (`AC-001` / `AC-009`)。
- Phase 3 着手直前の commit hash `909858230f70ffdc4f674c6c1e485a60ab1952aa` を `git log -1 --format=%H HEAD` で取得し、basic-design.md 末尾に記録 (`AC-010`)。

最終的な test / lint / build は `inspector` (`TASK-013`) に委ねる。

## 未確認事項

- **`dot_claude/settings.json` の Agent permission allowlist 残置**: 削除した 5 種 agent への `Agent(...)` permission descriptor (line 18 / 20 / 23 / 24 / 28) が残置。これは requirements / detailed-design / tasks の対象範囲に明示されていないため Scope 外と判断し未対応とした。ただし `AC-002` grep には 5 件としてヒットする。settings.json は権限 (permissions.allow) 設定のため、CLAUDE.md 共通契約の停止線「認証認可、権限、秘密情報、本番設定、セキュリティ上重要な処理に触れる」に該当しうる。lead 判断で (a) Scope に追加して別 task として削除、(b) `AC-002` 観測の除外パスに追加、(c) 別 request で扱う、のいずれかを選ぶ必要がある。機能的には削除済 agent への許可なので無効化されているが、permission descriptor 一覧の正確性と将来 agent 再追加時の予期せぬ自動許可リスクを考えると (a) が望ましい。
- 検証 (`TASK-013`) を `inspector` に委ねる必要がある。`AC-001`〜`AC-012` の最終観測と `test.md` 作成は inspector 経路。
- chezmoi 配布動作確認は範囲外。
