---
name: research
description: バグ原因、再現条件、外部変化、品質・セキュリティ・保守性への影響を、実装や判断の前に事実で切り分ける時に使う。facts、unknowns、options、recommendation、next_step を分ける。要件、設計、実装順序、検証方法の合意形成は `grill`。
---

# 調査

## 手順

- 調査対象と確認したい論点を一文で固定する。
- 初見 repo では `CLAUDE.md`、README、docs、config、manifest、CI、近傍実装、test / build / lint 入口を確認する。
- repo や既存文脈から確認できる事実だけを `facts` に集める。
- バグは期待状態、実際状態、再現条件、最小 failing check を分ける。
- 外部変化、quality、security、maintenance は、現状との差、影響、守る既存挙動を分ける。
- 分からない点は `unknowns` に残し、選択肢、推奨、次の確認を分ける。

## 境界

- 確認できた事実と未確認事項を混ぜない。
- 調査だけで閉じる案件では、要件、設計、実装案を決め打ちしない。
- 要件、設計、実装範囲、検証順序の合意形成は `grill`。
- architecture 候補探索は `architecture`。
- security / quality の差分 review は該当 reviewer subagent を使う。

## 停止条件

- workspace 外の前提が支配的で、根拠ある整理ができない。
