---
name: git-commit
description: Gitコミット実行（対象確認・ステージ・実行・結果報告）を支援する。ユーザーがコミット操作を求める場合に使用する。メッセージ整備のみが目的なら commit-message、プッシュは git-push を使う。
metadata:
  short-description: Git commit execution
---

# Git Commit

Git の変更を安全にコミットする依頼に対応する。

## 基本方針

- 対象が不明なら確認する。
- 破壊的操作は行わない。
- Git の書き込み系操作は逐次実行する。
- detached HEAD、rebase、merge、cherry-pick、revert 中やコンフリクト時は停止して確認する。
- 未追跡ファイルや機密情報が含まれる場合は対象を確認する。
- `git add .`、`git add -A`、`git add --all` のような broad add は既定手段にしない。
- `--amend` や履歴の書き換えは行わない。

## コミット分割の原則

- 1コミット1変更を原則とする。
- 単一のコミットメッセージで自然に説明できる最小の変更単位に分ける。
- 片方だけを取り消したくなりそうな変更は分ける。

## 対象外

- プッシュのみが目的の依頼。
- コミットメッセージの作成や推敲のみが目的の依頼。
- 変更が存在しない状態でのコミット要求。

## コミットメッセージの扱い

- メッセージ未指定時は、原則 `commit-message` を使って最終案を得る。
- 文面作成責務は `commit-message` に寄せる。
- 実行は `git commit -m` または `git commit -F` の非対話のみを使う。

## 手順

### 1) 状態確認

- `git status -sb` で状態を確認する。
- 異常状態があれば停止して確認する。

### 2) 変更内容の確認

- `git diff` で変更内容を確認する。
- 複数の変更が混在している場合は、コミットを停止して分割方針を確認する。

### 3) ステージ

- 合意した 1 変更の範囲のみを `git add <paths>` でステージする。
- 非対話で安全に分離できない場合は停止して確認する。

### 4) ステージ内容の確認

- `git diff --staged` でステージ内容を確認する。
- 想定と違う場合はコミットせずに見直す。

### 5) メッセージ作成

- 文面未指定時は `commit-message` を使って `header` / `body_text` / `footer_text` / `final` を得る。
- ユーザー指定の文面がある場合だけ、このスキル内で整形確認に留める。

### 6) コミット

- タイトルだけで十分なら `git commit -m "<header>"` を使う。
- 本文やフッターが必要なら `git commit -F <file>` を使う。
- 失敗時はエラー内容をそのまま示し、原因確認を優先する。

### 7) 事後確認

- `git status -sb` でコミット後の状態を確認する。

## 出力フォーマット

```markdown
branch: <branch-name>
commit: <commit-hash>
message: <commit-subject>
body: yes|no
remaining: clean|<remaining summary>
notes: <only when needed>
```
