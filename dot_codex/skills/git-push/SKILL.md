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
- push 実行前に outgoing range を確認し、`capture-push-knowledge` で知見の重複整理、状態整合、集約要否を判定する。
- `consolidation_required` の場合は push せず、必要な次アクションを返す。
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

### 4) push 前知見集約

- push 実行前に outgoing range を作る。
- upstream がある場合は `@{u}..HEAD` を使う。
- upstream 未設定で push 先 branch が一意に決められる場合は、その remote branch と `HEAD` の差分を使う。
- upstream 未設定で push 先 remote branch がまだ存在しない新規ブランチの場合は、`knowledge_preflight = { status: skipped, reason: no-upstream-new-branch }` として push 実行へ進める。
- range が安全に決められない場合は push せず、確認すべき upstream / remote / branch を返す。
- `git log <range>` 相当で outgoing commit 群を集める。
- `git diff --name-only <range>` 相当で変更 path を集約する。
- `docs/knowledge/` または `docs/adr/` の path が含まれる場合は `knowledge_or_adr_paths_in_range` に入れる。
- `capture-push-knowledge` に evidence packet を渡し、`skipped | ready | consolidation_required` を判定する。
- `skipped` または `ready` なら push 実行へ進む。
- `consolidation_required` なら push せず、必要な `write-knowledge-note`、`docs-update`、`write-adr`、`update-adr-status` の次アクションを返す。
- この skill は push 前整理のための docs 更新 commit を自動作成しない。

### 5) プッシュ実行

- upstream 未設定なら `git push -u <remote> <branch>` を使う。
- upstream 済みなら `git push` を使う。
- 明示指定がある場合は `git push <remote> <branch>` を使う。

### 6) タグのプッシュ

- 明示指示がある場合のみ行う。
- タグ数が多い場合は確認する。

### 7) 失敗時の扱い

- 認証エラー、non-fast-forward、保護ブランチなどのエラーは止めて確認する。
- 自動で解決策を実行しない。

## 結果報告

- 最終返答では、push 結果を通常の返答文の中で簡潔に報告する。
- `git-push` の結果報告では常に、最低限 `remote`、`branch`、`upstream`、`action`、`result`、`knowledge_preflight` を含める。
- `remote` は実際に使った push 先をそのまま返す。
- `branch` は push 対象ブランチを返す。
- `upstream` は既存 upstream を使ったのか、今回設定したのか、未設定のまま push しなかったのかが分かる user-facing な短い値で返す。
- `action` は `git push`、`git push -u <remote> <branch>`、`git push <remote> <branch>` のどれを実行したか、または no-op / 事前停止で判定した push 操作を返す。
- `result` は最低でも `pushed` / `nothing-to-push` / `skipped` / `failed` を表現できるようにする。
- `knowledge_preflight` は `skipped` / `ready` / `consolidation_required` と理由を返す。
- `notes` と `next_action` は任意にし、push 前集約、behind / diverged、認証失敗などの追加説明が必要な場合だけ使う。
- `success` の例: `remote=origin, branch=main, upstream=existing, action=git push, result=pushed, knowledge_preflight={status: ready, reason: no-consolidation-needed}`
- `nothing-to-push` の例: `remote=origin, branch=main, upstream=existing, action=no-op, result=nothing-to-push, knowledge_preflight={status: skipped, reason: no-outgoing-commits}`
- `new-branch` の例: `remote=origin, branch=feature-x, upstream=set, action=git push -u origin feature-x, result=pushed, knowledge_preflight={status: skipped, reason: no-upstream-new-branch}`
- `skipped` の例: `remote=origin, branch=main, upstream=existing, action=no-op, result=skipped, knowledge_preflight={status: consolidation_required, reason: adr-status-update-needed}, next_action=update-adr-status`
- 失敗時はエラー本文を丸ごと貼るのではなく、原因の要点と次に確認すべき点を短く示す。
