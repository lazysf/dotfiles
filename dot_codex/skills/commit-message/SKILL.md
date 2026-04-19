---
name: commit-message
description: Conventional Commits 準拠のコミットメッセージ作成・推敲を支援する。ユーザーがコミットメッセージ案の作成、既存文面の改善、rebase時の `reword` を求める場合に使用する。
metadata:
  short-description: Commit message authoring
---

# Commit Message

コミット実行は行わず、コミットメッセージの作成と見直しに特化して対応する。

## 基本方針

- リポジトリに別規約がなければ Conventional Commits を既定とする。
- 言語はリポジトリ規約を優先し、規約がなければ英語を既定とする。
- このスキルではヘッダーを `type: description` に固定し、scope は使わない。
- 本文の有無は、ユーザー指定、リポジトリ規約、変更の分かりやすさをもとに判断する。
- 通常は最終案を 1 件だけ返し、複数候補は明示要求がある場合に限る。

## 対象外

- `git add`、`git commit`、`git rebase` などの Git 実操作。
- プッシュ操作。

## 入力

- 変更概要、差分要約、既存の文面案、リポジトリ規約を受け取る。
- `git-commit` から呼ばれる場合は、その文脈を優先して受け取る。
- `mode: standalone / git-commit` を受け取る。
- `mode=git-commit` の場合、`header`、`body_text`、`footer_text`、`final` を返せること。

## コミットメッセージ規約

- Conventional Commits は既定であり、リポジトリ規約があればそれを優先する。
- このスキルのヘッダー形式は `type: description` に固定し、scope は採用しない。
- 既存の scoped commit 履歴は legacy とみなし、このスキルの推奨形には含めない。
- type / body / footer の詳細は `references/commit-message-format.md` を参照する。

## 手順

### 1) 入力確認

- 変更概要、既存の文面有無、本文の要否、規約の有無を確認する。
- 情報不足なら最小限の質問をする。

### 2) 初稿作成

- まず `type: description` の形で type と description を決定する。
- 本文が必要なら body を追加する。
- 変更の識別は description を優先し、必要なら body や footer で補足する。

### 3) 見直し

- 形式、意味、冗長性を見直して最終案を確定する。

### 4) 出力

- 通常は最終案を 1 件提示する。
- `mode=git-commit` の場合は、非対話投入に使える形で返す。

## `git-commit` との関係

- Git 導線では、この `commit-message` がメッセージ作成の唯一の窓口になる。
- `git-commit` 側では、文面が未指定なら原則このスキルを使う。
- このスキル自身は staging、commit、push を行わない。

## 出力フォーマット

```markdown
# コミットメッセージ案

- final:
- header:
- body_text:
- footer_text:
- type:
- body: あり / なし
- footer: あり / なし
- 備考:
```
