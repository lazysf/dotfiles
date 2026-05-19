---
name: research
description: 「まず調べたい」「原因を切り分けたい」「外部変化・品質・セキュリティ・保守性の影響を事実で整理したい」といった調査で使う。facts、unknowns、options、recommendation、next_step を分ける。要件整理は `product-planning`、技術計画は `implementation-planning`。
metadata:
  short-description: 調査手順
---

# 調査

実装や修正に入る前に、判断材料として必要な事実を整理する。

## 手順

- 調査対象と確認したい論点を一文で固定する。
- 初見 repo や規約が曖昧な場合は、`AGENTS.md`、README、docs、config、manifest、CI、近傍実装、test / build / lint 入口の順で grounding する。
- repo や既存文脈から確認できる事実だけを `facts` に集める。
- バグでは期待状態、実際状態、再現条件、最小 failing check を分ける。
- 外部変化、quality、security、maintenance では、現状との差、影響面、保護すべき既存挙動を分ける。
- まだ分からない点は `unknowns` に残し、選択肢を `options` に分ける。
- もっとも妥当な案を `recommendation` にまとめ、次に確認することを `next_step` に置く。

## 境界

- 確認できた事実と未確認事項を混ぜない。
- 調査だけで閉じる案件では、実装案を決め打ちしない。
- 要件を問いで固める段階では `product-planning` スキルを使う。
- 実装範囲や検証順序を決める段階では `implementation-planning` スキルを使う。
- architecture 改善候補の探索は `improve-codebase-architecture` スキルを使う。
- security / quality の差分 review は該当 reviewer agent を使う。

## 出力

- `facts`
- `unknowns`
- `options`
- `recommendation`
- `next_step`

`facts` は確認済み根拠に結び付く判断材料だけに絞り、低価値な網羅や一般論で埋めない。

## 停止条件

- workspace 外の前提が支配的で、根拠ある整理ができない。
