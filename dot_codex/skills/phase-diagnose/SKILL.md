---
name: phase-diagnose
description: 診断工程。症状と期待状態の差を整理し、修正対象を絞る。
metadata:
  short-description: Diagnose 工程
---

# Phase Diagnose

診断工程の入口をそろえ、修正前に原因候補と failing check を整理する。

## 入力

- 症状
- 期待状態
- 関連コンテキスト

## uses

- `core-bug-diagnosis`

## 出力

- `observed_gap`
- `repro_steps`
- `suspected_causes`
- `failing_check`
- `fix_target`

## 完了条件

- 修正対象と再現条件を説明できる
