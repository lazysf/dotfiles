---
name: improve-codebase-architecture
description: 「コードベースの architecture を改善したい」「リファクタ候補を見つけたい」「密結合や浅い module を整理したい」といった、保守性や testability のための構造改善を検討する依頼で使う。対象領域を zoom out して module、caller、責務の地図を作り、architecture friction と改善候補を出し、候補選択後に設計を grilling する。単なる事実調査は `research` スキル、実装順序や変更範囲を固めたい時は `implementation-planning` スキル、実装に入る時は `code-implementation-loop` スキルを使う。
metadata:
  short-description: architecture 改善
---

# Improve Codebase Architecture

コードベースの構造を一段引いて把握し、保守性、変更容易性、testability を上げるための architecture 改善候補を整理する。

## 前提

- root に `CONTEXT-MAP.md` があれば対象 context を選び、該当 `CONTEXT.md`、関連 docs、ADR を読む。
- architecture 用語の補助が必要な時は `references/architecture-language.md` を読む。
- この skill は改善候補の探索、候補整理、候補選択後の grilling までを扱う。
- 実装順序、変更境界、検証方法を確定する段階では `implementation-planning` スキルへ進む。
- 差分作成やテスト修正に入る段階では `code-implementation-loop` スキルへ進む。

## 対象

- 大きくなった code path の責務を整理したい依頼。
- 密結合、浅い module、重複した caller knowledge、testability の低さを見つけたい依頼。
- リファクタ候補を複数出し、どれを深掘りするか選びたい依頼。
- 既存 domain language と ADR に沿って architecture 改善案を詰めたい依頼。

## 対象外

- 具体的な不具合原因や外部変化を調べるだけの依頼。`research` スキルを使う。
- 既に決まった改善案の実装計画を作る依頼。`implementation-planning` スキルを使う。
- 既存差分の品質 review。`03-quality-reviewer` reviewer agent を使う。
- security boundary の review。`04-security-reviewer` reviewer agent を使う。

## 基本方針

- まず対象領域を zoom out し、module、caller、責務、データや制御の流れを地図化する。
- 既存 domain language を優先し、`CONTEXT.md` にある用語で候補を説明する。
- ADR で決まっている判断を軽く覆さない。実害があり再検討に値する時だけ ADR conflict として明示する。
- 候補提示の段階では interface を決め切らない。ユーザーが候補を選んでから grilling で詰める。
- `CONTEXT.md` や ADR 更新が必要になった時は、`grill-with-docs` スキルに切り替える。

## Workflow

1. 対象領域と改善目的を一文で言い換える。
2. `CONTEXT-MAP.md` / `CONTEXT.md`、関連 docs、ADR、近傍 code、既存テストを読む。
3. zoom out して、主要 module、caller、責務、外部 I/O、テスト入口を地図化する。
4. architecture friction を探す。
   - 1 つの概念理解に多くの小さな module を行き来していないか。
   - caller が同じ知識や分岐を重複して持っていないか。
   - module の interface が implementation と同じくらい複雑になっていないか。
   - test が interface ではなく内部 detail に寄りすぎていないか。
5. 改善候補を番号付きで提示する。
6. ユーザーが候補を選んだら、制約、守る既存挙動、module shape、interface、tests、移行順序の未確定事項を 1 つずつ grilling する。
7. 実装計画に進める状態になったら、`implementation-planning` へ渡せる粒度で整理する。

## Candidate Output

- `map`: module / caller / responsibility の要約
- `friction`: どこで理解、変更、検証が散っているか
- `candidate`: 改善候補
- `benefit`: locality、leverage、testability のどれが改善するか
- `risk`: 既存挙動、ADR、公開 interface、検証不足の懸念
- `next_question`: 深掘りする候補を 1 つ選ぶ質問

候補選択後の grilling では、確定事項、未確定事項、次に必要な planning / implementation / docs 更新を分けて返す。
