---
name: maintenance-analysis
description: 「リファクタ境界を決めたい」「保守性改善でどの挙動を守るか整理したい」といった maintenance 案件で使う。最小のリファクタ境界、今回の整理範囲、保護すべき既存挙動、重点確認点を整理する。性能や安定性を改善したい時は `quality-analysis` スキルを使い、新機能追加が主題の時は `request-shaping`、`task-intake`、`product-planning`、`implementation-planning` のうち状況に合うスキルを使う。
metadata:
  short-description: Maintenance 分析
---

# Maintenance Analysis

maintenance 案件で、どこまで整理し、どの挙動を守るかを決める。
変更容易性を主目的に、切り戻しやすい最小のリファクタ境界を置く。

## 手順

1. 重複、命名、責務分離、テスト不足など主課題を 1 つに絞る
2. 今回触る範囲を `maintenance_scope` に整理する
3. 現在の挙動、依存関係、切り戻し単位を確認して `refactor_boundary` を決める
4. 削除や統合を含む場合は、静的参照や運用前提を見て SAFE / CAREFUL / RISKY のどれに近いかを判断する
5. 守るべき既存挙動を `protected_behavior` に並べる
6. テストやレビューで重点確認する点を `test_focus` に置く

## 判断基準

- 品質改善ではなく変更容易性を主目的にする
- 大規模整理を避け、最小のリファクタ境界を置く
- 変更は切り戻しやすい単位に分ける
- 判断材料が弱い削除や統合を勢いで進めない
- 既存挙動の保護方法を先に決める

## 出力フォーマット

- `maintenance_scope`
- `refactor_boundary`
- `protected_behavior`
- `test_focus`

## 停止条件

- 既存挙動の保護方法が見えない
