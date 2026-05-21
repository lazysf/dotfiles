# VBA Implementation Reference Design

このメモは、言語別コーディング標準を `implementation` の reference として追加するときの設計・レビュー観点をまとめる。

## Context

- 旧 `coding-standards` は、実装・調査・計画・レビュー本体を置き換えず、言語別の制約やベストプラクティスを足す補助 skill として追加した。
- 現行では独立 skill ではなく、`implementation` が対応ファイルを扱う時だけ読む reference として吸収する。
- 初回 reference は Excel VBA の exported `.bas` / `.cls` に限定した。
- quality review では、reference 範囲より広い description、無効な `Attribute VB_Name` を生成しうるルール、新規 `.cls` の import 可能な skeleton 不足が指摘された。
- security review では、外部 I/O、秘密情報、保存上書き、VBE automation などの停止線に重大な指摘はなかった。

## Guidance

- 言語別標準は、主役 workflow ではなく `implementation` の補助 reference として設計する。調査は `research`、実装前の問い詰めは `grill` に任せる。
- `implementation/SKILL.md` は薄い router にし、言語固有の詳細は `references/` に分ける。description は変更実装として発火しやすく保ち、現時点で対応する言語やファイル種別は本文や references に逃す。
- 新しい reference を追加するときは、発火語、対象/非対象、保存形式、公開面、停止線、標準から外す例外条件をそろえる。
- exported file 形式を扱う reference では、ソース本文だけでなく import/export に必要な metadata、header、encoding、改行、名前制約まで確認する。
- ファイル名から識別子を生成するルールは、有効名条件と衝突回避を一緒に書く。無効名の場合は黙って別名を作らず、rename / 正規化方針を確認する。
- review では、`description` の発火範囲と `references/` の実対応範囲がずれていないかを重点確認する。

## References

- [implementation skill](../../dot_codex/skills/implementation/SKILL.md)
- [Excel VBA reference](../../dot_codex/skills/implementation/references/vba-excel-macro.md)
- [Runtime Surface Guidance](./runtime-surface-guidance.md)
