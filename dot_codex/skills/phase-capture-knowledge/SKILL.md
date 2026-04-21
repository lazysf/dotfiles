---
name: phase-capture-knowledge
description: 共通 Capture Knowledge 工程。残すべき知識の要否を整理し、適切な core へ渡す。
metadata:
  short-description: Knowledge 工程
---

# Phase Capture Knowledge

Capture Knowledge 工程の入口をそろえ、残すべき知識だけを適切な置き場へ送る。
この phase は docs を増やすこと自体を目的にせず、知識の仕分けと writer core への受け渡しを担う。

## 入力

- 変更概要
- 今回得た知見
- 既存 docs や ADR の候補
- 共有要否に関する前提

## 進め方

1. `core-capture-knowledge-triage` で残すかどうかと置き場を決める
2. 通常知見なら `core-write-knowledge-note` へ渡す
3. 判断記録なら `core-write-adr` へ渡す

## 出力

- `knowledge_decision`
- `destination`
- `writer_core`
- `draft_status`

## 完了条件

- 残すべき知識の要否が判断されている
- 共有する場合の置き場が既存構造に沿っている
- 必要な writer core へ受け渡せている
- 重複する記述や場違いな新規ファイルがない
