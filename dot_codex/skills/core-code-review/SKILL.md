---
name: core-code-review
description: Review フェーズの内部レビュー手順。`phase-review` から渡された対象差分に対し、quality-reviewer を基本として必要に応じて security-reviewer も呼び出し、findings-first の出口へつなぐ。
metadata:
  short-description: レビュー内部手順
---

# Code Review

Review 工程の内部手順として、コードレビュー対象を確定し reviewer agent の結果を統合する。
このスキルは、レビュー本体を広く自前でやり直すのではなく、既存 reviewer agent を起動して結果を統合する役割に徹する。
フェーズ全体の入口は `phase-review` を参照する。

## 基本方針

- まず対象差分または対象ファイルを確定する。
- レビュー本体は `quality-reviewer` を既定とし、必要時だけ `security-reviewer` を追加する。
- reviewer agent は補助役であり、workflow や phase の主導権は持たせない。
- reviewer agent は差分起点の read-only 用途に限り、差分が曖昧なまま範囲を広げない。
- agent の raw JSON は内部入力として扱い、最終返答は findings-first の人間向け要約にする。
- 出口整理は `core-review-findings-summary` の方針に合わせる。

## 対象

- 「コードレビューして」「この差分をレビューして」といったレビュー依頼。
- 実装差分の品質確認を入口からそろえたい場面。
- セキュリティ観点を含む可能性がある変更を、必要時だけ `security-reviewer` に振り分けたい場面。

## 対象外

- 実装前の設計レビュー。
- reviewer agent を使わず、広く手動レビューをやり直す場面。
- raw JSON の生出力をそのまま返すことを主目的にした場面。

## 手順

### 1) レビュー対象を確定する

- 明示された対象差分または対象ファイルがあれば、それを優先する。
- 明示指定がない場合は、`unstaged diff -> staged diff` の順で対象を確認する。
- 実施済み検証、未検証事項、今回見ない範囲を先にそろえる。
- 差分境界が曖昧な場合は、全体レビューへ拡張せずスコープ確認で止まる。

### 2) quality-reviewer を既定で使う

- 通常のコードレビューでは `quality-reviewer` を起動する。
- 変更意図と実装結果のずれ、責務分離、命名、例外処理、仕様不整合、テスト不足、回帰リスクを主に確認対象とする。
- `quality-reviewer` の結果は、後段の要約で findings / open questions / residual risks に整理して使う。

### 3) security-reviewer が必要か判断する

- ユーザーがセキュリティ観点を明示した場合は `security-reviewer` を追加する。
- 明示がなくても、差分に次が含まれる場合は `security-reviewer` を追加する。
  - 認証認可
  - 秘密情報
  - 権限境界
  - 外部入力
  - 外部 I/O
  - 危険なコマンド実行
  - 危険なファイル操作
  - デプロイや設定の境界
- 上記に明確に当てはまらない懸念は、一般論で security review を増やさない。

### 4) 必要なら両方の結果を統合する

- quality と security の両方が必要な場合は、可能なら独立に実行してから統合する。
- 並列実行できない環境では順次実行でよい。
- 両方の agent を使った場合でも、同じ指摘は重複して返さない。
- 根拠が弱い懸念は findings に入れず、open questions または residual risks に落とす。

### 5) core-review-findings-summary 形式で返す

- 最終返答は raw JSON ではなく、人間向けの findings-first 要約にする。
- 少なくとも次を落とさない。
  - 対象差分または対象範囲
  - 確認した事実
  - 実施済み検証
  - 未検証事項
  - findings または `重大な指摘なし`
  - Residual risks
- 必要な場合は Open questions を分けて示す。
- 出口整理は `core-review-findings-summary` の方針に合わせ、次に修正判断しやすい粒度へ整える。

## 出力ガイド

- 通常返答は findings-first の人間向け要約にする。
- `重大な指摘なし` は、確認した範囲に根拠のある `critical` / `high` がない場合に使う。
- reviewer agent の JSON key を本文へそのまま漏らしすぎず、人間向け見出しへ整える。
- 差分が曖昧、意図不明、または workspace 外前提が支配的な場合は、推測で埋めずスコープ確認や未確認論点として返す。
