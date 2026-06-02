# Requirements

## 目的

Claude / Codex 両 surface で、reviewer 以外の non-reviewer agent (`architect`、`requirements-engineer`、`task-planner`、`implementer`、`repository-maintainer`) を削除し、`researcher` + `inspector` + reviewer 4 種 = 6 agent 体制へ移行する。lead 一貫で要件 / 設計 / task / 実装を進め、isolation が要る調査・検証だけ subagent に渡す折衷案を運用に落とす。

## 背景 / 課題

- 現状は両 surface に reviewer 4 + non-reviewer 7 = 11 agent が存在し、要件〜実装の各工程が subagent に分割されている。
- subagent 化のメリットは (a) isolation: 中間出力の context window 隔離、(b) constraint enforcement: frontmatter / 本文での機械的な権限制限、の 2 つに整理した。
- 要件〜設計〜実装は lead 一貫で持つほうが handoff loss が小さい一方、`researcher` / `inspector` は中間出力（grep、log）が大きいため isolation を維持すべきと判断した。reviewer は独立批判視点として agent 形態を残す。
- 別セッションで `orchestrate` workflow がブラッシュアップ済み（stop-line catalog 統合等）であり、最新の reference 構成に合わせて参照書き換えが必要。
- 削除により `implementer` / `repository-maintainer` が担っていた機械的な constraint enforcement が失われるため、停止線運用の代替を明示する必要がある。

## Scope

- 両 surface (`dot_claude/agents/`、`dot_codex/agents/`) から削除対象 5 agent ファイル（計 10 ファイル）を削除する。
- `orchestrate` skill の `SKILL.md` および tier reference (`full.md` / `standard.md` / `micro.md`)、`handoff.md`、`gate-review.md` から削除対象 agent への参照を取り除き、lead + skill 直叩きの記述に置き換える。
- `implement` / `architecture` skill の description、`scribe/references/implementation-format.md` 等で削除対象 agent を名指ししている箇所を更新する。
- `docs/notes/runtime-surface-guidance.md`、`docs/notes/harness-regression-checks.md`、`docs/notes/harness-design-principles.md` の関連記述を追従更新する。
- `dot_claude/CLAUDE.md`「置き場」節、`dot_codex/AGENTS.md`「置き場」節の `agents/` 説明文を 6 agent 構成に整合する語り口へ更新する。
- 残置する `security-reviewer` および `quality-reviewer` agent 定義（`dot_claude/agents/{security,quality}-reviewer.md` / `dot_codex/agents/{security,quality}-reviewer.toml`）から、削除対象 `repository-maintainer` への参照（Gate 3 入力一覧、`security_ci_impact` 参照、`behavior_delta` / `quality_gate_impact` 参照、description、`verifier_return_required` 参照）と工程語 `repository maintenance` への前提依存記述を除去し、lead + `doc-followup` 主体の運用に整合させる。
- 今回の判断（折衷案採用、isolation / constraint enforcement トレードオフ）を新規 ADR に記録し、ADR 0024 / 0028 を superseded として関係付ける。
- 残置 agent は両 surface とも `researcher`、`inspector`、`requirements-reviewer`、`design-reviewer`、`security-reviewer`、`quality-reviewer` の 6 個に揃える。

## Non-Scope

- `researcher` / `inspector` / reviewer 4 agent 自体の責務、frontmatter、本文ロジックの再設計。参照する skill / handoff 仕様の整合確認に伴う最小修正は含むが、機能変更は行わない。
- `orchestrate` の Phase / Gate 構造自体の再設計。agent 名置換に伴う表現調整の範囲を超える構造変更は本要求では扱わない。
- skill (`requirements`、`architecture`、`task-planning`、`implement`、`doc-followup` 等) の手順本体の再設計。agent 名参照の除去や境界記述の整合に限定する。
- 新規 skill の追加、既存 skill の責務移し替え。
- root `AGENTS.md` / `CLAUDE.md` / `dot_claude/rules/` / `dot_codex/rules/` / `.chezmoiignore` の改変（researcher 確認の通り削除対象 agent への参照なし）。
- `dot_claude/CLAUDE.md` / `dot_codex/AGENTS.md` のうち、`agents/` 説明文以外の節、および `security-reviewer` agent 定義のうち `repository-maintainer` 参照箇所以外の節の改変。

