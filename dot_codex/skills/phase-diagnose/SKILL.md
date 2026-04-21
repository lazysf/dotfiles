---
name: phase-diagnose
description: Deprecated wrapper。旧 Diagnose 導線互換のために `core-bug-diagnosis` へ受け渡す。
metadata:
  short-description: Diagnose 工程
---

# Phase Diagnose

旧 Diagnose 導線互換のために、バグ診断依頼を `core-bug-diagnosis` へ橋渡しする。
新規の正式入口としては使わず、`core-bug-diagnosis` を直接使う。

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

## 次に渡す情報

- `fix_target` と `failing_check` を `phase-implement` へ渡す
- `observed_gap` と `repro_steps` は `phase-verify` の比較基準として残す

## 完了条件

- 修正対象と再現条件を説明できる
