# ADR Workflow Review Pitfalls

ADR 台帳フローを拡張するときは、次を先にそろえる。

## Acceptance policy

- `adr_acceptance_policy` の読み元は current project の `[projects."<repo-root>"]` に固定する。
- key 未設定時の fallback と不正値時の扱いを、`capture-change-knowledge`、`git-commit`、`git-push`、`update-adr-status` で一致させる。
- direct entry だけ別契約にしない。

## Supersede contract

- `Superseded` は、新 ADR 側に一致する `- Supersedes:` がすでにある場合だけ許可する。
- strict validation と auto-backfill を同時に書かない。
- `update-adr-status` は新 ADR 側の関係行を補完せず、検証だけを行う。

## Direct ADR flows

- `write-adr` で作る差分は docs-only になりやすいので、既定 `commit` policy では `ADR-only commit` 例外が必要になる。
- `ADR-only commit` や `default_branch` reconcile では、新 ADR の `Accepted` だけで終わらせず、必要なら旧 ADR の `Superseded` まで別更新で進める。
- `Accepted` と `Superseded` は 1 回の更新に詰め込まず、2 段階更新として明示した方が契約がぶれにくい。

## Review checklist

- policy source / fallback / invalid handling は全導線で一致しているか
- direct `write-adr` 導線でも `Accepted` に到達できるか
- `Supersedes` がある場合、旧 ADR が退役する後段があるか
- `default_branch` policy でも commit policy と同じ整合が保たれるか
