---
name: workflow-maintenance
description: maintenance 案件の入口 workflow。保守性分析、リファクタ、テスト、レビューの順で進める。
metadata:
  short-description: Maintenance workflow
---

# Workflow Maintenance

`maintenance` 分類の案件を、`maintenance-analysis -> implement -> test -> review` で進める。

## フロー

1. `phase-classify`
2. `phase-maintenance-analysis`
3. `phase-implement`
4. `phase-test`
5. `phase-review`

## 主要受け渡し

- `phase-maintenance-analysis` から `maintenance_scope`, `refactor_boundary`, `protected_behavior`, `test_focus` を受け取る
- `phase-implement` で最小リファクタ差分を作る
- `phase-test` と `phase-review` で保護したい挙動を確認する

## 完了条件

- リファクタ境界が明確である
- 既存挙動の保護とレビューが済んでいる
