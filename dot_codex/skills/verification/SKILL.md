---
name: verification
description: 「変更後の確認項目を決めたい」「新機能やリファクタを受け入れ確認したい」「バグ修正や追従、hardening の結果を検証したい」「rename / 削除後の参照ずれを確認したい」といった依頼で使う。成功条件、修正前症状、保護したい既存挙動、回帰観点、変更後の整合性を分け、実行した確認と残リスクを整理する。実装前に確認方法を置いて小さく進めたい時は `implementation` スキルを使う。
metadata:
  short-description: 検証手順
---

# 変更検証

変更後に、何をどう確認し、何が残リスクかを整理する。

## 手順

- 変更意図から `check_mode` を決める。
- `acceptance` では成功条件、期待挙動、保護したい既存挙動を確認対象にする。
- `verification` では修正前症状、対象リスク、品質ギャップ、外部変化への追従前ギャップを確認対象にする。
- `consistency` では rename / 削除 / path 変更 / surface 変更に伴う参照、docs、設定、ignore の追従漏れを確認対象にする。
- 変更意図に最も近い確認を先に置き、回帰観点は分けて `check_plan` に並べる。
- 直接確認できない項目には、代替確認と未確認理由を添える。
- 実行した確認を `executed_checks`、保護したい既存挙動や回帰観点を `regression_or_protected_behavior` に整理する。
- 未確認、未実行、結果のぶれは `remaining_risks` に残す。

## 確認モード

- `acceptance`: feature / maintenance の確認で使う。成功条件、期待挙動、保護したい既存挙動に対して確認する。
- `verification`: bugfix / security / quality / compat の確認で使う。修正前症状、対象リスク、品質ギャップ、外部変化への追従前ギャップに対して確認する。
- `consistency`: 変更差分の参照、docs、設定、ignore の追従漏れ確認で使う。詳細は [references/consistency-checks.md](references/consistency-checks.md) を読む。
- 迷う場合は、ユーザーが「新しい価値や整理の受け入れ」を見たいなら `acceptance`、既にあった問題や外部変化への「修正効果」を見たいなら `verification`、rename / 削除 / path 変更 / surface 変更後の追従漏れを見たいなら `consistency` に倒す。

## 境界

- feature は成功条件、maintenance は守るべき既存挙動、bugfix は再現手順の解消を優先する。
- security は hardening の効果と副作用、quality は対象品質特性の変化、compat は外部変化への追従成立を見る。
- 実行できない確認は、理由と代替確認をセットで残す。
- 同一条件で結果がぶれる場合は、未解消リスクとして扱う。
- `consistency` で事実だけで判断できる漏れを見つけた場合は同じ変更単位で修正してよい。
- `consistency` で公開インターフェース、既存挙動、削除判断、永続化、認証認可、権限に触れる判断が必要な場合は修正せず確認事項に残す。
- 実装前に確認方法を置いて小さく進める時は `implementation` スキルを使う。

## 出力

- `check_mode`
- `check_plan`
- `executed_checks`
- `regression_or_protected_behavior`
- `remaining_risks`

## 停止条件

- `acceptance` で成功条件や保護したい挙動が不明で、確認項目を作れない。
- `verification` で修正前症状や追従前ギャップが曖昧で、何を検証すべきか定まらない。
