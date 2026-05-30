---
paths:
  - "src/**/*.{bas,cls}"
---

# VBA Rules

- 新規作成、Claude Code 主導の編集、明示的な正規化では `UTF-8 without BOM` / `LF` を既定にする。
- 既存 file の charset / 改行 / export 形式が明確な場合は、既存形式を優先する。
- Excel VBA の exported module では、`Attribute VB_Name` などの module attributes を不用意に削除しない。
- 新規 `.cls` は VBE import 可能な class header と class attributes を含める。
- `Attribute VB_Name` は 31 文字以内にする。
- procedure / function / sub / property / 変数などの一般識別子は 255 文字以内にする。
- 識別子は先頭を英字にし、空白、ピリオド、`!`、`@`、`&`、`$`、`#`、予約語、同一 scope 内の衝突を避ける。
- `Option Explicit` は module level で procedure より前に置く。
- public interface、macro entrypoint、sheet/module 名を変える場合は影響範囲を確認する。
- workbook 内部と exported source の同期が不明な場合は、未確認事項として残す。
