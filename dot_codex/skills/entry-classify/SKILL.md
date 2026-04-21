---
name: entry-classify
description: Deprecated wrapper。旧導線互換のために要求を整理し、関連する `core-*` 候補へつなぐ。
metadata:
  short-description: 分類入口
---

# Entry Classify

旧導線互換のために、要求をざっくり整理して関連する `core-*` 候補へつなぐ。
新規の正式入口としては使わず、まず対応する `core-*` を直接使う。

## 入力

- ユーザー要求
- 既存文脈
- 制約

## uses

- `core-task-classification`

## 出力

- `primary_category`
- `reason`
- `boundary_note`
- `suggested_core_skills`
- `stop_conditions`

## 完了条件

- 分類理由と次に見るべき `core-*` を短く説明できる
