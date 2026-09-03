# VBA

`.bas` / `.cls` を扱う時に読む。VBE と exported source の間で壊れやすい部分を定める。VBA は import 時に形式を厳密に見るため、charset や attributes が崩れると module ごと読み込めなくなる。

`.cls` は LaTeX のクラスファイルや Salesforce Apex のクラスでも使う拡張子で、`.bas` も FreeBASIC など他の BASIC 系で使う。拡張子だけで判断せず、Excel や Office の VBA だと確かめてから適用する。

## 保存形式

- 新規作成、Claude Code 主導の編集、明示的な正規化では `UTF-8 without BOM` / `LF` を既定にする。
- 既存 file の charset / 改行 / export 形式が明確な場合は、既存形式を優先する。

## module attributes

VBE が import する時に読む metadata で、消えると module の identity が失われる。

- Excel VBA の exported module では、`Attribute VB_Name` などの module attributes を不用意に削除しない。
- 新規 `.cls` は VBE import 可能な class header と class attributes を含める。

## 識別子

VBA 側の上限で、超えるとコンパイルが通らない。

- `Attribute VB_Name` は 31 文字以内にする。
- procedure / function / sub / property / 変数などの一般識別子は 255 文字以内にする。
- 識別子は先頭を英字にし、空白、ピリオド、`!`、`@`、`&`、`$`、`#`、予約語、同一 scope 内の衝突を避ける。
- `Option Explicit` は module level で procedure より前に置く。

## 変更前の確認

- public interface、macro entrypoint、sheet/module 名を変える場合は影響範囲を確認する。呼び出し元が workbook 内の数式や他 module にあり、source だけを見ても追い切れない。
- workbook 内部と exported source の同期が不明な場合は、未確認事項として残す。どちらが新しいか分からないまま編集すると、片方の変更を消す。
