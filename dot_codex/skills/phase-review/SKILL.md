---
name: phase-review
description: Deprecated wrapper。旧 Review 導線互換のために review 系 `core-*` へ受け渡す。
metadata:
  short-description: Review 工程
---

# Phase Review

旧 Review 導線互換のために、レビュー依頼を review 系 `core-*` へ橋渡しする。
新規の正式入口としては使わず、`core-code-review` を直接使う。

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

## 次に渡す情報

- 指摘対応が必要な場合は `findings`, `residual_risks`, `recheck_needed` を再実装や再確認へ渡す
- 問題が閉じている場合は `review_scope` と結論を最終出口へ渡す

## 完了条件

- `critical` が残っていない
- `high` を未対応のまま放置していない
- 修正後の再確認が済んでいる
- 受け入れ条件に照らして大きな不足がない
