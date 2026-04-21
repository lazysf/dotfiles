---
name: phase-implement
description: Deprecated wrapper。旧 Implement 導線互換のために `core-code-implementation-loop` へ受け渡す。
metadata:
  short-description: Implement 工程
---

# Phase Implement

旧 Implement 導線互換のために、実装依頼を `core-code-implementation-loop` へ橋渡しする。
新規の正式入口としては使わず、`core-code-implementation-loop` を直接使う。

## 入力

- 合意済みの方針
- 触る範囲
- 変更意図
- 確認方法または確認観点

## uses

- `core-code-implementation-loop`

## 進め方

1. テスト可能な変更では、まず `$core-code-implementation-loop` を使って確認方法先行の小さな実装ループで進める
2. docs-only や設定変更では、同じ phase の出力 schema を満たす最小の実装・確認ループへ置き換える
3. 実装結果と確認結果をそろえ、次の `phase-test`、`phase-review`、`phase-verify` のいずれかへ渡す

## 出力

- `change_summary`
- `implemented_scope`
- `executed_checks`
- `remaining_risks`

## 次に渡す情報

- `phase-test` へ進む場合は `change_summary`, `implemented_scope`, `executed_checks` を渡す
- `phase-review` へ進む場合は `change_summary`, `executed_checks`, `remaining_risks` を渡す
- `phase-verify` へ進む場合は `change_summary`, `implemented_scope`, `executed_checks`, `remaining_risks` を渡す

## 完了条件

- 実装差分と確認結果がそろっている
- 方針外の変更が混ざっていない
- 次フェーズに渡せる説明がある
