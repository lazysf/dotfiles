---
name: test-case-planning
description: 「テストケースを作りたい」「テスト設計したい」「テスト可能なら確認観点を作りたい」「テストコードの前にケースを整理したい」といった、要件・設計・タスクに対するテスト設計で使う。テスト可能性を判断し、test case、manual check、test code 候補、未確認事項を `docs/TEST_CASES.md` と traceability matrix に反映できる形へ整理する。
metadata:
  short-description: テスト設計
---

# テスト設計

要件、設計、task に対して、テスト可能な場合の test case と確認入口を整理する。

## 手順

- 対象 `FR-*` の要件、受入条件、設計、実装計画、traceability matrix、既存 tests を確認する。
- 自動テスト可能、手動確認が必要、確認不能または費用対効果が低いものを分ける。
- test case は `TC-*` 単位で、前提、手順、期待結果、対応する `AC-*` / `TASK-*` を持たせる。
- test code を作る場合は、既存 test placement、命名、実行入口を確認する。
- Excel マクロなど TDD が難しい対象では、手動確認、比較観点、最小再現 workbook などを先に置く。
- `docs/TEST_CASES.md` を更新する時は `grill-with-docs` スキルの `references/test-case-format.md` を正本 format として使う。
- 対応関係が変わる場合は、`traceability-matrix` に渡す。

## 境界

- テスト実装は `code-implementation-loop` を使う。
- 変更後の受け入れ確認整理は `change-verification` を使う。
- テスト不可能な対象を無理に TDD 化しない。
- docs / ADR / CONTEXT 反映まで行う時は `grill-with-docs` を使う。

## 出力

- `feature_id`
- `testability`
- `test_cases`
- `manual_checks`
- `test_code_candidates`
- `traceability_updates`
- `open_questions`
- `next_step`
