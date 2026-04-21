---
name: phase-compat-assessment
description: Deprecated wrapper。旧 Compat 導線互換のために `core-compat-assessment` へ受け渡す。
metadata:
  short-description: Compat Assessment 工程
---

# Phase Compat Assessment

旧 Compat 導線互換のために、互換性評価依頼を `core-compat-assessment` へ橋渡しする。
新規の正式入口としては使わず、`core-compat-assessment` を直接使う。

## 入力

- 外部変更
- 依存差分
- 互換制約

## uses

- `core-compat-assessment`

## 出力

- `compat_gap`
- `affected_surface`
- `adaptation_scope`
- `verification_focus`

## 次に渡す情報

- `adaptation_scope` と `verification_focus` を `phase-implement` へ渡す

## 完了条件

- 追従方針と影響範囲を説明できる
