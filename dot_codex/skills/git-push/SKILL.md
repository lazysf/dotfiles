---
name: git-push
description: Git の commit を push したい、現在ブランチをリモートへ出したい、upstream を設定して push したい依頼で使う。push 先、upstream、outgoing range、push 前知見集約を確認してから通常 push する。commit 作成や commit message 整備が目的なら `git-commit` スキルを使い、force push は対象外とする。
metadata:
  short-description: Git push
---

# Git Push

現在のブランチのローカルコミットをリモートへプッシュし、必要なら upstream を設定する。
このスキルは、Git 導線のうち push 実行と upstream 判定の責務を担う。

## Stop conditions

次の状態では push せず、状況を確認する。
commit 作成や commit message 整備は `git-commit` スキルに委ねる。

- detached HEAD で、現在ブランチが確定していない場合。
- rebase、merge、cherry-pick、revert の途中で、履歴操作が完了していない場合。
- コンフリクトが残っていて、作業ツリーや index が未解決の場合。
- 複数リモートがあり、push 先が一意に決められない場合。
- upstream の設定先とユーザー意図が食い違う、または `git branch -vv` 上で upstream mismatch が疑われる場合。
- behind または diverged の状態で、同期方針が確認できていない場合。
- 保護ブランチ運用により、現在ブランチへの直接 push が禁止されている前提が分かっている場合。
- force push や広域 push が必要な場合。
- pull / rebase による履歴調整が必要だが、明示指示がない場合。

## 基本方針

- push はユーザーの明示的な依頼がある場合のみ行う。
- commit 作成やメッセージ整備はこのスキルの責務に含めない。
- push 実行前に outgoing range を確認し、`capture-push-knowledge` で知見の重複整理、状態整合、集約要否を判定する。
- `consolidation_required` の場合は push せず、必要な次アクションを返す。
- 強制 push や広域 push はこの skill の対象外とする。
- sandbox / network / 権限により承認が必要な場合は、承認要求を正規手順として扱い、承認を避けるための別経路や副作用のある代替操作を使わない。

## 対象外

- コミット作成やコミットメッセージ整備のみが目的の依頼。
- pull / rebase で履歴調整が必要だが、調整指示がない状態。

## 手順

### 1) 状況確認

- `git status -sb`、`git branch -vv`、`git remote -v` を確認する。
- Stop conditions に該当する場合は push せず停止して確認する。

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

Evidence packet は、推測ではなく確認済みの事実だけで次の最小項目をそろえる。
`recent_execution_context` には、直近のエラー、承認、検証結果を短く要約し、トークン、認証 URL、詳細な承認文面などの秘密情報は含めない。

```yaml
branch: <current branch>
remote: <push remote>
upstream_ref: <upstream ref or none>
outgoing_commits: <short sha, subject, and range summary>
changed_paths_summary: <paths or grouped path summary>
knowledge_or_adr_paths_in_range: <docs/knowledge or docs/adr paths, or none>
recent_execution_context: <short summary of recent errors, approvals, test/check results, or none>
```

### 5) プッシュ実行

- upstream 未設定なら `git push -u <remote> <branch>` を使う。
- upstream 済みなら `git push` を使う。
- 明示指定がある場合は `git push <remote> <branch>` を使う。

### 6) タグのプッシュ

- 明示指示がある場合のみ行う。
- タグ数が多い場合は確認する。

### 7) 失敗時の扱い

- `git push` 失敗時は force push、pull / rebase、GitHub API などで回避しない。
- 失敗時は約30秒待ってから、状態を再確認し、同じ push command を1回だけ再実行する。
- 再確認では `git status -sb`、`git branch -vv`、`git remote -v` と push 前知見集約に使った前提が変わっていないかを見る。
- 2回目も失敗した場合は停止し、回避策を実行せず、認証、権限、non-fast-forward、保護ブランチなどの原因要点と次に確認すべき点を `notes` に短く示す。

## 結果報告

- 最終返答では、push 結果を短い見出しと固定箇条書きで簡潔に報告する。
- push 成功時は、次の形を使う。

```md
プッシュしました。

- result: `<pushed|nothing-to-push|skipped|failed>`
- remote: `<remote>`
- branch: `<branch>`
- upstream: `<existing|set|not-set|skipped>`
- action: `<git push command or no-op>`
- knowledge_preflight: `<status> (<reason>)`
- notes: `<none or short note>`
```

- 失敗、no-op、事前停止でも同じ箇条書き構造を使い、見出しだけを `プッシュ対象はありません。`、`プッシュしませんでした。`、`プッシュできませんでした。` のように変える。
- `result`、`remote`、`branch`、`upstream`、`action`、`knowledge_preflight`、`notes` は常に表示する。
- `result` は `pushed` / `nothing-to-push` / `skipped` / `failed` のいずれかを返す。
- `remote` は実際に使った push 先をそのまま返す。
- `branch` は push 対象ブランチを返す。
- `upstream` は `existing` / `set` / `not-set` / `skipped` のいずれかを返す。
- `action` は `git push`、`git push -u <remote> <branch>`、`git push <remote> <branch>` のどれを実行したか、または no-op / 事前停止で判定した push 操作を返す。
- `knowledge_preflight` は `skipped` / `ready` / `consolidation_required` と理由を丸括弧で短く返す。
- 新規ブランチで remote branch がまだ存在しないため outgoing range を作れない場合は、`knowledge_preflight: skipped (no-upstream-new-branch)` とする。
- no-op や事前停止では `action: no-op` または判定した push 操作を返し、`upstream` は実態に合わせて `existing` / `not-set` / `skipped` を選ぶ。
- `notes` は push 前集約、behind / diverged、認証失敗、次アクションなどの追加説明を一文で返す。補足がない場合は `none` を返す。
- 失敗時はエラー本文を丸ごと貼るのではなく、原因の要点と次に確認すべき点を `notes` に短く示す。
