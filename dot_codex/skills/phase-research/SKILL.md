---
name: phase-research
description: 調査工程。事実確認と判断材料の整理を行う。
metadata:
  short-description: Research 工程
---

# Phase Research

調査工程の入口をそろえ、実装前の判断材料を整理する。

## 入力

- 調査対象
- 確認論点
- 制約

## uses

- `core-research`

## 出力

- `facts`
- `unknowns`
- `options`
- `recommendation`
- `next_step`

## 完了条件

- 事実と未知が分離されている
- 次に取る判断を説明できる
