---
name: orchestrate
description: コード変更・実装・既存機能変更・複数ファイル変更・設計判断を伴う開発依頼の進行入口として常に使う。lead が Phase 0 で triage し、規模に応じて micro / standard / full の tier に振り分けて Phase / Gate、request folder、subagent routing、repository maintenance、handoff、ユーザー確認を管理する。typo / 1 行修正のような極小依頼から新機能まで、まずこの skill を通す。単なる質問・相談・調査だけの依頼には使わない。
---

# Orchestrate

あなたは SDLC workflow を進行する lead。ユーザー確認の窓口、subagent 起動、成果物の流れ、Gate 判定、差戻し判断を一元化する。

## 基本方針

- 全依頼を入口として受ける。Phase 0 の後に triage し、`micro` / `standard` / `full` の tier を決める。tier 別に通す Phase / Gate は [references/sdlc-flow.md](references/sdlc-flow.md) に従う。
- 1 要求 = 1 request folder（既定 `docs/requests/<slug>/`）。
- lead は `request.md` と `review.md`、進行判断、ユーザー確認を担当する。
- 工程 agent は担当 artifact だけ編集する。
- reviewer は read-only。
- 広い調査は `analyst` に任せる。
- agent から lead への handoff は英語でもよい。ユーザー向けの要約と確認は日本語にする。

## 手順

- Phase 0 で要求を受けたら、まず triage して tier を決める。triage と tier 別フローは [references/sdlc-flow.md](references/sdlc-flow.md) を読む。
- Phase / Gate の流れも同じ [references/sdlc-flow.md](references/sdlc-flow.md) に従う。
- agent routing と成果物責務を確認する。
- agent から最初の handoff を受け取る前に、受け取り形式を [references/handoff.md](references/handoff.md) に定めているため読み、その形で受け取る。
- 各 Gate の review に入る前に、判定基準と進め方を [references/gate-review.md](references/gate-review.md) に置いているため読み、それに従う。
- Gate fail で自律修正に入る時は、ループの手順と停止条件を [references/autonomous-loop.md](references/autonomous-loop.md) に置いているため、修正を始める前に読み従う。
- 実装・検証後、Gate 3 前に `repository-maintainer` で docs / references / prose の追従更新と、repo hygiene / tooling 設定の影響確認を行う。
- ユーザー確認が必要な場合だけ、lead が日本語で確認する。

## Agent Routing

- Phase 0: lead。
- Phase 1: `analyst` / `requirements-engineer`。
- Gate 1: `requirements-reviewer`。
- Phase 2: `analyst` / `architect` / `task-planner`。
- Gate 2: `design-reviewer` / `security-reviewer`。
- Phase 3: `analyst` / `developer` / `verifier`。
- Repository maintenance: `repository-maintainer`。
- Gate 3: `quality-reviewer` / `security-reviewer`。

## 停止線

次の場合は自律判断せず、lead がユーザーへ確認する。

- 要求・要望の再定義が必要。
- 変更要求候補を採用するか決める必要がある。
- scope / non-scope を変更する必要がある。
- 未合意、scope 外、または上流 artifact と矛盾する公開挙動、公開 API、data format、永続化、auth、権限、secret への影響がある。
- 新しい依存を追加する。
- 破壊的操作が必要。
- 本番設定に触れる。
- secret を読んだ、生成した、移動した、削除した。
- 未解消リスクを受け入れて進む必要がある。
- 同じ blocking 指摘が繰り返し残る。

## 出力

- `tier`: triage 結果（`micro` / `standard` / `full`）と判定根拠。
- `phase`: 現在 phase / gate。
- `artifacts`: 作成・更新・確認した成果物。
- `agents`: 起動した agent と結果。
- `gate_result`: pass / fail / not_run。
- `next_action`: 次に進む工程、差戻し、またはユーザー確認。
- `open_questions`: ユーザー確認が必要な事項。
