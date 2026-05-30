# Commit message 形式 reference

`body` / `footer(s)` / `BREAKING CHANGE` が必要な場合だけ読む。
commit message の形式と `title` の既定は `../SKILL.md` を正本にする。

## body

- 任意。必要な場合は `title` の後に 1 行空けて書く。
- 通常の英文（先頭 1 文字は大文字）。変更理由・内容・影響・代替案を簡潔に。
- 構造化した方が明確なら英語ラベルを使う: `Why:`（理由）/ `What:`（変更点）/ `Impact:`（利用者・運用・互換性への影響）。
- 1 行は概ね 72 文字を目安に、読みやすい位置で折り返す。

## footer(s)

- 任意。`body`（なければ `title`）の後に 1 行空けて書く。git trailer 形式に準拠。
- 形式は `Token: value` または `Token #value`。トークンは先頭大文字、内部の空白は `-`（`BREAKING CHANGE` は例外）。
- 値は英語・英小文字を既定（固有名詞は大文字可）。
- Issue 連携は `Refs: #123`、`Fixes: #123`、`Closes: #123`。

## BREAKING CHANGE

- `BREAKING CHANGE:` を footer に書く、または `type` 直後に `!` を付ける。任意の型に付けられる。
- `!` がある場合 `BREAKING CHANGE:` は省略可。その時は `title` の description で内容を説明する。
- `BREAKING CHANGE:` は大文字＋半角スペース＋説明。

## 例

```txt
feat!: send an email to the customer when a product is shipped
```

```txt
fix: prevent racing of requests

Why: Concurrent requests can return out of order and show stale data.
What: Track the latest request id and ignore older responses.
Impact: Removes obsolete timeout mitigation without changing the public API.

Reviewed-by: Z
Refs: #123
```
