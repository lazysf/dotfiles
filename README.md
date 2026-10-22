# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理する dotfiles リポジトリです。

## セットアップ

セットアップスクリプトでパッケージを入れてから、chezmoi で dotfiles を展開します。スクリプトは machine profile（`personal` か `work`）を聞きます。`personal` では 1Password を入れ、サインインと CLI 連携、SSH agent の設定が済むまで待ちます。

### macOS（Apple Silicon）

Intel の mac は対象外です。

セットアップスクリプトを取得する:

```sh
curl -fsSLo setup.sh https://raw.githubusercontent.com/lazysf/dotfiles/main/scripts/macos/setup.sh
```

実行して、終わったら削除する:

```sh
bash setup.sh; rm setup.sh
```

Homebrew を、このターミナルの PATH に通す:

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
```

dotfiles を展開する:

```sh
chezmoi init --apply lazysf
```

### Windows

winget が無い場合は、先に <https://aka.ms/getwinget> から App Installer を入れます。

セットアップスクリプトを取得する:

```powershell
irm https://raw.githubusercontent.com/lazysf/dotfiles/main/scripts/windows/setup.ps1 -OutFile setup.ps1
```

実行して、終わったら削除する:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1; Remove-Item .\setup.ps1
```

新しいターミナルを開き、dotfiles を展開する:

```powershell
chezmoi init --apply lazysf
```

### work のマシン

git の identity は `~/.config/git/config.local` に書きます。1Password、Zotero、Raycast（Windows）は入りません。

### セットアップスクリプト

選んだ profile は chezmoi の設定ファイル（`~/.config/chezmoi/chezmoi.toml`）に保存され、`chezmoi init` やスクリプトの再実行では聞かれません。引数（`personal` / `work`）でも渡せます。スクリプトが変わると、次の `chezmoi apply` で、そのマシンの profile で実行し直されます。

## 更新

リモートの変更を取り込んで適用する:

```sh
chezmoi update
```

適用前に差分を見る:

```sh
chezmoi diff
```

手元で変えた source を適用する:

```sh
chezmoi apply
```

## 手作業が要るもの

- macOS の Terminal プロファイル: [`dot_config/terminal/Main.terminal`](dot_config/terminal/Main.terminal) は配布されますが、Terminal への import は手で行います。

## mole の週次チェック (macOS)

毎週月曜 9:00 に `mo clean --dry-run` を実行し、解放できる容量を通知します。通知の「クリーンアップ」ボタンで `mo clean` を実行できます。

すぐ実行する:

```sh
launchctl kickstart -k "gui/$(id -u)/local.mole.weekly-check"
```

止める:

```sh
launchctl bootout "gui/$(id -u)/local.mole.weekly-check"
```

ログは `~/Library/Logs/mole/` にあります。

## 構成

- [`dot_claude/`](dot_claude/): `~/.claude/` へ配布する Claude Code の設定、skills、agents、mod。
- [`dot_codex/`](dot_codex/): `~/.codex/` へ配布する Codex の設定。`config.toml` は配布しません。
- [`scripts/`](scripts/): セットアップスクリプト。chezmoi は配布しません。
- [`docs/`](docs/): 設計の理由（notes）と判断の記録（ADR）。一覧は [`docs/README.md`](docs/README.md)。

## 開発

commit 時に lint などの hook を走らせる:

```sh
prek install
```

手で Markdown を lint する時は、先に入れてから `npm run lint` / `npm run lint:fix` を使う:

```sh
npm install
```

repo の保守用 Python を用意する:

```sh
uv sync
```
