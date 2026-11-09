# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理する dotfiles リポジトリです。

## セットアップ

セットアップスクリプトでパッケージを入れてから、chezmoi で dotfiles を展開します。スクリプトは machine profile（`personal` か `work`）を聞きます。`personal` では 1Password を入れ、サインインと CLI 連携、SSH agent の設定が済むまで待ちます。Claude Code のエージェントが commit の署名に使う鍵（`~/.ssh/agent_signing_ed25519`）も作ります。

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

winget が無い場合は、先に <https://aka.ms/getwinget> から App Installer を入れます。シェルは Windows PowerShell（`powershell`）を使います。PowerShell 7（`pwsh`）も並べて入れ、同じプロファイルを配ります。`pwsh` から `winget upgrade` すると使用中の `pwsh` を更新できないため、更新は `powershell` から実行し、開いている `pwsh` は閉じておきます。プロファイルを読めるよう、スクリプトは現在のユーザーの実行ポリシーが未設定なら RemoteSigned にします。

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

macOS の `personal` では、`chezmoi apply` が Codex の署名設定を追加します。初回は Codex CLI の `/hooks` で署名用の hook を確認して信頼します。[Codex の署名設定と動作確認](docs/notes/codex-harness-operation.md#macos-のエージェント用署名) を参照してください。

- macOS の Terminal プロファイル: [`dot_config/terminal/Main.terminal`](dot_config/terminal/Main.terminal) は配布されますが、Terminal への import は手で行います。
- エージェント用の署名鍵の GitHub への登録（`personal`）は、作業機で新しい鍵を使い始めるときに行います。GitHub 上でエージェントの commit を Verified にするために必要です。

  新しい鍵の fingerprint は生成時の表示を控え、登録前に次のコマンドの結果と照合します。Windows ではコマンドを Git Bash で実行します。

  ```sh
  ssh-keygen -E sha256 -lf ~/.ssh/agent_signing_ed25519.pub
  ```

  ブラウザでは、意図したアカウントの Settings > SSH and GPG keys > New SSH key を開きます。Key type を Signing Key にして `~/.ssh/agent_signing_ed25519.pub` を登録します。

  CLI で登録する場合、未ログインなら `gh auth login --hostname github.com --skip-ssh-key` を実行します。`--skip-ssh-key` はログイン時の認証鍵のアップロードをスキップする指定です。mac では `--insecure-storage` も付けます。token が Keychain ではなく `~/.config/gh/hosts.yml` に置かれ、Claude Code の sandbox から届かなくなります（[理由](docs/notes/claude-code-settings-design.md#push-は-sandbox-内で-ssh-を通らない)）。次の出力が意図した登録先アカウントであることを確認します。[GitHub CLI のログイン手順](https://cli.github.com/manual/gh_auth_login)

  ```sh
  gh api --hostname github.com user --jq .login
  ```

  GitHub CLI の OAuth 認証には `write:ssh_signing_key` scope が必要です。権限が足りない場合はブラウザで登録できます。CLI で続ける場合は、意図したアカウントで `gh auth refresh --hostname github.com --scopes write:ssh_signing_key` を実行し、登録先アカウントを再確認します。[GitHub の署名鍵 API](https://docs.github.com/en/rest/users/ssh-signing-keys#create-a-ssh-signing-key-for-the-authenticated-user) / [GitHub CLI の権限更新](https://cli.github.com/manual/gh_auth_refresh)

  fingerprint と登録先を照合できたら、次のコマンドで登録します。

  ```sh
  GH_HOST=github.com gh ssh-key add ~/.ssh/agent_signing_ed25519.pub --type signing
  ```

  `gh auth refresh` で `write:ssh_signing_key` scope を足した場合は、登録が済んだら次のコマンドで外します。残すと、同じユーザーとして動くプロセスが、その token で署名鍵を追加できます。

  ```sh
  gh auth refresh --hostname github.com --remove-scopes write:ssh_signing_key
  ```

  登録後は、次の SSH 接続が `Permission denied (publickey)` で失敗することを確認します。認証に成功した場合は、GitHub からこの鍵の Authentication Key 登録を削除します。

  ```sh
  ssh -T -o IdentitiesOnly=yes -o IdentityAgent=none -i ~/.ssh/agent_signing_ed25519 git@github.com
  ```

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

- [`dot_claude/`](dot_claude/): `~/.claude/` へ配布する Claude Code の設定、hook、skills、mod。
- [`dot_codex/`](dot_codex/): `~/.codex/` へ配布する Codex の設定。`config.toml` は配布しません。
- [`scripts/`](scripts/): セットアップスクリプトと、commit 時の hook が呼ぶスクリプト。chezmoi は配布しません。
- [`docs/`](docs/): 設計の理由（notes）と判断の記録（ADR）。一覧は [`docs/README.md`](docs/README.md)。

## 開発

commit 時に lint、作業機の識別子（home の絶対パス、ユーザー名、ホスト名）の検査、commit message の title が `<type>: <description>` の形かの検査を走らせる。commit-msg の hook を足す前に入れた clone でも、もう一度打つ:

```sh
prek install
```

手で lint する時は、先に入れてから使う。Markdown は `npm run lint` / `npm run lint:fix`、TOML は `npm run lint:toml` / `npm run lint:toml:fix`:

```sh
npm install
```

repo の保守用 Python を用意する:

```sh
uv sync
```
