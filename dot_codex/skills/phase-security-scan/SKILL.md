---
name: phase-security-scan
description: セキュリティ分析工程。リスク低減対象と hardening 範囲を整理する。
metadata:
  short-description: Security Scan 工程
---

# Phase Security Scan

セキュリティ工程の入口をそろえ、修正すべきリスクと検証観点を整理する。

## 入力

- 対象変更
- 脅威境界
- 制約

## uses

- `core-security-scan`

## 出力

- `security_scope`
- `risk_findings`
- `required_hardening`
- `verification_focus`

## 完了条件

- リスク低減対象と hardening 範囲を説明できる
