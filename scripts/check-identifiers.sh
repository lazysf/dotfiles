#!/bin/sh
# prek の pre-commit hook。git-commit skill も同じファイルを使う
# （dot_claude/skills/git-commit/scripts/ の template が include する）。
# staged のファイルの path と追加行に、この作業機の識別子
# （home の絶対パス、ユーザー名、ホスト名）が無いかを調べる。
# 値は実行時に読む。値をこのファイルに書くと、このファイル自体が値を配る。

set -u

fail() {
  echo "check-identifiers: staged の差分を取れず、検査できなかった。" >&2
  exit 1
}

# 削除した path は除く。値を含む path を消す commit を止めないため。
# --no-ext-diff、--no-textconv、--text は、repo の設定や attribute で diff の中身が変わらないようにするため。
# --no-renames は、改名したファイルの中身も追加行として見るため。
staged() {
  git -c core.quotePath=false diff --cached --no-relative --no-renames --diff-filter=d "$@"
}
patch=$(staged -U0 --no-color --no-ext-diff --no-textconv --text) || fail
names=$(staged --name-only) || fail

# 追加行を「path<TAB>内容」の形にし、追加行の無いファイルのために path だけの行も足す。
# path は header から取るので、git が path をクォートしても中身は検査する。
lines=$(
  printf '%s\n' "$patch" | awk '
    /^diff --git / { hunk = 0; path = ""; next }
    !hunk && /^\+\+\+ / { path = substr($0, 5); sub(/^b\//, "", path); sub(/^"b\//, "\"", path); next }
    /^@@/ { hunk = 1; next }
    hunk && /^\+/ { print path "\t" substr($0, 2) }
  '
  printf '%s\n' "$names"
)

home=${HOME:-}
home=${home%/}
user=${USER:-${USERNAME:-}}
host=$(hostname 2>/dev/null) || host=
host=${host%%.*}

# $1 = 種類、$2 = 値、残りは grep の option。当たった path を 1 行ずつ出す。
hits() {
  kind=$1
  value=$2
  shift 2
  [ -n "$value" ] || return 0
  printf '%s\n' "$lines" | grep "$@" -- "$value" | cut -f1 | sort -u |
    while IFS= read -r path; do printf '  %s: %s\n' "$kind" "$path"; done
}
report=$(
  hits home "$home" -F
  hits user "$user" -i -w -F
  hits host "$host" -i -w -F
)

[ -n "$report" ] || exit 0

# 当たった行の内容は出さない。出すと log や transcript に値が残る。
{
  echo "check-identifiers: staged の path か追加行に、この作業機の識別子がある（home: home の絶対パス、user: ユーザー名、host: ホスト名）。"
  printf '%s\n' "$report"
  echo "値を ~/ や <user> のようなプレースホルダへ置き換え、stage し直してから commit する。"
} >&2
exit 1
