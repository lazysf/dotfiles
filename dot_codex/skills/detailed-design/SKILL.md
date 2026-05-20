---
name: detailed-design
description: 「詳細設計を作りたい」「基本設計から実装可能な設計へ落としたい」「interface や処理 flow を詰めたい」といった、基本設計後の詳細設計で使う。対象範囲、interface、処理 flow、validation、data mapping、edge case、未確定事項を `docs/DETAILED_DESIGN.md` に追記できる形へ整理する。実装計画は `implementation-planning` を使う。
metadata:
  short-description: 詳細設計
---

# 詳細設計

基本設計をもとに、実装計画へ渡せる粒度まで処理と interface を詰める。

## 手順

- 対象 `FR-*` の PRD、要件定義、基本設計、traceability matrix、関連 docs / ADR / code を確認する。
- 対象 scope と非対象を短く言い換える。
- interface、processing flow、validation / error handling、data mapping、edge cases、未確定事項を分ける。
- 質問は 1 つずつ行い、推奨回答を添える。
- 変わりやすい code snippet は、判断を明確にする時だけ短く使う。
- 詳細設計本文を書く時は `grill-with-docs` スキルの `references/detailed-design-format.md` を正本 format として使う。
- 詳細設計が固まったら、次は `implementation-planning` に渡す。

## 境界

- 基本方針や責務分担がまだ曖昧なら `basic-design` を使う。
- docs / ADR / CONTEXT 反映まで行う時は `grill-with-docs` を使う。
- 実装順序と検証方法は `implementation-planning` を使う。
- traceability matrix 更新は `traceability-matrix` を使う。

## 出力

- `feature_id`
- `confirmed_design`
- `target_scope`
- `interfaces`
- `processing_flow`
- `validation`
- `data_mapping`
- `edge_cases`
- `open_questions`
- `docs_update`
- `next_step`
