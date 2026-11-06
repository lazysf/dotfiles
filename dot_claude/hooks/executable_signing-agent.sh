#!/bin/sh
# Claude Code の SessionStart hook。エージェントの commit を、1Password ではなく
# 署名専用の鍵で署名させる。
#
# 専用の ssh-agent を起動して鍵を載せ、git の署名設定を CLAUDE_ENV_FILE 経由で
# この session の Bash コマンドにだけ渡す。人が terminal で行う commit は今まで
# どおり 1Password で署名される。hook は sandbox の外で動くので鍵ファイルを読める。
# sandbox 内のコマンドは鍵を読めず、socket 経由で署名を依頼できるだけになる。
#
# 失敗しても session を止めない。常に exit 0 で抜け、理由は stderr に出す。
# env を書かなければ 1Password での署名に戻るだけで、壊れた設定は残らない。

set -u

key="$HOME/.ssh/agent_signing_ed25519"
state_dir="$HOME/.local/state/agent-signing"
sock="$state_dir/agent.sock"
lock="$state_dir/lock"

warn() {
  echo "signing-agent: $*" >&2
}

# 鍵を作っていないマシン（work、Windows、未セットアップ）では何もしない。
[ -f "$key" ] && [ -f "$key.pub" ] || exit 0
[ -n "${CLAUDE_ENV_FILE:-}" ] || exit 0

if ! mkdir -p "$state_dir" || ! chmod 700 "$state_dir"; then
  warn "state ディレクトリを作れない: $state_dir"
  exit 0
fi

# 同時に始まった session が agent を二重に起動しないよう、mkdir で排他する。
# timeout で kill された hook のロックが残っても次の session を詰まらせないよう、
# 待っても取れない時は古いロックとみなして 1 回だけ取り直す。
tries=0
until mkdir "$lock" 2>/dev/null; do
  tries=$((tries + 1))
  if [ "$tries" -ge 50 ]; then
    warn "ロックが外れないので古いものとみなす: $lock"
    rmdir "$lock" 2>/dev/null
    if ! mkdir "$lock" 2>/dev/null; then
      warn "ロックを取れない: $lock"
      exit 0
    fi
    break
  fi
  sleep 0.1
done
trap 'rmdir "$lock" 2>/dev/null' EXIT

# 公開鍵は 1 行目の type と本体だけを使い、形式が完全に一致する時だけ進む。
# この値は env file に書かれ、Bash コマンドのたびに shell code として読まれるので、
# 引用符や改行が入る余地を残さない。
pub=$(head -n 1 "$key.pub" | cut -d ' ' -f 1,2)
if ! printf '%s\n' "$pub" | grep -Eqx 'ssh-ed25519 [A-Za-z0-9+/]+=*'; then
  warn "公開鍵の形式が想定と違う: $key.pub"
  exit 0
fi

# ssh-add -l は agent に接続できない時だけ 2 を返す。再起動後の残った socket もここで拾う。
SSH_AUTH_SOCK="$sock" ssh-add -l >/dev/null 2>&1
if [ "$?" -eq 2 ]; then
  rm -f "$sock"
  # agent は daemon として残る。hook の stdout を握ったままだと Claude Code が
  # hook の終了を待ち続けるので、標準入出力を外す。
  # -P '!*' は、PKCS#11 / FIDO の middleware をどれも読み込ませない指定。socket は
  # sandbox 内から使えるので、既定の /usr/lib*/* を許すと sandbox 外の agent に
  # system の library を dlopen させられる。
  if ! ssh-agent -a "$sock" -P '!*' </dev/null >/dev/null 2>&1; then
    warn "ssh-agent を起動できない: $sock"
    exit 0
  fi
  # 秘密鍵を渡すのは、この hook が今起動した agent だけにする。
  if ! SSH_AUTH_SOCK="$sock" ssh-add "$key" </dev/null >/dev/null 2>&1; then
    warn "鍵を agent に載せられない: $key"
    exit 0
  fi
fi

# 接続できる agent に鍵が無い時は、鍵を渡さない。socket の path に別のプロセスが
# 居座っている可能性があり、渡すとパスフレーズの無い秘密鍵がそこへ出る。
# 自分の agent で鍵が消えただけなら、agent を止めれば次の session で起動し直す。
if ! SSH_AUTH_SOCK="$sock" ssh-add -L 2>/dev/null | grep -qF "$pub"; then
  warn "agent に鍵が無いので使わない。agent を止めてから session を開き直す: $sock"
  exit 0
fi

# GIT_CONFIG_COUNT 系は、このプロセスの git にだけ設定を足す。~/.config/git/config は変えない。
# Claude Code 自身も sandbox のコマンドに GIT_CONFIG_COUNT 系（safe.directory）を入れるので、
# 番号を固定せず、env file が読まれた時点の GIT_CONFIG_COUNT の後ろへ足す。
# 固定の 0 番と 1 番に書くと、どちらかが相手を上書きする。
{
  printf "export SSH_AUTH_SOCK='%s'\n" "$sock"
  echo 'agent_signing_n=${GIT_CONFIG_COUNT:-0}'
  echo 'export "GIT_CONFIG_KEY_$agent_signing_n=gpg.ssh.program" "GIT_CONFIG_VALUE_$agent_signing_n=ssh-keygen"'
  echo 'agent_signing_n=$((agent_signing_n + 1))'
  printf 'export "GIT_CONFIG_KEY_$agent_signing_n=user.signingkey" "GIT_CONFIG_VALUE_$agent_signing_n=key::%s"\n' "$pub"
  echo 'export GIT_CONFIG_COUNT=$((agent_signing_n + 1))'
  echo 'unset agent_signing_n'
} >>"$CLAUDE_ENV_FILE"

exit 0
