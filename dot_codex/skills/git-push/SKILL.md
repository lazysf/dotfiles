---
name: git-push
description: 「今のブランチを push したい」「upstream を設定してリモートへ出したい」といった Git の依頼で使う。push 対象、push 先、upstream 設定の有無を確認し、通常 push を安全に実行する。コミットを作りたい時は `git-commit` スキルを使い、強制 push はこの skill の対象外とする。
metadata:
  short-description: Git push
---

# Git Push

現在のブランチのローカルコミットをリモートへプッシュし、必要なら upstream を設定する。
このスキルは、Git 導線のうち push 実行と upstream 判定の責務を担う。

## 基本方針

- push はユーザーの明示的な依頼がある場合のみ行う。
- commit 作成やメッセージ整備はこのスキルの責務に含めない。
- project policy `adr_acceptance_policy = "default_branch"` の場合だけ、採用確定後の ADR 状態更新をしたい時は `update-adr-status` スキルを使う。
- project policy は current project の `[projects."<repo-root>"].adr_acceptance_policy` を正本にし、未設定は `commit`、不正値は ADR 状態更新だけ skip にする。
- この skill では、手順に明示した Git コマンドだけを使う。
- 通常 push は引き続き approval / `prompt` 前提で扱う。

## 対象外

- コミット作成やコミットメッセージ整備のみが目的の依頼。
- pull / rebase で履歴調整が必要だが、調整指示がない状態。
- 手順に明示していない push 操作。

## 手順

### 1) 状況確認

- `git status -sb`、`git branch -vv`、`git remote -v` を確認する。
- 次の条件では push せず停止して確認する。
- detached HEAD で、現在ブランチが確定していない場合。
- rebase、merge、cherry-pick、revert の途中で、履歴操作が完了していない場合。
- コンフリクトが残っていて、作業ツリーや index が未解決の場合。
- 複数リモートがあり、push 先が一意に決められない場合。
- upstream の設定先とユーザー意図が食い違う、または `git branch -vv` 上で upstream mismatch が疑われる場合。
- 保護ブランチ運用により、現在ブランチへの直接 push が禁止されている前提が分かっている場合。

### 2) プッシュ対象の判定

- ahead が 0 でタグ指示もない場合は、プッシュ対象がない旨を伝えて終了する。
- behind または diverged の場合は、同期方針を確認するまで停止する。

### 3) プッシュ先の決定

- ユーザー指定があればそれを最優先する。
- upstream が一意ならそれを使う。
- upstream 未設定で単一リモートなら `origin` と現在ブランチを既定にする。
- upstream 未設定かつ複数リモートがある場合は、自動で決めずに確認する。

### 4) プッシュ実行

- upstream 未設定なら `git push -u <remote> <branch>` を使う。
- upstream 済みなら `git push` を使う。
- 明示指定がある場合は `git push <remote> <branch>` を使う。

### 5) タグのプッシュ

- 明示指示がある場合のみ行う。
- タグ数が多い場合は確認する。

### 6) 必要なら ADR 状態更新に進む

- current project の `[projects."<repo-root>"].adr_acceptance_policy` を読み、key がない場合は `commit` として扱う。
- 値が `commit | default_branch` 以外なら、push 自体は成功扱いのまま ADR 状態更新だけ `skipped(invalid-adr-acceptance-policy)` にする。
- policy が `commit` なら、`git-push` 側で ADR 状態更新は行わない。
- policy が `default_branch` で、今回の push 先が current project の default branch と確認できる場合だけ、今回の push に含まれる新規 `Proposed` ADR を 1 件ずつ `update-adr-status` で `Accepted` に進める。
- その新 ADR に `Supersedes` が明示されている場合だけ、続けて旧 ADR に対して `update-adr-status(target_adr=<old>, new_status=Superseded, related_adrs=<new>, event_basis=default_branch)` を別更新として行う。
- push 先や branch が採用確定条件を満たすか不明なら、ADR 状態は変えない。

### 7) 失敗時の扱い

- 認証エラー、non-fast-forward、保護ブランチなどのエラーは止めて確認する。
- 自動で解決策を実行しない。

## 結果報告

- 最終返答では、push 結果を通常の返答文の中で簡潔に報告する。
- 最低限、`remote`、`branch`、`upstream` 設定の有無、実行内容、結果、必要なら次アクションを含める。
- 失敗時はエラー本文を丸ごと貼るのではなく、原因の要点と次に確認すべき点を短く示す。
