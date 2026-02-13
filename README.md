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

If your source state is tracked by chezmoi and you want to pull latest changes:

```sh
chezmoi update
```

If this repo is already your local chezmoi source directory and you updated it manually:

```sh
chezmoi apply
```

Preview changes before applying:

```sh
chezmoi diff
```
