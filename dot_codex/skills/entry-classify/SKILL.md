---
name: entry-classify
description: 共通入口。ユーザー要求を単一主分類へ倒し、次に入る workflow を決める。
metadata:
  short-description: 分類入口
---

# Entry Classify

全導線の共通入口をそろえ、要求を単一主分類へ整理する。
この skill は workflow の一工程ではなく、workflow 選択前に使う入口である。

## 入力

- ユーザー要求
- 既存文脈
- 制約

## uses

- `core-task-classification`

## 出力

- `primary_category`
- `reason`
- `boundary_note`
- `selected_workflow`
- `stop_conditions`

## 完了条件

- 分類理由と選んだ workflow を短く説明できる
