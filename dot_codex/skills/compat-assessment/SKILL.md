---
name: compat-assessment
description: 「外部 API 変更に追従したい」「依存やランタイム更新の影響を見たい」といった compat 案件で使う。外部変化とのギャップ、影響面、今回の追従範囲、検証観点を整理する。目的や成功条件が未確定なら `product-planning` スキル、CVE や権限強化を進めたい時は `security-scan` スキルを使う。
metadata:
  short-description: Compat 分析
---

# Compat Assessment

compat 案件で、外部変化によるギャップと追従方針を整理する。
目的や成功条件が曖昧な場合は、追従方針を決める前に `product-planning` スキルへ戻す。

## 手順

1. どの外部変化に追従する案件かを特定する
2. 現状との差を `compat_gap` に整理する
3. 影響面を `affected_surface` にまとめる
4. 今回の追従範囲を `adaptation_scope` に絞る
5. 追従後に確認すべき点を `verification_focus` に置く

## 判断基準

- 外部変化への追従を主目的にする
- 便乗機能追加は `feature` へ混ぜない
- CVE や権限強化が主題なら `security` を優先する

## 出力フォーマット

- `compat_gap`
- `affected_surface`
- `adaptation_scope`
- `verification_focus`

## 停止条件

- 外部変化の仕様や影響が確認できない
