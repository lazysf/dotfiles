#!/usr/bin/env zsh
alias cls="clear"
if command -v eza >/dev/null 2>&1; then
	alias la="eza --icons --git -la"
	alias ll="eza --icons --git -l"
	alias ls="eza --icons --git"
	alias lt="eza --icons --git --tree"
else
	alias la="ls -la"
	alias ll="ls -l"
fi
alias reload="exec zsh -l"
alias vi="nvim"
alias vim="nvim"
