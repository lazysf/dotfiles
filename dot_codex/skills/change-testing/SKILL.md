---
name: change-testing
description: feature / maintenance 案件の確認手順。期待挙動と保護したい既存挙動の確認を整理する。
metadata:
  short-description: テスト手順
---

# Change Testing

feature と maintenance 案件で、何をどう確認するかを整理して実施する。
このスキルは確認計画と実施整理を担い、修正効果の検証は `change-verification` に持ち込まない。

## 手順

1. 変更意図に対応する確認項目を `test_plan` に並べる
2. 既存挙動を守るための確認項目も加える
3. 実行した確認を `executed_checks` に記録する
4. まだ確認できていない点を `remaining_test_risks` に残す

## 判断基準

- feature は成功条件に対応する確認を優先する
- maintenance は守るべき既存挙動の保護を優先する
- 未検証は成功扱いにしない

## 出力フォーマット

- `test_plan`
- `executed_checks`
- `remaining_test_risks`

## 停止条件

- 期待挙動や保護したい挙動が不明で確認項目を作れない
