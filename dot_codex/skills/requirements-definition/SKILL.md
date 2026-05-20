---
name: requirements-definition
description: 「要件定義したい」「FR-001 を詰めたい」「機能要件を固めたい」「PRD から個別要件に落としたい」といった、PRD 後の要件定義で使う。ぼんやりした要件や機能を問いで詰め、受入条件、非範囲、依存、未確定事項を `docs/REQUIREMENTS.md` に追記できる形へ整理する。設計は `basic-design`、docs 反映は `grill-with-docs` を使う。
metadata:
  short-description: 要件定義
---

# 要件定義

PRD や会話で出た実現したい要件を、`FR-*` 単位で扱える要件定義へ整理する。

## 手順

- 対象 PRD、既存 `docs/REQUIREMENTS.md`、`docs/TRACEABILITY_MATRIX.md`、関連 docs / ADR / code を確認する。
- 対象の feature / requirement を短く言い換える。
- 既存 ID があれば継続し、ID 体系が未確定なら採番前に確認する。
- 目的、要求、受入条件、非範囲、依存、制約、未確定事項を分ける。
- 質問は 1 つずつ行い、推奨回答を添える。
- 受入条件は、実装手段ではなく観測可能な結果として書く。
- 要件本文を書く時は `grill-with-docs` スキルの `references/requirements-format.md` を正本 format として使う。
- 要件が固まったら、次は `basic-design` に渡す。

## 境界

- PRD 全体がまだ曖昧なら `product-planning` を使う。
- docs / ADR / CONTEXT 反映まで行う時は `grill-with-docs` を使う。
- 基本設計は `basic-design`、詳細設計は `detailed-design`、実装計画は `implementation-planning` を使う。
- traceability matrix 更新は `traceability-matrix` を使う。

## 出力

- `requirement_id`
- `confirmed_context`
- `requirement`
- `acceptance_criteria`
- `non_goals`
- `dependencies`
- `open_questions`
- `docs_update`
- `next_step`
