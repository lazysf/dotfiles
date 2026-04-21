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

## 進め方

1. `core-code-review` でレビュー対象と必要な reviewer agent を決める
2. `quality-reviewer` を既定で使い、必要時だけ `security-reviewer` を追加する
3. `core-review-findings-summary` で findings-first の出口へ整理する

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
