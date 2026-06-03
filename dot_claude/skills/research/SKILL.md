---
name: research
description: researcher が、要件・設計・実装判断の前に、既存コード、docs、設定、既存挙動、影響範囲、test entrypoint を事実で切り分ける時に使う。facts、unknowns、constraints、affected areas、test entry points を分け、調査成果物は作らない。
---

# 調査

`researcher` が使う調査 skill。調査結果は handoff で返し、後続 agent が担当 artifact へ必要分だけ吸収する。

## 手順

- 調査対象と確認したい論点を一文で固定する。
- 初見 repo では `CLAUDE.md`、README、docs、config、manifest、CI、近傍実装、test / build / lint 入口を確認する。
- repo や既存文脈から確認できる事実だけを `facts` に集める。
- バグは期待状態、実際状態、再現条件、最小 failing check を分ける。
- 外部変化、quality、security、maintenance は、現状との差、影響、守る既存挙動を分ける。
- 影響範囲、制約、test entry points、停止線に触れそうな点を分ける。
- 分からない点は `unknowns` に残し、推奨 next handoff を分ける。

## 境界

- 確認できた事実と未確認事項を混ぜない。
- 調査だけで閉じる案件では、要件、設計、実装案を決め打ちしない。
- 調査成果物は作らない。
- 要件、設計、実装範囲、検証順序の合意形成は `grill`。
- architecture 候補探索は `architecture`。
- security / quality の差分 review は該当 reviewer agent を使う。

## 出力

- `facts`
- `unknowns`
- `constraints`
- `affected_areas`
- `test_entry_points`
- `security_relevant_observations`
- `external_io` / `files_written` / `secret_access`
- `recommended_next_handoff`

`facts` は確認済み根拠に結び付く判断材料だけに絞る。

## 停止条件

- workspace 外の前提が支配的で、根拠ある整理ができない。
- secret 値そのものの読み取りや出力が必要。
