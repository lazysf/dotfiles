---
name: scribe
description: README、既存 docs、運用手順、設計メモ、PRD、要件定義、基本設計、詳細設計、実装計画、テストケース、traceability matrix、CONTEXT、ADR などの doc / artifact 作成・更新・整形に使う。一次情報と確認済み文脈に沿って、format、文体、章構成、ID、リンク、path、command、未確認事項を整える。合意形成は `grill`。
metadata:
  short-description: 文書と成果物の整形
---

# Scribe

確認済みの事実と合意済み文脈を、適切な doc / artifact に読みやすく反映する。

## 手順

- 何を文書化するか、根拠となる一次情報を整理する。
- 影響する既存 docs / artifacts を特定する。
- 新規追加より既存の自然な位置へ差し込む。
- 対象 artifact と根拠資料を確認し、対象スコープと非スコープを短く言い換える。
- 責務外の内容は対象 artifact に書かない。
- 既存の章構成、用語、粒度、文体に寄せ、今回必要な最小差分に留める。
- 実装計画では、初回実装を最小で直線的な形から始める方針と、未確認の抽象化・分割・依存追加を非スコープとして必要十分に残す。
- 既存 ID があれば継続し、ID 体系が未確定なら採番前に確認する。
- 前提条件、手順、期待結果、注意点、受入条件、確認方法は必要なものだけ書く。
- リンク、path、command、用語、他文書との整合を確認する。
- artifact ごとの書き方で迷う時は [references/artifact-workflows.md](references/artifact-workflows.md) を読む。

## 成果物

- Docs README: [references/readme-format.md](references/readme-format.md)
- PRD: [references/prd-format.md](references/prd-format.md)
- 要件定義: [references/requirements-format.md](references/requirements-format.md)
- 基本設計: [references/basic-design-format.md](references/basic-design-format.md)
- 詳細設計: [references/detailed-design-format.md](references/detailed-design-format.md)
- 実装計画: [references/implementation-plan-format.md](references/implementation-plan-format.md)
- テストケース: [references/test-case-format.md](references/test-case-format.md)
- Traceability Matrix: [references/traceability-matrix-format.md](references/traceability-matrix-format.md)
- CONTEXT: [references/context-format.md](references/context-format.md)
- ADR: [references/adr-format.md](references/adr-format.md)

## 境界

- 実装や設定で確認できない内容は、事実として書かない。
- 未確認事項は断定せず、確認待ちとして分ける。
- 小さな変更に合わせて文書全体を書き直さない。
- 共有理解、要件、成功条件、scope、実装 readiness の合意形成は `grill`。
- ADR 作成や状態更新は、ユーザーに提案してから実行する。
- 秘密情報、認証情報、private config、未公開個人情報は durable artifact に残さない。
- docs review 専用依頼では、この skill だけで本文更新へ進まない。

## 出力

- `artifact_type`
- `updated_docs`
- `basis`
- `traceability_updates`
- `open_questions`
- `verification`

未確認事項や未実行の確認があれば隠さず示す。
