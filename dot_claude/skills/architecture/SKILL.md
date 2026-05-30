---
name: architecture
description: 構造改善、責務分散、密結合、浅い module、リファクタ候補、変更容易性、testability を整理する時に使う。module / caller / responsibility を地図化し、friction と改善候補を出す。原因調査は `research`、差分作成は `implement`。
---

# Architecture 改善

## 手順

- 対象領域と改善目的を一文で言い換える。
- `CONTEXT-MAP.md` / `CONTEXT.md`、関連 docs、ADR、近傍 code、既存テストを読む。
- module、caller、責務、外部 I/O、テスト入口を地図化する。
- 既存 domain language を優先し、`CONTEXT.md` にある用語で候補を説明する。
- ADR と衝突する案は conflict として明示する。
- architecture 用語の補助が必要な時だけ [references/architecture-language.md](references/architecture-language.md) を読む。
- friction と改善候補を番号付きで出す。
- ユーザーが候補を選んだら、制約、守る既存挙動、module shape、interface、tests、移行順序を 1 つずつ `grill` へ渡せる粒度で詰める。

## 確認観点

- 概念理解に多くの module を行き来していないか。
- caller が同じ知識や分岐を重複して持っていないか。
- interface が implementation と同じくらい複雑になっていないか。
- test が interface ではなく内部 detail に寄りすぎていないか。
- 改善候補が locality、leverage、testability のどれを改善するか説明できるか。

## 境界

- 原因調査は `research`。
- 実装順序、変更境界、検証方法の合意形成は `grill`。
- docs / CONTEXT / ADR 反映は `scribe`。
- 差分作成やテスト修正は `implement`。
- 設計 draft の review は `spec-reviewer`、品質 review は `quality-reviewer`、security boundary review は `security-reviewer` reviewer subagent。

## 出力

- `map`: module / caller / 責務 / 外部 I/O の地図
- `friction`: 構造上の摩擦点
- `candidate`: 番号付き改善候補（各候補に benefit / risk と、改善する性質 locality / leverage / testability）
- `next_question`: 候補選択・実装順序の問い詰めへ渡す点
