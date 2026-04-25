---
name: git-push
description: Git の commit を push したい、現在ブランチをリモートへ出したい、upstream を設定して push したい依頼で使う。push 先、upstream、通常 push の安全条件を確認してから、現在ブランチまたは明示された単一 tag を push する。commit 作成や commit message 整備が目的なら `git-commit` スキルを使い、force push や広域 push は対象外とする。
metadata:
  short-description: Git push
---

# Git Push

現在ブランチのローカル commit、または明示された単一 tag をリモートへ push する。
このスキルは、push 先の確認、upstream 判定、通常 push の実行だけを扱う。

## 停止条件

次の状態では push せず、状況を確認する。

- detached HEAD で、現在ブランチが確定していない場合。
- rebase、merge、cherry-pick、revert の途中で、履歴操作が完了していない場合。
- コンフリクトが残っていて、作業ツリーや index が未解決の場合。
- 複数リモートがあり、push 先が一意に決められない場合。
- upstream の設定先とユーザー意図が食い違う、または `git branch -vv` 上で upstream mismatch が疑われる場合。
- behind または diverged の状態で、同期方針が確認できていない場合。
- 保護ブランチ運用により、現在ブランチへの直接 push が禁止されている前提が分かっている場合。
- force push、削除 push、mirror / all / tags などの広域 push、または refspec を使う push が必要な場合。
- 明示された push 先が、`git remote -v` で確認できる remote 名ではなく URL 直接指定の場合。
- 明示された branch / tag が `-` で始まる、`:` を含む、glob を含む、または現在ブランチ名や単一 tag 名として安全に扱えない場合。
- pull / rebase による履歴調整が必要だが、明示指示がない場合。

## 安全ルール

- push はユーザーの明示的な依頼がある場合のみ行う。
- commit 作成や commit message 整備はこのスキルの責務に含めない。
- push 対象は、現在ブランチまたはユーザーが明示した単一 tag に限定する。
- 明示指定があっても、remote は確認済み remote 名、branch は現在ブランチ名、tag は単一の既存 local tag 名だけを扱う。
- `--force`、`--force-with-lease`、`--mirror`、`--all`、`--tags`、`:branch`、`HEAD:branch` などは通常 push として扱わず停止する。
- sandbox / network / 権限により承認が必要な場合は、承認要求を正規手順として扱い、承認を避けるための別経路や副作用のある代替操作を使わない。
- `git remote -v` や push error に credential、token、認証 URL が含まれる可能性があるため、最終返答には秘密情報やエラー全文を貼らない。

## 対象外

- コミット作成やコミットメッセージ整備のみが目的の依頼。
- pull / rebase で履歴調整が必要だが、調整指示がない状態。
- force push、削除 push、広域 push、refspec push。
- 複数 tag、全 tag、または tag 一覧の一括 push。

## 手順

### 1) 状態確認

- `git status -sb`、`git branch -vv`、`git remote -v` を確認する。
- 既に異常状態や停止条件に該当する場合は push せず停止して確認する。

### 2) push 対象の判定

- branch push では、現在ブランチと upstream / ahead / behind 状態を確認する。
- ahead が 0 で tag 指示もない場合は、push 対象がない旨を伝えて終了する。
- behind または diverged の場合は、同期方針を確認するまで停止する。
- tag push では、ユーザーが明示した単一 tag だけを対象にする。複数 tag や全 tag の指示なら停止する。

### 3) push 先の決定

- ユーザー指定があれば優先するが、安全ルールを満たさない指定は使わない。
- upstream が一意ならそれを使う。
- upstream 未設定で単一リモートへの通常 branch push なら、その remote と現在ブランチを既定にし、初回 push として upstream を設定する。
- upstream 未設定かつ複数リモートがある場合は、自動で決めずに確認する。

### 4) 実行 command の決定

- upstream 済みの現在ブランチを push する場合は `git push` を使う。
- upstream 未設定で、単一リモートを既定にした初回 branch push では `git push -u <remote> <branch>` を使う。
- ユーザーが remote だけを明示し、upstream 設定までは指定していない場合は `git push <remote> <branch>` を使う。
- 明示された単一 tag を push する場合は `git push <remote> <tag>` を使い、upstream は変更しない。

### 5) push 実行

- 決定した command だけを実行する。
- 失敗しても force push、pull / rebase、GitHub API、別 refspec などで回避しない。

### 6) 失敗時の扱い

- 一時的な network / transport failure と判断できる場合だけ、約30秒待ってから状態を再確認し、同じ push command を1回だけ再実行する。
- 認証失敗、権限不足、non-fast-forward、保護ブランチ拒否、pre-receive hook rejection、ref update rejection が示された場合は再試行しない。
- 再確認では `git status -sb`、`git branch -vv`、`git remote -v` と、push 先や対象 branch / tag が変わっていないかを見る。
- 2回目も失敗した場合は停止し、回避策を実行せず、原因要点と次に確認すべき点を `notes` に短く示す。

### 7) 事後確認

- push 後に `git status -sb` を確認する。
- upstream 設定を行った場合は、`git branch -vv` で upstream が意図どおりか確認する。

## 結果報告

- 最終返答では、push 結果を短い見出しと固定箇条書きで簡潔に報告する。
- push 成功時は、次の形を使う。

```md
プッシュしました。

- result: `<pushed|nothing-to-push|skipped|failed>`
- remote: `<remote>`
- branch: `<branch or none>`
- upstream: `<existing|set|not-set|skipped>`
- action: `<git push command or no-op>`
- verification: `<passed / skipped / not run>`
- notes: `<none or short note>`
```

- 失敗、no-op、事前停止でも同じ箇条書き構造を使い、見出しだけを `プッシュ対象はありません。`、`プッシュしませんでした。`、`プッシュできませんでした。` のように変える。
- `result`、`remote`、`branch`、`upstream`、`action`、`verification`、`notes` は常に表示する。
- `result` は `pushed` / `nothing-to-push` / `skipped` / `failed` のいずれかを返す。
- `remote` は実際に使った push 先を返す。使っていない場合や確定できない場合は `none` を返す。
- `branch` は push 対象ブランチを返す。tag push の場合は `none` を返す。
- `upstream` は `existing` / `set` / `not-set` / `skipped` のいずれかを返す。
- `action` は `git push`、`git push -u <remote> <branch>`、`git push <remote> <branch>`、`git push <remote> <tag>` のどれを実行したか、または `no-op` を返す。
- `verification` は push 後確認の結果として、`passed` / `skipped` / `not run` のいずれかを返す。
- tag push では、tag 名を `notes` に短く示す。
- `notes` は behind / diverged、認証失敗、権限不足、保護ブランチ、次アクションなどの追加説明を一文で返す。補足がない場合は `none` を返す。
- 失敗時はエラー本文を丸ごと貼るのではなく、原因の要点と次に確認すべき点を `notes` に短く示す。
