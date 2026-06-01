---
name: git-push
description: Git の commit を push したい、現在ブランチをリモートへ出したい、upstream を設定したい、明示された単一 tag を push したい依頼で使う。push 先、upstream、安全条件を確認し、通常 push だけを行う。commit 作成は `git-commit`。
---

# Git Push

## 手順

- push はユーザーの明示的な依頼がある場合だけ行う。
- `git status -sb`、`git branch -vv`、`git remote -v` を確認する。
- detached HEAD、未完了操作、未解決 conflict、behind / diverged、upstream mismatch、push 先不明では停止する。
- push 対象は現在ブランチ、またはユーザーが明示した単一の既存 local tag だけに限定する。
- remote は `git remote -v` の remote 名だけを使う。URL 直接指定、危険な branch / tag 名、複数 tag、全 tag は扱わない。
- force push、削除 push、mirror / all / tags、任意 refspec、pull / rebase、GitHub API 迂回は扱わない。
- 承認回避の別経路や副作用のある代替操作は使わない。
- upstream が一意ならそれを使う。upstream 未設定かつ単一 remote なら、通常 branch push として upstream を設定してよい。
- push 先・upstream・force 可否の判断や、停止・失敗時の対応に当たる時は、実行 command と結果報告の規定を [references/push-guardrails.md](references/push-guardrails.md) に置いているため、push を実行する前に読み従う。

## 出力

- `result`: `pushed` / `nothing-to-push` / `skipped` / `failed`
- `remote`: 使用した remote。ない場合は `none`
- `branch`: push した branch。tag push なら `none`
- `upstream`: `existing` / `set` / `not-set` / `skipped`
- `action`: 使用した command。ない場合は `no-op`
- `verification`: `passed` / `skipped` / `not run`
- `notes`: tag 名、停止・失敗理由。ない場合は `none`

失敗、no-op、事前停止でも同じ項目を返す。秘密情報やエラー全文は貼らず、要点を `notes` に書く。
