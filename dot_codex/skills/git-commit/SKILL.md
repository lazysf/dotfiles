---
name: git-commit
description: Git の変更を安全に commit したい依頼で使う。1コミット1変更を守り、差分確認、明示的なステージ、ステージ済み差分確認、通常 commit だけを行う。push が目的なら `git-push` スキルを使う。
metadata:
  short-description: Git commit
---

# Git Commit

Git の変更を、安全に 1 つの通常 commit として作成する。

## 手順

- `git status -sb` で状態を確認し、必要なら `git diff --stat` / `git diff` / `git diff --staged` で差分を読む。
- detached HEAD、未完了の merge / rebase / cherry-pick / revert、未解決 conflict、単一 commit にできない混在差分では停止して確認する。
- 1コミット1変更を守り、合意した範囲だけを `git add <paths>` でステージする。`git add .` と `git add -A` は使わない。
- 未追跡ファイル、機密情報、env/local/editor/temp/debug/build/generated files、lockfiles、migrations、config changes は、意図が確認できる場合だけ対象にする。
- ステージ後は `git diff --staged --stat` と `git diff --staged` で、意図しない削除、debug log、機密情報、無関係な formatting がないか確認する。
- repo の commit message 規約を優先する。規約がなければ `<type>: <description>` を使い、詳細が必要な時だけ [references/commit-message-format.md](references/commit-message-format.md) を読む。
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

失敗、no-op、事前停止でも同じ項目を返す。エラー全文や秘密情報は貼らず、原因の要点と次に確認すべき点だけを `notes` に書く。
