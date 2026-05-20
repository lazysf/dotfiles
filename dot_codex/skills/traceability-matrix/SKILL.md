---
name: traceability-matrix
description: 「traceability matrix を作りたい」「要件・設計・タスク・テストの対応表を更新したい」「FR/AC/BD/DD/TASK/TC の紐付きを確認したい」といった、成果物間の追跡性を整理する時に使う。PRD、要件、基本設計、詳細設計、実装計画、テストケース、テストコードの対応関係を `docs/TRACEABILITY_MATRIX.md` に反映できる形へ整理する。
metadata:
  short-description: Traceability matrix
---

# Traceability Matrix

PRD、要件、設計、task、test の対応関係を一覧化し、漏れや孤立を見つける。

## 手順

- `docs/PRD.md`、`docs/REQUIREMENTS.md`、`docs/BASIC_DESIGN.md`、`docs/DETAILED_DESIGN.md`、`docs/IMPLEMENTATION_PLAN.md`、`docs/TEST_CASES.md`、既存 tests を確認する。
- `FR-*`、`REQ-*`、`AC-*`、`BD-*`、`DD-*`、`TASK-*`、`TC-*`、test code の対応を抽出する。
- 対応が確認できないものは推測で埋めず、`TBD` または `N/A` と理由を残す。
- 要件に設計、task、test がない場合は漏れとして分ける。
- 設計、task、test が要件に紐付かない場合は孤立として分ける。
- `docs/TRACEABILITY_MATRIX.md` を更新する時は `grill-with-docs` スキルの `references/traceability-matrix-format.md` を正本 format として使う。

## 境界

- 要件本文の作成は `requirements-definition` を使う。
- 基本設計は `basic-design`、詳細設計は `detailed-design`、実装計画は `implementation-planning`、task 分解は `task-decomposition` を使う。
- test case 作成は `test-case-planning` を使う。
- 実装やテストコード作成は扱わない。

## 出力

- `matrix_updates`
- `missing_links`
- `orphaned_items`
- `tbd_items`
- `docs_update`
- `open_questions`
- `next_step`
