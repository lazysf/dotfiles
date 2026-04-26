---
name: change-verification
description: 「変更後の確認項目を決めたい」「新機能やリファクタを受け入れ確認したい」「バグ修正、追従、hardening の結果を検証したい」といった依頼で使う。acceptance mode では成功条件や保護したい既存挙動を確認し、verification mode では修正前症状や追従前ギャップに対する結果と回帰観点を整理する。実装前の確認方法を置いて最小差分で進めたい時は `code-implementation-loop` スキルを使う。
metadata:
  short-description: 検証手順
---

# Change Verification

変更後に、何をどう確認し、何が残リスクかを整理する。
このスキルは feature / maintenance の受け入れ確認と、bugfix / security / quality / compat の修正効果検証を担う。

## 基本方針

- `acceptance` と `verification` のどちらの mode で確認するかを先に決める。
- 変更意図に最も近い確認を先に置く。
- 保護したい既存挙動や回帰観点は、変更意図の確認と分けて整理する。
- 直接確認できない場合は、代替確認と未確認理由を明示する。
- 未確認や結果のぶれは `remaining_risks` に残す。

## Mode の選び方

- `acceptance`: feature / maintenance の確認で使う。成功条件、期待挙動、保護したい既存挙動に対して確認する。
- `verification`: bugfix / security / quality / compat の確認で使う。修正前症状、対象リスク、品質ギャップ、外部変化への追従前ギャップに対して確認する。
- 迷う場合は、ユーザーが「新しい価値や整理の受け入れ」を見たいなら `acceptance`、既にあった問題や外部変化への「修正効果」を見たいなら `verification` に倒す。

## 手順

1. 変更意図から `check_mode` を決める
2. `acceptance` では成功条件と保護したい既存挙動、`verification` では修正前症状や追従前ギャップを確認対象にする
3. 確認項目を `check_plan` に並べる
4. 直接確認できない項目には、代替確認と未確認理由を添える
5. 実行した確認を `executed_checks` に記録する
6. 保護したい既存挙動または回帰観点を `regression_or_protected_behavior` に整理する
7. 未確認や残リスクを `remaining_risks` に残す

## 判断基準

- feature は成功条件に対応する確認を優先する
- maintenance は守るべき既存挙動の保護を優先する
- bugfix は再現手順が解消したかを見る
- security は hardening が効いたかと副作用を見る
- quality は改善対象の品質特性に変化があるかを見る
- compat は外部変化への追従が成立したかを見る
- 実行できない確認は、理由と代替確認をセットで残す
- 同一条件で結果がぶれる場合は、未解消リスクとして扱う

## 出力フォーマット

- `check_mode`
- `check_plan`
- `executed_checks`
- `regression_or_protected_behavior`
- `remaining_risks`

## 停止条件

- `acceptance` で成功条件や保護したい挙動が不明で、確認項目を作れない
- `verification` で修正前症状や追従前ギャップが曖昧で、何を検証すべきか定まらない
