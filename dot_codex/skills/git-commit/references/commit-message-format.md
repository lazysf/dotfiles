# Commit message 形式 reference

`body` / `footer(s)` / `BREAKING CHANGE` が必要な場合だけ読む。
commit message の形式と `title` の既定は `../SKILL.md` を正本にする。

## body template

`body` は必要に応じて理由、内容、影響を書く。構造化する場合は次のラベルを英語で使う。

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

scope は使わない。`<type>(<scope>): <summary>` が必要に見える場合は、message を作らず停止する。

## body

- 通常は任意。必要な場合は `title` の後に1行空けて書く。
- 通常の文章で書いてよい。構造化した方が明確な場合は `Why:` / `What:` / `Impact:` を使う。
- ラベルの値が長ければ読みやすい位置で折り返せる。
- 通常の英文で記載する（先頭1文字が英大文字）。
- 変更理由や影響、代替案を簡潔に記す。
- 1行は概ね72文字程度を目安にする。

## footer(s)

- 任意。`body` の後に1行空けて書く（`body` がない場合は `title` の後に1行空ける）。
- git trailer 形式に準拠する。
- 形式は `Token: value` または `Token #value`。
- トークンは先頭1文字を英大文字にする。
- トークン内の空白は `-` に置き換える（後述する `BREAKING CHANGE` は例外）。
- 値はスペースや改行を含められ、次の token で終端される。
- 値は英語を既定とし、英小文字で記載する（固有名詞は英大文字でよい）。
- Issue 連携は `Refs: #123`、`Fixes: #123`、`Closes: #123` を用いる。

## BREAKING CHANGE

- `BREAKING CHANGE:` を `footer(s)` に書く、または `type` 直後に `!` を付けると破壊的変更を表す。
- `BREAKING CHANGE` は任意の型に付けられる。
- `!` がある場合、`BREAKING CHANGE:` を省略してよい。その場合は `title` の `description` で破壊的変更の内容を説明する。
- `BREAKING CHANGE:` は大文字で、後に半角スペースを入れて説明を書く。
- `BREAKING-CHANGE` は `BREAKING CHANGE` と同義。

## 例

`title` と `BREAKING CHANGE` footer:

```txt
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

`!` 付き:

```txt
feat!: send an email to the customer when a product is shipped
```

`!` と `BREAKING CHANGE` footer:

```txt
chore!: drop support for Node 6

BREAKING CHANGE: use JavaScript features not available in Node 6.
```

`body` なし:

```txt
docs: correct spelling of CHANGELOG
```

機能追加:

```txt
feat: add Polish language
```

通常文 body と複数 footer:

```txt
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.

Remove timeouts which were used to mitigate the racing issue but are
obsolete now.

Reviewed-by: Z
Refs: #123
```

構造化 body と複数 footer:

```txt
fix: prevent racing of requests

Why: Concurrent requests can return out of order and show stale data.
What: Track the latest request id and ignore older responses.
Impact: Removes obsolete timeout mitigation without changing the public API.

Reviewed-by: Z
Refs: #123
```
