#!/bin/sh
# prek の commit-msg hook。commit message の title が `<type>: <description>` の形かを調べる。
# 規約の正本は git-commit スキルの「commit message」。ここはその title の形だけを機械的に見る。

set -u

file=${1:-}
if [ -z "$file" ] || [ ! -r "$file" ]; then
  echo "check-commit-msg: commit message のファイルを読めず、検査できなかった。" >&2
  exit 1
fi

# git は hook の後で `#` の行を消すので、title はコメントと空行を除いた最初の行。
title=$(grep -v -e '^#' -e '^[[:space:]]*$' "$file" | head -n 1)

# git merge が生成する title は通す。人が書き直す機会の無い message で merge を止めないため。
case $title in
  "Merge "*) exit 0 ;;
esac

types='feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert'
problems=''

if ! printf '%s\n' "$title" | grep -Eq "^($types): [^[:space:]]"; then
  problems="$problems
- \`<type>: <description>\` の形にする。type は $types のどれか。scope は付けない。"
elif printf '%s\n' "$title" | grep -Eq "^($types): [[:upper:]]"; then
  problems="$problems
- description は小文字で始める。"
fi

case $title in
  *.) problems="$problems
- 末尾にピリオドを付けない。" ;;
esac

# 文字数は byte ではなく文字で数える。
length=$(printf '%s' "$title" | LC_ALL=en_US.UTF-8 wc -m | tr -d ' ')
if [ "$length" -gt 72 ]; then
  problems="$problems
- title は 72 文字以内にする（今は $length 文字）。"
fi

if [ -n "$problems" ]; then
  printf 'check-commit-msg: title が規約に合わない: %s\n%s\n' "$title" "$problems" >&2
  exit 1
fi
