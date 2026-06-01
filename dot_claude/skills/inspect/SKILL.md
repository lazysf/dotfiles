---
name: inspect
description: verifier が実装後に AC / TASK に対応する test、lint、build、manual check、参照ずれを確認し、test.md に TC、結果、未確認事項、残リスクを整理する時に使う。実装前の確認設計や修正は `implement`。
---

# 変更検証

`verifier` が実装後の検証を行い、`test.md` に記録するための skill。

## 手順

- 変更意図から `check_mode` を決める。
- `requirements.md`、`tasks.md`、`implementation.md`、実装差分を確認する。
- `AC-*` / `TASK-*` に対応する `TC-*` を整理する。
- 変更意図に最も近い確認を先に置き、回帰観点は分けて `check_plan` に並べる。
- 直接確認できない項目には、代替確認と未確認理由を添える。
- 実行した確認を `executed_checks`、保護したい既存挙動や回帰観点を `regression_or_protected_behavior` に整理する。
- 未確認、未実行、結果のぶれは `remaining_risks` に残す。
- 実装修正が必要な場合は直さず lead に返す。

## 確認モード

- `acceptance`: 受入条件、期待挙動、保護したい既存挙動に対して確認する。
- `verification`: bugfix / security / quality / compat の確認で使う。
- `consistency`: 変更差分の参照、docs、設定、ignore の追従漏れ確認で使う。docs 追従更新まで行う依頼では `doc-followup` を使う。詳細は [references/consistency-checks.md](references/consistency-checks.md) を読む。
- 迷う場合は、新規価値は `acceptance`、既存問題の修正効果は `verification`、参照ずれは `consistency`。

## 境界

- 実装はしない。
- `test.md` 以外の成果物を編集しない。
- 実行できない確認は、理由と代替確認をセットで残す。
- 同一条件で結果がぶれる場合は、未解消リスクとして扱う。
- `consistency` で docs 追従漏れを見つけた場合、更新まで行う依頼では `doc-followup` を使う。
- 実装前に確認方法を置く段階は `implement`。

## 停止条件

- `acceptance` で成功条件や保護したい挙動が不明で、確認項目を作れない。
- `verification` で修正前症状や追従前ギャップが曖昧で、何を検証すべきか定まらない。
- 未解決リスクを受け入れる判断が必要。
