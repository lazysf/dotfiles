---
name: phase-commit
description: 共通 Commit 工程。コミット対象の境界を確認し、commit core へ受け渡す。
metadata:
  short-description: Commit 工程
---

# Phase Commit

Commit 工程の入口をそろえ、差分を意味のある最小単位へまとめる。
この phase は workflow の後段だけでなく、コミットだけを求める明確な単独依頼の正式入口としても使う。
この phase は詳細な Git 操作を自前で持たず、commit 実行に必要な前提をそろえて `core-git-commit` へ渡す薄い orchestrator である。

## 入力

- コミット候補差分
- 変更意図
- 文面要件
- 残タスクの有無

単独依頼では、この入力だけでコミット境界の整理、メッセージ要件の確認、実行可否の判断まで返せることを重視する。

## 進め方

1. 不要差分が混ざっていないかを確認する
2. 1 コミット 1 変更で説明できる粒度へそろえる
3. `core-git-commit` へ渡して実行または文面整理を行う

## 出力

- `commit_scope`
- `commit_message_requirements`
- `remaining_changes`
- `commit_result`

## 完了条件

- 不要差分がない
- コミット単位に意味がある
- メッセージが規約に沿っている
