---
name: verification
description: 変更後に受け入れ条件、修正効果、hardening 効果、rename / 削除 / path 変更後の参照ずれを確認する時に使う。実行した確認、守った既存挙動、残リスクを整理する。実装前の確認設計は `implementation`。
metadata:
  short-description: 検証手順
---

# 変更検証

変更後に、何をどう確認し、何が残リスクかを整理する。

## 手順

- 変更意図から `check_mode` を決める。
- `acceptance`: 成功条件、期待挙動、保護したい既存挙動。
- `verification`: 修正前症状、対象リスク、品質ギャップ、外部変化への追従前ギャップ。
- `consistency`: rename / 削除 / path / surface 変更に伴う参照、docs、設定、ignore の追従漏れ。
- 変更意図に最も近い確認を先に置き、回帰観点は分けて `check_plan` に並べる。
- 直接確認できない項目には、代替確認と未確認理由を添える。
- 実行した確認を `executed_checks`、保護したい既存挙動や回帰観点を `regression_or_protected_behavior` に整理する。
- 未確認、未実行、結果のぶれは `remaining_risks` に残す。

## 確認モード

- `acceptance`: feature / maintenance の確認で使う。成功条件、期待挙動、保護したい既存挙動に対して確認する。
- `verification`: bugfix / security / quality / compat の確認で使う。修正前症状、対象リスク、品質ギャップ、外部変化への追従前ギャップに対して確認する。
- `consistency`: 変更差分の参照、docs、設定、ignore の追従漏れ確認で使う。確認項目を [references/consistency-checks.md](references/consistency-checks.md) に列挙しているため、確認を始める前に読んで各項目を当てる。docs 追従更新まで行う依頼では `doc-followup` を使う。
- 迷う場合は、新規価値は `acceptance`、既存問題の修正効果は `verification`、参照ずれは `consistency`。

## 境界

- feature は成功条件、maintenance は守る既存挙動、bugfix は再現手順の解消を優先する。
- security は hardening の効果と副作用、quality は対象品質特性、compat は外部変化への追従成立を見る。
- 実行できない確認は、理由と代替確認をセットで残す。
- 同一条件で結果がぶれる場合は、未解消リスクとして扱う。
- `consistency` で docs 追従漏れを見つけた場合、更新まで行う依頼では `doc-followup` を使う。
- `consistency` で公開インターフェース、既存挙動、削除判断、永続化、認証認可、権限に触れる判断が必要な場合は修正せず確認事項に残す。
- 実装前に確認方法を置く段階は `implementation`。

## 出力

- `check_mode`
- `check_plan`
- `executed_checks`
- `regression_or_protected_behavior`
- `remaining_risks`

## 停止条件

- `acceptance` で成功条件や保護したい挙動が不明で、確認項目を作れない。
- `verification` で修正前症状や追従前ギャップが曖昧で、何を検証すべきか定まらない。
