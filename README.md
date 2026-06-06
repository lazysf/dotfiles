# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理する dotfiles リポジトリです。

この README では、セットアップ・更新・配布対象・repo-level knowledge の入口だけをまとめています。

## セットアップ

初回セットアップ:

```sh
chezmoi init --apply https://github.com/lazysf/dotfiles.git
```

## 更新

リモートの変更を取り込んで適用:

```sh
chezmoi update
```

この repo がローカルの source directory で、手動で更新した内容を適用:

```sh
op signin  # `op` が使える環境では先に実行
chezmoi apply
```

適用前に差分を確認するなら `chezmoi diff`。

## macOS Terminal プロファイル

[`dot_config/terminal/Main.terminal`](dot_config/terminal/Main.terminal) は macOS では `chezmoi apply` で配布、`Terminal` への import は手動です（非 macOS では配布対象外）。

## Python 実行

repo 保守用 Python は `uv` で管理します。初回セットアップまたは依存更新後は `uv sync` を実行します。

## 管理対象と配布対象

`.chezmoiignore` は、chezmoi で home directory へ配布しない repo 保守用ファイルを定義します。
`docs/`、`README.md`、root `AGENTS.md` / `CLAUDE.md`、`.tombi.toml`、`pyproject.toml`、`uv.lock` などは repo 保守専用のため配布対象外です。
`dot_codex/private_config.toml.tmpl` の展開先になる `.codex/config.toml` も、現在は配布対象外です。
`dot_config/terminal/Main.terminal` は macOS では展開対象、非 macOS では配布対象外です。

`.gitignore` は、この repo で Git 管理しないローカル生成物を定義します。
`.cache/`、`.venv/`、`nvim.log` などは Git 管理対象外です。

## Repo-Level Knowledge

この repo を保守するときの知見は `docs/` に置きます。

- `docs/notes/`: repo-level の通常知見
- `docs/adr/`: `Accepted` や `Superseded` を含む状態付き判断台帳

共通ハーネスの source は `dot_codex/` と `dot_claude/` に置きます。
root `CLAUDE.md` は Claude Code 向けの repo-local import shim で、root `AGENTS.md` を参照します。

現在 chezmoi の管理対象になる Codex surface は `~/.codex/AGENTS.md`、`~/.codex/skills/`、`~/.codex/agents/`、`~/.codex/rules/` です。
Claude Code surface は `~/.claude/CLAUDE.md`、`~/.claude/skills/`、`~/.claude/agents/`、`~/.claude/rules/`、`~/.claude/output-styles/`、`~/.claude/settings.json` です。
