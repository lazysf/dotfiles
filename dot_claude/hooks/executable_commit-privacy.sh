#!/bin/sh
# Claude Code の PreToolUse hook（Bash）。Claude が打つ git commit の前に、
# staged の追加行にこの作業機の識別子（home の絶対パス、ユーザー名、ホスト名）が
# 無いかを調べる。当たったら exit 2 で tool call を止め、stderr を Claude に返す。
#
# 調べる値は実行時に読む。値をこのファイルに書くと、このファイル自体が値を配る。
# hook は sandbox の外で動くので、repo の設定から program を起動させない形で git を呼ぶ。

set -u

input=$(cat)

# tool_input.command の値だけを見る。description や cwd に commit という語があっても検査しない。
# 値は JSON の escape（\" など）を残したまま扱う。
cmd=$(printf '%s\n' "$input" | sed -n -E 's/.*"command"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p')

# git の subcommand は、command の区切りの直後にある git の、option の後ろの語で見る。
# path や message の中の commit / add という文字列では判定しない。
# 先頭の環境変数の代入と、-c <値>、-C <値>、- で始まる option は飛ばす。
git_sub='[[:space:]]*([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*git([[:space:]]+(-[cC][[:space:]]+[^[:space:]]+|-[^[:space:]]+))*[[:space:]]+'
word_end='([^[:alnum:]_.-]|$)'

# commit の判定では改行（JSON の \n）も区切りに数え、複数行の command でも検査を外さない。
# 当たり過ぎても、検査が増えるだけで止まりはしない。
printf '%s\n' "$cmd" | grep -q -E "(^|&&|\|\||;|\||\\\\n)${git_sub}commit${word_end}" || exit 0

# PreToolUse は command 全体の前に 1 回だけ動く。同じ command で stage すると、
# その分は検査の時点の index に無い。こちらは当たると止まるので、commit message の
# 本文に出やすい改行と ( の後ろは区切りに数えない。
if printf '%s\n' "$cmd" | grep -q -E "(^|&&|\|\||;|\|)${git_sub}(add|stage)${word_end}"; then
  echo "commit-privacy: stage と commit を 1 つの command で打っている。この hook は command を実行する前の index を見るので、これから stage する分を検査できない。git add と git commit を別の command に分けて打ち直す。" >&2
  exit 2
fi

# Windows の Git Bash には jq が無いので、cwd は sed で取り出す。
cwd=$(printf '%s\n' "$input" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | sed 's/\\\\/\\/g')
[ -n "$cwd" ] || cwd=.

# repo でない場所では commit も失敗するので、検査せずに通す。
top=$(git -C "$cwd" -c core.fsmonitor=false rev-parse --show-toplevel 2>/dev/null) || exit 0

# agent は sandbox の中から .git/config を書ける。repo の設定に書かれた program
# （core.fsmonitor、diff.external、textconv、partial clone の lazy fetch が起動する
# fetch の program、submodule の中の diff、pager）を、sandbox の外のこの hook から
# 起動しないようにする。
GIT_NO_LAZY_FETCH=1
export GIT_NO_LAZY_FETCH
diff=$(git --no-pager --no-lazy-fetch -C "$top" -c core.fsmonitor=false -c core.quotePath=false \
  diff --cached -U0 --no-relative --default-prefix --no-ext-diff --no-textconv --no-color --submodule=short 2>/dev/null) || {
  # repo なのに差分を取れない時は、検査を飛ばさずに止める。
  echo "commit-privacy: staged の差分を取れず、検査できなかった。git の版が古い（--no-lazy-fetch が無い）か、repo が壊れている。人が terminal で確かめる。" >&2
  exit 2
}
[ -n "$diff" ] || exit 0

# 追加行を「path<TAB>内容」の形にする。path も一緒に検査する。
lines=$(printf '%s\n' "$diff" | awk '
  /^diff --git / { inhunk = 0; path = ""; next }
  !inhunk && /^\+\+\+ / { path = substr($0, 5); sub(/^b\//, "", path); sub(/^"b\//, "\"", path); next }
  /^@@/ { inhunk = 1; next }
  inhunk && /^\+/ { print path "\t" substr($0, 2) }
')
[ -n "$lines" ] || exit 0

home=${HOME:-}
home=${home%/}
user=${USER:-${USERNAME:-}}
# 引数なしの hostname はどの OS でも名前を出すので、-s に頼らず最初のラベルを取る。
host=$(hostname 2>/dev/null) || host=
host=${host%%.*}

paths_with() { # $1 以降は grep の option と値。当たった path を空白区切りで返す。
  printf '%s\n' "$lines" | grep "$@" | cut -f1 | sort -u | tr '\n' ' '
}
report=
if [ -n "$home" ]; then
  p=$(paths_with -F -- "$home")
  [ -z "$p" ] || report="${report}  home: ${p}
"
fi
if [ -n "$user" ]; then
  p=$(paths_with -i -w -F -- "$user")
  [ -z "$p" ] || report="${report}  user: ${p}
"
fi
if [ -n "$host" ]; then
  p=$(paths_with -i -w -F -- "$host")
  [ -z "$p" ] || report="${report}  host: ${p}
"
fi

[ -n "$report" ] || exit 0

# 当たった内容は出さない。出すと transcript に残る。
{
  echo "commit-privacy: staged の追加行に、この作業機の識別子がある（home: home の絶対パス、user: ユーザー名、host: ホスト名）。"
  printf '%s' "$report"
  echo "値を ~/ や <user> のようなプレースホルダへ置き換え、stage し直してから commit する。command の形を変えて、この hook を避けない。"
} >&2
exit 2