## 要求事項

- `REQ-001`: 両 surface の `agents/` 配下から、削除対象 5 種（`architect`、`requirements-engineer`、`task-planner`、`implementer`、`repository-maintainer`）の agent 定義ファイルを削除する。
- `REQ-002`: 両 surface とも残置 agent が `researcher`、`inspector`、`requirements-reviewer`、`design-reviewer`、`security-reviewer`、`quality-reviewer` の 6 個に揃い、surface 間で agent 名・責務が対称である。
- `REQ-003`: `orchestrate/SKILL.md` および `references/full.md` / `standard.md` / `micro.md` / `handoff.md` / `gate-review.md` から、削除対象 agent への参照を取り除き、該当工程は lead が対応 skill を直接呼び出す記述に置き換える。
- `REQ-004`: micro tier の "lead が直接実装。必要なら implementer か該当 skill" 相当の記述から `implementer` 並列言及を除去し、lead + skill のみの表現に揃える。
- `REQ-005`: 要件 / 設計 / task / 実装 / 検証の artifact 作成主体を、lead が `scribe` skill を用いて担う運用として明文化する。各 artifact の format reference (`scribe/references/*-format.md`) はそのまま正本として維持する。
- `REQ-006`: `repository-maintainer` が担っていた "Gate 3 前の docs / 参照ずれ確認" は、lead が `doc-followup` skill を必要時に直接呼び出す運用に移行することを `orchestrate` reference 上で明示する。
- `REQ-007`: `implement/SKILL.md`、`architecture/SKILL.md`、`scribe/references/implementation-format.md` の description / 本文から、削除対象 agent を主語にする記述を取り除き、lead + skill 表現へ統一する。
- `REQ-008`: `docs/notes/runtime-surface-guidance.md`、`docs/notes/harness-regression-checks.md`、`docs/notes/harness-design-principles.md` のうち削除対象 agent を参照している箇所を、6 agent 構成に整合する記述へ更新する。
- `REQ-009`: handoff template (`orchestrate/references/handoff.md`) の "Engineering Agent Output" 一覧と "Repository Maintenance Impact" block を、残置 agent (researcher / inspector / reviewer 4) と lead 主体の運用に合わせて再整理する。`Repository Maintenance Impact` block と `verifier_return_required` field は廃止し、Rules 節の関連記述も整合的に除去する。
- `REQ-013`: `dot_claude/CLAUDE.md`「置き場」節と `dot_codex/AGENTS.md`「置き場」節の `agents/` 説明文から、削除対象 agent の役割語（要件・設計・実装・repository maintenance の各役）を取り除き、6 agent 構成（調査・検証 + reviewer 4）に整合する語り口へ書き換える。
- `REQ-014`: `dot_claude/agents/{security,quality}-reviewer.md` および `dot_codex/agents/{security,quality}-reviewer.toml` から、`repository-maintainer` への参照（Gate 3 入力一覧、`security_ci_impact` 参照、`behavior_delta` / `quality_gate_impact` 参照、description、`verifier_return_required` 参照）と、`repository maintenance` 工程語への前提依存記述（役割節の "repository maintenance がある場合は..." 分岐、入力節 / 進め方節 / 停止線節の "repository maintenance 後の全変更セット" 等）を除去し、lead が `doc-followup` で観測した結果 + 全変更セットを Gate 3 reviewer が確認する記述に置き換える。security-reviewer / quality-reviewer 自体の責務範囲は変えない。
- `REQ-010`: 今回の判断（折衷案採用、isolation 維持 / constraint enforcement 喪失のトレードオフ、削除 5 agent と残置 6 agent の選択）を新規 ADR として記録し、ADR 0024（add-repository-maintainer-agent）および ADR 0028（align-agent-names-with-skill-pairs）を superseded 関係としてメタデータ上で結ぶ。
- `REQ-011`: 削除により失われる `implementer` / `repository-maintainer` の機械的な constraint enforcement の代替が、`orchestrate/references/stop-lines.md` カタログ + 各 skill 境界記述 + lead の自走停止線で賄われる旨を ADR またはそれが参照する reference 上で明示する。
- `REQ-012`: 着手前に最新の `orchestrate` workflow 構成（最新 commit に取り込まれた stop-line catalog 統合を含む）を取得し、本要求の対象 reference / 行数の前提を再確認する。

