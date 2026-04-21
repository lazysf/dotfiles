---
name: phase-capture-knowledge
description: Deprecated wrapper。旧 Knowledge 導線互換のために knowledge 系 `core-*` へ受け渡す。
metadata:
  short-description: Knowledge 工程
---

# Phase Capture Knowledge

旧 Knowledge 導線互換のために、知識の仕分けや文面化を knowledge 系 `core-*` へ橋渡しする。
新規の正式入口としては使わず、`core-capture-knowledge-triage`, `core-write-knowledge-note`, `core-write-adr` を直接使う。

## 入力

- 変更概要
- 今回得た知見
- 既存 docs や ADR の候補
- 共有要否に関する前提

## uses

- `core-capture-knowledge-triage`
- `core-write-knowledge-note`
- `core-write-adr`

## 進め方

1. まず `$core-capture-knowledge-triage` を使い、残すかどうか、共有範囲、置き場を決める
2. 通常知見として残す場合は `$core-write-knowledge-note` へ渡す
3. 判断記録として残す場合は `$core-write-adr` へ渡す
4. 最後に Capture Knowledge 工程の出力形式へ統合する

## 出力

- `knowledge_decision`
- `destination`
- `writer_core`
- `draft_status`

## 次に渡す情報

- 知識を残す場合は `destination`, `writer_core`, `draft_status` を writer core や後続共有判断へ渡す
- 残さない場合は `knowledge_decision` だけを簡潔に返す

## 完了条件

- 残すべき知識の要否が判断されている
- 共有する場合の置き場が既存構造に沿っている
- 必要な writer core へ受け渡せている
- 重複する記述や場違いな新規ファイルがない
