# dotfiles (chezmoi)

Dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Requirements

- macOS (primary target; other OSes are untested)
- chezmoi installed and available in `PATH`
- git (used by `chezmoi init` and repo updates)
- 1Password CLI (`op`) if you use template secrets (`onepasswordRead`)
- Run `op signin` before `chezmoi apply` when using `op`
- prek only if you want to run pre-commit hooks (`.pre-commit-config.yaml`)

## Quick start

Initialize from the repo:

```sh
chezmoi init --apply git@github.com:lazysf/dotfiles.git
```

If this repo is already your chezmoi source directory:

```sh
chezmoi apply
```

Preview changes before applying:

```sh
chezmoi diff
```

## Repository structure

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
