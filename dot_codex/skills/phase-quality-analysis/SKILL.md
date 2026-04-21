---
name: phase-quality-analysis
description: Deprecated wrapper。旧 Quality 導線互換のために `core-quality-analysis` へ受け渡す。
metadata:
  short-description: Quality Analysis 工程
---

# Phase Quality Analysis

旧 Quality 導線互換のために、品質改善の分析依頼を `core-quality-analysis` へ橋渡しする。
新規の正式入口としては使わず、`core-quality-analysis` を直接使う。

## 入力

- 品質課題
- 計測情報または観測事実
- 制約

## uses

- `core-quality-analysis`

## 出力

- `quality_target`
- `bottleneck_or_risk`
- `improvement_scope`
- `verification_focus`

## 次に渡す情報

- `improvement_scope` と `verification_focus` を `phase-implement` へ渡す

## 完了条件

- どの品質特性を改善するか説明できる
