---
name: git-commit
description: Git の変更を安全に commit したい依頼で使う。1コミット1変更を守り、ステージ範囲とステージ済み差分を確認してから通常 commit を作成する。push が目的の依頼では `git-push` スキルを使う。
metadata:
  short-description: Git commit
---

# Git Commit

Git の変更を安全に 1 つの commit として作成する。
このスキルは、変更範囲の確認、明示的なステージ、ステージ済み差分の確認、コミットメッセージ作成、通常 commit 実行だけを扱う。

## 停止条件

次の状態では commit せず、状況を確認する。

- detached HEAD で、現在ブランチが確定していない場合。
- rebase、merge、cherry-pick、revert の途中で、履歴操作が完了していない場合。
- コンフリクトが残っていて、作業ツリーや index が未解決の場合。
- 複数の変更が混在し、単一のコミットメッセージで自然に説明できない場合。

## 安全ルール

- ステージと commit は順に実行する。
- 1コミット1変更を原則とし、単一のコミットメッセージで自然に説明できる最小単位に分ける。
- sandbox / network / 権限により承認が必要な場合は、承認要求を正規手順として扱い、承認を避けるための別経路や副作用のある代替操作を使わない。
- `git add .` と `git add -A` は使わない。
- 無関係なファイルや hunk はステージしない。
- 未追跡ファイル、機密情報、env/local/editor/temp/debug/build/generated files、lockfiles、migrations、config changes は、意図が確認できる場合だけ commit 対象にする。
- `commit the changes` や `commit everything` と言われても、差分を確認せずに全てをステージ / commit しない。
- push は扱わない。
- 知見蓄積は自動実行しない。作業後に知見整理が必要だと明示されている場合でも、必要な次アクションとして `capture-knowledge` を示すだけにする。
- rebase、amend、squash など、通常 commit 以外の履歴操作は扱わない。

## コミットメッセージ

- repo に commit message 規約があればそれを優先する。

repo 規約がなければ、commit message は次の形式にする。

```txt
<type>: <description>

[optional body]

[optional footer(s)]
```

- `title` は commit message の 1 行目で、commit list に表示される短い要約に相当する。repo 規約がなければ `<type>: <description>` にする。
- `body` は任意。理由、内容、影響などを `title` だけで表しきれない場合に使う。
- `footer(s)` は任意。issue refs や `BREAKING CHANGE` などの trailer に使う。
- `title` は 1 行のみで書き、可能なら 72 文字以内にする。
- `type` は変更の主目的に合わせて選ぶ。迷ったら、ユーザー-visible な挙動への影響を優先して判断する。
- `description` は変更内容を短く表す動詞句にし、repo 規約がなければ英語で書く。
- `description` に詳細を書ききれない場合は、`title` を短く保ち、理由や影響を `body` に書く。
- `feat` と `fix` は Semantic Versioning に対応する。その他の type は、`BREAKING CHANGE` を含まない限り version への暗黙的な効果を持たない。
- `body` / `footer(s)` の詳細が必要な場合は `references/commit-message-format.md` を参照する。

| type | 使う場面 |
| --- | --- |
| `fix` | 期待どおりに動いていない挙動や不具合を直す。 |
| `feat` | 新しい機能、設定、選択肢などを追加する。 |
| `docs` | README、手順書、設計メモなど、ドキュメントだけを変える。 |
| `test` | テストコード、fixtures、snapshots など、テストだけを変える。 |
| `refactor` | 外から見える挙動を変えずに、コード構造を整理する。 |
| `chore` | 利用者向け挙動に直接関係しない保守作業を行う。 |
| `style` | 挙動を変えずに、コード整形や lint 指摘だけを直す。 |
| `perf` | 挙動を保ったまま、速度やメモリ使用量などを改善する。 |
| `build` | build system、package manager、依存関係、lockfile を変える。 |
| `ci` | CI workflow、job、runner、release automation を変える。 |

## 手順

### 1) 変更内容と規約を確認

