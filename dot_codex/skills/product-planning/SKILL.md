---
name: product-planning
description: 「計画を深掘りしたい」「要件を固めたい」「目的や成功条件を整理したい」といった重めの要件定義で使う。問いを 1 つずつ立て、探索で答えられることは先に確認し、目的、成功条件、非目的、制約、用語、未確定事項を実装可能な要件へ落とし込む。plan / design を横断的に stress-test したい時は `grill-me` スキル、既存 docs や ADR と照合して inline 更新したい時は `grill-with-docs` スキルを使う。
metadata:
  short-description: プロダクト計画
---

# Product Planning

計画を問いで鍛え、実装前に扱える要件へ整理する。

## 前提

- [AGENTS.md](../../AGENTS.md) の契約と停止線を前提に適用する。
- root に `CONTEXT-MAP.md` があれば multi-context repo として扱い、対象 context を選んでから該当 `CONTEXT.md` を読む。
- root に `CONTEXT.md` だけがあれば single-context repo として扱う。
- CONTEXT は glossary であり、spec、作業メモ、実装判断の置き場にしない。

## 目的

- 曖昧な計画を、実装可能な要件へ落とし込む。
- 目的、成功条件、非目的、制約、用語、優先順位、未確定事項を明確にする。
- context / docs / code / ADR と照合し、既存の言葉や判断と矛盾したまま進むのを避ける。
- 実装タスクではなく、ユーザー価値や運用上の完了条件を定義する。
- plan / design 全体の pressure test や inline docs 更新が主目的の場合は、`grill-me` または `grill-with-docs` に切り替える。

## 対象

- 背景、目的、成功条件、対象ユーザーが曖昧な依頼。
- 実装前に合意すべき用語、制約、非目的、優先順位が多い依頼。
- 既存 context / docs / code / ADR と照らして計画を詰めたい依頼。
- `task-intake` では不足する重めの上流整理。

## 対象外

- 軽い入口整理だけで足りる依頼。`task-intake` スキルを使う。
- 事実確認だけが目的の依頼。`research` スキルを使う。
- 実装順序、影響範囲、検証方法を詰める依頼。`implementation-planning` スキルを使う。
- 要件 draft のレビュー本体。`01-product-planning-reviewer` reviewer agent を使う。

## 基本方針

- 質問は 1 つずつ行い、各質問に推奨回答を添える。
- context / docs / code / ADR で答えられる疑問は、ユーザーへ聞く前に探索する。
- 用語の曖昧さ、成功条件、非目的、制約、既存挙動との矛盾、判断の不可逆性を優先して詰める。
- 解決策より先に、目的と期待結果を揃える。
- 成功条件は実装手段ではなく、確認できる結果で置く。
- 技術設計の詳細には踏み込みすぎない。
- この skill 自体は review を行わず、要件整理に専念する。

## Planning Loop

1. 依頼を短く言い換え、今回の主題と停止線を置く。
2. `CONTEXT-MAP.md` / `CONTEXT.md`、関連 docs、ADR、近傍 code から、先に確認できる事実を集める。
3. 既存用語と違う言葉、曖昧な言葉、複数意味を持つ言葉を見つけたら、その場で正す。
4. 最も影響が大きい未確定事項を 1 つ選び、推奨回答つきで質問する。
5. 回答を受けたら、確定事項、仮定、未確定事項を分けて要件 draft に反映する。
6. 用語や判断を inline で docs に反映する必要が出たら、`grill-with-docs` へ切り替える。
7. 判断が ADR 条件を満たしそうな場合は、`grill-with-docs` で扱う候補として分離する。
8. 目的、成功条件、非目的、制約が説明できるまで 3-7 を繰り返す。

## CONTEXT の扱い

- 用語は、その context 固有の domain language だけを入れる。
- 一般的なプログラミング用語、実装詳細、設定値、短命な作業メモは入れない。
- 1 つの概念には canonical term を選び、避けたい別名があれば `_Avoid_` に残す。
- 既存 glossary と衝突する場合は、黙って上書きせず、どちらの意味で使うか確認する。
- context が複数あり、対象 context が不明なら推測で新しい `CONTEXT.md` を作らず確認する。

## ADR の扱い

ADR は次の 3 条件をすべて満たす場合だけ候補にする。

1. あとから変えるコストが意味を持つ。
2. 文脈なしに見ると将来の読み手が驚く。
3. 実際の trade-off から選ばれた判断である。

ADR を作る場合は `Status` を必須にし、本文は必要十分に短くする。
判断がまだ採用されていないなら `Proposed`、採用が明示されているなら `Accepted` へ進める。

## 出力ガイド

- `goal`
- `confirmed_context`
- `terms`
- `success_criteria`
- `non_goals`
- `constraints`
- `assumptions`
- `open_questions`
- `next_step`

必要なら `docs_update_candidates` を添える。
ただし inline 更新や ADR 作成まで行う場合は `grill-with-docs` スキルを使う。
review を求める場合は、この出力を `01-product-planning-reviewer` reviewer agent に渡せる粒度で整理する。
