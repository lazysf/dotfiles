---
name: architecture
description: 文脈上、architecture 改善、リファクタ候補探索、密結合・浅い module・責務分散の整理が必要な時に自動使用する。対象領域を zoom out し、module / caller / responsibility の map、friction、改善候補を整理する。事実調査だけなら `research`、実装前計画は `planning`、差分作成は `implementation` スキルを使う。
metadata:
  short-description: architecture 改善
---

# Architecture 改善

コードベースの構造を一段引いて把握し、保守性、変更容易性、testability を上げるための architecture 改善候補を整理する。

## 手順

- 対象領域と改善目的を一文で言い換える。
- `CONTEXT-MAP.md` / `CONTEXT.md`、関連 docs、ADR、近傍 code、既存テストを読む。
- 対象領域を zoom out し、module、caller、責務、外部 I/O、テスト入口を地図化する。
- 既存 domain language を優先し、`CONTEXT.md` にある用語で候補を説明する。
- ADR で決まっている判断を軽く覆さない。実害があり再検討に値する時だけ ADR conflict として明示する。
- architecture 用語の補助が必要な時だけ [references/architecture-language.md](references/architecture-language.md) を読む。
- friction を探し、改善候補を番号付きで提示する。
- ユーザーが候補を選んだら、制約、守る既存挙動、module shape、interface、tests、移行順序を 1 つずつ grilling する。
- 実装計画に進める状態になったら、`planning` へ渡せる粒度で整理する。

## 確認観点

- 1 つの概念理解に多くの小さな module を行き来していないか。
- caller が同じ知識や分岐を重複して持っていないか。
- module の interface が implementation と同じくらい複雑になっていないか。
- test が interface ではなく内部 detail に寄りすぎていないか。
- 改善候補が locality、leverage、testability のどれを改善するか説明できるか。

## 境界

- 具体的な不具合原因や外部変化の調査だけなら `research` スキルを使う。
- 実装順序、変更境界、検証方法を確定する段階では `planning` スキルを使う。
- 差分作成やテスト修正に入る段階では `implementation` スキルを使う。
- 既存差分の品質 review は `quality-reviewer`、security boundary review は `security-reviewer` reviewer agent を使う。
- `CONTEXT.md` や ADR 更新が必要になった時は `planning` スキルを使う。

## 出力

- `map`: module / caller / responsibility の要約
- `friction`: どこで理解、変更、検証が散っているか
- `candidate`: 改善候補
- `benefit`: locality、leverage、testability のどれが改善するか
- `risk`: 既存挙動、ADR、公開 interface、検証不足の懸念
- `next_question`: 深掘りする候補を 1 つ選ぶ質問

候補選択後の grilling では、確定事項、未確定事項、次に必要な planning / implementation / docs 更新を分けて返す。
