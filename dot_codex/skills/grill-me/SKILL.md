---
name: grill-me
description: 「grill me」「問い詰めて」「stress-test して」といった、plan / design の未確定事項を会話で詰める依頼で使う。1 問ずつ質問し、推奨回答を添えて共有理解まで進める。docs / CONTEXT / ADR と照合して記録する時は `grill-with-docs` スキルを使う。
metadata:
  short-description: 計画を問い詰める
---

# 計画を問い詰める

計画や設計を、共有理解に到達するまで一問ずつ問い詰める。

## 手順

- 対象の plan / design / 方針を短く言い換える。
- codebase や既存文脈で答えられることは、ユーザーへ聞く前に探索する。
- 最も影響が大きい未確定事項を 1 つ選ぶ。
- 質問は 1 つだけ出し、必ず推奨回答を添える。
- 回答を受けたら、確定事項と残る未確定事項を短く更新する。
- 共有理解に到達するまで繰り返す。

## 境界

- この skill では変更実装や docs 更新を行わない。
- docs-aware な用語整理、`CONTEXT.md` 更新、ADR 作成まで進める時は `grill-with-docs` スキルを使う。
- 一段落したら `grill_status: 一段落` とし、まだ続ける時は `next_question` を 1 つだけ出す。