- 変更概要、差分要約、既存の文面案、リポジトリ規約があれば受け取る。

### 2) 状態確認

- `git status -sb` で状態を確認する。
- 既にステージ済み変更がある場合は、`git diff --staged --stat` と `git diff --staged` で未ステージ変更と分けて確認する。
- 異常状態があれば停止して確認する。

### 3) 変更内容の確認

- `git diff --stat` で変更規模を確認する。
- `git diff` で変更内容を確認する。
- 必要なら `git diff --check` で whitespace error や conflict marker を軽く確認する。
- 複数の変更が混在している場合は、コミットを停止して分割方針を確認する。

### 4) コミットメッセージを決める

- repo 規約がある場合は、その形式で `title` を決める。
- repo 規約がない場合は、確認した差分をもとに `<type>: <description>` を作る。
- `body` / `footer(s)` が必要な場合だけ `references/commit-message-format.md` を参照する。
- 変更の識別は `title` を優先し、必要なら `body` や `footer(s)` で補足する。

### 5) ステージ

- 合意した 1 変更の範囲のみを `git add <paths>` でステージする。
- `git add <paths>` は単一ファイル、複数ファイル、ディレクトリ指定を含む。
- 非対話で安全に分離できない場合は停止して確認する。

### 6) ステージ済み差分の確認

- `git diff --staged --stat` でステージ済み差分の規模を確認する。
- `git diff --staged` でステージ内容を確認する。
- 無関係なファイル、意図しない削除、debug log、コメントアウトされたコード、機密情報、想定外に大きい差分、無関係な formatting が含まれていないか見る。
- 想定と違う場合はコミットせずに見直す。

### 7) コミット

- `title` だけで十分なら `git commit -m "<message>"` を使う。
- `body` や `footer(s)` が必要なら `git commit -F <file>` を使う。
- `git commit` 失敗時は `--no-verify`、別の commit 方法、直接 refs 操作などで回避しない。
- 失敗時は約30秒待ってから、状態を再確認し、同じ commit command を 1 回だけ再実行する。
- 再確認では `git status -sb` と `git diff --staged` で、作業ツリーとステージ済み差分が想定どおりかを見る。
- 2回目も失敗した場合は停止し、回避策を実行せず、原因の要点と次に確認すべき点を `notes` に短く示す。

### 8) 事後確認

- `git status -sb` でコミット後の状態を確認する。

## 結果報告

- 最終返答では、コミット結果を短い見出しと固定箇条書きで簡潔に報告する。
- 成功した commit では、次の形を使う。

```md
コミットしました。

- branch: `<branch>`
- commit: `<short-sha>`
- message: `<commit message>`
- files: `<included paths summary>`
- verification: `<passed / skipped / not run / already run>`
- left_unstaged: `<none or short summary>`
- notes: `<none or short note>`
```

- 失敗、no-op、事前停止でも同じ箇条書き構造を使い、見出しだけを `コミットできませんでした。` のように変える。
- `branch`、`commit`、`message`、`files`、`verification`、`left_unstaged`、`notes` は常に表示する。
- `commit` は短縮 SHA を返す。commit が作成されなかった場合は `none` を返す。
- `message` は実際に使った、または使おうとした commit message を返す。該当しない場合は `none` を返す。
- no-op や事前停止では `commit: none`、該当する message がなければ `message: none` とする。
- `files` は commit に含めた path の要約を返す。commit が作成されなかった場合は `none` を返す。
- `verification` は検証状況として、実行済み、未実行、skipped、または既存実行結果を短く返す。
- `left_unstaged` は未ステージのまま残した無関係 / 曖昧 / 危険または要確認のファイルを短く返す。なければ `none` を返す。
- `notes` は hook 警告、失敗理由、停止理由、次に確認すべき点だけを一文で返す。補足がない場合は `none` を返す。
- 失敗時はエラー全文を丸ごと貼るのではなく、原因の要点と次に確認すべき点を `notes` に短く示す。
