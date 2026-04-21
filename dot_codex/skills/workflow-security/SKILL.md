---
name: workflow-security
description: security 案件の導線 workflow。セキュリティ観点のスキャン、実装、検証の順で進める。
metadata:
  short-description: Security workflow
---

# Workflow Security

`security` 分類の案件を、`security-scan -> implement -> verify` で進める。
この workflow は `entry-classify` により選択されたあとに始まる。

## フロー

1. `phase-security-scan`
2. `phase-implement`
3. `phase-verify`

## 主要受け渡し

- `phase-security-scan` から `security_scope`, `risk_findings`, `required_hardening`, `verification_focus` を受け取る
- `phase-implement` で hardening を実装する
- `phase-verify` で remediation と回帰を確認する

## 完了条件

- リスク低減対象が特定されている
- 対応後の検証結果がそろっている
