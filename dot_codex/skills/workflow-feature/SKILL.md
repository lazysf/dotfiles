---
name: workflow-feature
description: feature 案件の入口 workflow。計画、実装、テスト、レビューの順で進める。
metadata:
  short-description: Feature workflow
---

# Workflow Feature

`feature` 分類の案件を、`plan -> implement -> test -> review` で進める。

## フロー

1. `phase-classify`
2. `phase-plan`
3. `phase-implement`
4. `phase-test`
5. `phase-review`

## 主要受け渡し

- `phase-plan` から `plan_scope`, `success_criteria`, `implementation_outline` を受け取る
- `phase-implement` から `change_summary`, `executed_checks`, `remaining_risks` を受け取る
- `phase-test` で `test_plan`, `executed_checks`, `remaining_test_risks` を整理する
- `phase-review` で findings-first のレビュー出口を作る

## 完了条件

- 成功条件に対応する実装と確認がそろっている
- レビュー観点で大きな不足が残っていない
