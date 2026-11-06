#!/bin/sh
# Claude Code の SessionStart hook。エージェントの commit を、1Password ではなく
# 署名専用の鍵で署名させる。
#
# 共通の起動処理が成功した時だけ、この session の Bash に署名設定を渡す。
# 起動に失敗した時は env を書かず、既定の署名設定を使う。

set -u

[ -n "${CLAUDE_ENV_FILE:-}" ] || exit 0
pub=$("$HOME/.config/git/start-signing-agent") || exit 0
sock="$HOME/.local/state/agent-signing/agent.sock"

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
