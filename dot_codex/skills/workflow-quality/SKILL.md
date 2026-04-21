---
name: workflow-quality
description: quality 案件の導線 workflow。品質課題の分析、改善実装、検証の順で進める。
metadata:
  short-description: Quality workflow
---

# Workflow Quality

`quality` 分類の案件を、`quality-analysis -> implement -> verify` で進める。
この workflow は `entry-classify` により選択されたあとに始まる。

## フロー

1. `phase-quality-analysis`
2. `phase-implement`
3. `phase-verify`

## 主要受け渡し

- `phase-quality-analysis` から `quality_target`, `bottleneck_or_risk`, `improvement_scope`, `verification_focus` を受け取る
- `phase-implement` で改善差分を作る
- `phase-verify` で改善結果と副作用を確認する

## 完了条件

- 改善対象の品質特性が明確である
- 改善結果を検証できている
