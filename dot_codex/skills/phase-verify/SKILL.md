---
name: phase-verify
description: 検証工程。bugfix / security / quality / compat の修正結果と回帰を確認する。
metadata:
  short-description: Verify 工程
---

# Phase Verify

検証工程の入口をそろえ、修正や追従が効いた証拠を整理する。

## 入力

- 修正内容
- 修正前症状または追従前ギャップ
- 検証観点

## uses

- `core-change-verification`

## 出力

- `verification_plan`
- `verification_result`
- `regression_check`
- `residual_risks`

## 完了条件

- remediation 結果と回帰確認を説明できる
