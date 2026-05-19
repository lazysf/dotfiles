# Push ガードレール

## 停止または確認

次の場合は、状況が解消されるまで push しない。

- 現在 branch が曖昧、または HEAD が detached
- merge / rebase / cherry-pick / revert が進行中
- worktree または index に未解決 conflict がある
- 複数 remote があり、push 先が明らかではない
- upstream がユーザー意図と違う、または `git branch -vv` 上で mismatch に見える
- branch が behind または diverged
- protected branch policy により direct push が禁止されていると分かっている
- push に force、delete、mirror、all、tags、任意 refspec、pull、rebase が必要
- remote が既知の remote 名ではなく URL で渡された
- branch / tag 名が `-` で始まる、`:` を含む、glob を含む、または現在 branch / 単一 tag として安全に扱えない

## 対象と command

- 現在 branch に有効な upstream がある場合は `git push` を使う。
- 現在 branch に upstream がなく、remote が 1 つだけの場合は `git push -u <remote> <branch>` を使う。
- ユーザーが既知の remote を指定し、upstream 設定を求めていない場合は `git push <remote> <branch>` を使う。
- 明示された単一 local tag を push する場合は `git push <remote> <tag>` を使い、upstream は変更しない。
- ahead が 0 で tag も依頼されていない場合は `nothing-to-push` と報告する。

## 失敗時

- force push、pull、rebase、GitHub API、別 refspec で復旧しない。
- 一時的に見える network / transport failure の場合だけ 1 回 retry する。
- retry 前に `git status -sb`、`git branch -vv`、`git remote -v` を再確認する。
- authentication failure、permission denial、non-fast-forward、protected branch rejection、pre-receive hook rejection、ref update rejection は retry しない。

## 報告

次を返す。

- `result`: `pushed`、`nothing-to-push`、`skipped`、または `failed`
- `remote`: 使用した remote。ない場合は `none`
- `branch`: push した branch。tag push の場合は `none`
- `upstream`: `existing`、`set`、`not-set`、または `skipped`
- `action`: 使用した command。ない場合は `no-op`
- `verification`: `passed`、`skipped`、または `not run`
- `notes`: tag 名、停止理由、失敗理由。ない場合は `none`