## 受入条件

- `AC-001` (REQ-001 / REQ-002): `dot_claude/agents/` と `dot_codex/agents/` を一覧した結果、両 surface とも残置 6 agent のファイルのみが存在し、削除対象 5 種に対応するファイルが存在しない。
- `AC-002` (REQ-001 / REQ-003 / REQ-007 / REQ-008): repo 全体を対象に `architect` / `requirements-engineer` / `task-planner` / `implementer` / `repository-maintainer` の文字列を検索し、agent への参照として残っている箇所がない（ADR 履歴本文での過去経緯記述、本 request folder 配下の artifact、変更履歴系を除く）。
- `AC-003` (REQ-003 / REQ-006): `orchestrate/references/full.md` / `standard.md` / `micro.md` のいずれにも削除対象 agent 名が現れず、各工程の主体が lead + skill 直叩きで一貫して記述されている。Gate 3 前の docs 整備が `doc-followup` 経路で説明されている。
- `AC-004` (REQ-004): `orchestrate/references/micro.md` 内の lead 実装に関する記述に `implementer` への並列言及が含まれていない。
- `AC-005` (REQ-005): `orchestrate` reference 群のいずれかに、要件 / 設計 / task / 実装 / 検証 artifact を lead が `scribe` で書く方針が明記されている。`scribe/references/*-format.md` の章立て・ID 規則は変更されていない。
- `AC-006` (REQ-009): `orchestrate/references/handoff.md` の "Engineering Agent Output" 一覧が残置 agent のみで構成され、"Repository Maintenance Impact" block と `verifier_return_required` field が整合的に除去され、Rules 節の関連記述も残らない。
- `AC-007` (REQ-010): 新規 ADR が `docs/adr/` に追加され、status / superseded 関係メタデータが ADR 0024 / 0028 と双方向に整合している（0024 / 0028 側にも superseded-by メタが入る）。
- `AC-008` (REQ-011): 新規 ADR またはそれが参照する reference 上で、削除によって失われる constraint enforcement と、`stop-lines.md` カタログ + skill 境界 + lead 停止線による代替手段の対応が読み取れる。
- `AC-009` (REQ-002): Claude / Codex 両 surface で agent 名集合が一致し、片側のみに残っている agent ファイルが存在しない。
- `AC-010` (REQ-012): 実装着手前に取得した最新 `orchestrate` 構成に基づき、本要件・後続設計の参照行・対象ファイル一覧が再確認されている（researcher handoff の行番号が現行 HEAD と一致するか、差分がある場合は設計に反映されている）。
- `AC-011` (REQ-013): `dot_claude/CLAUDE.md`「置き場」節と `dot_codex/AGENTS.md`「置き場」節を grep し、削除対象 agent の役割語（特に `repository maintenance`）が agent 集合説明として残っていない。
- `AC-012` (REQ-014): `dot_claude/agents/{security,quality}-reviewer.md` および `dot_codex/agents/{security,quality}-reviewer.toml` を grep し、`repository-maintainer` / `security_ci_impact` / `behavior_delta` / `quality_gate_impact` / `verifier_return_required` / `repository maintenance` への参照が残っていない。security-reviewer / quality-reviewer の Gate 3 入力記述、役割節、進め方節、停止線節が lead + `doc-followup` 主体に整合している。

