---
name: phase-publish
description: Deprecated wrapper。旧 Publish 導線互換のために `core-git-push` へ受け渡す。
metadata:
  short-description: Publish 工程
---

# Phase Publish

旧 Publish 導線互換のために、push 依頼を `core-git-push` へ橋渡しする。
新規の正式入口としては使わず、`core-git-push` を直接使う。

## 入力

- push 実行の明示依頼
- 共有先とブランチ
- 共有時の補足

## uses

- `core-git-push`

## 進め方

1. push 実行の要否と共有先を確認する
2. upstream やブランチの前提をそろえる
3. 最後に `$core-git-push` へ渡して実行する

## 出力

- `publish_target`
- `publish_action`
- `publish_result`

## 次に渡す情報

- `publish_target` と `publish_action` を `core-git-push` へ渡す
- 実行後は `publish_result` を共有結果として返す

## 完了条件

- 実行の要否が確認されている
- 共有先と実行内容が一致している
- push や共有結果を簡潔に説明できる
