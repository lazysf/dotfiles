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

winget が無い場合は、先に <https://aka.ms/getwinget> から App Installer を入れます。シェルは Windows PowerShell（`powershell`）を使います。プロファイルを読めるよう、スクリプトは現在のユーザーの実行ポリシーが未設定なら RemoteSigned にします。

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

git の identity は `~/.config/git/config.local` に書きます。1Password と Zotero と Parsec は入りません。

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
- macOS の Parsec のクライアント設定（`personal`）: Parsec が設定と同じファイルに状態値を書き込むため、`~/.parsec/config.json` は配布しません。Parsec の Settings で Window Mode を Windowed、Immersive Mode を Keyboard、Swap Command and Ctrl for MacOS を Off にします。
- Windows の VB-CABLE（`personal`）: winget に無いため、<https://vb-audio.com/Cable/> から Driver Pack の zip を取得し、展開した `VBCABLE_Setup_x64.exe` を管理者として実行します。導入後に再起動します。未導入ならセットアップスクリプトが手順を表示し、このページを開きます。
- Windows の Parsec の仮想ディスプレイ（`personal`）: ドライバ（`Parsec.ParsecVDD`）はセットアップスクリプトが入れます。物理ディスプレイが無い時に仮想ディスプレイを使うには、Parsec の Settings > Host で Fallback To Virtual Display をオンにします。無料プランで使えるのはこの 1 枚だけです。
- Windows の Parsec のバーチャルマウス（`personal`）: ドライバ（`Parsec.ParsecVUD`）はセットアップスクリプトが入れます。物理マウスが無いと Windows がカーソルを消すので、Parsec の Settings > Host で Virtual Mouse をオンにします。

## mole の週次チェック (macOS)

毎週月曜 12:00 に `mo clean --dry-run` を実行し、解放できる容量を通知します。通知の「クリーンアップ」ボタンで `mo clean` を実行できます。離席中はキーボードかマウスの操作が戻るまで待ってから実行し、18 時まで操作が無ければその週は通知しません。

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
