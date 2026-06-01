# Excel VBA `.bas` / `.cls` コーディング標準

Excel VBA の exported standard module (`.bas`) / class module (`.cls`) を作成・編集する時の既定ガード。
既存挙動や Excel / VBE の互換性を優先すべき場面では、標準から外す理由と影響範囲を明示する。

## 対象と非対象

- 対象は Excel VBA の exported `.bas` / `.cls`。
- `.bas` は standard module、`.cls` は class module として扱う。
- VB6、Access VBA、`.frm`、workbook 本体の生成・変換は対象外。

## 保存・生成ルール

- 新規作成、Codex 主導の編集、明示的な正規化では `UTF-8 without BOM` / `LF` を既定にする。
- ファイル先頭に BOM、空行、不要なコメントを入れない。
- `Attribute VB_Name` はファイル種別と一致する名前を設定する。
  - `.bas`: 標準モジュール名。
  - `.cls`: クラス名。
- 新規生成時の `Attribute VB_Name` は、ファイル名の拡張子なし部分が有効な VBA module 名である場合に一致させる。
- `Attribute VB_Name` は 31 文字以内。
- `Attribute VB_Name` は先頭を英字にし、空白、ピリオド、`!`、`@`、`&`、`$`、`#` を含めない。予約語や同一 project 内の重複名も避ける。
- ファイル名の拡張子なし部分が有効な VBA module 名でない場合は、黙って別名を作らず rename / 正規化方針を確認する。`VB_Name` がずれる場合は理由を報告する。
- 一般の識別子は 255 文字以内にし、VBA naming rules に従う。
- 既存ファイルでは、明示的な rename / 正規化依頼がない限り、既存の `Attribute` 行と module metadata を保持する。
- 既存ファイルが別 encoding / 改行の場合は実態を確認し、変換するなら理由を明示する。

## 標準モジュール (`.bas`)

- 拡張子は `.bas` を使う。
- class header や class attributes を書かない。
- 先頭 metadata として `Attribute VB_Name = "<ModuleName>"` を扱う。
- 標準モジュールに state を増やす時は、呼び出し順序や再実行時の影響を確認する。

## クラスモジュール (`.cls`)

- 拡張子は `.cls` を使う。
- class header と class attributes を含める。
- `Attribute VB_Name = "<ClassName>"` を class 名として扱う。
- public members、default member、`VB_PredeclaredId`、`VB_Exposed` などの属性変更は公開面として扱い、変更前に参照と影響範囲を確認する。
- 既存 class の lifetime、初期化順序、state、イベント購読は不用意に変えない。
- 新規 `.cls` は、少なくとも次の exported class module skeleton を満たす。

```vb
VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "<ClassName>"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
```

- 既存 `.cls` では、VBE が生成した `VERSION`、`BEGIN` / `END`、class attributes を保持する。

## 基本実装ガード

- `Option Explicit` を使い、変数は明示的に宣言する。
- 暗黙 `Variant` は避け、必要な型を明示する。行番号、行数、セル数などは `Integer` ではなく `Long` を既定にする。
- `ActiveWorkbook`、`ActiveSheet`、`Selection`、`Activate` への未修飾依存は避ける。
- UI 操作マクロや既存 recorder code の互換性で `Selection` や `Activate` が必要な場合は、対象 workbook / worksheet / range と例外理由を明示する。
- workbook、worksheet、range、table などの境界は変数に束縛する。

## Excel Application state

- `Application.ScreenUpdating`、`EnableEvents`、`DisplayAlerts`、`Calculation` を変更する時は、変更前の値を保存する。
- 正常終了と error path の両方で、保存した値を cleanup で復元する。
- `DisplayAlerts = False` や calculation mode 変更は保存・上書き・再計算結果に影響するため、範囲を狭く保つ。

## エラー処理

- 失敗しうる境界では、どの操作が失敗したか追える error handling を置く。
- `On Error Resume Next` は、存在確認や optional object access など局所的な用途に限定する。
- `On Error Resume Next` の直後に `Err.Number` を確認し、終わったら `On Error GoTo 0` または通常の handler に戻す。
- エラーを握りつぶさない。呼び出し側へ返す、再送出する、または説明できる形で扱う。

## Range / performance

- 大量セル処理では、セル単位の read / write loop を避け、`Range.Value2` と配列による bulk read / write を優先する。
- `Select` / `Activate` を使った移動ではなく、対象 `Range` に直接アクセスする。
- 画面更新やイベント停止は、性能目的でも cleanup 復元を必須にする。

## 確認優先の停止線

- ファイル削除、保存上書き、別 workbook への書き込み、外部プロセス起動、ネットワークアクセス、秘密情報、VBE automation に触れる時は確認を優先する。
- public API、module / class 名、`Attribute`、イベントハンドラ名、保存形式、計算結果に影響する変更は、既存参照と影響範囲を確認する。
- 標準から外す必要がある時は、最終報告で例外理由、守った既存挙動、未確認事項を分けて書く。
