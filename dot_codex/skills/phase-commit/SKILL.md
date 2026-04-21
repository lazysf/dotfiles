---
name: phase-commit
description: Deprecated wrapper。旧 Commit 導線互換のために `core-git-commit` へ受け渡す。
metadata:
  short-description: Commit 工程
---

# Phase Commit

旧 Commit 導線互換のために、コミット依頼を `core-git-commit` へ橋渡しする。
新規の正式入口としては使わず、`core-git-commit` を直接使う。

## 入力

- コミット候補差分
- 変更意図
- 文面要件
- 残タスクの有無

単独依頼では、この入力だけでコミット境界の整理、メッセージ要件の確認、実行可否の判断まで返せることを重視する。

## uses

- `core-git-commit`

## 進め方

1. 不要差分が混ざっていないかを確認する
2. 1 コミット 1 変更で説明できる粒度へそろえる
3. 最後に `$core-git-commit` へ渡して実行または文面整理を行う

## 出力

- `commit_scope`
- `commit_message_requirements`
- `remaining_changes`
- `commit_result`

## 次に渡す情報

- commit 実行前は `commit_scope` と `commit_message_requirements` を `core-git-commit` へ渡す
- commit 後は `commit_result` と `remaining_changes` を次の共有判断へ渡す

## 完了条件

- 不要差分がない
- コミット単位に意味がある
- メッセージが規約に沿っている
