# AGENTS.md

## 概要

このリポジトリは、`chezmoi` を使って各種の設定ファイルを一元管理するための dotfiles リポジトリ。

## 対象環境

- macOS（主対象。他OSは未検証）

## 事前要件

- `chezmoi` が `PATH` にあること
- `git`（`chezmoi init` と更新に使用）
- 1Password CLI `op`（テンプレート内で `onepasswordRead` を使う場合）
- `op` を使う場合は `chezmoi apply` の前に `op signin`
- `pre-commit` を使う場合のみ `prek`（`.pre-commit-config.yaml`）

## 使い方（要点）

- 初回セットアップ:
  - `chezmoi init --apply https://github.com/lazysf/dotfiles.git`
- 既にソースディレクトリがこのリポジトリの場合:
  - `chezmoi apply`
- 変更の確認:
  - `chezmoi diff`

## リポジトリ構成（抜粋）

```text
.
├── AGENTS.md
├── Documents/
│   └── PowerShell/
│       └── Microsoft.PowerShell_profile.ps1
├── .chezmoiignore
├── .pre-commit-config.yaml
├── dot_codex/          # ~/.codex (Codex config/skills)
│   ├── AGENTS.md
│   ├── config.toml
│   ├── rules/
│   └── skills/
├── dot_config/         # ~/.config
│   ├── chezmoi/
│   ├── gh/
│   ├── git/
│   ├── lazygit/
│   ├── nvim/
│   ├── starship.toml
│   ├── wezterm/
│   ├── yazi/
│   └── zsh/
├── dot_ssh/            # ~/.ssh
│   └── private_config.tmpl  # ~/.ssh/config (private template)
├── dot_zshenv          # ~/.zshenv
├── LICENSE
└── README.md
```

## メモ

- `dot_ssh/private_config.tmpl` はプライベートな設定を想定。
- macOSで`op`が存在する場合、`dot_config/git/config.tmpl` は `op whoami` 成功を前提に展開される。未サインイン時は `chezmoi apply` が失敗する。
- Neovim のツール管理方針: LSP/DAP は Mason 管理、runtime/formatter/linter は mise 管理とする。
- `taplo` は役割分担を明確化し、LSP は Mason、format/lint は mise 側の CLI を利用する。
- 詳細は `README.md` を参照。
