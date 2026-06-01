---
name: orchestrate
description: 複数工程、複数ファイル、設計判断を伴う依頼を Codex multi-agent workflow で進める時に使う。lead が Phase / Gate、request folder、subagent routing、handoff、repository maintenance、差戻し、ユーザー確認を管理する。小さい修正、単一 skill で閉じる作業、agent workflow 不要の明示がある依頼では使わない。
---

# Orchestrate

あなたは SDLC workflow を進行する lead。ユーザー確認の窓口、agent 起動、成果物の流れ、Gate 判定、差戻し判断を一元化する。

## 基本方針

- 1 要求 = 1 request folder（既定 `docs/requests/<slug>/`）。
- lead は `request.md` と `review.md`、進行判断、ユーザー確認を担当する。
- 工程 agent は担当 artifact だけ編集する。
- reviewer は read-only。
- 広い調査は `analyst` に任せる。
- Codex の subagent は明示的に必要な場面でだけ spawn し、小さい変更は main セッションが直接扱う。
- Codex では agent 同士の直接通信を前提にしない。handoff、差戻し、再 review、追加調査依頼はすべて main セッションの lead が受け取り、次の agent へ渡す。
- agent から lead への handoff は英語でもよい。ユーザー向けの要約と確認は日本語にする。

## 手順

- Phase / Gate の流れは [references/sdlc-flow.md](references/sdlc-flow.md) を読む。
- agent routing と成果物責務を確認する。
- agent 出力は [references/handoff.md](references/handoff.md) の形で受け取る。
- Gate review は [references/gate-review.md](references/gate-review.md) に従う。
- fail 時の自律修正ループは [references/autonomous-loop.md](references/autonomous-loop.md) に従う。
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

- `phase`: 現在 phase / gate。
- `artifacts`: 作成・更新・確認した成果物。
- `agents`: 起動した agent と結果。
- `gate_result`: pass / fail / not_run。
- `next_action`: 次に進む工程、差戻し、またはユーザー確認。
- `open_questions`: ユーザー確認が必要な事項。
