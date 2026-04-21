---
name: phase-maintenance-analysis
description: 保守性分析工程。リファクタ境界と保護したい挙動を整理する。
metadata:
  short-description: Maintenance Analysis 工程
---

# Phase Maintenance Analysis

保守性分析工程の入口をそろえ、今回のリファクタ境界を整理する。

## 入力

- 保守性課題
- 関連コード
- 制約

## uses

- `core-maintenance-analysis`

## 出力

- `maintenance_scope`
- `refactor_boundary`
- `protected_behavior`
- `test_focus`

## 完了条件

- 今回触る範囲と守る挙動が明確である
