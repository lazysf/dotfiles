# ADR Workflow Review Pitfalls

ADR 台帳フローを拡張するときは、次を先にそろえる。

## Acceptance timing

- ADR の `Accepted` 化は commit 作成と切り離し、明示された採用判断だけを根拠にする。
- `planning` の ADR 作成、採用、supersede 更新で採用判断契約を一致させる。
- `git-push` は ADR を採用状態へ進めず、push 実行だけを扱う。

## Supersede contract

- `Superseded` は、新 ADR 側に一致する `- Supersedes:` がすでにある場合だけ許可する。
- strict validation と auto-backfill を同時に書かない。
- `planning` は旧 ADR 更新時に新 ADR 側の関係行を補完せず、明示された関係だけを検証する。

## Direct ADR flows

- `planning` は新 ADR をまず `Proposed` として作る。
- ADR の採用判断が明示された場合だけ、後続 action で `Accepted` に進める。
- `Accepted` と `Superseded` は順序付き action として分ける。

## Review checklist

- 採用判断の契約は全導線で一致しているか
- ADR 作成後に明示根拠があれば `Accepted` に到達できるか
- `Supersedes` がある場合、旧 ADR が退役する後段があるか
- Git push 導線へ ADR lifecycle が再流入していないか
