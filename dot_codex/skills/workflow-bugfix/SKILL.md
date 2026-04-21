---
name: workflow-bugfix
description: bugfix 案件の入口 workflow。診断、実装、検証の順で進める。
metadata:
  short-description: Bugfix workflow
---

# Workflow Bugfix

`bugfix` 分類の案件を、`diagnose -> implement -> verify` で進める。

## フロー

1. `phase-classify`
2. `phase-diagnose`
3. `phase-implement`
4. `phase-verify`

## 主要受け渡し

- `phase-diagnose` から `observed_gap`, `repro_steps`, `failing_check`, `fix_target` を受け取る
- `phase-implement` から `change_summary`, `executed_checks`, `remaining_risks` を受け取る
- `phase-verify` で `verification_result` と `regression_check` を閉じる

## 完了条件

- 修正対象が診断済みである
- 修正結果が検証済みである
