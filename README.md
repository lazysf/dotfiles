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

## 整形と lint

repo 内の整形と lint は `mise` task 経由で実行します。
Markdown を含む対象ファイルをまとめて処理するには、次を使います。

```sh
mise run format
mise run lint
mise run test
```

## Python 実行

repo 保守用の Python 実行環境は `uv` で管理します。
初回セットアップまたは依存更新後は、次を実行します。

```sh
uv sync
```

手動でハーネス検証を実行するときは、repo 直下の仮想環境を使うため `uv run python ...` を使います。

```sh
uv run python scripts/verify-codex-harness.py
```

通常の確認入口は引き続き `mise run test` です。
`.python-version`、`pyproject.toml`、`uv.lock`、`.venv/` は repo 保守専用のため、`.chezmoiignore` により dotfiles の配布対象から外しています。

## Repo-Level Knowledge

この repo を保守するときの知見は `docs/` に置きます。

- `docs/knowledge/`: repo-level の通常知見
- `docs/adr/`: 今も有効な判断記録

共通ハーネスの deployable artifact は `dot_codex/` に置き、運用契約と導線は `dot_codex/AGENTS.md` を参照します。
