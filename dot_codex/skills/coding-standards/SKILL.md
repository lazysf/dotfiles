---
name: coding-standards
description: 「VBA / Excel マクロの .bas / .cls を直したい」「対応 reference がある言語固有標準を確認したい」といった補助で使う。対象 reference だけを読み、通常作業に保存形式、公開面、例外処理などのガードを足す。実装は `code-implementation-loop`、調査は `research` スキルを使う。
metadata:
  short-description: コーディング標準
---

# コーディング標準

言語やファイル形式ごとの制約を、通常の実装・調査・レビュー作業に足す補助 skill。

## 手順

- まず対象ファイル、言語、実行環境を特定する。
- 対応する reference がある場合だけ読む。対象外の reference は読まない。
- reference の標準は既定ガードとして扱い、既存挙動や互換性の都合で外す場合は理由と影響を明示する。
- 実装、原因調査、要件整理、レビュー本体は、この skill だけで進めない。

## Reference 選択

- Excel VBA の exported `.bas` / `.cls`: [references/vba-excel-macro.md](references/vba-excel-macro.md)

## 境界

- 実装に入る時は `code-implementation-loop` と併用する。
- 原因や影響を先に調べる時は `research` と併用する。
- 要件を固める時は `product-planning`、技術計画を固める時は `implementation-planning` と併用する。
- 言語別標準に関係しない README、ADR、設定説明だけの更新では使わない。

## 確認観点

- 対象 reference があるか。
- 既存ファイルの生成元、encoding、改行、metadata を壊していないか。
- 公開面、永続化、外部 I/O、秘密情報、破壊的操作に触れていないか。
- 標準から外した場合、その理由を説明できるか。
