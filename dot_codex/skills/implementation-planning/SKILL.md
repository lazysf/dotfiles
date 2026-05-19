---
name: implementation-planning
description: 「実装順序を決めたい」「影響範囲と検証方法を詰めたい」「リファクタ境界や品質・互換性・セキュリティの範囲を整理したい」といった技術計画で使う。変更境界、依存関係、検証入口、既存パターンとの矛盾を詰める。実装は `code-implementation-loop` スキルを使う。
metadata:
  short-description: 技術計画
---

# 技術計画

要件が固まったあとに、実装計画を問いで鍛え、安全に実行できる段取りへ整理する。

## 手順

- 要件 draft の目的、成功条件、非目的、制約を確認する。
- `CONTEXT-MAP.md` / `CONTEXT.md`、関連 docs、ADR、近傍 code、既存テストを読む。
- 変更境界、依存関係、検証入口、既存パターンとの矛盾を洗い出す。
- 質問は 1 つずつ行い、推奨回答を添える。
- 回答を受けたら、計画、リスク、未確定事項を更新する。
- 最小スライス、後続ステップ、検証方法を並べる。
- 計画の粒度や確認順で迷う時だけ [references/architect-planning-heuristics.md](references/architect-planning-heuristics.md) を読む。

## 境界

- 目的や成功条件がまだ曖昧なら `product-planning` スキルを使う。
- 事実調査だけなら `research` スキルを使う。
- architecture 改善候補の探索なら `improve-codebase-architecture` スキルを使う。
- 差分作成は `code-implementation-loop` スキルを使う。
- 計画 review は `02-implementation-planning-reviewer` reviewer agent を使う。
- 品質 review は `03-quality-reviewer`、security review は `04-security-reviewer` reviewer agent を使う。
- inline docs 更新や ADR 作成まで行う場合は `grill-with-docs` スキルを使う。

## 確認観点

- 触る箇所と触らない箇所が分かれているか。
- schema、config、runtime、権限、外部 I/O など先に確認すべき依存がないか。
- 近傍実装、test placement、命名、用語に沿っているか。
- test、lint、build、手動確認のどれで見るか。
- 公開インターフェース、永続化、認証認可、秘密情報、本番設定に触れないか。

## 出力

- `confirmed_requirements`
- `context_checked`
- `implementation_scope`
- `non_scope`
- `steps`
- `verification`
- `risks`
- `open_questions`
- `next_step`

`verification` には実行可能な確認入口を書き、未確認事項や実行後の結果と混ぜない。
根拠が弱いリスクや前提は、実装手順ではなく `risks` または `open_questions` に残す。
