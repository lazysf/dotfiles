---
name: git-commit
description: 「この変更をコミットしたい」「安全に commit したい」といった Git の依頼で使う。1 コミット 1 変更の粒度で staging 範囲を整理し、必要ならコミットメッセージを整えたうえで commit を実行する。push の実行や upstream 判定は `git-push` で扱う。
metadata:
  short-description: Git commit
---

# Git Commit

Git の変更を安全にコミットし、必要ならコミットメッセージを整えたうえで commit を実行する。
このスキルは、Git 導線のうち `1コミット1変更` を守りながら commit を実行する責務を担う。

## 基本方針

- 対象が不明なら確認する。
- Git の書き込み系操作は逐次実行する。
- detached HEAD、rebase、merge、cherry-pick、revert 中やコンフリクト時は停止して確認する。
- 未追跡ファイルや機密情報が含まれる場合は対象を確認する。
- この skill では、手順に明示した Git コマンドだけを使う。
- 1コミット1変更を原則とし、単一のコミットメッセージで自然に説明できる最小単位に分ける。
- 複数の変更が混在している場合は、そのまま進めず分割方針を確認する。
- 実コミット後に durable change の知見化が必要なら `capture-change-knowledge` へ渡す。

## 対象外

- プッシュのみが目的の依頼。`git-push` を使う。
- 変更が存在しない状態でのコミット要求。

## コミットメッセージの扱い

- リポジトリに別規約がなければ Conventional Commits を既定とする。
- 言語はリポジトリ規約を優先し、規約がなければ英語を既定とする。
- 本文やフッターの有無は、ユーザー指定、リポジトリ規約、変更の分かりやすさをもとに判断する。
- 実行は `git commit -m` または `git commit -F` の非対話のみを使う。
- type / body / footer の詳細は `references/commit-message-format.md` を参照する。

## 手順

### 1) 変更内容と規約を確認

- 変更概要、差分要約、既存の文面案、リポジトリ規約があれば受け取る。

### 2) 状態確認

- `git status -sb` で状態を確認する。
- 異常状態があれば停止して確認する。

### 3) 変更内容の確認

- `git diff` で変更内容を確認する。
- 複数の変更が混在している場合は、コミットを停止して分割方針を確認する。

### 4) コミットメッセージを決める

- ユーザー指定の文面があれば、それを優先して整形確認する。
- 文面未指定なら、確認した差分をもとにコミットメッセージを組み立てる。
- まず `type: description` の形で type と description を決定する。
- 本文が必要なら body を追加する。
- 変更の識別は description を優先し、必要なら body や footer で補足する。

### 5) ステージ

- 合意した 1 変更の範囲のみを `git add <paths>` でステージする。
- `git add <paths>` は単一ファイル、複数ファイル、ディレクトリ指定を含む。
- 非対話で安全に分離できない場合は停止して確認する。

### 6) ステージ内容の確認

- `git diff --staged` でステージ内容を確認する。
- 想定と違う場合はコミットせずに見直す。

### 7) コミット

- タイトルだけで十分なら `git commit -m "<header>"` を使う。
- 本文やフッターが必要なら `git commit -F <file>` を使う。
- 失敗時はエラー内容をそのまま示し、原因確認を優先する。

### 8) 事後確認

- `git status -sb` でコミット後の状態を確認する。

### 9) 必要なら変更後知見化または ADR 状態更新へ渡す

- 実際に commit が成功した場合だけ後段へ進む。
- project policy は current project の `[projects."<repo-root>"].adr_acceptance_policy` を正本にする。
- key がない場合は `commit` として扱う。
- 値が `commit | default_branch` 以外なら、自動 `Accepted` 化だけを抑止し `notes` に `skipped(invalid-adr-acceptance-policy)` を残す。
- `ADR-only commit` は、新規 `docs/adr/NNNN-*.md` 1 件と任意の `docs/README.md` 変更だけを含む commit とする。
- `ADR-only commit` では `capture-change-knowledge` を使わず、policy が `commit` のときだけ新 ADR を `update-adr-status` で `Accepted` に進める。
- `ADR-only commit` の新 ADR に `Supersedes` が明示されている場合だけ、続けて旧 ADR に対して `update-adr-status(target_adr=<old>, new_status=Superseded, related_adrs=<new>, event_basis=commit)` を別更新として行う。
- `ADR-only commit` で policy が `default_branch` のときは、新 ADR を `Proposed` に留める。
- `ADR-only commit` で policy が不正値なら、新 ADR を更新せず `notes` に skip 理由を残す。
- それ以外の docs-only のコミットや、一過性の change だけなら知見化しない。
- 上記以外の durable change は `capture-change-knowledge` に渡す。
- `capture-change-knowledge` が ADR を作り、policy が `commit` なら `update-adr-status` で `Accepted` に進める。

## 結果報告

- 最終返答では、コミット結果を通常の返答文の中で簡潔に報告する。
- 最低限、`branch`、`commit`、`message`、必要なら `knowledge_capture` または `notes` を含める。
- 失敗時は、失敗理由と次に確認すべき点を短く示す。
