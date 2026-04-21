---
name: phase-implement
description: 共通 Implement 工程。合意した方針に沿って実装し、必要な確認ループへ受け渡す。
metadata:
  short-description: Implement 工程
---

# Phase Implement

Implement 工程の入口をそろえ、変更意図に対応する実装と確認を進める。
この phase は詳細手順を自前で持たず、既定の実装 core と確認結果の受け渡しに徹する薄い orchestrator である。

## 入力

- 合意済みの方針
- 触る範囲
- 変更意図
- 確認方法または確認観点

## 進め方

1. テスト可能な変更では `core-code-implementation-loop` を既定ループとして使う
2. docs-only や設定変更では、同じ phase の出力 schema を満たす確認手段へ置き換える
3. 実装結果と確認結果を次の `phase-test`、`phase-review`、`phase-verify` のいずれかへ渡す

## 出力

- `change_summary`
- `implemented_scope`
- `executed_checks`
- `remaining_risks`

## 完了条件

- 実装差分と確認結果がそろっている
- 方針外の変更が混ざっていない
- 次フェーズに渡せる説明がある
