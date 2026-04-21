---
name: phase-test
description: Deprecated wrapper。旧 Test 導線互換のために `core-change-testing` へ受け渡す。
metadata:
  short-description: Test 工程
---

# Phase Test

旧 Test 導線互換のために、feature / maintenance の確認依頼を `core-change-testing` へ橋渡しする。
新規の正式入口としては使わず、`core-change-testing` を直接使う。

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

## 次に渡す情報

- `executed_checks` と `remaining_test_risks` を `phase-review` や最終報告へ渡す

## 完了条件

- 変更意図に対応する確認がそろっている
