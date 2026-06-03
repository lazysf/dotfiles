---
name: architecture
description: lead が basic-design.md / detailed-design.md を作る前に、構造改善、責務分担、module boundary、interface、data flow、testability、security boundary を整理する時に使う。原因調査は `research`、差分作成は `implement`。
---

# Architecture

構造、責務、境界、interface、data flow、testability を設計判断へ落とす。

## 手順

- 対象領域と改善目的を一文で言い換える。
- `requirements.md`、researcher handoff、関連 docs、ADR、近傍 code、既存テストを読む。
- module、caller、責務、外部 I/O、テスト入口を地図化する。
- 既存 domain language を優先し、`CONTEXT.md` にある用語で候補を説明する。
- ADR と衝突する案は conflict として明示する。
- basic-design.md / detailed-design.md で構造・責務・境界・data flow を記述する時は、用語の定義と使い分けを [references/architecture-language.md](references/architecture-language.md) に置いているため、記述する前に読んで用語を揃える。
- `basic-design.md` に置く全体方針・責務境界と、`detailed-design.md` に置く処理詳細を分ける。
- friction と改善候補を番号付きで出す。

## 確認観点

- 概念理解に多くの module を行き来していないか。
- caller が同じ知識や分岐を重複して持っていないか。
- interface が implementation と同じくらい複雑になっていないか。
- test が interface ではなく内部 detail に寄りすぎていないか。
- 改善候補が locality、leverage、testability のどれを改善するか説明できるか。
- security / 権限 / data / 外部 I/O の境界が設計上見えているか。

## 境界

- 原因調査は `research`。
- 実装順序、変更境界、検証方法の合意形成は `grill`。
- docs / CONTEXT / ADR 反映は `scribe`。
- 差分作成やテスト修正は `implement`。
- Gate 2 design review は `design-reviewer`、security boundary review は `security-reviewer` を使う。

## 出力

- `map`: module / caller / 責務 / 外部 I/O の地図
- `friction`: 構造上の摩擦点
- `candidate`: 番号付き改善候補
- `basic_design_notes`: `basic-design.md` に置く判断
- `detailed_design_notes`: `detailed-design.md` に置く判断
- `next_question`: 候補選択・実装順序の問い詰めへ渡す点

## 停止条件

- 対象領域の実装や依存が workspace 外にあり、根拠ある設計ができない。
- ADR と衝突する候補しか残らず、方針変更の判断が必要。
