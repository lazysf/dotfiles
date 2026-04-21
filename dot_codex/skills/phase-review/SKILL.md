---
name: phase-review
description: 共通 Review 工程。レビュー依頼、reviewer agent の起動、出口整理をまとめる。
metadata:
  short-description: Review 工程
---

# Phase Review

Review 工程の入口をそろえ、重大な欠陥や受け入れ条件とのずれを残さない状態へ進める。
この phase は workflow 内の工程としてだけでなく、レビューだけを求める明確な単独依頼の正式入口としても使う。
この phase は詳細レビュー手順を自前で持たず、review core と reviewer agent の受け渡しに徹する薄い orchestrator である。

## 入力

- 対象差分または対象ファイル
- 変更意図
- 実施済み検証
- 未検証事項

単独依頼では、この入力だけでレビュー対象、懸念点、再確認の要否まで返せることを重視する。

## uses

- `core-code-review`
- `core-review-findings-summary`

## 進め方

1. まず `$core-code-review` を使い、レビュー対象の確定と必要な reviewer agent の起動方針をそろえる
2. `quality-reviewer` を既定とし、必要時だけ `security-reviewer` を追加する判断は `core-code-review` の中で扱う
3. 最後に `$core-review-findings-summary` を使い、findings-first の出口へ統合する

## 出力

- `review_scope`
- `findings`
- `open_questions`
- `residual_risks`
- `recheck_needed`

## 完了条件

- `critical` が残っていない
- `high` を未対応のまま放置していない
- 修正後の再確認が済んでいる
- 受け入れ条件に照らして大きな不足がない
