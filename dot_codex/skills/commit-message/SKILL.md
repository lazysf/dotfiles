---
name: commit-message
description: Conventional Commits 準拠のコミットメッセージ作成・推敲を支援する。ユーザーがコミットメッセージ案の作成、既存文面の改善、rebase時の `reword` を求める場合に使用する。
metadata:
  short-description: Commit message authoring
---

# Commit Message

コミット実行は行わず、コミットメッセージの作成・見直しに特化して対応する。
本文必須の判定は `commit-policy` に委譲する。

## 基本方針

- Conventional Commits に準拠する（必須）。
- 言語は原則英語だが、リポジトリの規約があればそれを優先し、不明なら確認する。
- 形式に合わない場合は修正案を提示して確認する。
- 本文やフッターが必要な場合は、それを含む完全なメッセージを提示する。
- 可能なら 1〜3 件の候補を提示し、ユーザーに選んでもらう。
- 生成したコミットメッセージは、レビューと改善を3回繰り返して最終案を確定する。
- 本文必須の有無は `commit-policy` の `require_body` を唯一の根拠として扱う。

## 対象外

- `git add`、`git commit`、`git rebase` などのGit実操作（git-commit を使用）。
- プッシュ操作（git-push を使用）。
- 本文必須の判定（commit-policy を使用）。

## 入力契約（commit-policy 連携）

- `commit-policy` の判定結果を受け取る。
  - `require_body: yes/no`
  - `reason`
  - `changed_files`
  - `total_changed_lines`
  - `exception`
- 呼び出し元のモードを受け取る（`mode: standalone / git-commit`）。
- `require_body` が未指定・不整合な場合:
  - `mode=git-commit`: エラーを返し、メッセージ最終案を返さない（fail-closed）。
  - `mode=standalone`: 不足情報を問い合わせる。

## コミットメッセージ規約

- Conventional Commits を必須とする。
- 本文必須判定は `commit-policy` に従う（このスキル内で閾値判定しない）。

## 本文テンプレート

本文は次の3点を簡潔に含める。

- Why: この変更が必要な理由
- What: 何を変更したか
- Impact: 利用者・運用・互換性への影響

例:

```txt
<type>(<scope>): <summary>

Why: ...
What: ...
Impact: ...
```

## レビュー・改善サイクル（必須）

- 生成したコミットメッセージ案に対して、以下の観点でレビューする。
  - Conventional Commits 形式に準拠しているか
  - 変更内容と type/scope/description が一致しているか
  - ヘッダーが簡潔で曖昧さがないか（目安 72 文字以内）
  - 本文・フッターが必要十分か（不足・冗長がないか）
- レビュー結果を反映して改善し、これを3回繰り返す。
- 3回目の改善結果のみを最終案としてユーザーに提示する（途中案は原則提示しない）。
- ユーザーがメッセージ未指定の場合は最終案を提示して確認する。
- ユーザーがメッセージ指定済みの場合でも、内部で3回の改善を実施して最終案のみ提示する。
- 途中案や各ラウンドの内容は、ユーザーから明示的に要求された場合にのみ提示する。

## 形式

```txt
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## ヘッダー (header)

- 形式の `<type>[optional scope]: <description>` に相当する。
- 1 行のみで書く。
- 72 文字以内にする。
- 英小文字で記載する（固有名詞は英大文字でよい）。
- 動詞は命令形（add・fix・update など）を基本とする。

### タイプ (type)

- ヘッダーの `<type>` に相当する。
- 下記のタイプから適切なものを選ぶ。

#### 基本のタイプ

- `fix`: バグ修正（Semantic Versioning の `PATCH`）
- `feat`: 新機能（Semantic Versioning の `MINOR`）

#### 追加のタイプ（例）

- `build`: ビルドシステムや外部依存の変更
- `chore`: メンテナンスや雑多な変更（他の type に当てはまらないもの）
- `ci`: CI 設定やスクリプトの変更
- `docs`: ドキュメントのみの変更
- `style`: ふるまいに影響しない見た目の変更（空白・フォーマット等）
- `refactor`: バグ修正や新機能追加を伴わないコード整理
- `perf`: パフォーマンス向上
- `test`: テストの追加・修正

追加のタイプは必須ではない。BREAKING CHANGE を含まない限り Semantic Versioning に対する暗黙的な効果を持たない。

### スコープ (scope)

- ヘッダーの `[optional scope]` に相当する。
- 任意。必須ではない。
- 型には追加の文脈としてスコープを付けられる。スコープは括弧で囲み、名詞にする。例: `feat(parser): add ability to parse arrays`。
- リポジトリがスコープ運用をしていない場合は無理に付けない。

### 説明 (description)

- ヘッダーの `<description>` に相当する。
- 変更内容の短い要約を書く。
- できれば約 50 文字以内で簡潔に書く（72 文字以内の範囲で）。
- 先頭行はコミットのタイトルとして扱われるため、読みやすい要約にする。
- 詳細が書ききれない場合は description を簡潔にし、本文に詳細を記載する。

## 本文 (body)

- 形式の `[optional body]` に相当する。
- 通常は任意。`require_body=yes` の場合は必須とする。
- 記載する場合は、ヘッダーの後に 1 行空けて書く。
- 改行で区切った複数段落にできる。
- 通常の英文で記載する（先頭1文字が英大文字）。
- 変更理由や影響、代替案を簡潔に記す。
- 1行の長さは概ね 72 文字程度を目安にする。

## フッター (footer)

- 形式の `[optional footer(s)]` に相当する。
- 任意。本文の後に 1 行空けて書く（本文がない場合はヘッダーの後に 1 行空ける）。
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

## 手順

### 1) 入力確認

- 変更概要、既存の文面有無、`commit-policy` 判定結果を確認する。
- 情報不足なら最小限の質問をする。

### 2) 初稿作成

- type/scope/description を決定し、`require_body=yes` なら body を必ず追加する。

### 3) 3回レビュー

- 形式・意味・冗長性を観点に3回見直して最終案を確定する。

### 4) 出力

- 通常は最終案を1件提示する。
- ユーザー要求がある場合のみ候補を1〜3件提示する。

## 出力フォーマット

```markdown
# コミットメッセージ案

- final:
- type:
- scope:
- body: あり / なし（`require_body` と整合）
- footer: あり / なし
- 備考:
```

## 返答のガイド

- 最終メッセージをコードブロックで提示する。
- なぜその type/scope にしたかを1〜2行で補足する。
- `require_body=yes` の場合は、その根拠（`commit-policy` の `reason`）を明示する。
