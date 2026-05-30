# VBA Implementation Reference Design

このメモは、VBA の path rule と `implement` の VBA best practices reference の分担をまとめる。

## Context

- 現行では独立 skill ではなく、`implement` が対応ファイルを扱う時だけ読む reference として扱う。
- path rule は `src/**/*.{bas,cls}` に限定する。
- reference は Excel VBA の exported `.bas` / `.cls` に限定する。
- quality review では、reference 範囲より広い description、無効な `Attribute VB_Name` を生成しうるルール、新規 `.cls` の import 可能な skeleton 不足が指摘された。
- security review では、外部 I/O、秘密情報、保存上書き、VBE automation などの停止線に重大な指摘はなかった。

## Guidance

- VBA best practices reference は、主役 workflow ではなく `implement` の補助 reference として設計する。調査は `research`、実装前の問い詰めは `grill` に任せる。
- `implement/SKILL.md` は薄い router にし、言語固有の詳細は `references/` に分ける。description は変更実装として発火しやすく保ち、現時点で対応する言語やファイル種別は本文や references に逃す。
- path rule で毎回効かせたい短い制約は `rules/vba.md` に置き、reference にはベストプラクティス、例外条件、skeleton、影響確認の観点を置く。
- 新しい reference を追加するときは、発火語、対象/非対象、保存形式、公開面、停止線、標準から外す例外条件をそろえる。
- exported file 形式を扱う reference では、ソース本文だけでなく import/export に必要な metadata、header、encoding、改行、名前制約まで確認する。
- ファイル名から識別子を生成するルールは、有効名条件と衝突回避を一緒に書く。無効名の場合は黙って別名を作らず、rename / 正規化方針を確認する。
- review では、`description` の発火範囲と `references/` の実対応範囲がずれていないかを重点確認する。

## References

- [implement skill](../../dot_claude/skills/implement/SKILL.md)
- [VBA rule](../../dot_claude/rules/vba.md)
- [VBA best practices reference](../../dot_claude/skills/implement/references/vba-best-practices.md)
- [Runtime Surface Guidance](./runtime-surface-guidance.md)
