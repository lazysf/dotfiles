# ADR Workflow Review Pitfalls

ADR 台帳フローを拡張するときは、次を先にそろえる。

## Acceptance timing

- ADR の `Accepted` 化は commit 作成と切り離し、明示された採用判断だけを根拠にする。
- `capture-change-knowledge`、`write-adr`、`update-adr-status` の採用判断契約を一致させる。
- `git-push` は ADR を採用状態へ進めず、push 前の重複整理、状態整合、集約漏れだけを確認する。
- direct entry だけ別契約にしない。

## Supersede contract

- `Superseded` は、新 ADR 側に一致する `- Supersedes:` がすでにある場合だけ許可する。
- strict validation と auto-backfill を同時に書かない。
- `update-adr-status` は新 ADR 側の関係行を補完せず、検証だけを行う。

## Direct ADR flows

- `write-adr` は新 ADR を `Proposed` として作るだけにする。
- ADR の採用判断が明示された場合だけ、`update-adr-status` で `Accepted` に進める。
- `Accepted` と `Superseded` は 1 回の更新に詰め込まず、2 段階更新として明示した方が契約がぶれにくい。

## Review checklist

- 採用判断の契約は全導線で一致しているか
- direct `write-adr` 導線でも `Accepted` に到達できるか
- `Supersedes` がある場合、旧 ADR が退役する後段があるか
- push 前集約が個別 change の routing を再分類せず、重複整理、状態整合、集約漏れに責務を絞っているか
