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

## Shell policy

- Use the macOS default `/bin/zsh` as the login shell
- Use Homebrew to provide shell-related tools and plugins such as `starship`, `fzf`, and `mise`
- Do not require Homebrew's `zsh` package for this dotfiles setup
- Initialize `mise` in `~/.zprofile` with `mise activate zsh --shims` so tools installed via `mise` are available from non-interactive shell entry points
- Initialize `mise` again in `~/.zshrc` with `mise activate zsh` because day-to-day work usually runs through interactive shells

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

## Codex 運用

`dot_codex/` では、Codex 用の設定、ルール、スキルを管理しています。

### Main files

- `dot_codex/AGENTS.md`
  - 運用全体の基準。判断原則、既定フロー、確認必須境界、検証と報告、Git 方針、スキル選択ルールを定義します。
- `dot_codex/HIGH_QUALITY_VIBE_CODING.md`
  - 高品質なバイブコーディングの手引き。依頼テンプレート、レーン別の進め方、良い依頼例、終了時チェックをまとめます。
- `dot_codex/private_config.toml.tmpl`
  - Codex の設定テンプレート。現在の既定値は `gpt-5.4`、`high`、`on-request`、`workspace-write`、`web_search=live`、`multi_agent=true`、`max_depth=1` です。
- `dot_codex/rules/`
  - 実行ガードレール。`git diff/status/log` やパス限定 `git add` などの許可、`git push` や `rm` などの要確認、`git push --force` と `grep` の禁止を管理します。
- `dot_codex/skills/`
  - 再利用可能な作業単位を管理します。コア導線と状況別スキルに分けて使います。

### Default flow

通常は次の順で、必要な段階だけ進めます。

1. `task-intake`
2. `workspace-intake`
3. 必要なら `plan-product`
4. 必要なら `plan-architect`
5. `coding-standards`
6. 必要なら `test-runner`
7. 必要なら `change-review`
8. 必要なら `commit-message`
9. 必要なら `git-commit`
10. 必要なら `git-push`

依頼が散らばっている場合は、入口で `request-shaping` を使ってから既定フローへ入ります。長めの変更では、`plan-product` のあとに `session-orchestrator` または `plan-architect` を使って進め方を固めます。

### Core skills

- `request-shaping`
  - 散らばった依頼を実装ブリーフへ整える
- `task-intake`
  - 曖昧依頼の軽い入口整理
- `workspace-intake`
  - 既存規約、関連ファイル、近傍実装、テスト入口の探索
- `plan-product`
  - 目的、成功条件、非目的、制約の整理
- `session-orchestrator`
  - 長めの作業で、探索、要件整理、実装、検証、レビューの切り替え条件を整理
- `plan-architect`
  - 実装順序、影響範囲、検証方法の整理
- `coding-standards`
  - 最小差分、既存準拠、境界重視の実装
- `test-runner`
  - テスト範囲決定、実行、結果整理
- `change-review`
  - 変更後の自己レビューと review agent 利用判断
- `commit-message`
  - コミットメッセージの作成と推敲
- `git-commit`
  - 限定 staging と非対話 commit 実行

### Git skill split

- `commit-message`
  - メッセージ作成専用
- `git-commit`
  - staging と commit 実行専用
- `git-push`
  - push 専用

### Situational skills

状況に応じて `debug-fix`、`refactor-safely`、`git-push`、`docs-update` を使います。運用の具体例は `dot_codex/HIGH_QUALITY_VIBE_CODING.md` を参照してください。

- `debug-fix`
  - 症状再現、原因切り分け、最小修正が必要なときに使います。
- `refactor-safely`
  - 既存挙動維持のまま段階的に整理したいときに使います。
- `git-push`
  - コミット後に明示依頼があったときだけ使います。
- `docs-update`
  - 仕様・実装・運用文書を同期したいときに使います。
