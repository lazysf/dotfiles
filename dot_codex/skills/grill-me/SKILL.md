---
name: grill-me
description: 「grill me」「この計画を問い詰めて」「設計を stress-test して」といった、plan / design の穴や未確定事項を会話で詰めたい依頼で使う。質問を 1 つずつ出し、各質問に推奨回答を添え、共有理解に到達するまで decision tree を辿る。既存 docs や code と照合しながら用語や ADR も更新したい時は `grill-with-docs` スキルを使う。
metadata:
  short-description: 計画を問い詰める
---

# Grill Me

計画や設計を、共有理解に到達するまで一問ずつ問い詰める。

## 基本方針

- 計画、設計、方針の全体を pressure test する。
- decision tree の枝を 1 つずつ辿り、判断同士の依存関係を解く。
- 質問は 1 つずつ行う。
- 各質問には、既存文脈に照らした推奨回答を添える。
- codebase を探索すれば答えられる疑問は、ユーザーへ聞く前に探索する。

## 手順

1. 対象の plan / design / 方針を短く言い換える。
2. 既存ファイルや codebase から答えられる前提を先に確認する。
3. 最も影響が大きい未確定事項を 1 つ選ぶ。
4. 推奨回答を添えて質問する。
5. 回答を受けたら、確定事項と残る未確定事項を短く更新する。
6. 共有理解に到達するまで 3-5 を繰り返す。

## 停止線

- 変更実装や docs 更新はこの skill では行わない。
- docs-aware な用語整理、`CONTEXT.md` 更新、ADR 作成まで進めたい時は `grill-with-docs` スキルを使う。
