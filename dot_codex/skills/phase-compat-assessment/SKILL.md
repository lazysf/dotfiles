---
name: phase-compat-assessment
description: 互換性評価工程。外部変化の影響範囲と追従方針を整理する。
metadata:
  short-description: Compat Assessment 工程
---

# Phase Compat Assessment

互換性評価工程の入口をそろえ、追従すべき外部変化と検証観点を整理する。

## 入力

- 外部変更
- 依存差分
- 互換制約

## uses

- `core-compat-assessment`

## 出力

- `compat_gap`
- `affected_surface`
- `adaptation_scope`
- `verification_focus`

## 完了条件

- 追従方針と影響範囲を説明できる
