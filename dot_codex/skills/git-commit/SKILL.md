---
name: git-commit
description: "Git の変更を commit する時に使う。「commit して」「コミットして」「変更を確定して」などの依頼に加え、作業を Git の履歴に残す流れになったら、commit という語が無くても使う。変更を目的ごとの commit に分け、明示した path だけを stage し、staged diff と秘密情報を確かめてから、`type: description` 形式の英語 message で通常の commit を作る。push、rebase、amend は扱わない。"
---

# Git Commit

## 手順

指示された段までしか進まない。「stage して」なら手順 5 で止める。「進めて」のような作業を続ける言葉や、このスキルが読み込まれたことは、commit の指示に数えない。

1. `git status -sb`、`git diff`、`git diff --staged` で変更の全体を読む。`git status` に `-uall` は付けない。commit まで進む時は、名義を `git var GIT_AUTHOR_IDENT` と `git var GIT_COMMITTER_IDENT` で見る。
2. 「止まる条件」に当たらないか確かめる。
3. 「変更の単位」に従って commit の範囲を決める。複数の commit に分かれるなら、手順 4 の後で、1 つずつ手順 5〜8 を回す。
4. commit する変更の全体を `lapidary` で見直す。範囲が複数でも、分けずに 1 回で通す。分けて見ると、ある範囲の変更が別の範囲の記述を古くした箇所を見落とす。ユーザーが見直しは要らないと言った時は飛ばす。`lapidary` が commit できないと判定したら、止まって報告する。見直しで直したファイルが増えたら、手順 3 に戻って範囲を決め直す。見直しの後に変更を足した時は、足した分を通し直す。
5. 範囲の path を `git add <path>` で stage する。stage と commit は別のコマンドで打つ。同じコマンドにすると、手順 6 の確認が stage 前の状態に当たる。
6. `git diff --staged` を読み、意図しない削除、debug 出力、無関係な整形が無いか見る。秘密情報は目視で済ませず、staged diff を検索して確かめる。作業機の識別子は同梱 script で検査する。読み込んだ `SKILL.md` の親を基準に script の絶対 path を解決し、作業対象 repo のカレントディレクトリは変えない。Windows は `pwsh -NoProfile -NonInteractive -File "<skill directory>/scripts/check-identifiers.ps1"`、macOS は `sh "<skill directory>/scripts/check-identifiers.sh"` を実行する。exit 0 以外（script 不在、起動拒否を含む）では commit しない。自分の変更で検出された値はプレースホルダへ置き換え、stage し直して再検査する。
7. message を heredoc で渡して commit する。
8. `git status -sb` と `git log -1 --format='%h %s'` で結果を確かめる。

## 止まる条件

次に当たったら commit せず、状況と人が取れる選択肢を報告する。rebase の中断、conflict の解決、branch の切り替えは人が決めることなので、自分で解消しない。

- 識別子の検査が exit 0 以外で、自分では直せない。ユーザー自身の編集、誤検出に見える結果、script 不在、起動拒否、差分取得の失敗が当たる。検査を飛ばしたり、別の方法で通したりしない。実行ポリシーや sandbox は変更しない
- detached HEAD
- merge / rebase / cherry-pick / revert の途中
- 未解決の conflict
- 変更が混ざっていて、分け方が決まらない
- 1 つのファイルの中に、範囲に入れる変更と入れない変更が混ざっている。ユーザー自身の編集や前の作業の残りで、範囲に入るか確かめられない変更も、入れない側に数える
- 範囲に入らない変更が、すでに stage されている。自分で stage したものでなければ、unstage せずに報告する
- commit に進む時、author か committer のアドレスが、公開してよいと確かめられない（GitHub の repo で noreply でない、など）。名義は差し替えずに報告し、判断を待つ
- commit する変更が無い。空の commit は作らない

## 変更の単位

1 commit は 1 つの論理的な変更。単独で説明でき、その commit の時点で repo が壊れていない（build、lint、test が通る）まとまりにする。`git bisect`、`revert`、`cherry-pick` は commit を単位に動くので、単位が論理的な変更とずれると、途中の版が壊れるか、変更の片側だけが残る。

- その変更を完結させるのに要るものは、同じ commit に入れる。変更が古くした記述の更新、変更の理由や設計を書いた doc、test、機械的な追従（参照の更新、番号の振り直し）がこれに当たる。分けると、間の commit で記述と実態がずれる。
- 独立に成り立つ変更は分ける。別の不具合の修正、挙動を変えない整形や refactor と挙動の変更、変更と関係なく成り立つ doc（実測の記録、既存の誤字の修正）がこれに当たる。
- type は commit の主な目的で選ぶ。`feat` や `fix` に添えた doc や test は、type を変えない。`docs` と `test` は、それだけを変える commit に使う。目的が 2 つあって主従を決められない時は、分ける合図。
- repo の `AGENTS.md` が commit の分け方を決めていれば、それに従う。

