# Push ガードレール

## 停止または確認

次の場合は push しない。

- 現在 branch が曖昧、または HEAD が detached
- merge / rebase / cherry-pick / revert 進行中
- worktree または index に未解決 conflict がある
- 複数 remote があり、push 先が明らかではない
- upstream がユーザー意図と違う、または `git branch -vv` 上で mismatch に見える
- branch が behind または diverged
- protected branch policy で direct push 禁止と分かっている
- push に force、delete、mirror、all、tags、任意 refspec、pull、rebase が必要
- remote が既知の remote 名ではなく URL で渡された
- branch / tag 名が `-` で始まる、`:` や glob を含む、または安全に扱えない

## 対象と command

- 有効な upstream がある現在 branch は `git push`。
- upstream がなく remote が 1 つだけなら `git push -u <remote> <branch>`。
- 既知 remote 指定かつ upstream 設定不要なら `git push <remote> <branch>`。
- 明示された単一 local tag は `git push <remote> <tag>`。upstream は変更しない。
- ahead が 0 で tag も依頼されていない場合は `nothing-to-push` と報告する。

## 失敗時

- force push、pull、rebase、GitHub API、別 refspec で復旧しない。
- 一時的に見える network / transport failure だけ、状態を再確認して 1 回 retry する。
- authentication failure、permission denial、non-fast-forward、protected branch rejection、pre-receive hook rejection、ref update rejection は retry しない。
