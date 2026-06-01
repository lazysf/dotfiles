# ADR Workflow Review Pitfalls

ADR 台帳フローを拡張するときは、次を先にそろえる。

## Acceptance timing

- ADR の `Accepted` 化は commit 作成と切り離し、明示された採用判断だけを根拠にする。
- `grill` / `scribe` の ADR 作成、採用、supersede 更新で採用判断契約を一致させる。
- `git-push` は ADR を採用状態へ進めず、push 実行だけを扱う。

## Supersede contract

- `Superseded` は、新 ADR 側に一致する `- Supersedes:` がすでにある場合だけ許可する。
- strict validation と auto-backfill を同時に書かない。
- `scribe` は旧 ADR 更新時に新 ADR 側の関係行を補完せず、明示された関係だけを検証する。
- 旧 ADR 本文は後続方針で上書きせず、状態・関係メタデータだけを更新する。

## Direct ADR flows

- `scribe` は採用判断が未確定なら新 ADR を `Proposed` として作る。
- ユーザーの明示依頼または会話上の合意で採用済みなら、新 ADR は作成時点で `Accepted` にしてよい。
- `Accepted` と `Superseded` は順序付き action として分ける。
- 方針変更や既存判断の補正は、既存 ADR 本文の編集ではなく新 ADR として作る。

## Review checklist

- 採用判断の契約は全導線で一致しているか
- ADR 作成後に明示根拠があれば `Accepted` に到達できるか
- `Supersedes` がある場合、旧 ADR が退役する後段があるか
- 旧 ADR 本文が履歴として保持され、方針変更で上書きされていないか
- Git push 導線へ ADR lifecycle が再流入していないか
