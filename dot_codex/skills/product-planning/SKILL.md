---
name: product-planning
description: 「依頼文が散らばっている」「今回どこまでやるか決めたい」「要件を固めたい」といった実装前の要件整理で使う。目的、成功条件、非目的、制約、用語、未確定事項を整理する。PRD draft は `to-prd`、技術計画は `implementation-planning`、docs 反映は `grill-with-docs` スキルを使う。
metadata:
  short-description: プロダクト計画
---

# プロダクト計画

計画を問いで鍛え、実装前に扱える要件へ整理する。

## 手順

- 依頼を短く言い換え、今回扱うことと扱わないことを置く。
- `CONTEXT-MAP.md` / `CONTEXT.md`、関連 docs、ADR、近傍 code で答えられる前提は先に確認する。
- 目的、成功条件、非目的、制約、用語、優先順位、未確定事項を分ける。
- 質問は 1 つずつ行い、推奨回答を添える。
- 成功条件は実装手段ではなく、確認できる結果で置く。
- 回答を受けたら、確定事項、仮定、未確定事項を分けて要件 draft に反映する。
- 要件整理の観点で迷う時だけ [references/product-planning-heuristics.md](references/product-planning-heuristics.md) を読む。

## 境界

- 実装順序や検証方法を詰める段階では `implementation-planning` スキルを使う。
- 整理済みの要件を PRD draft にする時は `to-prd` スキルを使う。
- plan / design 全体の pressure test は `grill-me`、docs / ADR 反映まで進める時は `grill-with-docs` スキルを使う。
- 要件 draft の review は `01-product-planning-reviewer` reviewer agent を使う。
- 差分作成や review 本体は扱わない。

## 出力

- `goal`
- `confirmed_context`
- `terms`
- `success_criteria`
- `non_goals`
- `constraints`
- `assumptions`
- `open_questions`
- `next_step`

`confirmed_context` と `open_questions` を混ぜず、未確認事項を確認済み前提として扱わない。
必要なら `docs_update_candidates` を添える。
