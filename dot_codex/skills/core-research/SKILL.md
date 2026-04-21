---
name: core-research
description: 調査系案件の詳細手順。事実、未知、選択肢、推奨を整理する。
metadata:
  short-description: 調査手順
---

# Core Research

Research 工程の内部手順として、実装や修正に入る前に判断材料として必要な事実を整理する。
フェーズ全体の入口は `phase-research` を参照する。

## 対象

- 原因調査
- 影響調査
- PoC や方式比較
- 仕様確認

## 対象外

- 調査結果を前提にした実装

## 手順

1. 調査対象と確認したい論点を一文で固定する
2. repo や既存文脈から確認できる事実を集める
3. まだ分からない点を `unknowns` として分離する
4. 取りうる選択肢を `options` に分ける
5. もっとも妥当な案を `recommendation` にまとめる
6. 次に進むなら何を確認するかを `next_step` に置く

## 判断基準

- 未確認事項を事実として書かない
- 実装方針が揺れる要因は `unknowns` に残す
- 調査だけで閉じる案件では実装案を決め打ちしない

## 出力フォーマット

- `facts`
- `unknowns`
- `options`
- `recommendation`
- `next_step`

## 停止条件

- workspace 外の前提が支配的で、根拠ある整理ができない
