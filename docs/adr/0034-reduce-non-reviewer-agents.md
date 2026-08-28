# 0034: non-reviewer agent を researcher / inspector のみへ集約する

- Status: Superseded
- Superseded-By: 0040
- Supersedes: 0024, 0028

## 背景

Claude / Codex 両 surface に reviewer 4 + non-reviewer 7 = 11 agent が存在し、要件・基本設計・詳細設計・タスク分解・実装・repository maintenance の各工程が subagent (`requirements-engineer` / `architect` / `task-planner` / `implementer` / `repository-maintainer`) に分割されていた。subagent 化のメリットは (a) isolation: 中間出力 (grep、log、test output) を別 context window に隔離すること、(b) constraint enforcement: frontmatter の `tools:` 制限と本文 stop-line による機械的な権限制限、の 2 つに整理できる。

要件・設計・task・実装の工程は lead 一貫で持つほうが artifact 間の handoff loss が小さい。中間出力が嵩む調査・検証だけ subagent に隔離すれば context window 圧迫は避けられる。reviewer は独立批判視点として agent 形態の価値が大きい。`orchestrate` workflow は別セッションで stop-line catalog 統合と tier 表示 brushing up が進んだため、最新構成に合わせて参照書き換えが必要になった。

ADR 0024 で `repository-maintainer` を、ADR 0028 で `implementer` / `inspector` / `researcher` を含む skill-agent ペアの語幹一致を採用した。本 ADR はこの両者を folded して再決定する。

## 決定

reviewer 4 種 (`requirements-reviewer` / `design-reviewer` / `security-reviewer` / `quality-reviewer`) + `researcher` + `inspector` の 6 agent に集約する。両 surface で対称に以下を実行する。

- 削除: `dot_claude/agents/{architect,requirements-engineer,task-planner,implementer,repository-maintainer}.md` および `dot_codex/agents/{...}.toml` の 10 ファイル。
- 工程主体の置換: 要件 / 基本設計 / 詳細設計 / タスク分解 / 実装は lead が `requirements` / `architecture` / `task-planning` / `implement` skill を直接使い、artifact 作成は `scribe` skill を介して行う。
- repository maintenance 工程は廃止し、Gate 3 前 docs / 参照ずれ確認は lead が `doc-followup` skill を必要時に使う。確認結果と残リスクは `request.md` または `implementation.md` の自然な節へ短くまとめる。
- handoff schema から `Repository Maintenance Impact` block と `verifier_return_required` field を完全廃止する。Engineering Agent Output の対象は `researcher` / `inspector` のみへ縮約する。
- ADR 0024 / 0028 の Status を `Superseded` に変更し、`Superseded-By: 0034` を追加する。ADR 本文は履歴として保持する (ADR 0022)。

## 影響

- 失われる constraint enforcement: 削除する 5 agent の frontmatter / 本文に置いていた `tools:` 制限と工程別 stop-line が機械的には消える。代替として (i) `orchestrate/references/stop-lines.md` カタログによる公開挙動系 / command 系停止線、(ii) 各 skill SKILL.md の境界記述 (`implement` / `architecture` / `requirements` / `task-planning` / `doc-followup` の責務とスコープ)、(iii) `dot_claude/CLAUDE.md` / `dot_codex/AGENTS.md` の lead 自走停止線、の 3 層で代替する。tier 判定で `full` に倒される条件は維持する。
- isolation 維持: `researcher` と `inspector` を agent として残すことで、grep / log / test 出力など中間データの context window 隔離は維持する。reviewer 4 種は独立批判視点として agent 形態で残し、`Reviewer Execution Boundary` (`modified_artifacts: none` / `write_operations: none` / `external_io: none`) も従来どおり強制する。
- ADR 0024 superseded: repository maintenance を独立 agent に分けた決定は、handoff loss と工程廃止の 2 観点で superseded する。docs / references / prose 追従は lead が `doc-followup` skill で扱う。
- ADR 0028 superseded: skill-agent ペアの語幹一致を 3 件 rename で実現した決定のうち、`implementer` agent は本 ADR で削除する。`researcher` / `inspector` は残置し、命名規則も維持する。reviewer / `requirements-engineer` / `task-planner` / `repository-maintainer` への命名規則言及は履歴として残す。
- schema 互換破棄: `verifier_return_required` field を完全廃止することで、過去 request 配下の handoff (`docs/requests/<other-slug>/handoff.md`) には旧 field が残るが、これは履歴として保持する。新規 handoff からは field が消える。lead が `doc-followup` で観測した tooling 挙動差分が inspector 再確認を必要とする場合は、lead が field 経由ではなく直接 inspector を起動する orchestration で扱う。
- 旧 ADR 本文の旧 agent 名: ADR 0020 / 0024 / 0027 / 0028 等の本文に残る `architect` / `requirements-engineer` / `task-planner` / `implementer` / `developer` / `repository-maintainer` / `analyst` / `verifier` は履歴として保持する (ADR 0022)。
