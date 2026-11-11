#!/bin/sh
set -eu
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
root=$(mktemp -d "${TMPDIR:-/tmp}/identifier-sh-tests.XXXXXXXX")
cleanup() {
  case "$root" in "${TMPDIR:-/tmp}"/identifier-sh-tests.*) rm -rf -- "$root" ;; *) exit 1 ;; esac
}
trap cleanup EXIT HUP INT TERM
mkdir "$root/bin"
printf '#!/bin/sh\nprintf "%%s\\n" synthetic-host\n' > "$root/bin/hostname"
chmod +x "$root/bin/hostname"
PATH="$root/bin:$PATH"
HOME=/synthetic/home
USER=synthetic-user
export PATH HOME USER
cd "$root"
git init -q
probe() {
  expected=$1
  actual=0
  sh "$script_dir/check-identifiers.sh" > "$root/out" 2> "$root/err" || actual=$?
  [ "$actual" -eq "$expected" ] || { echo 'unexpected checker exit' >&2; exit 1; }
  for value in "$HOME" "$USER" synthetic-host; do
    if grep -i -F -- "$value" "$root/out" "$root/err" >/dev/null; then echo 'identifier leaked' >&2; exit 1; fi
  done
}
probe 0
printf '%s\n' ordinary > probe.txt
git add -- probe.txt
probe 0
for value in "$HOME" "$USER" synthetic-host; do
  printf '%s\n' "$value" > probe.txt
  git add -- probe.txt
  probe 1
done
printf '%s\n' ordinary > probe.txt
git add -- probe.txt
for path in synthetic-user.txt SYNTHETIC-HOST.txt 'synthetic-user"quote.txt'; do
  : > "$path"
  git add -- "$path"
  probe 1
  git rm --cached -q -- "$path"
done
GIT_CONFIG_COUNT=1
GIT_CONFIG_KEY_0=diff.ignoreSubmodules
GIT_CONFIG_VALUE_0=all
export GIT_CONFIG_COUNT GIT_CONFIG_KEY_0 GIT_CONFIG_VALUE_0
git update-index --add --cacheinfo 160000,0123456789012345678901234567890123456789,synthetic-user
probe 1
git rm --cached -q -- synthetic-user
git update-index --add --cacheinfo 160000,0123456789012345678901234567890123456789,ordinary-submodule
probe 0
echo 'PASS: 10 shell cases'
