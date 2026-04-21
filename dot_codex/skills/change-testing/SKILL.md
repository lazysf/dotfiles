---
name: change-testing
description: feature / maintenance 案件の確認手順。期待挙動と保護したい既存挙動の確認を整理する。
metadata:
  short-description: テスト手順
---

# Change Testing

feature と maintenance 案件で、何をどう確認するかを整理して実施する。
このスキルは確認計画と実施整理を担い、修正効果の検証は `change-verification` に持ち込まない。

## 基本方針

- feature は成功条件に対応する確認を優先する。
- maintenance は保護したい既存挙動の確認を優先する。
- 変更に最も近い確認を先に置き、影響が広い場合だけ上位の確認を足す。
- 直接テストできない場合は、lint / build / manual smoke などの代替確認を明示する。
- 未実行項目は成功扱いにしない。

## 手順

1. 変更意図に対応する確認項目を `test_plan` に並べる
2. 既存挙動を守るための確認項目も加え、最も近い確認から順に並べる
3. 直接テストできない項目には、代替確認と未確認理由を添える
4. 実行した確認を `executed_checks` に記録する
5. まだ確認できていない点を `remaining_test_risks` に残す

## 判断基準

- feature は成功条件に対応する確認を優先する
- maintenance は守るべき既存挙動の保護を優先する
- 実行できない確認は、理由と代替確認をセットで残す
- 同一条件で結果がぶれる場合は、未解消リスクとして扱う
- 未検証は成功扱いにしない

## 出力フォーマット

- `test_plan`
- `executed_checks`
- `remaining_test_risks`

## 停止条件

- 期待挙動や保護したい挙動が不明で確認項目を作れない
