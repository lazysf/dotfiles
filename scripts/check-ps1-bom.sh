#!/bin/sh
# prek の pre-commit hook。渡された .ps1 が UTF-8 の BOM で始まるかを調べる。
# Windows PowerShell は BOM の無い UTF-8 のスクリプトを ANSI のコードページで読み、日本語が化けるため。

set -u

status=0
for file in "$@"; do
  if [ ! -r "$file" ]; then
    echo "check-ps1-bom: $file を読めず、検査できなかった。" >&2
    status=1
    continue
  fi
  head=$(head -c 3 "$file" | od -An -tx1 | tr -d ' \n')
  if [ "$head" != "efbbbf" ]; then
    echo "check-ps1-bom: $file が UTF-8 の BOM で始まっていない。BOM 付きの UTF-8 で保存し直す。" >&2
    status=1
  fi
done

exit "$status"
