---
name: change-verification
description: 「バグ修正が効いたか確かめたい」「追従や hardening の結果を検証したい」といった bugfix / security / quality / compat の依頼で使う。修正前症状や追従前ギャップに対する verification plan、結果、回帰観点、残リスクを整理する。feature / maintenance の受け入れ確認をしたい時は `change-testing` スキルを使う。
metadata:
  short-description: 検証手順
---

# Change Verification

bugfix / security / quality / compat 案件で、修正や追従の効果を確認する。
このスキルは修正結果と回帰確認を担う。
feature / maintenance の受け入れ確認をしたい時は `change-testing` スキルを使う。

## 基本方針

- 修正前症状や追従前ギャップに最も近い確認を先に置く。
- 回帰観点は修正効果と分けて整理する。
- 直接確認できない場合は、代替確認と未確認理由を明示する。
- 未確認や結果のぶれは `residual_risks` に残す。

## 手順

1. 修正前症状または追従前ギャップに対応する確認を `verification_plan` に置く
2. 直接確認できない項目には、代替確認と未確認理由を添える
3. 実行結果を `verification_result` に整理する
4. 回帰観点を `regression_check` に整理する
5. 未確認や残リスクを `residual_risks` に残す

## 判断基準

- bugfix は再現手順が解消したかを見る
- security は hardening が効いたかと副作用を見る
- quality は改善対象の品質特性に変化があるかを見る
- compat は外部変化への追従が成立したかを見る
- 実行できない確認は、理由と代替確認をセットで残す
- 同一条件で結果がぶれる場合は、未解消リスクとして扱う

## 出力フォーマット

- `verification_plan`
- `verification_result`
- `regression_check`
- `residual_risks`

## 停止条件

- 修正前の症状や追従前ギャップが曖昧で、何を検証すべきか定まらない
