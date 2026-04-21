---
name: phase-publish
description: 共通 Publish 工程。共有の要否を確認し、push core へ受け渡す。
metadata:
  short-description: Publish 工程
---

# Phase Publish

Publish 工程の入口をそろえ、共有が必要な場合だけ push や共有文面の整理へ進める。
この phase は push 詳細を自前で持たず、共有条件と push 対象を `core-git-push` へ渡す薄い orchestrator である。

## 入力

- push 実行の明示依頼
- 共有先とブランチ
- 共有時の補足

## 進め方

1. push 実行の要否と共有先を確認する
2. upstream やブランチの前提をそろえる
3. `core-git-push` へ渡して実行する

## 出力

- `publish_target`
- `publish_action`
- `publish_result`

## 完了条件

- 実行の要否が確認されている
- 共有先と実行内容が一致している
- push や共有結果を簡潔に説明できる