## staging

- `git add .` と `git add -A` は使わない。意図しないファイルが混ざっても気づけない。
- directory を stage する時は、中の全 path が同じ変更に属することを確かめる。
- 無関係な変更、曖昧な変更、ユーザー自身が編集した変更は unstaged に残す。
- 未追跡ファイル、env・local・editor・temp・build・generated のファイル、lockfile、migration、config は、含める意図が確かめられた時だけ stage する。
- 秘密情報（`.env`、credential、鍵、token）を含みそうなファイルは commit しない。ユーザーに頼まれた時も、先に警告する。

## commit message

repo に commit-msg hook があれば、形式はそれが検査する。ここの規定は、最初から hook を通る message を書くためのもの。repo が別の形式を決めていれば、そちらに従う。

- title は `<type>: <description>` の 1 行。
- type は `feat` / `fix` / `docs` / `style` / `refactor` / `perf` / `test` / `build` / `ci` / `chore` / `revert` から選ぶ。scope は付けない。どれにも当たらないと感じたら、その commit が複数の変更を含んでいないか疑う。
- description は英語の命令形で、小文字で始める（`add` / `fix` / `remove`）。末尾にピリオドを付けない。emoji を使わない。50 文字を目安、72 文字を上限にする。
- body には原則 `Why:` で変えた理由を 1〜2 文書く。doc は今の形を書くので、変えた直接の理由は commit に残す。英語で書き、72 文字で折り返す。`This commit`、`I` / `we`、`now` / `currently` は使わない。commit は変更そのものの記録で、書き手や時点の話ではない。
- 理由は具体的な事実、判断、失敗を書く。「保守しやすくするため」のような一般論しか書けないなら省く。title だけで理由が明らかな変更（typo、機械的な追従、整形、lint の指摘への対応、依存の更新）でも省く。
- breaking change、security の修正、data migration、revert では、`Why:` に加えて影響も書く。`Why:` 以外のラベル、footer、`BREAKING CHANGE` を書く時は、先に [references/message-format.md](references/message-format.md) を読む。

```sh
git commit -F - <<'EOF'
fix: drop the duplicated sandbox credential entries

Why: Read deny rules are merged into the sandbox denyRead list, so the
credentials.files entries protected the same paths twice.
EOF
```

## Gotchas

- pre-commit や commit-msg の hook が失敗した時、commit はできていない。ここで `--amend` すると 1 つ前の commit を書き換える。原因を直して stage し直し、新しい commit を作る。
- 自動修正型の hook（末尾改行の補正、`markdownlint --fix` など）は、ファイルを書き換えたうえで失敗する。修正差分を `git diff` で確かめてから stage し直す。確かめずに stage すると、hook が何を変えたか分からないまま commit する。
- hunk 単位の stage（`git add -p` / `-i`）はしない。対話で選ぶ hunk を取り違えると、同じファイルにあるユーザーの編集や範囲外の変更まで stage される。1 ファイル内で分ける必要が出たら、「止まる条件」に当たる。
- 署名に失敗したら、迂回せず止まって報告する。
- 既定の `workspace-write` sandbox では、`<writable_root>/.git` は読み取り専用。`.git` が `gitdir:` ファイルなら参照先も保護される。現在の権限で実行できるコマンドはそのまま実行する。sandbox の制限で実行できず、承認で許可できる場合に限り、必要な `git add` と `git commit` を別々に正式な承認経路へ申請する（`AGENTS.md` の「権限」）。明示的な deny や承認の拒否に当たったら止まって報告する。
- 再実行は 1 回だけ、index lock の競合のように再実行で解ける見込みがある失敗に限る。hook の失敗、conflict、権限エラーは、再実行しても変わらない。

## 出力

- 作った commit の hash と title。
- staged diff で確かめたこと（削除、debug 出力、秘密情報の検索、識別子の検査、無関係な整形）と、hook の結果。「確認した」だけでは、何を見たかを次の人が再現できない。
- `lapidary` が直したものと、提案した組み込みの review。ここに書かないと、提案がユーザーに届かないまま push される。見直しを飛ばした時は、その旨。
- unstaged に残した変更と、その理由。
- 識別子の検査は終了コードと種類・相対 path を報告し、実際の home・ユーザー名・ホスト名は伏せる。
- 止まった時や失敗した時は、その理由の要点。git の出力は全文を貼らない。認証 URL や token が混ざることがある。
