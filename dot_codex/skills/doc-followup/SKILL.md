---
name: doc-followup
description: 変更後の docs 追従更新、README/index/ADR/notes/CONTEXT/skill references の参照ずれ修正、rename/delete 後の古い導線整理に使う。diff や変更根拠から影響する durable docs を特定し、確認できるずれだけを最小修正する。新規本文作成や artifact 整形は `scribe`、確認だけなら `verification`。
metadata:
  short-description: docs 追従更新
---

# Doc Follow-up

変更後に、durable docs / index / reference の追従漏れを見つけて最小更新する。

## 手順

- 追従元を確認する。ユーザー指定 path / issue / PR / request folder がある場合はそれを最優先にする。未指定なら unstaged / staged diff、untracked file list、直近 commit の順で根拠を取る。
- ユーザー指定 scope がある場合はその外へ更新を広げない。scope 外の docs 更新が必要なら、理由を `Open Questions` に残して確認する。
- 変更の種類を分ける: rename / delete / new file / surface 追加 / runtime 設定 / skill / agent / rules / docs 構造 / public behavior。
- 影響する docs を探す。rename / delete / 移動を含む変更や、複数 surface・複数 docs に波及する変更では、確認すべき箇所を [references/followup-checklist.md](references/followup-checklist.md) に列挙しているため、探索の前に読んで漏れなく当たる。単一ファイルの軽微な追従なら読まなくてよい。
- 古い path、名称、導線、責務説明、ADR / README / index の抜けを `rg` と既存 docs で確認する。
- 確認できたずれだけを、既存の章構成、文体、粒度に合わせて最小更新する。
- Codex / Claude の両 surface に対応物がある場合は、片側だけ更新していないか確認する。
- ADR は履歴として扱い、方針変更は新規 ADR と状態・関係メタデータで記録する。既存 ADR 本文は上書きしない。
- 更新後、参照語、旧 path、旧名称、削除済み file 名が残っていないか確認する。

## 境界

- 実装や runtime 設定の挙動は変更しない。
- 未確認の意図や未来の運用を docs に足さない。
- docs 追従ではなく新しい説明本文、artifact、ADR 本文を作る作業は `scribe` を使う。
- 追従漏れの確認だけで修正しない依頼は `verification` を使う。
- 公開挙動、権限、secret、本番設定、破壊的操作に触れる判断が必要なら止めて確認する。
- 秘密情報、認証情報、private config 値、未公開個人情報は durable docs に残さない。

## 出力

- `basis`
- `updated_docs`
- `followup_checks`
- `remaining_risks`
- `verification`

未確認事項や意図的に更新しなかった docs があれば隠さず示す。
