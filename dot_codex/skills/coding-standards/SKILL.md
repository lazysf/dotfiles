---
name: coding-standards
description: "「VBA / Excel マクロの .bas / .cls を直したい」「対応済み言語のコーディング標準を確認したい」といった、コード作業で言語固有の制約やベストプラクティスが必要な依頼で使う。現時点では Excel VBA の exported .bas / .cls を対象に、対象ファイルや言語を特定して対応する reference だけを読み、既存の実装・レビュー・調査 skill に言語別ガードレールを足す。実装手順、原因調査、要件整理そのものは扱わず、実装は code-implementation-loop、調査は research、要件や技術計画の整理は product-planning / implementation-planning を使う。"
metadata:
  short-description: コーディング標準
---

# Coding Standards

言語やファイル形式ごとの制約を、通常の実装・調査・レビュー作業に足す補助 skill。
この skill は作業の主入口ではなく、対象言語で事故りやすい保存形式、公開面、例外処理、命名、生成ルールを確認するために使う。

## 基本方針

- まず対象ファイル、言語、実行環境を特定する。
- 対応する reference がある場合だけ読む。
- reference の標準は既定ガードとして扱い、既存挙動や互換性の都合で外す場合は理由と影響を明示する。
- 実装、原因調査、要件整理、レビュー本体は、この skill だけで進めない。

## Reference 選択

- Excel VBA の exported `.bas` / `.cls`: [references/vba-excel-macro.md](references/vba-excel-macro.md)

## 使い分け

- 実装に入る時は `code-implementation-loop` と併用する。
- 原因や影響を先に調べる時は `research` と併用する。
- 要件を固める時は `product-planning`、技術計画を固める時は `implementation-planning` と併用する。
- 言語別標準に関係しない README、ADR、設定説明だけの更新では使わない。

## 確認観点

- 対象 reference があるか。
- 既存ファイルの生成元、encoding、改行、metadata を壊していないか。
- 公開面、永続化、外部 I/O、秘密情報、破壊的操作に触れていないか。
- 標準から外した場合、その理由を説明できるか。
