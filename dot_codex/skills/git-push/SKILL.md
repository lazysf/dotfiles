---
name: git-push
description: ローカルコミットのリモートプッシュ手順（upstream 設定・タグプッシュを含む）を提供する。ユーザーがプッシュや upstream 設定を求める場合に使用する（強制プッシュは現行ルールでは対象外）。
metadata:
  short-description: Git push
---

# Git Push

現在のブランチのローカルコミットをリモートへプッシュし、必要なら upstream を設定する。

## 基本方針

- push はユーザーの明示的な依頼がある場合のみ行う。
- commit 作成やメッセージ整備はこのスキルの責務に含めない。
- 強制 push は対象外とし、自動実行しない。
- `git push --force`、`git push --force-with-lease`、`git push origin main --force-with-lease` のような後置フラグ形も含めて扱わない。

## 対象外

- コミット作成やコミットメッセージ整備のみが目的の依頼。
- pull / rebase で履歴調整が必要だが、調整指示がない状態。
- 強制プッシュの実行。

## 手順

### 1) 状況確認

- `git status -sb`、`git branch -vv`、`git remote -v` を確認する。
- 次の条件では push せず停止して確認する。
- detached HEAD で、現在ブランチが確定していない場合。
- rebase、merge、cherry-pick、revert の途中で、履歴操作が完了していない場合。
- コンフリクトが残っていて、作業ツリーや index が未解決の場合。
- 複数リモートがあり、push 先が一意に決められない場合。
- upstream の設定先とユーザー意図が食い違う、または `git branch -vv` 上で upstream mismatch が疑われる場合。
- 保護ブランチ運用により、現在ブランチへの直接 push が禁止されている前提が分かっている場合。

### 2) プッシュ対象の判定

- ahead が 0 でタグ指示もない場合は、プッシュ対象がない旨を伝えて終了する。
- behind または diverged の場合は、同期方針を確認するまで停止する。

### 3) プッシュ先の決定

- ユーザー指定があればそれを最優先する。
- upstream が一意ならそれを使う。
- upstream 未設定で単一リモートなら `origin` と現在ブランチを既定にする。
- upstream 未設定かつ複数リモートがある場合は、自動で決めずに確認する。

### 4) プッシュ実行

- upstream 未設定なら `git push -u <remote> <branch>` を使う。
- upstream 済みなら `git push` を使う。
- 明示指定がある場合は `git push <remote> <branch>` を使う。

### 5) タグのプッシュ

- 明示指示がある場合のみ行う。
- タグ数が多い場合は確認する。

### 6) 失敗時の扱い

- 認証エラー、non-fast-forward、保護ブランチなどのエラーは止めて確認する。
- 自動で解決策を実行しない。

## 結果報告

- 最終返答では、push 結果を通常の返答文の中で簡潔に報告する。
- 固定テンプレートやキー順は要求しない。
- prose でも短い箇条書きでもよいが、次の事実は漏らさない。
  - `remote`
  - `branch`
  - `upstream` 設定の有無
  - 実行内容（通常 push / tag push など）
  - 結果
  - 失敗時の次アクション
- 失敗時はエラー本文を丸ごと貼るのではなく、原因の要点と次に確認すべき点を短く示す。
