# 0023: docs 追従更新を専用 skill に分ける

- Status: Superseded
- Superseded-By: 0040
- Amended-By: 0024
- Amends: 0011, 0019, 0020

変更後の README、index、ADR、notes、CONTEXT、skill references の追従更新は、`scribe` の一般的な文書作成・整形や `verification` / `inspect` の検証記録だけでは入口が曖昧になりやすい。`doc-followup` skill を追加し、差分や変更根拠から影響する durable docs を特定して、事実で確認できる参照ずれや古い導線を最小更新する入口にする。`orchestrate` workflow では、実装・検証後かつ Gate 3 前に docs 追従チェックを行い、Gate 3 review 入力へ含める。

`doc-followup` は実装や runtime 設定を変更せず、新規本文作成や artifact 整形は `scribe`、確認だけの依頼は `verification` / `inspect` に残す。ADR は履歴として扱い、方針変更は既存 ADR 本文の上書きではなく新規 ADR と状態・関係メタデータで記録する。

この判断は ADR 0019 で廃止した一般的な `docs-update` 入口を復活させるものではない。`doc-followup` は変更後の追従更新と workflow 内の完了前チェックに範囲を限定する。
