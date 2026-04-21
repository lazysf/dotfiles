---
name: phase-test
description: テスト工程。feature と maintenance の確認方法と実施結果を整理する。
metadata:
  short-description: Test 工程
---

# Phase Test

テスト工程の入口をそろえ、期待挙動と保護したい既存挙動の確認結果を整理する。

## 入力

- 変更意図
- 期待挙動
- 保護したい既存挙動

## uses

- `core-change-testing`

## 出力

- `test_plan`
- `executed_checks`
- `remaining_test_risks`

## 完了条件

- 変更意図に対応する確認がそろっている
