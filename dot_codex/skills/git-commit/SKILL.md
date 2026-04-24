---
name: git-commit
description: 「この変更をコミットしたい」「安全に commit したい」といった Git の依頼で使う。1 コミット 1 変更の粒度で staging 範囲を整理し、必要ならコミットメッセージを整えたうえで commit を実行する。push を進めたい時は `git-push` スキルを使う。
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
- 1コミット1変更を原則とし、単一のコミットメッセージで自然に説明できる最小単位に分ける。
- 複数の変更が混在している場合は、そのまま進めず分割方針を確認する。
- sandbox / network / 権限により承認が必要な場合は、承認要求を正規手順として扱い、承認を避けるための別経路や副作用のある代替操作を使わない。
- 実コミット後に単一 commit の durable change を知見化したい時は `capture-change-knowledge` スキルを使う。
- ADR は commit 時採用に固定し、新規 ADR が作られた場合は `update-adr-status` スキルで `Accepted` に進める。

## 対象外

- プッシュだけしたい時は `git-push` スキルを使う。
- 変更が存在しない状態でのコミット要求。

## コミットメッセージの扱い

- リポジトリに別規約がなければ Conventional Commits を既定とする。
- 言語はリポジトリ規約を優先し、規約がなければ英語を既定とする。
- 本文やフッターの有無は、ユーザー指定、リポジトリ規約、変更の分かりやすさをもとに判断する。
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
- `git commit` 失敗時は `--no-verify`、別の commit 方法、直接 refs 操作などで回避しない。
- 失敗時は約30秒待ってから、`git status -sb` と `git diff --staged` で状態と staged diff を再確認し、同じ commit command を1回だけ再実行する。
- 2回目も失敗した場合は停止し、エラー本文を丸ごと貼らず、原因の要点と次に確認すべき点を `notes` に短く示す。

### 8) 事後確認

- `git status -sb` でコミット後の状態を確認する。

### 9) 必要なら次に使うスキルを決める

- 実際に commit が成功した場合だけ後段へ進む。
- 成功した commit の最終返答では、`knowledge_capture` を必ず含める。
- `knowledge_capture.status` は `skipped` / `knowledge_created` / `adr_created` だけを使い、新しい分類は増やさない。
- 通常フローで `capture-change-knowledge` スキルが `skipped` を返したら、`knowledge_capture = { status: skipped, reason: <triage reason> }` として返す。
- 通常フローで `capture-change-knowledge` スキルが `knowledge_created` または `adr_created` を返したら、`knowledge_capture = { status: <status>, path: <created path>, reason: <optional> }` として返す。
- `ADR-only commit` は、新規 `docs/adr/NNNN-*.md` 1 件と任意の `docs/README.md` 変更だけを含む commit とする。
- `ADR-only commit` では `capture-change-knowledge` スキルを使わず、`knowledge_capture = { status: skipped, reason: adr-only-commit }` を返したうえで、新 ADR を `update-adr-status` スキルで `Accepted` に進める。
- `ADR-only commit` の新 ADR に `Supersedes` が明示されている場合だけ、続けて旧 ADR に対して `update-adr-status(target_adr=<old>, new_status=Superseded, related_adrs=<new>, event_basis=commit)` を別更新として行う。
- 上記以外の commit 後の知見判断は `capture-change-knowledge` スキルを使う。
- `capture-change-knowledge` スキルが ADR を作った場合は、`update-adr-status` スキルで `Accepted` に進める。
- push 前の重複整理、状態整合、集約確認は `git-push` 側の `capture-push-knowledge` に委ねる。

## 結果報告

- 最終返答では、コミット結果を短い見出しと固定箇条書きで簡潔に報告する。
- 成功した commit では、次の形を使う。

```md
コミットしました。

- branch: `<branch>`
- commit: `<short-sha>`
- message: `<commit message>`
- knowledge_capture: `<status> (<reason or path>)`
- notes: `<none or short note>`
```

- 失敗、no-op、事前停止でも同じ箇条書き構造を使い、見出しだけを `コミットできませんでした。` のように変える。
- `branch`、`commit`、`message`、`knowledge_capture`、`notes` は常に表示する。
- `commit` は短縮 SHA を返す。commit が作成されなかった場合は `none` を返す。
- `message` は実際に使った、または使おうとした commit message を返す。該当しない場合は `none` を返す。
- `knowledge_capture` は `status` と、理由または作成 path を丸括弧で短く返す。該当しない場合も `skipped (<reason>)` の形で返す。
- `knowledge_capture.reason` は、`capture-change-knowledge` の根拠または `adr-only-commit` のような user-facing な短い理由をそのまま返してよい。
- `notes` は hook 警告、後段状態更新スキップ、失敗理由などの追加説明を一文で返す。補足がない場合は `none` を返す。
- 失敗時はエラー本文を丸ごと貼るのではなく、原因の要点と次に確認すべき点を `notes` に短く示す。
