---
name: git-commit
description: Git の変更を commit したい依頼で使う。「commit して」「これをコミット」「変更を確定させて」のように、作業結果を Git 履歴へ残したい時が対象。1 commit 1 変更に分け、明示 path で stage し、staged diff を確認してから通常 commit だけを行う。push は扱わない。doc の作成・更新は `scribe`。
---

# Git Commit

## 手順

1. `git status -sb` で状態を確認する。必要なら `git diff --stat` / `git diff` / `git diff --staged` で差分を読む。
2. 1 commit 1 変更になるよう範囲を決める。性質の違う変更が混ざっていれば分割し、1 つずつ commit する。
3. 合意した範囲だけを明示 path で stage する。
4. `git diff --staged --stat` と `git diff --staged` で内容を確認する。
5. commit message を書き、通常 commit を実行する。
6. `git log -1 --format='%h %s'` で結果を確認する。「出力」の `commit` に書く short SHA はここで得る。
7. 「出力」の項目を返す。

停止条件に当たった時、pre-commit hook が失敗した時、commit 自体が失敗した時は [references/failure-handling.md](references/failure-handling.md) を読む。

## 停止条件

どの手順の途中であっても、次に当たったら commit せず、状況と選択肢を報告する。

- detached HEAD で対象 branch が曖昧
- merge / rebase / cherry-pick / revert が進行中
- worktree または index に未解決 conflict がある
- 変更が混在していて、分割の単位が判断できない
- 1 つのファイル内で無関係な変更が混ざり、ファイル単位では分けられない

## staging

- 合意した単一の変更だけを `git add <path>` で stage する。`git add .` と `git add -A` は使わない。範囲を広く取ると、意図しない変更が混ざっても気づけない。
- 無関係、曖昧、危険、またはユーザー自身が編集した変更は unstaged のまま残す。
- directory を stage する時は、含まれる全 path が同じ変更に属することを確認する。
- 未追跡ファイル、機密情報、env / local / editor / temp / debug / build / generated、lockfile、migration、config は、含める意図が確認できる時だけ stage する。

stage 後の確認では、意図しない削除、debug 出力、機密情報、無関係な整形を見る。**機密情報の混入は目視で済ませず、staged diff 全体に対する検索で確認する。** diff が長いと目視は必ず漏れる。

## commit message

title は `<type>: <description>` の 1 行。

- `<type>` は `feat` / `fix` / `docs` / `style` / `refactor` / `perf` / `test` / `build` / `ci` / `chore` / `revert` から選ぶ。Conventional Commits は `feat` / `fix` 以外の type を自由にしているため、集合を決めないと commit ごとに語が揺れて履歴を type で追えなくなる。どれにも当てはまらないと感じたら、type を増やす前に、その commit が複数の変更を含んでいないか疑う。
- **scope は使わない。** `<type>(<scope>): <description>` の形にしない。repo 規約が scope を要求する場合は、scope 付き message を作らず停止して報告する。
- 命令形で書く。`add` / `fix` / `remove` を使い、`added` / `adds` / `adding` は使わない。
- 英語で書く。応答は日本語だが、`git log` を追う時に履歴の言語が混ざっていると読みにくい。
- 50 文字以内を目安にし、72 文字を上限にする。
- 末尾にピリオドを付けない。
- emoji を使わない。

body は原則不要。title だけで理由と影響が伝わるなら書かない。ただし次の 4 つは title に圧縮せず body を付ける。後から原因を追う人には、title の情報量では足りないため。

- breaking change
- security 修正
- data migration
- 過去の commit を revert するもの

body / footer / BREAKING CHANGE を書く時は形式と禁止事項が決まっているので、書く前に [references/message-format.md](references/message-format.md) を読み、その規定に従う。自己流の body / footer を書かない。title だけで足りる時は読まなくてよい。

## Gotchas

- **pre-commit hook はファイルを書き換えることがある。** 自動修正型の hook が発火すると commit が失敗し、修正後の内容が unstaged で残る。この dotfiles repo では `fix end of files` と `markdownlint-cli2 --fix` が該当する。修正差分を確認してから再 stage して commit し直す。確認せずに再 stage しない。
- **`git add -i` と `git add -p` は使えない。** この環境では interactive flag が動かないため、hunk 単位の staging ができない。1 ファイル内で変更を分ける必要が出た時は、上の停止条件に当たる。

## 扱わないもの

通常 commit だけを行う。push、rebase、amend、squash、`--no-verify`、直接の refs 操作、知見の蓄積は扱わない。commit が失敗しても、これらへ切り替えて回避しない。

push は人が手元の terminal で実行する。sandbox の proxy は SSH を運ばないため、agent が実行しても失敗する。知見の蓄積（README / docs、ADR、notes）は `scribe` skill が扱う。

## 出力

| 項目 | 内容 |
| --- | --- |
| `branch` | 現在の branch 名 |
| `commit` | short SHA |
| `message` | 実際に使った、または使おうとした commit message |
| `files` | commit した path の要約 |
| `verification` | staged diff で何を確認したか（削除、debug 出力、機密情報、無関係な整形）と、pre-commit hook の結果 |
| `left_unstaged` | 無関係または意図的に除外した変更 |
| `notes` | hook の warning、停止理由、失敗理由 |

失敗、no-op、事前停止でも同じ項目を返す。該当が無ければ `none`。`verification` だけは確認を行わなかった理由を書く。

`verification` は単語 1 つでなく、何を見て何が無かったかを書く。「確認した」だけでは、次に読む人が確認の範囲を再現できない。

エラー全文をそのまま貼らない。`git` の出力には認証 URL や token が混ざることがあり、報告に残すと秘密情報が履歴に残る。要点だけを `notes` に書く。
