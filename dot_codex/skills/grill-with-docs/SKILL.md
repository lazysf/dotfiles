---
name: grill-with-docs
description: 「docs と照らして問い詰めたい」「CONTEXT / ADR と照合して grill して」といった、plan / design を既存 docs、ADR、codebase language に照らして詰める依頼で使う。確定した用語や判断だけ inline 記録する。docs 更新なしの grilling は `grill-me` スキルを使う。
metadata:
  short-description: docs と照らして問い詰める
---

# Docs と照らして問い詰める

計画や設計を問い詰めながら、既存の domain language、docs、ADR、code と照合し、確定した durable knowledge をその場で反映する。

## 手順

- `grill-me` と同じく、質問は 1 つずつ行い、推奨回答を添える。
- codebase、`CONTEXT-MAP.md` / `CONTEXT.md`、関連 docs、ADR で答えられることは先に確認する。
- 既存用語との衝突、曖昧語、code との矛盾を見つけたら、具体例を添えてどちらを正とするか確認する。
- 回答を受けたら、確定事項、残る未確定事項、必要な docs 更新を分ける。
- 共有理解に到達するまで、最も影響が大きい未確定事項を 1 つずつ詰める。

## 対象 Context の扱い

- root に `CONTEXT-MAP.md` があれば multi-context repo として扱う。
- multi-context repo では、map から対象 context を選び、該当する `CONTEXT.md` と ADR 置き場を使う。
- root に `CONTEXT.md` だけがあれば single-context repo として扱う。
- `CONTEXT.md` が存在しない場合は、最初の用語が解決されるまで作成しない。
- 対象 context が不明なら、推測で root `CONTEXT.md` を作らず確認する。

## Inline 記録

- `CONTEXT.md` は glossary であり、spec、作業メモ、実装判断、秘密情報を混ぜない。
- `CONTEXT.md` を更新する時は [references/context-format.md](references/context-format.md) に従う。
- 用語が確定したら、対象 context の `CONTEXT.md` を inline 更新する。
- ADR は、あとから変えるコスト、文脈なしの意外性、実際の trade-off の 3 条件を満たす場合だけ扱う。
- ADR を作成または状態更新する時は [references/adr-format.md](references/adr-format.md) に従う。
- ADR 作成や状態更新は、提案してから実行する。
- 既存 docs や note を更新する場合は、会話中に確認された evidence に限定し、自然な置き場が不明なら確認する。
- 秘密情報、認証情報、private config、未公開個人情報は durable artifact に残さない。
- commit 前の差分確認と commit 作成は扱わない。commit したい時は `git-commit` スキルを使う。

## 出力

- `confirmed_context`
- `resolved_terms`
- `updated_docs`
- `adr_changes`
- `open_questions`
- `grill_status`
- `next_question`

一段落した時は、`grill_status: 一段落`、確定事項、更新した docs / ADR、残る未確認事項、次に進める入口を短く示す。
まだ問いを続ける必要がある時は、`next_question` を 1 つだけ出す。
