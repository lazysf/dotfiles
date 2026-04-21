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

## Repo-Level Knowledge

この repo を保守するときの知見は `docs/` に置きます。

- `docs/knowledge/`: repo-level の通常知見
- `docs/adr/`: 今も有効な判断記録

共通ハーネスの deployable artifact は `dot_codex/` に置き、運用契約と導線は `dot_codex/AGENTS.md` を参照します。
