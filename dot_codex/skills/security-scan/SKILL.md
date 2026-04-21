---
name: security-scan
description: security 案件の分析手順。リスク低減対象、hardening 範囲、検証観点を整理する。
metadata:
  short-description: Security 分析
---

# Security Scan

security 案件で、どのリスクをどこまで下げるかを整理する。

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
