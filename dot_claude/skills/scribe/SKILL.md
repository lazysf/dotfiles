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
- 対象 artifact と根拠資料を確認し、対象スコープと非スコープを短く言い換える。
- 責務外の内容は対象 artifact に書かない。
- request folder は既定で `docs/requests/<slug>/` に作り、工程 artifact の責務を混ぜない。
- 既存の章構成、用語、粒度、文体に寄せ、今回必要な最小差分に留める。
- 実装計画では、初回実装を最小で直線的な形から始める方針と、未確認の抽象化・分割・依存追加を非スコープとして必要十分に残す。
- 既存 ID があれば継続し、ID 体系が未確定なら採番前に確認する。
- `REQ-*` / `AC-*` / `BD-*` / `DD-*` / `TASK-*` / `TC-*` の対応を崩さない。
- 前提条件、手順、期待結果、注意点、受入条件、確認方法は必要なものだけ書く。
- リンク、path、command、用語、他文書との整合を確認する。
- 複数 artifact をまたぐ進め方や、どの artifact から書くかの判断に迷う時は、その手順を [references/artifact-workflows.md](references/artifact-workflows.md) に置いているため、書き始める前に読む。

## 成果物

各 artifact を作成・更新する時は、章立て・ID 規則・記述順を対応する format reference に定めているため、書き始める前に対象の 1 つを必ず読み、その構成に従う。記憶や推測で書かない。

- Request: [references/request-format.md](references/request-format.md)
- Docs README: [references/readme-format.md](references/readme-format.md)
- PRD: [references/prd-format.md](references/prd-format.md)
- Requirements: [references/requirements-format.md](references/requirements-format.md)
- Basic Design: [references/basic-design-format.md](references/basic-design-format.md)
- Detailed Design: [references/detailed-design-format.md](references/detailed-design-format.md)
- Implementation Plan: [references/implementation-plan-format.md](references/implementation-plan-format.md)
- Tasks: [references/tasks-format.md](references/tasks-format.md)
- Implementation: [references/implementation-format.md](references/implementation-format.md)
- Test: [references/test-format.md](references/test-format.md)
- Review: [references/review-format.md](references/review-format.md)
- Traceability Matrix: [references/traceability-matrix-format.md](references/traceability-matrix-format.md)
- CONTEXT: [references/context-format.md](references/context-format.md)
- ADR: [references/adr-format.md](references/adr-format.md)

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

## 停止条件

- 一次情報や確認済み根拠がなく、事実として書けない。
- format reference や ID 体系が不明で、推測で採番・構成することになる。
- 秘密情報、認証情報、本番設定を artifact に書く必要がある。
