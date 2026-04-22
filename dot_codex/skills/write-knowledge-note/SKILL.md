---
name: write-knowledge-note
description: 「通常知見として残すメモを作りたい」「knowledge note を追加したい」といった依頼で使う。手順メモ、確認ポイント、落とし穴、運用メモを `docs/knowledge/kebab-case-title.md` として新規作成する。判断記録を残したい時は `write-adr` スキルを使い、既存 note を更新したい時は `docs-update` スキルを使う。
metadata:
  short-description: 通常知見メモ作成
---

# Write Knowledge Note

通常知見として残す内容を、`root docs/knowledge/` 向けの新規 knowledge note として作成する。
この skill は path 決定、本文生成、新規ファイル作成に責務を限定し、既存 note の更新は行わない。

## 基本方針

- 通常知見として残す理由を先に明確にする。
- 判断記録ではなく、共有して再利用したい知見だけを扱う。
- knowledge note は短く、後から参照しやすい形に絞る。
- 内容に応じて要点を優先し、重い固定構造を持ち込まない。
- 既存 note と衝突する場合は上書きせず停止する。

## 対象

- 手順メモ
- 確認ポイント
- 再発しやすい落とし穴
- 軽量な運用メモ
- 再発防止メモ

## 対象外

- 複数案からの選定理由を残す判断記録
- 方針変更や互換性判断
- 採用 / 不採用の決定
- 既存 knowledge note の追記や統合
- 上記に当てはまる内容を残したい時は `write-adr` スキルを使う

## 出力ガイド

- 結果は `status=created|skipped`、`path`、`title`、`reason` を返せる形にする。
- 新規 path は `docs/knowledge/kebab-case-title.md` の形式で決める。
- 本文は短い Markdown で作成する。
- 必須の固定見出しは `# Title` のみとし、必要なら要点や注意点を簡潔に加える。

## 手順

### 1) 通常知見として残す理由を整理する

- 何を覚えておくべきかを一文でまとめる。
- なぜ判断記録ではなく通常知見として残すのかを確認する。

### 2) 要点をそろえる

- 手順、確認ポイント、注意点のうち必要なものだけを抜き出す。
- 背景説明は、知見を理解するのに必要な範囲へ絞る。

### 3) ファイル名案を作る

- 内容を表す短い kebab-case のタイトルを付ける。
- path は `docs/knowledge/kebab-case-title.md` として決める。

### 4) 知見メモ本文を書く

- `# Title` を置く。
- 本文は短い知見メモとして、要点中心にまとめる。

### 5) 新規ファイルを作成する

- 既存ファイルと path が衝突しないかを確認する。
- 衝突する場合は上書きせず `skipped` にする。
- 衝突しなければ、新規 knowledge note として作成する。

## 完了条件

- 通常知見として残す理由が説明できる
- `docs/knowledge/kebab-case-title.md` 形式の path がある
- 短い Markdown 本文がある
- 新規 knowledge note が作成されるか、`skipped` 理由が説明できる
