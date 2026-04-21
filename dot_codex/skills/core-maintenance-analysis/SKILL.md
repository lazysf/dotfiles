---
name: core-maintenance-analysis
description: maintenance 案件の分析手順。最小リファクタ境界と保護すべき挙動を整理する。
metadata:
  short-description: Maintenance 分析
---

# Core Maintenance Analysis

maintenance 案件で、どこまで整理し、どの挙動を守るかを決める。

## 手順

1. 重複、命名、責務分離、テスト不足など主課題を 1 つに絞る
2. 今回触る範囲を `maintenance_scope` に整理する
3. 切り戻し単位を意識して `refactor_boundary` を決める
4. 守るべき既存挙動を `protected_behavior` に並べる
5. テストやレビューで重点確認する点を `test_focus` に置く

## 判断基準

- 品質改善ではなく変更容易性を主目的にする
- 大規模整理を避け、最小のリファクタ境界を置く
- 既存挙動の保護方法を先に決める

## 出力フォーマット

- `maintenance_scope`
- `refactor_boundary`
- `protected_behavior`
- `test_focus`

## 停止条件

- 既存挙動の保護方法が見えない
