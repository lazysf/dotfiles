# 0018: Git mutation rules を既定 prompt に任せる

- Status: Accepted
- Amends: 0008

`git add` と `git commit` の allow rule は mutation を自走しやすくする一方、staging や commit 作成は repository state を変えるため、明示的な skill 停止線と既定 prompt で扱う方が現行運用に合う。Git rule の allow は `git status`、`git diff`、`git branch -vv`、`git remote -v`、`git log` の読み取り操作に限定し、`git add` と `git commit -m` / `git commit -F` は `git-commit` skill の手順内でも未定義コマンドとして prompt に任せる。
