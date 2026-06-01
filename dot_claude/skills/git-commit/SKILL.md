---
name: git-commit
description: Git の変更を安全に commit したい依頼で使う。1コミット1変更、差分確認、明示的な stage、staged diff 確認、通常 commit だけを行う。push は `git-push`。
---

# Git Commit

## 手順

- `git status -sb` で状態を確認し、必要なら `git diff --stat` / `git diff` / `git diff --staged` で差分を読む。
- detached HEAD、未完了操作、未解決 conflict、混在差分では停止する。
- 合意範囲だけを `git add <paths>` で stage する。`git add .` と `git add -A` は使わない。
- 未追跡、機密情報、env/local/editor/temp/debug/build/generated、lockfile、migration、config は意図が確認できる時だけ含める。
- stage 後は `git diff --staged --stat` と `git diff --staged` で、意図しない削除、debug log、機密情報、無関係な formatting を確認する。
- commit message の title は `<type>: <description>` を使う。`<type>(<scope>): <description>` のような scope は使わない。repo 規約が scope を要求する場合は停止して報告する。
- body / footer / BREAKING CHANGE を付ける場合は形式が決まっているので、書く前に [references/commit-message-format.md](references/commit-message-format.md) を読み、その規定（`Why:` / `What:` / `Impact:` ラベル、git trailer 形式の footer）に従う。自己流の body / footer を書かない。title だけで足りる時は読まなくてよい。
- 通常 commit だけを実行する。push、rebase、amend、squash、`--no-verify`、直接 refs 操作、知見蓄積は扱わない。
- 承認回避の別経路や副作用のある代替操作は使わない。
- detached HEAD・未解決 conflict・混在差分・hook 失敗など停止や失敗の判断に当たったら、対応と結果報告の規定を [references/commit-guardrails.md](references/commit-guardrails.md) に置いているため、その場で読み従う。

## 出力

- `branch`: 現在 branch。不明なら `none`
- `commit`: short SHA。ない場合は `none`
- `message`: 実際または試行した commit message。ない場合は `none`
- `files`: commit した path の要約。ない場合は `none`
- `verification`: `passed` / `skipped` / `not run` / `already run`
- `left_unstaged`: 意図的に除外した変更。ない場合は `none`
- `notes`: hook warning、停止・失敗理由。ない場合は `none`

失敗、no-op、事前停止でも同じ項目を返す。エラー全文や秘密情報は貼らず、要点を `notes` に書く。
