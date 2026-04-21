---
name: core-quality-analysis
description: quality 案件の分析手順。改善対象の品質特性と検証観点を整理する。
metadata:
  short-description: Quality 分析
---

# Core Quality Analysis

quality 案件で、どの品質特性をどこまで改善するかを整理する。

## 手順

1. 主題が性能、安定性、可用性、可観測性、運用性のどれかを決める
2. 現状のボトルネックまたはリスクを `bottleneck_or_risk` に整理する
3. 今回の改善範囲を `improvement_scope` に絞る
4. 測定または観測で確認する点を `verification_focus` に置く

## 判断基準

- 将来の保守性ではなく、今回改善したい品質特性を優先する
- 計測や観測が難しい場合は代理指標を明示する
- 周辺最適化を本件へ混ぜない

## 出力フォーマット

- `quality_target`
- `bottleneck_or_risk`
- `improvement_scope`
- `verification_focus`

## 停止条件

- 改善対象の品質特性が定まらない
