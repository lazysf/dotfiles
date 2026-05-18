---
name: grill-with-docs
description: 「docs と照らして計画を問い詰めたい」「CONTEXT / ADR と照合して grill して」といった、plan / design を既存 docs と codebase language に照らして stress-test したい依頼で使う。質問を 1 つずつ行い、確定した用語や ADR 条件を満たす判断だけ inline 記録する。docs 更新を伴わない純粋な grilling は `grill-me` スキルを使う。
metadata:
  short-description: docs と照らして問い詰める
---

# Grill With Docs

計画や設計を問い詰めながら、既存の domain language、docs、ADR、code と照合し、確定した durable knowledge をその場で反映する。

## 基本方針

- `grill-me` と同じく、質問は 1 つずつ行い、各質問には推奨回答を添える。
- codebase を探索すれば答えられる疑問は、ユーザーへ聞く前に探索する。
- `CONTEXT-MAP.md` / `CONTEXT.md`、関連 docs、ADR、近傍 code を見て、既存の言葉や判断と照合する。
- 用語が既存 `CONTEXT.md` と衝突する場合は、その場で衝突を示して確認する。
- 曖昧な言葉や overloaded term は、具体例を使って境界を詰める。
- ユーザーが述べた挙動と code が矛盾する場合は、どちらを正とするか確認する。

## Domain Awareness

### File structure

- root に `CONTEXT-MAP.md` があれば multi-context repo として扱う。
- multi-context repo では、map から対象 context を選び、該当する `CONTEXT.md` と ADR 置き場を使う。
- root に `CONTEXT.md` だけがあれば single-context repo として扱う。
- `CONTEXT.md` が存在しない場合でも、最初の用語が解決されるまで作成しない。
- 対象 context が不明なら、推測で root `CONTEXT.md` を作らず確認する。

### During the session

1. 対象 plan / design / 方針を短く言い換える。
2. `CONTEXT-MAP.md` / `CONTEXT.md`、関連 docs、ADR、近傍 code から答えられる前提を確認する。
3. 既存用語との衝突、曖昧語、code との矛盾を探す。
4. 最も影響が大きい未確定事項を 1 つ選び、推奨回答つきで質問する。
5. 回答を受けたら、確定事項、残る未確定事項、必要な docs 更新を切り分ける。
6. 用語が確定したら `CONTEXT.md` を inline 更新する。
7. 判断が ADR 条件を満たす場合だけ、ADR 作成や状態更新を提案してから実行する。
8. 共有理解に到達するまで 3-7 を繰り返す。
9. 主要な未確定事項が解け、次が実装、調査、commit など別 workflow になる時は、`grill_status: 一段落` と示す。

## Inline Knowledge Capture

- `CONTEXT.md` は glossary であり、spec、作業メモ、実装判断、秘密情報を混ぜない。
- `CONTEXT.md` を更新する時は [references/context-format.md](references/context-format.md) に従う。
- ADR は、あとから変えるコスト、文脈なしの意外性、実際の trade-off の 3 条件を満たす場合だけ扱う。
- ADR を作成または状態更新する時は [references/adr-format.md](references/adr-format.md) に従う。
- 手順、確認ポイント、落とし穴、軽量な運用メモは ADR ではなく既存 docs や `docs/notes/` の候補として扱う。
- 既存 docs や note を更新する場合は、会話中に確認された evidence に限定し、自然な置き場が不明なら確認する。
- 秘密情報、認証情報、private config、未公開個人情報は durable artifact に残さない。
- commit 前の差分確認と commit 作成は扱わない。commit したい時は `git-commit` スキルを使う。

## Output Guide

- `confirmed_context`
- `resolved_terms`
- `updated_docs`
- `adr_changes`
- `open_questions`
- `grill_status`
- `next_question`

一段落した時は、`grill_status: 一段落`、確定事項、更新した docs / ADR、残る未確認事項、次に進める入口を短く示す。
まだ問いを続ける必要がある時は、`next_question` を 1 つだけ出す。
