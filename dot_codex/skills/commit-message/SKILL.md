---
name: commit-message
description: Conventional Commits 準拠のコミットメッセージ作成・推敲を支援する。ユーザーがコミットメッセージ案の作成、既存文面の改善、rebase時の `reword` を求める場合に使用する。
metadata:
  short-description: Commit message authoring
---

# Commit Message

コミット実行は行わず、コミットメッセージの作成・見直しに特化して対応する。

## 基本方針

- リポジトリに別規約がなければ Conventional Commits を既定とする。
- 言語はリポジトリ規約を優先し、規約がなければ英語を既定とする。
- スコープはデフォルトでは付けず、リポジトリ規約や識別上の必要性がある場合にのみ付ける。
- 形式に合わない場合は修正案を提示して確認する。
- 本文やフッターが必要な場合は、それを含む完全なメッセージを提示する。
- 通常は最終案を1件だけ返し、複数候補はユーザーが明示的に求めた場合に限る。
- 本文の有無は、ユーザー指定・リポジトリ規約・変更の分かりやすさをもとに判断する。

## 対象外

- `git add`、`git commit`、`git rebase` などのGit実操作（git-commit を使用）。
- プッシュ操作（git-push を使用）。

## 入力

- 変更概要、差分要約、既存の文面案、リポジトリ規約を受け取る。
- 呼び出し元が本文の要否を決めている場合は、その判断を優先して受け取る。
- 呼び出し元のモードを受け取る（`mode: standalone / git-commit`）。
- `mode=git-commit` の場合、呼び出し元が非対話でコミットを組み立てられるように、`header` / `body_text` / `footer_text` / `final` を分離して返せること。
- `mode=git-commit` かつ自動コミットモードの場合、未指定メッセージに対する確認待ちを行わず、最終案をそのまま返せること。

## コミットメッセージ規約

- Conventional Commits は既定であり、リポジトリ規約があればそれを優先する。
- スコープは既定で省略し、同じ type だけでは対象領域の識別が難しい場合や、リポジトリ規約で要求される場合にのみ付ける。
- type / scope / body / footer の詳細な書式、本文テンプレート、BREAKING CHANGE の扱い、具体例は `references/commit-message-format.md` を参照する。
- 書式や例が必要なときだけ、必要な節だけを参照する。

## 手順

### 1) 入力確認

- 変更概要、既存の文面有無、本文の要否、規約の有無を確認する。
- 情報不足なら最小限の質問をする。

### 2) 初稿作成

- まず scope なしで type/description を決定し、本文が必要なら body を追加する。
- scope は、対象領域の識別に実益がある場合にのみ追加する。
- 書式や type の選択に迷う場合は `references/commit-message-format.md` の必要な節を参照する。

### 3) 見直し

- 形式、意味、冗長性を見直して最終案を確定する。
- 書式確認や例との照合が必要な場合は `references/commit-message-format.md` の必要な節を参照する。

### 4) 出力

- 通常は最終案を1件提示する。
- ユーザー要求がある場合のみ候補を1〜3件提示する。
- `mode=git-commit` の場合は、非対話投入に使えるよう `header`、`body_text`、`footer_text`、`final` を整合した形で返す。
- `mode=git-commit` かつ自動コミットモードでは、確認待ちの文面を挟まずに最終案を返す。

## 出力フォーマット

```markdown
# コミットメッセージ案

- final:
- header:
- body_text:
- footer_text:
- type:
- scope:
- body: あり / なし
- footer: あり / なし
- 備考:
```

## 返答のガイド

- 最終メッセージをコードブロックで提示する。
- なぜその type にしたかを1〜2行で補足し、scope を付けた場合のみその理由を追記する。
- 本文を付けた場合は、必要になった理由を短く添える。
- `mode=git-commit` の場合は、呼び出し元が `git commit -m ...` または `git commit -F ...` を選べるよう、`header` / `body_text` / `footer_text` / `final` を欠落なく返す。
