# AGENTS.md

## 概要

このリポジトリは、`chezmoi` を使って各種の設定ファイルを一元管理するための dotfiles リポジトリ。

## Codex 設定の目的

このリポジトリの `dot_codex/` 配下の設定、ルール、スキルは、Codex を高品質に運用するための基盤である。Codex を使ってこのリポジトリの Codex 設定を追加・修正するときにも、何のための設定かを見失わないよう、この目的を明示する。

- 高品質かつ素晴らしいバイブコーディング体験を実現するため
- 高品質なハーネスエンジニアリングを実現し、開発の高品質化と高速化を支えるため

詳細な運用ルールは `dot_codex/AGENTS.md`、日常の入口は `dot_codex/QUICKSTART.md`、実務ガイドは `dot_codex/docs/workflow-guide.md` を参照する。

## ハーネス知見の置き場

- 外部ベストプラクティスの調査結果や repo-level の保守知識は `docs/harness-engineering-best-practices.md` に蓄積する。
- 知見を `docs / ADR / dot_codex/docs / skills / rules / agents` のどこへ昇格するかの判断は `docs/adr/` を正本とする。
- 展開後にも日常運用で参照したい判断基準は `dot_codex/docs/knowledge-promotion.md` に置く。
- 手動で回す確認シナリオは `docs/harness-regression-scenarios.md` に置き、`dot_codex/docs/verification.md` から辿れるように保つ。

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
- chezmoi 管理下のソース状態を最新化して適用する場合:
  - `chezmoi update`
- 既にソースディレクトリがこのリポジトリで、手動更新済みの場合:
  - `chezmoi apply`
- 変更の確認:
  - `chezmoi diff`

## Source of Truth

- このリポジトリで管理している設定はすべて、repo 側の source を正本として扱う。
- `Documents/*` を含む chezmoi 管理下の全 source を編集対象にする。
- `~/.codex/*`、`~/.config/*`、`~/.ssh/*`、`~/.zshenv` を含む home 配下の実ファイルは `chezmoi apply` 後の反映先であり、直接編集してはならない。
- home 配下の設定を変更したい場合でも、必ず repo 側 source を修正し、`chezmoi apply` で反映する。
- このガードの目的は、Codex が repo 外の live 設定を誤って直接編集する事故を防ぐこと。

## リポジトリ構成（抜粋）

```text
.
├── AGENTS.md
├── Documents/
│   └── PowerShell/
│       └── Microsoft.PowerShell_profile.ps1
├── .chezmoiignore
├── .pre-commit-config.yaml
├── dot_codex/          # ~/.codex (高品質なバイブコーディングを実現するための Codex 設定/skills)
│   ├── AGENTS.md
│   ├── private_config.toml.tmpl
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
