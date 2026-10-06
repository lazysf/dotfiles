# 停止と失敗の扱い

`SKILL.md` の停止条件に当たった時、pre-commit hook が失敗した時、commit 自体が失敗した時に読む。

## 停止した時の対応

commit を作らず、次を報告する。

- 何が起きているか（detached HEAD、rebase 進行中、conflict、分割単位が不明、ファイル単位で分けられない）
- そのまま進めると何が壊れるか
- 解消するために人が取れる選択肢

**状況を自分で解消しない。** rebase の中断、conflict の解決、branch の切り替えは、いずれも人が意図を持って決めることで、commit skill の責務を超える。判断材料を揃えて返すところまでを行う。

## pre-commit hook

hook は失敗の種類で対応が変わる。

| hook の挙動 | 対応 |
| --- | --- |
| 検査だけ行い失敗（lint、型、secret 検出など） | 指摘された原因を直し、直した内容を stage して commit し直す |
| ファイルを自動修正して失敗（該当する hook は `SKILL.md` の Gotchas） | **修正差分を `git diff` で確認してから**再 stage して commit し直す |
| どの種類か判別できない | hook の出力を読み、判別できるまで再実行しない |

自動修正型で差分を確認せずに再 stage すると、hook が何を変えたか分からないまま commit することになる。整形のつもりで内容が変わっていても気づけない。

`--no-verify` で hook を迂回しない。hook は repo が合意した検査で、迂回すると commit 履歴に検査を通っていない変更が混ざる。

## 失敗時

- amend、squash、直接の ref 編集、その他の history 操作へ切り替えない。失敗の回避手段としてこれらを使うと、履歴が意図せず書き換わる。
- retry は 1 回だけ、かつ**再実行で解ける見込みがある失敗**に限る。index lock の競合のように、他プロセスとの一時的な衝突が該当する。hook 失敗、conflict、権限エラーは再実行しても状態が変わらないので retry しない。
- retry する前に `git status -sb` と `git diff --staged` を読み直し、状態が想定どおりか確認する。
- retry しても失敗する場合は停止し、理由の要点を報告する。
