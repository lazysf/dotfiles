# Commit message 形式 reference

この reference は `body` / `footer(s)` / `BREAKING CHANGE` が必要な場合の詳細として使う。
commit message の形式と `title` の既定ルールは `../SKILL.md` の `## コミットメッセージ` を正本にする。

## body template

`body` は、必要に応じて理由、内容、影響を簡潔に説明する。
構造化した方が明確な場合は、次のラベルをそのまま英語で使う。

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

## body

- 形式の `[optional body]` に相当する。
- 通常は任意。`body` が必要な場合は必須とする。
- 記載する場合は、`title` の後に1行空けて書く。
- 通常の文章で書いてよい。構造化した方が明確な場合は `Why:` / `What:` / `Impact:` を使う。
- ラベルを使う場合、各ラベルの値が長ければ読みやすい位置で折り返せる。
- 通常の英文で記載する（先頭1文字が英大文字）。
- 変更理由や影響、代替案を簡潔に記す。
- 1行の長さは概ね72文字程度を目安にする。

## footer(s)

- 形式の `[optional footer(s)]` に相当する。
- 任意。`body` の後に1行空けて書く（`body` がない場合は `title` の後に1行空ける）。
- git trailer 形式に準拠する。
- 形式は `Token: value` または `Token #value`。
- トークンは先頭1文字を英大文字にする。
- トークン内の空白は `-` に置き換える（後述する `BREAKING CHANGE` は例外）。
- 値はスペースや改行を含められ、次のトークンで終端される。
- 値は英語を既定とし、英小文字で記載する（固有名詞は英大文字でよい）。
- Issue 連携は `Refs: #123`、`Fixes: #123`、`Closes: #123` を用いる。

## BREAKING CHANGE

- `BREAKING CHANGE:` を `footer(s)` に書く、または `type` の直後に `!` を付けると破壊的変更を表す（Semantic Versioning の `MAJOR`）。
- `BREAKING CHANGE` は任意の型に付けられる。
- `!` がある場合、`BREAKING CHANGE:` を省略してよい。その場合は `title` の `description` で破壊的変更の内容を説明する。
- `BREAKING CHANGE:` は大文字で `BREAKING CHANGE:` の後に半角スペースを入れて説明を書く。
- `BREAKING-CHANGE` は `BREAKING CHANGE` と同義。

## 例

`title` および `BREAKING CHANGE` の `footer(s)` を持つ commit message

```txt
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

破壊的変更を目立たせるために `!` を持つ commit message

```txt
feat!: send an email to the customer when a product is shipped
```

`!` と `BREAKING CHANGE` の `footer(s)` の両方を持つ commit message

```txt
chore!: drop support for Node 6

BREAKING CHANGE: use JavaScript features not available in Node 6.
```

`body` を持たない commit message

```txt
docs: correct spelling of CHANGELOG
```

`body` なしの機能追加 commit message

```txt
feat: add Polish language
```

通常の文章による `body` と複数の `footer(s)` を持った commit message

```txt
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.

Remove timeouts which were used to mitigate the racing issue but are
obsolete now.

Reviewed-by: Z
Refs: #123
```

構造化した `body` と複数の `footer(s)` を持った commit message

```txt
fix: prevent racing of requests

Why: Concurrent requests can return out of order and show stale data.
What: Track the latest request id and ignore older responses.
Impact: Removes obsolete timeout mitigation without changing the public API.

Reviewed-by: Z
Refs: #123
```
