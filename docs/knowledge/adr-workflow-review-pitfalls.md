# ADR Workflow Review Pitfalls

ADR 台帳フローを拡張するときは、次を先にそろえる。

## Acceptance timing

- ADR の `Accepted` 化は commit 時採用に固定し、config key で切り替えない。
- `capture-change-knowledge`、`git-commit`、`update-adr-status` の commit 時採用契約を一致させる。
- `git-push` は ADR を採用状態へ進めず、push 前の重複整理、状態整合、集約漏れだけを確認する。
- direct entry だけ別契約にしない。

## Supersede contract

- `Superseded` は、新 ADR 側に一致する `- Supersedes:` がすでにある場合だけ許可する。
- strict validation と auto-backfill を同時に書かない。
- `update-adr-status` は新 ADR 側の関係行を補完せず、検証だけを行う。

## Direct ADR flows

- `write-adr` で作る差分は docs-only になりやすいので、`ADR-only commit` 例外が必要になる。
- `ADR-only commit` では、新 ADR の `Accepted` だけで終わらせず、必要なら旧 ADR の `Superseded` まで別更新で進める。
- `Accepted` と `Superseded` は 1 回の更新に詰め込まず、2 段階更新として明示した方が契約がぶれにくい。

## Review checklist

- commit 時採用の契約は全導線で一致しているか
- direct `write-adr` 導線でも `Accepted` に到達できるか
- `Supersedes` がある場合、旧 ADR が退役する後段があるか
- push 前集約が commit 時 routing を再分類せず、重複整理、状態整合、集約漏れに責務を絞っているか
