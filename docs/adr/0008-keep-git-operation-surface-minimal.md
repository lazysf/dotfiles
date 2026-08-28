# 0008: Git 操作 surface を最小に保つ

- Status: Superseded
- Superseded-By: 0042
- Amended by: 0018

## Context

Codex の Git 導線には、正式な操作 skill と機械的な rule がある。
commit と push は手順、停止条件、結果報告が必要なので `git-commit` と `git-push` を正式入口として持っている。

一方で、branch 切替、stash、reset、restore、mv、rebase などの Git 操作まで skill 化すると、surface が増えて使い分けが曖昧になる。
また、未定義コマンドは `approval_policy = "on-request"` により prompt 相当で扱われるため、prompt rule を大量に置くと、明示的に許可したい操作と明示的に禁止したい操作が見えにくくなる。

知見整理は Git 操作そのものではなく、push の有無に依存しない作業締めの導線として扱う。
そのため、`git-push` は知見整理を呼び出さず、push 実行と upstream 判定だけに責務を絞る。

## Decision

- Git 操作の正式 skill は `git-commit` と `git-push` だけにする。
- `git-push` は push 実行と upstream 判定だけを扱い、知見整理や ADR 状態更新の導線を持たない。
- push に紐づく知見集約を Git 操作 surface の一部として扱わない。
- Git rule は `allow` だけで整理し、未定義コマンドは既定の prompt に任せる。
- `prompt` / `forbidden` rule は置かない。
- Git rule の allow は、`git-commit` / `git-push` skill の手順で必要な読み取り専用操作と、`git-commit` skill に必要な変更操作に限定する。
- 読み取り専用操作は `git status`、`git diff`、`git branch -vv`、`git remote -v`、`git log` だけを allow にする。
- `git-commit` の手順で使う `git add` と `git commit -m` / `git commit -F` は allow にする。
- `git-push` の手順で使う通常 push は共有先へ影響するため、未定義コマンドとして既定 prompt に任せる。
- 強制 push、広域 push、削除 push、hard reset、ignored file を含む clean なども個別 rule を置かず、既定 prompt と skill 停止線に任せる。

## Consequences

- Git 操作用 skill の入口が commit / push に絞られ、依頼時の routing が単純になる。
- `git-push` が知見整理を始めないため、リモートリポジトリを使わない作業でも知見整理導線を別に保てる。
- commit / push skill の手順に必要な読み取り専用の Git 照会は自走しやすくなる。
- `git add` と通常 commit は skill 手順内の必要操作として自走しやすくなる。
- 通常 push は refspec variant を broad allow で通さないため、skill 手順内でも approval friction が残る。
- `git add` は broad allow とし、option staging の個別 carveout は置かない。
- `git mv`、`git restore`、`git switch`、`git checkout`、`git stash`、`git rebase` などは rule を置かず、未定義コマンドとして既定 prompt に任せる。
- 新しい Git 操作導線を追加したい場合は、まず rule の prompt 運用で足りるかを確認し、skill 増設を既定にしない。
