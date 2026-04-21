---
name: phase-classify
description: 分類工程。ユーザー要求を単一主分類へ倒し、次に入る workflow を決める。
metadata:
  short-description: Classify 工程
---

# Phase Classify

分類工程の入口をそろえ、要求を単一主分類へ整理する。

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
