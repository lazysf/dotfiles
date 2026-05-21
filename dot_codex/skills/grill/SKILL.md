---
name: grill
description: 文脈上、実装、設計、要件整理、仕様化の前に、共有理解へ到達するまで一問ずつ問い詰める必要がある時に自動使用する。確定事項を適切な doc / artifact に最小反映し、未確認事項を残したまま勝手に打ち切らず、scope、成功条件、制約、検証入口、実装 readiness を固める。format 整形や本格的な docs 更新は `scribe`、事実調査は `research`、差分作成は `implementation` スキルを使う。
metadata:
  short-description: 共有理解の問い詰め
---

# Grill

実装や文書化に入る前に、共有理解へ到達するまで一問ずつ問い詰める。
回答ごとに確定事項、仮定、未確認事項を分け、確定事項だけを適切な doc / artifact に最小反映する。

## 手順

- 依頼を短く言い換え、目的、作る成果物、今回扱わないことを置く。
- `CONTEXT-MAP.md` / `CONTEXT.md`、関連 docs、ADR、近傍 code、既存 tests で答えられる前提は先に確認する。
- どの artifact に反映すべきか迷う時は [references/artifact-routing.md](references/artifact-routing.md) を読む。
- 要件整理の観点で迷う時は [references/requirements-heuristics.md](references/requirements-heuristics.md) を読む。
- 技術計画の観点で迷う時は [references/implementation-heuristics.md](references/implementation-heuristics.md) を読む。
- 最も影響が大きい未確認事項を 1 つ選ぶ。
- 質問は 1 つだけ出し、必ず推奨回答を添える。
- 回答を受けたら、確定事項、仮定、未確認事項、docs 更新候補を分ける。
- 確定事項は、置き場と形式が明確な場合だけ doc / artifact へ最小反映する。
- 共有理解に到達するまで、最も影響が大きい未確認事項を 1 つずつ詰める。
- 実装へ進む前に、scope、成功条件、変更境界、検証入口、未確認事項、残リスクを明示する。

## 反映

- 小さい追記や未確認事項の移動は `grill` 単独で行ってよい。
- 新規 artifact の本格作成、format 適用、ID / section / traceability 整理、複数 docs の整合更新は `scribe` スキルを使う。
- `CONTEXT.md` は glossary として扱い、spec、作業メモ、実装判断、秘密情報を混ぜない。
- 既存 docs や note を更新する場合は、会話中に確認された evidence に限定し、自然な置き場が不明なら質問を続ける。
- ADR が必要に見える場合は、作成や状態更新を提案してから `scribe` スキルで扱う。
- 成果物の `未確認事項` に残すべき未確認事項は、確認済み知識として `CONTEXT.md`、ADR、notes に昇格させない。
- 秘密情報、認証情報、private config、未公開個人情報は durable artifact に残さない。

## 境界

- バグ原因、再現条件、外部変化の事実調査だけなら `research` スキルを使う。
- architecture 改善候補の探索なら `architecture` スキルを使う。
- 文書本文の作成、更新、整形、format 適用は `scribe` スキルを使う。
- 差分作成やテスト実装は `implementation` スキルを使う。
- 品質 review は `quality-reviewer`、security review は `security-reviewer` reviewer agent を使う。

## 出力

- `confirmed_context`
- `scope`
- `non_scope`
- `updated_docs`
- `open_questions`
- `readiness`
- `next_question`

`confirmed_context` と `open_questions` を混ぜず、未確認事項を確認済み前提として扱わない。
