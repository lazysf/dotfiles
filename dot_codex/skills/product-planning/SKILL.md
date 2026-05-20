---
name: product-planning
description: 「ぼんやりした要望を問い詰めて PRD まで仕上げたい」「依頼文が散らばっている」「今回どこまでやるか決めたい」「目的・範囲・成功条件を固めたい」といった初期計画で使う。目的、成功条件、非目的、制約、用語、未確定事項を整理し、PRD draft まで作る。個別要件定義は `requirements-definition`、技術計画は `implementation-planning`、docs / ADR / CONTEXT 反映は `grill-with-docs` スキルを使う。
metadata:
  short-description: プロダクト計画
---

# プロダクト計画

ぼんやりした要望を問いで鍛え、PRD draft または実装前に扱える要件へ整理する。

## 手順

- 依頼を短く言い換え、今回扱うことと扱わないことを置く。
- `CONTEXT-MAP.md` / `CONTEXT.md`、関連 docs、ADR、近傍 code で答えられる前提は先に確認する。
- 目的、成功条件、非目的、制約、用語、優先順位、未確定事項を分ける。
- 質問は 1 つずつ行い、推奨回答を添える。
- 複数案が自然に出る場合は、2-3 案、trade-off、推奨案を短く示す。
- 成功条件は実装手段ではなく、確認できる結果で置く。
- 回答を受けたら、確定事項、仮定、未確定事項を分けて要件 draft に反映する。
- PRD draft まで求められている時は、要件が扱える粒度になってから `docs/PRD.md` にまとめる。
- PRD 本文を作成・更新する時は、`grill-with-docs` スキルの `references/prd-format.md` を正本 format として使う。
- 要件整理の観点で迷う時だけ [references/product-planning-heuristics.md](references/product-planning-heuristics.md) を読む。

## 成果物の置き方

- 当面は成果物ごとに 1 ファイルで運用し、PRD は `docs/PRD.md` を正本にする。
- 後続の要件、設計、実装計画、test case、traceability は `docs/REQUIREMENTS.md`、`docs/BASIC_DESIGN.md`、`docs/DETAILED_DESIGN.md`、`docs/IMPLEMENTATION_PLAN.md`、`docs/TEST_CASES.md`、`docs/TRACEABILITY_MATRIX.md` に追記する前提で扱う。
- 各要件や機能は `FR-001` のような ID で追跡する。ID 体系が未確定なら、この skill では仮置きせず確認する。
- `docs/adr/` と `docs/notes/` は現行どおりフォルダ運用し、PRD や plan のフォルダは明示されるまで作らない。

## 境界

- 実装順序や検証方法を詰める段階では `implementation-planning` スキルを使う。
- 個別要件を固める段階では `requirements-definition`、基本設計は `basic-design`、詳細設計は `detailed-design` スキルを使う。
- 初期 workflow では PRD draft 作成まで進めてよい。
- plan / design 全体の pressure test は `grill-me`、docs / ADR 反映まで進める時は `grill-with-docs` スキルを使う。
- 差分作成や review 本体は扱わない。

## 出力

- `goal`
- `confirmed_context`
- `terms`
- `success_criteria`
- `non_goals`
- `constraints`
- `assumptions`
- `prd_draft`
- `open_questions`
- `next_step`

`confirmed_context` と `open_questions` を混ぜず、未確認事項を確認済み前提として扱わない。
必要なら `docs_update_candidates` を添える。
