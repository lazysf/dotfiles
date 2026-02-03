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
  - `chezmoi init --apply git@github.com:lazysf/dotfiles.git`
- 既にソースディレクトリがこのリポジトリの場合:
  - `chezmoi apply`
- 変更の確認:
  - `chezmoi diff`

## リポジトリ構成（抜粋）

```text
.
├── .chezmoiignore
├── .pre-commit-config.yaml
├── dot_codex/          # ~/.codex (Codex config/skills)
├── dot_config/         # ~/.config
│   ├── gh/
│   ├── git/
│   ├── lazygit/
│   ├── nvim/
│   ├── starship.toml
│   ├── wezterm/
│   ├── yazi/
│   └── zsh/
├── dot_ssh/            # ~/.ssh
│   └── private_config  # ~/.ssh/config (private)
├── dot_zshenv          # ~/.zshenv
├── LICENSE
└── README.md
```

## メモ

- `dot_ssh/private_config` はプライベートな設定を想定。
- 詳細は `README.md` を参照。
