# CONTEXT 形式

`CONTEXT.md` は context 固有の言葉の glossary として扱う。
spec、scratchpad、実装計画、判断記録、秘密情報の置き場ではない。
この repo では、確立済み英語用語を残す方が明確な場合を除き、`CONTEXT.md` 本文は日本語で書く。

## 構造

```markdown
# [Context 名]

[この context が何で、なぜ存在するかを 1-2 文で説明する。]

## 用語

**Term**: [概念の短い 1 文定義。]
_Avoid_: [避ける alias や多義語]

## 関係

- **Term A** は **Term B** と関係する

## 曖昧さの記録

- "[曖昧な語]" が **A** と **B** の両方の意味で使われた。Resolved: [resolution]
```

## ルール

- canonical term を選び、避ける alias を明示する。
- prose は日本語で書く。ただし、翻訳すると glossary の精度が落ちる確立済み英語 domain terms は残す。
- 定義は短く保つ。最大 1 文で、それが何かを定義し、実装 behavior は書かない。
- この context 固有の用語だけを入れる。一般的な programming concept は入れない。
- 関係は太字の term 名で示し、明らかな場合は cardinality も書く。
- 衝突は `曖昧さの記録` に明示し、resolution を書く。
- 対話例は、用語境界を短い定義だけで示しにくい場合だけ `## 対話例` として追加する。
- 自然なまとまりがある場合だけ subheading で group 化する。
- secrets、credentials、private config values、未公開個人情報、一時的な作業メモ、spec、実装判断を入れない。

## 単一 / 複数 Context

単一 context repo:

- root `CONTEXT.md` を 1 つ使う。

複数 context repo:

- root `CONTEXT-MAP.md` を使う。
- 各 context、対応する `CONTEXT.md` の場所、context 間の関係を書く。
- 各 `CONTEXT.md` は、それが説明する対象の近くに置く。

更新時:

- `CONTEXT-MAP.md` があれば先に読み、関連する context を選ぶ。
- root `CONTEXT.md` だけがあれば、single context として更新する。
- どちらもない場合は、最初の term が解決された時だけ root `CONTEXT.md` を作る。
- 複数 context があり対象 context が曖昧なら、推測で新しい context を作らず確認する。
