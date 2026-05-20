---
name: basic-design
description: 「基本設計を作りたい」「要件定義から設計方針に落としたい」「FR-001 の構成や責務を決めたい」といった、要件定義後の基本設計で使う。要件、受入条件、制約をもとに、全体方針、責務分担、主要 flow、代替案、未確定事項を `docs/BASIC_DESIGN.md` に追記できる形へ整理する。詳細設計は `detailed-design` を使う。
metadata:
  short-description: 基本設計
---

# 基本設計

要件定義をもとに、実装詳細へ入る前の全体方針と責務分担を整理する。

## 手順

- 対象 `FR-*` の PRD、要件定義、traceability matrix、関連 docs / ADR / code を確認する。
- 設計対象と非対象を短く言い換える。
- design goal、approach、components / responsibilities、data / state、user / system flow、代替案、未確定事項を分ける。
- 質問は 1 つずつ行い、推奨回答を添える。
- 詳細な処理順や実装手順は入れすぎず、詳細設計に送る。
- 基本設計本文を書く時は `grill-with-docs` スキルの `references/basic-design-format.md` を正本 format として使う。
- 基本設計が固まったら、次は `detailed-design` に渡す。

## 境界

- 要件がまだ曖昧なら `requirements-definition` を使う。
- docs / ADR / CONTEXT 反映まで行う時は `grill-with-docs` を使う。
- 詳細設計は `detailed-design`、実装計画は `implementation-planning` を使う。
- traceability matrix 更新は `traceability-matrix` を使う。

## 出力

- `feature_id`
- `confirmed_requirements`
- `design_goal`
- `approach`
- `components`
- `data_state`
- `flow`
- `alternatives`
- `open_questions`
- `docs_update`
- `next_step`
