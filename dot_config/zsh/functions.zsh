#!/usr/bin/env zsh
# -----------------------------------------
# yazi
# -----------------------------------------
if command -v yazi >/dev/null 2>&1; then
  function y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")" || return 1

    # Ensure cleanup even if yazi errors or the shell is interrupted
    trap 'rm -f -- "$tmp"' EXIT INT TERM

    yazi "$@" --cwd-file="$tmp"

    if cwd="$(command cat -- "$tmp")" && [[ -n "$cwd" ]] && [[ "$cwd" != "$PWD" ]]; then
      builtin cd -- "$cwd"
    fi

    rm -f -- "$tmp"
    trap - EXIT INT TERM
  }
fi

# -----------------------------------------
# ghq + fzf
# -----------------------------------------
if command -v ghq >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
  function ghq-fzf() {
    local root src target
    root="$(ghq root)" || return 1

    src="$(ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 ${root}/{}/README.*")"
    if [[ -n "${src}" ]]; then
      target="${root}/${src}"
      BUFFER="cd ${(q)target}"
      zle accept-line
    fi
    zle -R -c
  }
  zle -N ghq-fzf
  bindkey '^g' ghq-fzf
fi
