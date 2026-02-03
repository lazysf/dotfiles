---
name: git-commit
description: Gitのコミット作成を支援する。ユーザーがコミット、コミットメッセージ作成、変更のコミット依頼を求める場合に使用する。
metadata:
  short-description: Git commit (Conventional Commits)
---

# Git Commit

Gitの変更をコミットする依頼に対応する。

## 基本方針

- 対象が不明なら確認する。
- 破壊的操作は行わない。
- コミットメッセージが未指定なら候補を提示して確認する。
- detached HEAD の場合は止めて、どのブランチでコミットするか確認する。
- rebase・merge・cherry-pick・revert 中やコンフリクトがある場合は止めて確認する。
- 未追跡ファイルや大きな生成物、バイナリ、機密情報が含まれる場合は対象を確認する。
- リポジトリの規約（README・CONTRIBUTING・テンプレ）があれば優先する。
- `--amend` や履歴の書き換えは指示がない限り行わない。
- ステージ対象は原則すべて（`git add -A`）。ユーザー指定があればその指定を優先する。
- 無関係な変更が混在する場合は分割を提案する。

## コミットメッセージ

- Conventional Commits に準拠する（必須）。
- 言語は原則英語だが、リポジトリの規約があればそれを優先し、不明なら確認する。
- 形式に合わない場合は修正案を提示して確認する。
- 本文やフッターが必要な場合は、エディタ起動のコミットを優先する。
- 可能なら 1〜3 件の候補を提示し、ユーザーに選んでもらう。

### 形式

```txt
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### ヘッダー (header)

- 形式の `<type>[optional scope]: <description>` に相当する。
- 1 行のみで書く。
- 72 文字以内にする。
- 英小文字で記載する（固有名詞は英大文字でよい）。
- 動詞は命令形（add・fix・update など）を基本とする。

#### タイプ (type)

- ヘッダーの `<type>` に相当する。
- 下記のタイプから適切なものを選ぶ。

##### 基本のタイプ

- `fix`: バグ修正（Semantic Versioning の `PATCH`）
- `feat`: 新機能（Semantic Versioning の `MINOR`）

##### 追加のタイプ（例）

- `build`: ビルドシステムや外部依存の変更
- `chore`: メンテナンスや雑多な変更（他の type に当てはまらないもの）
- `ci`: CI 設定やスクリプトの変更
- `docs`: ドキュメントのみの変更
- `style`: ふるまいに影響しない見た目の変更（空白・フォーマット等）
- `refactor`: バグ修正や新機能追加を伴わないコード整理
- `perf`: パフォーマンス向上
- `test`: テストの追加・修正

追加のタイプは必須ではない。BREAKING CHANGE を含まない限り Semantic Versioning に対する暗黙的な効果を持たない。

#### スコープ (scope)

- ヘッダーの `[optional scope]` に相当する。
- 任意。必須ではない。
- 型には追加の文脈としてスコープを付けられる。スコープは括弧で囲み、名詞にする。例: `feat(parser): add ability to parse arrays`。
- リポジトリがスコープ運用をしていない場合は無理に付けない。

#### 説明 (description)

- ヘッダーの `<description>` に相当する。
- 変更内容の短い要約を書く。
- できれば約 50 文字以内で簡潔に書く（72 文字以内の範囲で）。
- 先頭行はコミットのタイトルとして扱われるため、読みやすい要約にする。
- 詳細が書ききれない場合は description を簡潔にし、本文に詳細を記載する。

### 本文 (body)

- 形式の `[optional body]` に相当する。
- 任意。ヘッダーの後に 1 行空けて書く。
- 改行で区切った複数段落にできる。
- 通常の英文で記載する（先頭1文字が英大文字）。
- 変更理由や影響、代替案を簡潔に記す。
- 1行の長さは概ね 72 文字程度を目安にする。

### フッター (footer)

- 形式の `[optional footer(s)]` に相当する。
- 任意。本文の後に 1 行空けて書く（本文がない場合はヘッダーの後に 1 行空ける）。
- git trailer 形式に準拠する。
- 形式は `Token: value` または `Token #value`。
- トークンは先頭1文字を英大文字にする。
- トークン内の空白は `-` に置き換える（後述する `BREAKING CHANGE` は例外）。
- 値はスペースや改行を含められ、次のトークンで終端される。
- 値は英小文字で記載する（固有名詞は英大文字でよい）。
- Issue 連携は `Refs: #123`、`Fixes: #123`、`Closes: #123` を用いる。

### 破壊的変更

- `BREAKING CHANGE:` をフッターに書く、または型・スコープの直後に `!` を付けると破壊的変更を表す（Semantic Versioning の `MAJOR`）。
- `BREAKING CHANGE` は任意の型に付けられる。
- `!` がある場合、`BREAKING CHANGE:` を省略してよい。その場合はヘッダーの description で破壊的変更の内容を説明する。
- `BREAKING CHANGE:` は大文字で `BREAKING CHANGE:` の後に半角スペースを入れて説明を書く。
- `BREAKING-CHANGE` は `BREAKING CHANGE` と同義。

### 例

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

## 手順

### 1) 状態確認

- `git status -sb` で状態を確認する。
- rebase・merge・cherry-pick・revert 中やコンフリクトがある場合は止めて確認する。

### 2) 変更有無の判定

- 変更がない場合は「コミット対象がない」旨を伝えて終了する。

### 3) 変更内容の確認

- `git diff` で変更内容を確認する（対象が不明なら質問する）。
- 無関係な変更が混在している場合は、対象を確認し、必要なら部分ステージを提案する。
- 未追跡ファイルや大きな生成物、バイナリが含まれる場合は対象を確認し、必要なら除外を提案する。

### 4) ステージ

- 指定がなければ `git add -A` でステージする。
- 指定があれば `git add <paths>` などでその範囲のみステージする。

### 5) ステージ内容の確認

- `git diff --staged` でステージ内容を確認する。

### 6) コミット

- コミットメッセージを確認する。
- 本文やフッターが必要な場合は `git commit` を使い、短いタイトルのみなら `git commit -m "..."` を使う。
- 必要なら `git log -1 --oneline` でコミット結果を確認する。

### 7) 事後確認

- `git status -sb` でコミット後の状態を確認する。

## 返答のガイド

- 何をステージし、何をコミットしたかを簡潔に報告する。
- コミットハッシュ、ブランチ名、残りの未コミット変更があれば併記する。
- 追加の確認が必要なら、短く具体的に質問する。
