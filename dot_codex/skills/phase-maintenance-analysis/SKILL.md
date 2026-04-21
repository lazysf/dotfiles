---
name: phase-maintenance-analysis
description: Deprecated wrapper。旧 Maintenance 導線互換のために `core-maintenance-analysis` へ受け渡す。
metadata:
  short-description: Maintenance Analysis 工程
---

# Phase Maintenance Analysis

旧 Maintenance 導線互換のために、保守性分析依頼を `core-maintenance-analysis` へ橋渡しする。
新規の正式入口としては使わず、`core-maintenance-analysis` を直接使う。

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

## 次に渡す情報

- `refactor_boundary`, `protected_behavior`, `test_focus` を `phase-implement` と `phase-test` へ渡す

## 完了条件

- 今回触る範囲と守る挙動が明確である
