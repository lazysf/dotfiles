---
name: core-review-findings-summary
description: Review フェーズの出口整理。reviewer 結果や自己レビュー結果を findings-first で整理し、未検証事項と残リスクを分けて返す。修正プランへ渡しやすい出口整理に使用する。
metadata:
  short-description: レビュー要約
---

# Core Review Findings Summary

reviewer 結果を、人間が次の判断に使いやすい形へ整える。
このスキルは、reviewer agent の代替ではなく、出口整理を担う。
レビュー対象の確定と reviewer 起動は `core-code-review` が担い、このスキルは findings-first の整理に専念する。
フェーズ全体の入口は `phase-review` を参照する。

## 基本方針

- findings-first で返す。
- `quality-reviewer` / `security-reviewer` の結果があれば、それを優先して統合する。
- 指摘がなくても、未検証事項や残リスクは隠さない。
- 広く再レビューせず、結果整理に必要な範囲だけ確認する。
- 人間向けの見出しと JSON key を混在させない。

## 対象

- 実装後の最終確認。
- reviewer agent の結果を人間向けに整理して返す場面。
- `core-code-review` から渡された reviewer agent 結果を出口整理する場面。
- 次に修正プランを依頼しやすい形へ要約したい場面。

## 対象外

- 実装前の設計レビュー。
- `quality-reviewer` / `security-reviewer` の代わりとなるレビュー本体。
- raw JSON をそのまま返すことが主目的の場面。

## 手順

### 1) 入力をそろえる

- 対象差分または対象範囲を確認する。
- 実施済み検証と未検証事項を分ける。
- `core-code-review` から渡された場合も、ここでは reviewer agent の追加起動より出口整理を優先する。
- reviewer agent の結果があれば、findings / open_questions / residual_risks を先に集める。
- 今回見ていない範囲があれば明示する。

### 2) 出口整理に必要な確認だけ行う

- findings の根拠が薄くないかを確認する。
- `open_questions` と `residual_risks` の置き先を整理する。
- 単一ファイルの軽微変更で強い懸念がなければ、自己レビューは最小限で止める。
- reviewer agent の結果がある場合は、再レビューより重複除去と要約を優先する。

### 3) findings-first でまとめる

- 指摘がある場合は、重要度順に findings を並べる。
- 指摘がない場合は `重大な指摘なし` を明示し、何を確認したかを短く添える。
- 未検証事項は findings と混ぜずに残す。
- 残リスクは、今回の範囲外や運用前提依存の論点として分ける。
- JSON key を指すときだけ `open_questions` / `residual_risks` を backticks 付きで書く。
- 人間向けの本文では、`Open questions` / `Residual risks` または日本語見出しに統一する。

## 出力ガイド

- 次の項目が落ちないように整理する。
  - 対象差分または対象範囲
  - 確認した事実
  - 実施済み検証
  - 未検証事項
  - findings または `重大な指摘なし`
  - `Open questions` または日本語の未確認論点見出し
  - `Residual risks` または日本語の残リスク見出し
- `重大な指摘なし` は、確認した範囲に根拠のある `critical` / `high` がない場合に使う。
- 次に修正プランを依頼しやすいよう、何を直すべきかと何が未確認かを分けて見せる。
