---
name: task-decomposition
description: 「タスク分解したい」「実装計画を作業タスクへ落としたい」「TASK-001 を切りたい」といった、実装計画後のタスク分解で使う。実装計画をもとに、順序、依存、確認方法、非対象を分け、`docs/IMPLEMENTATION_PLAN.md` と traceability matrix に反映できる task へ整理する。実装は `code-implementation-loop` を使う。
metadata:
  short-description: タスク分解
---

# タスク分解

実装計画を、実行しやすく検証可能な `TASK-*` 単位へ分ける。

## 手順

- 対象 `FR-*` の詳細設計、実装計画、traceability matrix、関連 code / tests を確認する。
- 実装 scope、非 scope、依存、検証入口を確認する。
- task は小さく、完了条件と確認方法が見える粒度にする。
- task 間の依存順を明示する。
- テスト可能な task では、先に test case / test code の候補を分ける。
- `docs/IMPLEMENTATION_PLAN.md` を更新する時は `grill-with-docs` スキルの `references/implementation-plan-format.md` を正本 format として使う。
- 対応関係が変わる場合は、`traceability-matrix` に渡す。

## 境界

- 実装計画自体が未確定なら `implementation-planning` を使う。
- test case の設計は `test-case-planning` を使う。
- 差分作成は `code-implementation-loop` を使う。
- docs / ADR / CONTEXT 反映まで行う時は `grill-with-docs` を使う。

## 出力

- `feature_id`
- `confirmed_plan`
- `tasks`
- `dependencies`
- `verification`
- `test_candidates`
- `traceability_updates`
- `open_questions`
- `next_step`
