---
name: implementation-planning
description: 「実装順序を決めたい」「影響範囲と検証方法を詰めたい」「要件確定後に技術計画を固めたい」といった依頼で使う。変更境界、依存関係、検証入口、既存パターンとの矛盾を問いで 1 つずつ詰め、実行可能な技術計画へ落とし込む。plan / design を横断的に stress-test したい時は `grill-me` スキル、既存 docs や ADR と照合して inline 更新したい時は `grill-with-docs` スキルを使う。
metadata:
  short-description: 技術計画
---

# Implementation Planning

要件が固まったあとに、実装計画を問いで鍛え、安全に実行できる段取りへ整理する。

## 前提

- [AGENTS.md](../../AGENTS.md) の契約と停止線を前提に適用する。
- 目的、成功条件、非目的、制約が説明できる状態で使う。
- root に `CONTEXT-MAP.md` があれば対象 context を選び、該当 `CONTEXT.md` を読んでから計画する。
- CONTEXT は glossary であり、実装判断は ADR または計画本文で扱う。

## 目的

- 既存 context / docs / code / ADR に沿った実装計画を作る。
- 最初に通すべき最小スライスを決め、書き込み範囲を広げすぎない。
- 変更境界、依存関係、検証入口、既存パターンとの矛盾を先に潰す。
- 技術計画全体の pressure test や inline docs 更新が主目的の場合は、`grill-me` または `grill-with-docs` に切り替える。

## 対象

- 要件がある程度固まり、実装順序や影響範囲を整理したい依頼。
- 複数ファイルや複数レイヤーにまたがる実装の段取りを詰めたい依頼。
- 既存 context / docs / code / ADR と照合して技術計画を固めたい依頼。

## 対象外

- 目的や成功条件がまだ曖昧な依頼。`product-planning` スキルを使う。
- 事実調査だけが目的の依頼。`research` スキルを使う。
- 計画 draft のレビュー本体。`02-implementation-planning-reviewer` reviewer agent を使う。
- そのまま実装に入れるほど小さい依頼。

## 基本方針

- 質問は 1 つずつ行い、各質問に推奨回答を添える。
- context / docs / code / ADR で答えられる疑問は、ユーザーへ聞く前に探索する。
- 既存の責務、ファイル配置、テスト配置、命名、用語に寄せる。
- 不要な抽象化や大規模設計を前提にしない。
- この skill 自体は review を行わず、実装計画の整理に専念する。

## Planning Loop

1. 要件 draft を確認し、目的、成功条件、非目的、制約が足りるかを見る。
2. 対象 context、関連 docs、ADR、近傍 code、既存テストを読む。
3. 変更境界、依存関係、検証入口、既存パターンとの矛盾を洗い出す。
4. 最も計画を左右する未確定事項を 1 つ選び、推奨回答つきで質問する。
5. 回答を受けたら、計画、リスク、未確定事項を更新する。
6. 最小スライス、後続ステップ、検証方法を並べる。
7. 判断が ADR 条件を満たし、inline で記録したい場合は `grill-with-docs` へ切り替える。

## 確認観点

- 変更境界: 触る箇所と触らない箇所が分かれているか。
- 依存関係: 先に確認すべき schema、config、runtime、権限、外部 I/O がないか。
- 既存パターン: 近傍実装、test placement、命名、用語に沿っているか。
- 検証入口: test、lint、build、手動確認のどれで見るか。
- 切り戻し: 変更が切り戻しやすい単位に分かれているか。
- 停止線: 公開インターフェース、永続化、認証認可、秘密情報、本番設定に触れないか。

## 出力ガイド

- `confirmed_requirements`
- `context_checked`
- `implementation_scope`
- `non_scope`
- `steps`
- `verification`
- `risks`
- `open_questions`
- `next_step`

必要なら `docs_update_candidates` を添える。
ただし inline 更新や ADR 作成まで行う場合は `grill-with-docs` スキルを使う。
review を求める場合は、この出力を `02-implementation-planning-reviewer` reviewer agent に渡せる粒度で整理する。
