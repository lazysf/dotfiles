---
name: research
description: バグ原因、再現条件、外部変化、品質・セキュリティ・保守性への影響など、実装や判断の前に事実を調べて切り分けたい時に使う。確認済み事実、未確認事項、選択肢、推奨、次の確認を分ける。要件、設計、実装順序、検証方法を固める対話は `grill` を使う。
metadata:
  short-description: 調査手順
---

# 調査

主にバグ、外部変化、品質、セキュリティ、保守性の判断材料として必要な事実を整理する。

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
- 調査だけで閉じる案件では、要件、設計、実装案を決め打ちしない。
- 要件、設計、実装範囲、検証順序を問い詰めて固める段階では `grill` スキルを使う。
- architecture 改善候補の探索は `architecture` スキルを使う。
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
