# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理する dotfiles リポジトリです。

この README では、セットアップ、更新、整形・lint・検証の入口と、repo-level knowledge の参照先だけをまとめています。

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

`op` が使える環境では、先に `op signin` してから実行:

```sh
op signin
chezmoi apply
```

適用前に差分を確認:

```sh
chezmoi diff
```

## macOS Terminal プロファイル

macOS 標準 `Terminal` 用のプロファイルは repo 内の [`dot_config/terminal/Main.terminal`](dot_config/terminal/Main.terminal) で管理しています。
このファイルは macOS では `chezmoi apply` の展開対象にし、非 macOS では `.chezmoiignore` により配布対象から外しています。

利用するときは、repo 内の `dot_config/terminal/Main.terminal` を Finder か `open` で開いて `Terminal` に import し、必要なら `Main` をデフォルトプロファイルに設定してください。

## Python 実行

repo 保守用の Python 実行環境は `uv` で管理します。
初回セットアップまたは依存更新後は、次を実行します。

```sh
uv sync
```

## 管理対象と配布対象

`.chezmoiignore` は、chezmoi で home directory へ配布しない repo 保守用ファイルを定義します。
`docs/`、`README.md`、root `AGENTS.md` / `CLAUDE.md`、`CONTEXT-MAP.md`、CONTEXT 系ファイル、`.tombi.toml`、`pyproject.toml`、`uv.lock` などは repo 保守専用のため配布対象外です。
`dot_codex/CONTEXT.md` と `dot_codex/private_config.toml.tmpl` の展開先になる `.codex/CONTEXT.md` / `.codex/config.toml` も、現在は配布対象外です。
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