## 制約

- 編集対象は本 request folder (`docs/requests/reduce-non-reviewer-agents/`) 配下の artifact、削除対象 agent ファイル、`orchestrate` / `implement` / `architecture` / `scribe` 配下の該当 reference、`docs/notes/` の該当 3 ファイル、`dot_claude/CLAUDE.md`「置き場」節と `dot_codex/AGENTS.md`「置き場」節の `agents/` 説明文、`dot_claude/agents/{security,quality}-reviewer.md` と `dot_codex/agents/{security,quality}-reviewer.toml` の `repository-maintainer` / `repository maintenance` 参照箇所、新規 ADR、および ADR 0024 / 0028 のメタデータ更新に限定する。
- Claude / Codex 両 surface を同期して更新する。片側のみの更新は不可。
- `scribe/references/*-format.md` の章立て・ID 規則・記述順は維持する。本要求では正本としての format を変えない。
- 既存 ADR 本文は上書きせず、新規 ADR と status / superseded 関係メタデータで履歴を表現する。
- 公開挙動（agent 名集合、orchestrate workflow の対外的記述、surface 間対称性）に影響するため、変更前に最新構成を再取得し前提ずれがないことを確認する。
- secret / auth / 外部 I/O / 破壊的操作の停止線は維持する。constraint enforcement の代替が `stop-lines.md` + skill 境界 + lead 停止線に依存する点を ADR で明示する。
- ID は `REQ-*` / `AC-*` のみ採番し、設計・task・実装は本 artifact で決めない。

## 前提

- researcher handoff により削除対象 / 残置 / 書き換え対象ファイルと現状の参照箇所が特定済み。Gate 2 design review で `dot_claude/CLAUDE.md` / `dot_codex/AGENTS.md` / `dot_claude/agents/{security,quality}-reviewer.md` / `dot_codex/agents/{security,quality}-reviewer.toml` への参照漏れが追加発見されたため、REQ-013 / REQ-014 / AC-011 / AC-012 / 制約 / Scope に追加反映済み。`requirements-reviewer` / `design-reviewer` は grep clean。最新 commit 取得後に行番号差分の再確認は引き続き要る（REQ-012 / AC-010）。
- root `AGENTS.md` / `CLAUDE.md` / `dot_claude/rules/` / `dot_codex/rules/` / `.chezmoiignore` には削除対象 agent への参照がない（researcher 確認済み）。
- `researcher` / `inspector` / reviewer 4 agent は本要求の Scope 内では責務再設計を行わず、参照整合確認のみ実施する。
- 折衷案（reviewer 4 + `researcher` + `inspector`）の採用方針はユーザー確認済み。

## 未確認事項

- `orchestrate/references/full.md` の Phase 1 / 2 / 3 工程記述について、agent 名置換だけで十分か、Phase 構造の語り口（例: "engineering agent" 集合の括り方）まで踏み込むかは設計フェーズで判断する必要がある。
- handoff template の "Repository Maintenance Impact" block と `verifier_return_required` field は廃止する方針で確定（Gate 2 design review FINDING-002 解消）。Rules 節の関連記述も整合的に除去する。
- `researcher` / `inspector` agent 定義側に、参照する skill / handoff 仕様の更新に伴う追従修正が必要かは、最新構成取得後に再判定する。
- 新規 ADR の番号採番（0029 以降の最新空き番号）は ADR 一覧取得後に確定する。
- ADR 0024 / 0028 側へ superseded-by メタを追記する操作が、AGENTS.md「方針変更は既存 ADR 本文を上書きせず、新規 ADR と状態・関係メタデータで履歴として反映する」の "メタデータ" 範囲に収まるかは ADR format reference で再確認する。
