---
name: change-verification
description: bugfix / security / quality / compat 案件の検証手順。修正結果と回帰を確認する。
metadata:
  short-description: 検証手順
---

# Change Verification

bugfix / security / quality / compat 案件で、修正や追従の効果を確認する。
このスキルは修正結果と回帰確認を担い、feature / maintenance の受け入れ確認は `change-testing` に委ねる。

## 手順

1. 修正前症状または追従前ギャップに対応する確認を `verification_plan` に置く
2. 実行結果を `verification_result` に整理する
3. 回帰観点を `regression_check` に整理する
4. 未確認や残リスクを `residual_risks` に残す

## 判断基準

- bugfix は再現手順が解消したかを見る
- security は hardening が効いたかと副作用を見る
- quality は改善対象の品質特性に変化があるかを見る
- compat は外部変化への追従が成立したかを見る

## 出力フォーマット

- `verification_plan`
- `verification_result`
- `regression_check`
- `residual_risks`

## 停止条件

- 修正前の症状や追従前ギャップが曖昧で、何を検証すべきか定まらない
