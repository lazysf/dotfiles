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

この repo で `dot_codex/` をどう設計・保守するかの判断履歴は [docs/adr/](./docs/adr/) に置きます。展開後に Codex が日常参照する運用文書は `dot_codex/` 側に集約します。

### Main files

- `dot_codex/AGENTS.md`
  - 共通運用契約。停止線、報告方針、Git 方針、スキル導線を定義します。
- `dot_codex/QUICKSTART.md`
  - 日常の入口として、依頼レーンの選び方と shorthand をまとめた索引です。正式なフローは `dot_codex/AGENTS.md` を参照します。
- `dot_codex/HIGH_QUALITY_VIBE_CODING.md`
  - 高品質なバイブコーディングの考え方と良い依頼例をまとめた実務ガイドです。
- `dot_codex/docs/`
  - 展開後にも参照する共通 docs です。ハーネス構成、project との連携、検証手順、rules の考え方を整理します。
- `dot_codex/private_config.toml.tmpl`
  - Codex の設定テンプレート。主要な既定値は `gpt-5.4`、`high`、`on-request`、`workspace-write`、`web_search=live`、`multi_agent=true`、`codex_hooks=false`、`max_depth=1` です。`chezmoi apply` 時に `chezmoi` テンプレート内で既存の `~/.codex/config.toml` を読み、`projects` を preserve しつつ、repo 管理の allowlist に含めた `plugins` / `marketplaces` だけを OpenAI の sample config に寄せた順序で最終設定へ出力します。
- `dot_codex/rules/`
  - 実行ガードレール。`git diff/status/log`、パス限定 `git add`、`mise run test/lint/format` などの許可、`git push`、`rm`、`sudo`、高リスクな Git 操作、依存追加系コマンドなどの要確認、`git push --force*` と `grep` の禁止を管理します。
- 既知制約として、current `prefix_rule` DSL では raw `git commit` / `git push` の後置フラグを厳密に拒否できません。`--amend`、`--no-verify`、force push は skills と運用方針で扱い、rules 側で suffix 形まで完全には強制していません。
- `dot_codex/agents/`
  - 専門化した subagent 定義を管理します。レビュー本体は `review-quality` / `review-security` agent を優先して使います。
- `dot_codex/skills/`
  - 再利用可能な作業単位を管理します。コア導線と状況別スキルに分けて使います。

### Config merge behavior

- `~/.codex/config.toml` は、dotfiles 側で管理する静的既定値と、Codex がランタイムに追記する状態が混在するファイルです。
- `chezmoi apply` では `dot_codex/private_config.toml.tmpl` が現在の `~/.codex/config.toml` を読み、`projects` を preserve したうえで最終ファイルを再生成します。
- `plugins` / `marketplaces` はローカル既存値をそのまま引き継がず、repo 管理の allowlist に含めたものだけを出力します。
- allowlist が空の間は `plugins` / `marketplaces` セクションを出力しません。
- 出力順は OpenAI の sample config の相対順に寄せます。
- `projects` は既存エントリを残しつつ、同一 path に対してテンプレートが明示する key を優先します。
- Windows でも Codex の既定 sandbox は `workspace-write` を使い、OS ごとの権限昇格設定は追加しません。
- Codex が今後ほかの自動管理テーブルを追加した場合は、必要に応じて repo 管理 allowlist の対象を増やします。

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

依頼が散らばっている場合は、入口で `request-shaping` を使い、その後 `task-intake` を経て既定フローへ入ります。長めの変更では、`plan-product` のあとに `session-orchestrator` または `plan-architect` を使って進め方を固めます。
Codex 環境自体を点検したい場合は、入口に `environment-audit` を置いてから通常の整理へ進みます。
品質レビューが必要な場合は `review-quality` agent、セキュリティレビューが必要な場合は `review-security` agent を使います。結果を人間向けに整理するときは `change-review` を使います。

### Project-local knowledge

- 共通ハーネスの正本は `dot_codex/`
- project-specific knowledge の正本は各プロジェクトの `docs/`
- 各プロジェクトのルート `AGENTS.md` は短いポインタとして、`./docs/` を参照させる運用を推奨します
- `.codex/` は knowledge の標準置き場としては採用しません

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
  - 長めの作業で、探索、要件整理、実装、検証、レビューの切り替え条件と checkpoint を整理
- `plan-architect`
  - 実装順序、影響範囲、検証方法の整理
- `coding-standards`
  - 最小差分、既存準拠、境界重視の実装
- `test-runner`
  - テスト範囲決定、実行、結果整理
- `change-review`
  - 変更後の自己レビュー、または review agent の結果を findings / 未検証 / 残リスクへ整理
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

状況に応じて `environment-audit`、`debug-fix`、`refactor-safely`、`git-push`、`docs-update` を使います。日常の入口は `dot_codex/QUICKSTART.md`、運用の具体例は `dot_codex/HIGH_QUALITY_VIBE_CODING.md` を参照してください。

### Review agents

- `review-quality`
  - 品質レビュー本体を担当します。可読性、責務、命名、例外処理、仕様不整合、回帰リスクを確認します。
- `review-security`
  - セキュリティレビュー本体を担当します。入力検証、認証認可、注入、秘密情報、外部 I/O、危険なデフォルトを確認します。
- `change-review`
  - specialized review の代替ではなく、review の出口整理に使います。

- `environment-audit`
  - Codex の config、文書、rules、skills、agents の整合性確認と改善候補整理に使います。
- `debug-fix`
  - 症状再現、原因切り分け、最小修正が必要なときに使います。
- `refactor-safely`
  - 既存挙動維持のまま段階的に整理したいときに使います。
- `git-push`
  - コミット後に明示依頼があったときだけ使います。
- `docs-update`
  - 仕様・実装・運用文書を同期したいときに使います。
