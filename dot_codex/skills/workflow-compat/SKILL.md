---
name: workflow-compat
description: compat 案件の導線 workflow。互換性ギャップの評価、追従実装、検証の順で進める。
metadata:
  short-description: Compat workflow
---

# Workflow Compat

`compat` 分類の案件を、`compat-assessment -> implement -> verify` で進める。
この workflow は `entry-classify` により選択されたあとに始まる。

## フロー

1. `phase-compat-assessment`
2. `phase-implement`
3. `phase-verify`

## 主要受け渡し

- `phase-compat-assessment` から `compat_gap`, `affected_surface`, `adaptation_scope`, `verification_focus` を受け取る
- `phase-implement` で追従差分を作る
- `phase-verify` で互換性の回復と回帰を確認する

## 完了条件

- 外部変化への追従方針が固まっている
- 追従後の検証結果がそろっている
