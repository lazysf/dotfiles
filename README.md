# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理する dotfiles リポジトリです。

## セットアップ

初回セットアップ:

```sh
chezmoi init --apply https://github.com/lazysf/dotfiles.git
```

OS / 用途別のセットアップスクリプトを `scripts/` 配下に置いています（chezmoi の配布対象外）。

```text
scripts/
├─ macos/setup.sh
├─ windows_personal/setup.ps1
└─ windows_work/setup.ps1
```

各スクリプトは Homebrew / winget を未導入なら入れたうえで、用途別の `install_*_stack` (macOS) / `Install-*Stack` (Windows) ブロックを順に実行します。ブロック構成・除外したパッケージの理由はスクリプト内コメントを参照してください。

### macOS

```sh
scripts/macos/setup.sh
```

### Windows

```powershell
scripts/windows_personal/setup.ps1   # 個人用
scripts/windows_work/setup.ps1       # 仕事用
```

仕事用は個人用と構造を共有し、次のブロックを落としています:

- パスワード管理 (`AgileBits.1Password` 系): 会社管理ツール想定
- 研究 (`DigitalScholar.Zotero`): 不要

winget が無ければ <https://aka.ms/getwinget> で App Installer を導入。新規 Windows の既定実行ポリシー (`Restricted`) で `.ps1` が弾かれる場合は以下:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
scripts/windows_personal/setup.ps1
# または
pwsh -ExecutionPolicy Bypass -File scripts/windows_personal/setup.ps1
```

## 更新

リモートの変更を取り込んで適用:

```sh
chezmoi update
```

ローカル source directory として手動で更新した内容を適用:

```sh
op signin  # `op` が使える環境では先に
chezmoi apply
```

適用前に差分を確認するなら `chezmoi diff`。

## macOS Terminal プロファイル

[`dot_config/terminal/Main.terminal`](dot_config/terminal/Main.terminal) は macOS では `chezmoi apply` で配布されますが、`Terminal` への import は手動です。

## Python / Markdown lint

repo 保守用 Python は `uv` で管理 (`uv sync`)。
Markdown は `markdownlint-cli2` で lint:

```sh
npm install    # 初回。package-lock.json も commit 済み
npm run lint
npm run lint:fix
```

設定は [`.markdownlint-cli2.jsonc`](.markdownlint-cli2.jsonc) に集約。[`.pre-commit-config.yaml`](.pre-commit-config.yaml) にも hook 登録済みで、commit 時に staged Markdown を自動 lint / fix します。

## 管理対象と配布対象

`.chezmoiignore` で chezmoi が home directory へ配布しない repo 保守用ファイルを定義しています (`docs/`、`scripts/`、`README.md`、`pyproject.toml`、`package.json`、`uv.lock` など)。
`.gitignore` で Git 管理しないローカル生成物を定義しています (`.cache/`、`.venv/`、`node_modules/` など)。

## Repo-Level Knowledge

- [`docs/notes/`](docs/notes/): repo-level の通常知見
- [`docs/adr/`](docs/adr/): `Accepted` / `Superseded` を含む状態付き判断台帳

共通ハーネスの source は `dot_codex/` と `dot_claude/` に置きます。root `CLAUDE.md` は Claude Code 向けの repo-local import shim で root `AGENTS.md` を参照します。
