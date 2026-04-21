---
name: phase-plan
description: 共通 Plan 工程。依頼整理、要件整理、技術計画のどこまで必要かを見極め、関連 core へ受け渡す。
metadata:
  short-description: Plan 工程
---

# Phase Plan

Plan 工程の入口をそろえ、依頼を実装可能な計画状態まで引き上げる。
この phase は詳細手順を自前で持たず、どの core をどの順で使うかと、各 core の入出力をそろえる薄い orchestrator に徹する。

## 入力

- ユーザー要求
- 既存文脈
- 触ってよい範囲と制約
- 既知の前提やリスク

## 進め方

1. 依頼文が散らばっている場合は `core-request-shaping` を使う
2. 今回の停止線を軽く固定するときは `core-task-intake` を使う
3. 成功条件や非目的の整理が重い場合は `core-product-planning` を使う
4. 実装順序や影響範囲を詰める場合は `core-implementation-planning` を使う

## 出力

- `plan_scope`
- `success_criteria`
- `constraints`
- `selected_cores`
- `implementation_outline`
- `verification_outline`

## 完了条件

- 何をやるかを短く説明できる
- どこを触るかと触らないかを説明できる
- 主要な依存関係とリスクが見えている
- 実装と確認の進め方を段階に分けて示せる
