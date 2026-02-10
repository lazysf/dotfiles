# dotfiles (chezmoi)

Dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Requirements

### Target OS

- macOS (primary target; other OSes are untested)

### Required tools

- `chezmoi` installed and available in `PATH`
- `git` (used by `chezmoi init` and repo updates)

### Optional tools

- 1Password CLI (`op`) if you use template secrets (`onepasswordRead`)
  - If `op` is installed on macOS, run `op signin` before `chezmoi apply` (`dot_config/git/config.tmpl` requires `op whoami`)
- `prek` only if you want to run pre-commit hooks (`.pre-commit-config.yaml`)

## Quick start

Initialize from the repo:

```sh
chezmoi init --apply https://github.com/lazysf/dotfiles.git
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
