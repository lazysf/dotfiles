---
name: workflow-research
description: 調査系案件の入口 workflow。分類後に事実確認と判断材料の整理へ進め、標準では実装へ接続しない。
metadata:
  short-description: 調査 workflow
---

# Workflow Research

`research` 分類の案件を、調査結果で閉じるための workflow。

## フロー

1. `phase-classify` で主分類と停止条件を確定する
2. `phase-research` で `facts`, `unknowns`, `options`, `recommendation`, `next_step` をそろえる

## 出力

- `primary_category`
- `facts`
- `unknowns`
- `options`
- `recommendation`
- `next_step`

## 完了条件

- 調査結果が判断材料として返せる
- 実装へ進むかどうかを別途判断できる
