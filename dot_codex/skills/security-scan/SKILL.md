---
name: security-scan
description: 「セキュリティリスクを下げたい」「hardening の対象と検証観点を決めたい」といった security 案件で使う。対象リスク、今回の security scope、必要な hardening、重点検証項目を整理する。目的や成功条件が未確定なら `product-planning` スキル、外部変化への追従が主題の時は `compat-assessment` スキルを使う。
metadata:
  short-description: Security 分析
---

# Security Scan

security 案件で、どのリスクをどこまで下げるかを整理する。
目的や成功条件が曖昧な場合は、security scope を決める前に `product-planning` スキルへ戻す。

## 手順

1. 認証認可、入力検証、秘密情報、権限境界、外部 I/O の順に確認する
2. 修正が必要な論点だけを `risk_findings` に残す
3. 今回の対象範囲を `security_scope` に絞る
4. 必要な hardening を `required_hardening` に整理する
5. 検証時に重点確認する項目を `verification_focus` に置く

## 判断基準

- 一般論の不安ではなく、実害につながる論点を優先する
- 外部前提に依存する懸念は断定せず観測事実と分ける
- hardening のために不要な設計変更を広げない

## 出力フォーマット

- `security_scope`
- `risk_findings`
- `required_hardening`
- `verification_focus`

## 停止条件

- 脅威境界が不明で、修正対象を絞れない
