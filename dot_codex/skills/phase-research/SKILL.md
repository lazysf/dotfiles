---
name: phase-research
description: Deprecated wrapper。旧 Research 導線互換のために `core-research` へ受け渡す。
metadata:
  short-description: Research 工程
---

# Phase Research

旧 Research 導線互換のために、調査依頼を `core-research` へ橋渡しする。
新規の正式入口としては使わず、`core-research` を直接使う。

## 入力

- 調査対象
- 確認論点
- 制約

## uses

- `core-research`

## 進め方

1. まず `$core-research` を使い、調査対象、確認論点、既存文脈から確認できる事実を整理する
2. `facts`、`unknowns`、`options`、`recommendation`、`next_step` を分けて扱い、未確認事項を事実へ混ぜない
3. 最後に Research 工程の出力形式へ統合する

## 出力

- `facts`
- `unknowns`
- `options`
- `recommendation`
- `next_step`

## 次に渡す情報

- 標準ではこの phase で閉じる
- 実装へ進める場合だけ `recommendation` と `next_step` を次の phase 判断へ渡す

## 完了条件

- 事実と未知が分離されている
- 次に取る判断を説明できる
