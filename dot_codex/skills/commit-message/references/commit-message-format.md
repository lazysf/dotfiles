# Commit Message Format Reference

## 目次

- 形式
- 本文テンプレート
- ヘッダー
- タイプ
- スコープ
- 説明
- 本文
- フッター
- 破壊的変更
- 例

## 形式

```txt
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## 本文テンプレート

本文は次の3点を簡潔に含める。

- Why: この変更が必要な理由
- What: 何を変更したか
- Impact: 利用者・運用・互換性への影響

例:

```txt
<type>: <summary>

Why: ...
What: ...
Impact: ...
```

## ヘッダー

- 形式の `<type>[optional scope]: <description>` に相当する。
- 1行のみで書く。
- 72文字以内にする。
- 英小文字で記載する（固有名詞は英大文字でよい）。
- 動詞は命令形（add・fix・update など）を基本とする。
- デフォルトでは scope を付けず、`<type>: <description>` を優先する。

## タイプ

- ヘッダーの `<type>` に相当する。
- 下記のタイプから適切なものを選ぶ。

### 基本のタイプ

- `fix`: バグ修正（Semantic Versioning の `PATCH`）
- `feat`: 新機能（Semantic Versioning の `MINOR`）

### 追加のタイプ（例）

- `build`: ビルドシステムや外部依存の変更
- `chore`: メンテナンスや雑多な変更（他の type に当てはまらないもの）
- `ci`: CI 設定やスクリプトの変更
- `docs`: ドキュメントのみの変更
- `style`: ふるまいに影響しない見た目の変更（空白・フォーマット等）
- `refactor`: バグ修正や新機能追加を伴わないコード整理
- `perf`: パフォーマンス向上
- `test`: テストの追加・修正

追加のタイプは必須ではない。BREAKING CHANGE を含まない限り Semantic Versioning に対する暗黙的な効果を持たない。

## スコープ

- ヘッダーの `[optional scope]` に相当する。
- 任意。必須ではない。
- デフォルトでは省略する。
- 付けるのは、同じ type だけでは変更対象の識別が弱い場合、またはリポジトリ規約で要求される場合に限る。
- 型には追加の文脈としてスコープを付けられる。スコープは括弧で囲み、名詞にする。例: `feat(parser): add ability to parse arrays`。
- リポジトリがスコープ運用をしていない場合は無理に付けない。

## 説明

- ヘッダーの `<description>` に相当する。
- 変更内容の短い要約を書く。
- できれば約50文字以内で簡潔に書く（72文字以内の範囲で）。
- 先頭行はコミットのタイトルとして扱われるため、読みやすい要約にする。
- 詳細が書ききれない場合は description を簡潔にし、本文に詳細を記載する。

## 本文

- 形式の `[optional body]` に相当する。
- 通常は任意。本文が必要な場合は必須とする。
- 記載する場合は、ヘッダーの後に1行空けて書く。
- 改行で区切った複数段落にできる。
- 通常の英文で記載する（先頭1文字が英大文字）。
- 変更理由や影響、代替案を簡潔に記す。
- 1行の長さは概ね72文字程度を目安にする。

## フッター

- 形式の `[optional footer(s)]` に相当する。
- 任意。本文の後に1行空けて書く（本文がない場合はヘッダーの後に1行空ける）。
- git trailer 形式に準拠する。
- 形式は `Token: value` または `Token #value`。
- トークンは先頭1文字を英大文字にする。
- トークン内の空白は `-` に置き換える（後述する `BREAKING CHANGE` は例外）。
- 値はスペースや改行を含められ、次のトークンで終端される。
- 値は英小文字で記載する（固有名詞は英大文字でよい）。
- Issue 連携は `Refs: #123`、`Fixes: #123`、`Closes: #123` を用いる。

## 破壊的変更

- `BREAKING CHANGE:` をフッターに書く、または型・スコープの直後に `!` を付けると破壊的変更を表す（Semantic Versioning の `MAJOR`）。
- `BREAKING CHANGE` は任意の型に付けられる。
- `!` がある場合、`BREAKING CHANGE:` を省略してよい。その場合はヘッダーの description で破壊的変更の内容を説明する。
- `BREAKING CHANGE:` は大文字で `BREAKING CHANGE:` の後に半角スペースを入れて説明を書く。
- `BREAKING-CHANGE` は `BREAKING CHANGE` と同義。

## 例

タイトルおよび破壊的変更のフッターを持つコミットメッセージ

```txt
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

破壊的変更を目立たせるために `!` を持つコミットメッセージ

```txt
feat!: send an email to the customer when a product is shipped
```

スコープおよび破壊的変更を目立たせるための `!` を持つコミットメッセージ

```txt
feat(api)!: send an email to the customer when a product is shipped
```

`!` と `BREAKING CHANGE` フッターの両方を持つコミットメッセージ

```txt
chore!: drop support for Node 6

BREAKING CHANGE: use JavaScript features not available in Node 6.
```

本文を持たないコミットメッセージ

```txt
docs: correct spelling of CHANGELOG
```

スコープを持つコミットメッセージ

```txt
feat(lang): add Polish language
```

複数段落からなる本文と複数のフッターを持ったコミットメッセージ

```txt
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.

Remove timeouts which were used to mitigate the racing issue but are
obsolete now.

Reviewed-by: Z
Refs: #123
```
