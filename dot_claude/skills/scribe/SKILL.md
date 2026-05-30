---
name: scribe
description: feature note（1 変更 1 ノート）、README、既存 docs、運用手順、ADR、CONTEXT などの doc / artifact 作成・更新・整形に使う。既定は feature note。PRD、要件定義、基本設計、詳細設計、実装計画、テストケース、traceability matrix は大規模時のみ別建てする。一次情報と確認済み文脈に沿って、format、文体、章構成、ID、リンク、path、command、未確認事項を整える。合意形成は `grill`。
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
- 既定は 1 変更 1 ノートの feature note。別建ては「成果物の選び方」に従う。
- 各 artifact は専用フォルダを作らず、reference 冒頭の単一 path に書く。
- 既存 ID があれば継続し、ID 体系が未確定なら採番前に確認する。
- 受入条件・確認方法・期待結果は観測可能な形で、必要なものだけ書く。
- リンク、path、command、用語、他文書との整合を確認する。
- 未確認事項は各 doc の `未確認事項` に残し、確認済みと混ぜない。
- 対象 doc は「成果物の選び方」で 1 つに絞り、手順・注意点・書式はその reference を読む。

## 成果物の選び方

書く前に対象 doc を 1 つに絞る。**迷ったら feature note に寄せ、別建ては必要が確認できてからにする。** 合意フェーズでの artifact 選択は `grill`。書くフェーズはここで対象を確定し、各 reference の手順に従う。

既定:

- Feature Note（1 変更 1 ノート。要件 → 設計 → 実装・検証を 1 枚に。Level 1 はノートを作らず完了報告へ記録）: [references/feature-note-format.md](references/feature-note-format.md)

横断的な恒久知見（必要時）:

- CONTEXT（用語・文脈固有の呼び名が確定した時）: [references/context-format.md](references/context-format.md)
- ADR（不可逆・非自明・trade-off のある判断）: [references/adr-format.md](references/adr-format.md)
- Docs README（docs 体系の案内）: [references/readme-format.md](references/readme-format.md)

大規模・多 feature で feature note に収まらない時だけ別建て:

- PRD（目的・成功条件・制約が曖昧）: [references/prd-format.md](references/prd-format.md)
- 要件定義（`FR-*` ごとの要求・受入条件）: [references/requirements-format.md](references/requirements-format.md)
- 基本設計（全体方針・責務分担）: [references/basic-design-format.md](references/basic-design-format.md)
- 詳細設計（IF・処理・validation・edge case）: [references/detailed-design-format.md](references/detailed-design-format.md)
- 実装計画（実装順序・変更境界・`TASK-*`）: [references/implementation-plan-format.md](references/implementation-plan-format.md)
- テストケース（確認観点）: [references/test-case-format.md](references/test-case-format.md)
- Traceability Matrix（要件↔テストの対応漏れ）: [references/traceability-matrix-format.md](references/traceability-matrix-format.md)

## 境界

- 実装や設定で確認できない内容は、事実として書かない。
- 未確認事項は断定せず、確認待ちとして分ける。
- 小さな変更に合わせて文書全体を書き直さない。
- 共有理解、要件、成功条件、scope、実装 readiness の合意形成は `grill`。
- ADR 作成や状態更新は、ユーザーに提案してから実行する。
- 秘密情報、認証情報、private config、未公開個人情報は durable artifact に残さない。
- docs review 専用依頼では、この skill だけで本文更新へ進まない。
