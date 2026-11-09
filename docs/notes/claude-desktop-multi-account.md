# Claude Desktop で 2 つ目のアカウントを使う構成

- Date: 2026-11-07
- 出典: [anthropics/claude-code #30565](https://github.com/anthropics/claude-code/issues/30565) / `scripts/windows/setup.ps1` の `New-ClaudeAccountShortcut` / `scripts/macos/setup.sh` の `create_claude_account_app`

## 現在の構成

Claude Desktop はアカウントを 1 つしか保持しない。切り替えるには、ログアウトして別のアカウントでログインし直す必要がある。
Desktop にしか無い機能（ファイルのドラッグ&ドロップ、Code タブ）を両方のアカウントで使うため、2 つ目のアカウントは Electron の `--user-data-dir` で別のデータフォルダを指定して起動する。
1 つ目のアカウントは、通常の Claude をそのまま使う。

setup スクリプトが、Claude を入れた直後に `Claude-2nd` という名前のショートカットを作る。

- Windows: ユーザーのスタートメニューに `Claude-2nd.lnk` を作る。データフォルダは `%APPDATA%\Claude-2nd`。
- macOS: `~/Applications/Claude-2nd.app` を `osacompile` の applet として作る。データフォルダは `~/Library/Application Support/Claude-2nd`。アイコンは作成時に `/Applications/Claude.app` からコピーするため、Claude の更新でアイコンが変わっても setup を再実行するまで追従しない。

どちらの置き場も Raycast が拾う。setup スクリプトが変わると `run_onchange_after_install-packages.*.tmpl` が再実行するので、専用の run_ スクリプトは置かない。
名前を変えたり外したりしても、setup は古いショートカットとデータフォルダを消さない。手で消す。

## Windows で確認した事実

2026-11-01 に、Squirrel 版（`%LOCALAPPDATA%\AnthropicClaude`）で確認した。

- 版ごとのフォルダではなく、直下のスタブ `claude.exe` に `--user-data-dir` を渡すと、ログイン画面の別ウィンドウが開く。通常の Claude と同時に起動できる。
- `~/.claude/` に `.credentials.json` は無い。Code タブの認証は Desktop のログインから来ていると考えられる。このため、`~/.claude/` を共有してもログインは混ざらない見込み。
- 2 つ目のインスタンスの Code タブのセッションには、そのインスタンスのアカウントと org が環境変数（`CLAUDE_CODE_ACCOUNT_UUID`、`CLAUDE_CODE_ORGANIZATION_UUID`）で渡される。実行ファイルも `%APPDATA%\Claude-2nd\claude-code\` の下にあるものが使われる。
- そのセッションの実行中も、`~/.claude.json` の `oauthAccount` は 1 つ目のアカウントのままだった。2 つ目のインスタンスを起動した後にも `~/.claude.json` は書き込まれていたが、`oauthAccount` は上書きされていない。2 つ目のセッションは、このずれがあっても問題なく動いた。
- `modelAccessCache` は空、`orgModelDefaultCache` は `null` だった。中身が無いため、アカウント間でずれる値も無い。

## macOS で確認した事実

2026-11-07 に、個人の Mac での確認結果をユーザーから受け取った。

- `scripts/macos/setup.sh` の実行で `~/Applications/Claude-2nd.app` が生成された。
- 通常の Claude を開いた状態で、Raycast と Spotlight のどちらから `Claude-2nd` を起動しても、別ウィンドウにログイン画面が開いた。
- 別ウィンドウで 2 つ目のアカウントにログインできた。ファイルのドラッグ&ドロップと Code タブも動作した。

## 共有されるもの

`--user-data-dir` で分かれるのは Desktop のデータフォルダだけ。home 直下の `~/.claude/` と `~/.claude.json` は、両方のインスタンスが同じものを読む。
dotfiles で配る `CLAUDE.md`、`settings.json`、hooks、skills、mods を両方のアカウントで使えるのは、この共有による。

一方で、アカウントに依存する状態も共有される。

- `~/.claude.json` は `oauthAccount`、`modelAccessCache`、`orgModelDefaultCache` を持つ。Code タブはアカウントを環境変数で受け取るため、Windows ではこれらの共有による実害は出ていない。ターミナルから直接起動する `claude` は環境変数を受け取らないため、影響を受けうる。こちらは確かめていない。
- `~/.claude/projects/` の Code タブの履歴は、両方のアカウントの分が混ざる。

これで実害が出たら、2 つ目のインスタンスの状態を別フォルダへ分け、dotfiles で配るファイルだけをリンクで共有する構成を検討する。

## 未確認

- 2 つ目のアカウントの org がモデルの既定値を持つ場合に、`orgModelDefaultCache` を通じて 1 つ目に影響するか。今回は値が `null` だったため確かめられていない。
