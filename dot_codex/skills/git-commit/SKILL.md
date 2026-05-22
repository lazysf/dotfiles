---
name: git-commit
description: Git の変更を安全に commit したい依頼で使う。1コミット1変更、差分確認、明示的な stage、staged diff 確認、通常 commit だけを行う。push は `git-push`。
metadata:
  short-description: Git commit
---

# Git Commit

Git の変更を、安全に 1 つの通常 commit として作成する。

## 手順

- `git status -sb` で状態を確認し、必要なら `git diff --stat` / `git diff` / `git diff --staged` で差分を読む。
- detached HEAD、未完了操作、未解決 conflict、混在差分では停止する。
- 合意範囲だけを `git add <paths>` で stage する。`git add .` と `git add -A` は使わない。
- 未追跡、機密情報、env/local/editor/temp/debug/build/generated、lockfile、migration、config は意図が確認できる時だけ含める。
- stage 後は `git diff --staged --stat` と `git diff --staged` で、意図しない削除、debug log、機密情報、無関係な formatting を確認する。
- commit message は `<type>: <description>` を使う。`<type>(<scope>): <description>` のような scope は使わない。repo 規約が scope を要求する場合は停止して報告する。詳細が必要な時だけ [references/commit-message-format.md](references/commit-message-format.md) を読む。
- 通常 commit だけを実行する。push、rebase、amend、squash、`--no-verify`、直接 refs 操作、知見蓄積は扱わない。
- 承認が必要な操作は正規の承認要求を使い、承認回避のための別経路や副作用のある代替操作は使わない。
- 停止条件、失敗時、結果報告の詳細が必要な時は [references/commit-guardrails.md](references/commit-guardrails.md) を読む。

## 出力

- `branch`
- `commit`
- `message`
- `files`
- `verification`
- `left_unstaged`
- `notes`

失敗、no-op、事前停止でも同じ項目を返す。エラー全文や秘密情報は貼らず、要点を `notes` に書く。
