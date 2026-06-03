---
name: architecture
description: 構造改善、責務分担、module boundary、interface、data flow、testability、security boundary を整理する時に使う。module / caller / responsibility / external I/O を地図化し、friction と改善候補を出す。原因調査は `research`、差分作成は `implement`。
metadata:
  short-description: architecture 改善
---

# Architecture 改善

構造を一段引いて見て、責務、境界、interface、data flow、保守性、変更容易性、testability の改善候補を整理する。

## 手順

- 対象領域と改善目的を一文で言い換える。
- `CONTEXT-MAP.md` / `CONTEXT.md`、関連 docs、ADR、近傍 code、既存テストを読む。
- module、caller、責務、interface、data flow、外部 I/O、security / 権限 / data boundary、テスト入口を地図化する。
- 既存 domain language を優先し、`CONTEXT.md` にある用語で候補を説明する。
- ADR と衝突する案は conflict として明示する。
- basic-design.md / detailed-design.md で構造・責務・境界・data flow を記述する時は、用語の定義と使い分けを [references/architecture-language.md](references/architecture-language.md) に置いているため、記述する前に読んで用語を揃える。
- friction と改善候補を番号付きで出す。
- ユーザーが候補を選んだら、制約、守る既存挙動、module shape、interface、tests、移行順序を 1 つずつ grilling する。
- 実装前に問い詰める状態なら、`grill` へ渡せる粒度で整理する。

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
- 品質 review は `quality-reviewer`、security boundary review は `security-reviewer`。

## 出力

- `map`
- `friction`
- `candidate`
- `benefit`
- `risk`
- `boundary_notes`
- `next_question`

候補選択後の grilling では、確定事項、未確定事項、次に必要な `grill` / `scribe` / `implement` を分けて返す。

## 停止条件

- 対象領域の実装や依存が workspace 外にあり、根拠ある設計ができない。
- ADR と衝突する候補しか残らず、方針変更の判断が必要。
