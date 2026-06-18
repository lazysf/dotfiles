---
name: scribe
description: 実装が固まった後の README / docs（仕様・使い方）、ADR（なぜそうしたか）、notes（背景・調査メモ）を、確認済みの事実から作成・更新する時に使う。開発駆動の事前 doc は対象外で、third-party 保守に必要な後追い doc に絞る。
metadata:
  short-description: doc 生成
---

# Scribe

実装が固まった後に、確認済みの事実から third-party 保守に必要な doc を作る。開発駆動の事前 doc は対象外。

## いつ使うか

- **仕様・使い方 doc（README / docs）**: 実装が固まった後、third-party が使い方を理解する必要がある時。
- **ADR**: 実装中の分岐点で、3 条件（下記）を満たす時。
- **notes**: 背景・調査メモを残す価値がある時（任意）。

## doc 要否（silent skip 禁止）

実装一段落時と commit 前に、仕様 doc 追従の要否を一言で明示する。黙って飛ばさない。

- **要**: 公開 IF / CLI / API の追加・変更、新機能・新しい使い方、設定項目の追加・変更、third-party が挙動を知る必要のある変更。
- **不要（と明示）**: 内部リファクタ、挙動不変のバグ修正、typo。

## 共通の進め方

- 根拠となる一次情報（コード、差分、コマンド結果、確定済み合意）を特定する。
- 既存の自然な位置に差し込む。新規 doc は既存に収まらない時だけ作る。
- 既存の章構成、用語、粒度、文体に寄せ、最小差分に留める。
- 推測で書かない。未確認は「確認待ち」として分けるか、書かない。

## 成果物別の書式

書き始める前に、対象の format reference を 1 つだけ読む。記憶や推測で書かない。

- README / docs: [references/readme-format.md](references/readme-format.md)
- ADR: [references/adr-format.md](references/adr-format.md)
- notes: [references/notes-format.md](references/notes-format.md)

## ADR の判断基準

3 条件 AND（複数案を実比較 / 覆すコストが高い / 捨てた案に再検討価値）を全部満たす時だけ書く。乱発も silent skip も避ける。詳細条件・最小テンプレ・Status lifecycle・関係メタデータは [references/adr-format.md](references/adr-format.md) を参照。既存 ADR 本文は履歴として扱い、上書きせず新規 ADR + 関係メタデータで反映する。

## 境界・停止条件

- 実装や設定で確認できない内容を事実として書かない（一次情報がなければ書かない）。
- 小さな変更で doc 全体を書き直さない。
- 開発を駆動する事前 doc（requirements / design / tasks）は作らない。
- 仕様 doc が必要かの判断を曖昧にしたまま commit に進まない。
- ADR の 3 条件を満たさないのに ADR を求められたら、不要と明示するか notes を提案する。
- 秘密情報、認証情報、private config、本番設定、未公開個人情報を doc に書かない（必要なら停止する）。

## 出力

- `artifact_type`（README / ADR / notes）
- `updated_docs`（path のリスト）
- `basis`（一次情報）
- `open_questions`（未確認事項）
