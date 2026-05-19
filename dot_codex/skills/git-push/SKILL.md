---
name: git-push
description: Git の commit を push したい、現在ブランチをリモートへ出したい、upstream を設定したい依頼で使う。push 先、upstream、安全条件を確認し、現在ブランチまたは明示された単一 tag だけを通常 push する。commit 作成は `git-commit` スキルを使う。
metadata:
  short-description: Git push
---

# Git Push

現在ブランチのローカル commit、または明示された単一 tag をリモートへ通常 push する。

## 手順

- push はユーザーの明示的な依頼がある場合だけ行う。
- `git status -sb`、`git branch -vv`、`git remote -v` を確認する。
- detached HEAD、未完了の merge / rebase / cherry-pick / revert、未解決 conflict、behind / diverged、upstream mismatch、複数 remote で push 先が曖昧な場合は停止して確認する。
- push 対象は現在ブランチ、またはユーザーが明示した単一の既存 local tag だけに限定する。
- remote は `git remote -v` で確認できる remote 名だけを使う。URL 直接指定、危険な branch / tag 名、複数 tag、全 tag は扱わない。
- force push、削除 push、mirror / all / tags、任意 refspec、pull / rebase による履歴調整、GitHub API への迂回は扱わない。
- 承認が必要な操作は正規の承認要求を使い、承認回避のための別経路や副作用のある代替操作は使わない。
- upstream が一意ならそれを使う。upstream 未設定かつ単一 remote なら、通常 branch push として upstream を設定してよい。
- `git remote -v` や push error に秘密情報が含まれる可能性があるため、最終返答に credential、token、認証 URL、エラー全文を貼らない。
- 停止条件、実行 command、失敗時、結果報告の詳細が必要な時は [references/push-guardrails.md](references/push-guardrails.md) を読む。

## 出力

- `result`
- `remote`
- `branch`
- `upstream`
- `action`
- `verification`
- `notes`

失敗、no-op、事前停止でも同じ項目を返す。秘密情報やエラー全文は貼らず、原因の要点と次に確認すべき点だけを `notes` に書く。
