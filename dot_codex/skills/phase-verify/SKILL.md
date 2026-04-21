---
name: phase-verify
description: Deprecated wrapper。旧 Verify 導線互換のために `core-change-verification` へ受け渡す。
metadata:
  short-description: Verify 工程
---

# Phase Verify

旧 Verify 導線互換のために、修正結果や追従結果の確認依頼を `core-change-verification` へ橋渡しする。
新規の正式入口としては使わず、`core-change-verification` を直接使う。

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

## 次に渡す情報

- `verification_result`, `regression_check`, `residual_risks` を最終報告や追加修正判断へ渡す

## 完了条件

- remediation 結果と回帰確認を説明できる
