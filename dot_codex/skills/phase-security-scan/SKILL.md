---
name: phase-security-scan
description: Deprecated wrapper。旧 Security 導線互換のために `core-security-scan` へ受け渡す。
metadata:
  short-description: Security Scan 工程
---

# Phase Security Scan

旧 Security 導線互換のために、セキュリティ分析依頼を `core-security-scan` へ橋渡しする。
新規の正式入口としては使わず、`core-security-scan` を直接使う。

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

## 次に渡す情報

- `required_hardening` と `verification_focus` を `phase-implement` へ渡す

## 完了条件

- リスク低減対象と hardening 範囲を説明できる
