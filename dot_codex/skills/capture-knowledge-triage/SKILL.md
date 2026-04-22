---
name: capture-knowledge-triage
description: 「今回の知見をどこに残すべきか決めたい」「通常知見か ADR かを分けたい」といった依頼で使う。残す価値の有無を判断し、`skip | knowledge | adr` と根拠を返して置き場を決める。既存 docs 更新は `docs-update`、新規 knowledge / ADR 作成は `write-knowledge-note` / `write-adr` で扱う。
metadata:
  short-description: 知識の仕分け
---

# Capture Knowledge Triage

今回の作業で得た知識を `skip | knowledge | adr` に分ける。
この skill は artifact routing の正本であり、本文作成や既存 docs 更新は行わない。

## 出力フォーマット

- `decision`: `skip` / `knowledge` / `adr`
- `reason`: なぜその分岐にしたか
- `evidence_used`: 判断に使った事実

## 基本方針

- 推測ではなく、change や会話の中で明示された事実だけを使う。
- 再利用価値が説明できないなら `skip` に倒す。
- 手順、確認ポイント、落とし穴は `knowledge` に送る。
- durable decision とその理由は `adr` に送る。

## 手順

### 1) 残すべき知識かを判定する

- 次回以降も参照するかを考える。
- その場限りの調査メモなら共有 docs に持ち込まない。
- 複数案から選んだ理由や、方針変更、互換性判断として残すものは `adr` 候補とする。
- 再利用価値や判断理由が説明できないなら `skip` にする。

### 2) 個人メモか共有知識かを分ける

- チームや将来の自分が再利用するなら共有候補とする。
- 作業中の思考過程や試行錯誤は共有対象にしない。

### 3) 既存の置き場を探す

- 通常知見として残す場合は、`root docs/knowledge/` を置き先にする。
- 通常知見として残す場合の次の具体作業は `write-knowledge-note` に渡す。
- 判断記録として残す場合は、`root docs/adr/` を置き先にする。
- 判断記録として残す場合の次の具体作業は `write-adr` に渡す。
- 既存 docs、コードコメント、設定や成果物で十分かを確認する。
- 追加が必要なら既存構造のどこへ置くかを決める。
- 既存 docs 更新だけで足りる場合は `docs-update` に渡す。

### 4) 重複を避ける

- 同じ事実を複数箇所へ書かない。
- 既存記述を更新すべきか、新規追加すべきかを分ける。

## 完了条件

- `decision` が `skip | knowledge | adr` のいずれかで説明できる
- `reason` と `evidence_used` がある
- 置き場が既存構造に沿っている
- 重複記述や場違いな新設がない

## 参照先

- 置き場判断の補助: [references/knowledge-placement-rules.md](references/knowledge-placement-rules.md)
