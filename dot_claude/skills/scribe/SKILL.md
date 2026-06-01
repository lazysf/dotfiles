---
name: scribe
description: request.md、requirements.md、basic-design.md、detailed-design.md、tasks.md、implementation.md、test.md、review.md、README、ADR、CONTEXT などの doc / artifact 作成・更新・整形に使う。一次情報と確認済み文脈に沿って、format、文体、章構成、ID、traceability、未確認事項を整える。変更後の参照ずれや docs 追従更新は `doc-followup`、合意形成は `grill`。
---

# Scribe

確認済みの事実と合意済み文脈を、適切な doc / artifact に読みやすく反映する。

## 手順

- 何を文書化するか、根拠となる一次情報を整理する。
- 影響する既存 docs / artifacts を特定する。
- 新規追加より既存の自然な位置へ差し込む。
- request folder は既定で `docs/requests/<slug>/` に作る。
- request folder artifact は担当工程の責務を超えないように書く。
- 既存 ID があれば継続し、ID 体系が未確定なら採番前に確認する。
- `REQ-*` / `AC-*` / `BD-*` / `DD-*` / `TASK-*` / `TC-*` の対応を崩さない。
- 前提条件、手順、期待結果、注意点、受入条件、確認方法は必要なものだけ書く。
- 未確認事項は各 artifact の `未確認事項` に残し、確認済みと混ぜない。
- 対象 artifact は 1 つに絞り、必要な reference だけ読む。

## 成果物

- Request: [references/request-format.md](references/request-format.md)
- Requirements: [references/requirements-format.md](references/requirements-format.md)
- Basic Design: [references/basic-design-format.md](references/basic-design-format.md)
- Detailed Design: [references/detailed-design-format.md](references/detailed-design-format.md)
- Tasks: [references/tasks-format.md](references/tasks-format.md)
- Implementation: [references/implementation-format.md](references/implementation-format.md)
- Test: [references/test-format.md](references/test-format.md)
- Review: [references/review-format.md](references/review-format.md)
- Traceability Matrix: [references/traceability-matrix-format.md](references/traceability-matrix-format.md)
- Docs README: [references/readme-format.md](references/readme-format.md)
- ADR: [references/adr-format.md](references/adr-format.md)
- CONTEXT: [references/context-format.md](references/context-format.md)

## 境界

- 実装や設定で確認できない内容は、事実として書かない。
- 未確認事項は断定せず、確認待ちとして分ける。
- 小さな変更に合わせて文書全体を書き直さない。
- 共有理解、要件、成功条件、scope、実装 readiness の合意形成は `grill`。
- 変更後の README、index、ADR、notes、CONTEXT、skill references の追従更新は `doc-followup`。
- ADR 作成や状態更新は、ユーザーの明示依頼、または方針変更・採用判断の合意がある場合に実行する。合意が曖昧な場合だけ提案してから実行する。
- 方針変更や既存判断の補正は既存 ADR 本文を上書きせず、新規 ADR と状態・関係メタデータで履歴として反映する。
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
