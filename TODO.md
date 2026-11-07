# 残タスク

- Date: 2026-11-02

このファイルは、着手を保留している項目の一覧。

`CLAUDE.md` は「1 つの作業（着手から commit まで）で扱うスコープは 1 つに保つ。作業中に別の問題へ気づいたら、その場で着手せずユーザーへ伝える。今のスコープを閉じてから扱う」と定めている。**逸れた分の行き先がここ。** ある作業の途中で見つかった別スコープの問題を、その場で直さずに移し、今のスコープを閉じてから改めて扱う。

各項目に記載日と、どの作業中に見つけたかを書く。どの文脈で浮上したかが分かると、再開時に前提を取り直せる。

判断の記録は `docs/adr/`、設計の理由は `docs/notes/` を正本とし、ここには重複させない。

---

## 1. Windows の Codex のエージェント用署名

- 記載: 2026-11-07（Windows の `personal` にエージェント用署名鍵を入れた時）

Windows では Claude Code だけがエージェント用の鍵で署名する。

- Codex の署名設定を入れる `scripts/macos/configure-codex-signing.py` と `run_after_zz-configure-codex-signing.sh.tmpl` は macOS 専用で、zsh のログインシェルを前提にしている。Windows の Codex で同じ鍵を使うなら、Codex の Windows の sandbox と hook の shell を公式情報で確かめてから設計する。
- `dot_codex/rules/destructive.rules` の disk 系の command は macOS のものだけで、2026-11-07 に Claude Code の `permissions.deny` へ足した Windows の command（`diskpart`、`format.com`、`convert.exe`、`wbadmin`）は入っていない。Codex の Windows の sandbox を確かめる時に、揃えるかも判断する。

---

## 2. Windows 実機での動作確認

- 記載: 2026-10-22（machine profile の導入、セットアップスクリプトの統合、`chezmoi apply` からのセットアップ実行）

2026-10-22 に、セットアップ済みの個人の Windows で、状態の読み取りと画面の目視で確かめられる項目は確認した。次の項目は、setup の対話実行か新しいマシンが要るので残っている。

個人の Windows で確かめること。

- `scripts/windows/setup.ps1 personal` の日本語の出力が化けない。先頭に UTF-8 の BOM を付けてある。
- 引数なしで実行すると、`PromptForChoice` で profile の選択肢が出る。
- 1Password が未設定の時は、Developer の設定画面が開いて待つ。設定すると Enter で先へ進む。`Update-SessionPath` で、winget で入れた `op` が見つかる。設定済みなら待たずに進む。
- `chezmoi init --apply lazysf` で profile を聞かれない。
- 新しいマシンの `chezmoi init --apply` で、`run_onchange_after_install-yazi-plugins.cmd` が plugin を `%USERPROFILE%\.config\yazi\plugins` に入れる。
- Parsec が per computer（`%ProgramFiles%\Parsec`）で入る。管理者でない PowerShell から実行した時に UAC が出て先へ進む。導入後の再実行で `Parsec.Parsec (skip)` になる。VB-CABLE が未導入なら手順が出て公式ページが開き、導入後は `VB-CABLE (skip)` になる。（2026-11-02 追加）
- Parsec の host settings で Fallback To Virtual Display をオンにでき、物理ディスプレイが無い状態で接続すると仮想ディスプレイが出る。`Parsec.ParsecVDD` が `-Scope` 無しの winget で入り、Parsec Virtual Display Adapter が出ることは 2026-11-02 に確認した。（2026-11-02 追加）
- Parsec の host settings で Virtual Mouse をオンにでき、物理マウスが無い状態で接続してもカーソルが出る。`Parsec.ParsecVUD` が `-Scope` 無しの winget で入り、Parsec Virtual USB Adapter が出ることは 2026-11-02 に確認した。（2026-11-02 追加）
- `powershell` から `winget upgrade Microsoft.PowerShell` で PowerShell 7 を更新できる。次の版が出るまで確かめられない。`chezmoi apply` で 7.6.9 の MSIX 版が入り、`pwsh` で profile が読まれて starship と `ls`（eza）が効くことは 2026-11-03 に確認した。（2026-11-03 追加）

仕事の Windows では、`work` を選んだ時に 1Password と Zotero と Parsec が入らず、git の identity と署名の設定が出ないことを確かめる。

---

## 3. mac で 1Password が未設定の時の待機

- 記載: 2026-10-22（setup で 1Password の設定を待つようにした時）

この mac は 1Password を設定済みなので、`scripts/macos/setup.sh` の `wait_for_onepassword` は「設定済み」の経路しか通していない。未設定の経路は、関数だけを取り出し、`op` を偽物にして試した範囲に留まる。

新しい mac、または 1Password の CLI 連携と SSH agent を切った状態で確かめること。

- Developer の設定画面（`onepassword://settings/developers`）が開き、やることの一覧と、未設定の項目が出る。
- 設定する前に Enter を押すと、まだ未設定の項目を出して待ち続ける。
- 両方を設定して Enter を押すと、「1Password は設定済みです」と出て先へ進む。

---

## 4. mac で Claude Desktop の 2 つ目のアカウント

- 記載: 2026-11-01（Claude Desktop の 2 つ目のアカウント用ショートカットを setup に足した時）

Windows では、`--user-data-dir` で別のインスタンスが開くことを確認した。mac の `create_claude_account_app` は実機で動かしていない。構成の理由は `docs/notes/claude-desktop-multi-account.md` にある。

mac で確かめること。

- `scripts/macos/setup.sh` を実行すると、`~/Applications/Claude-2nd.app` ができる。
- Raycast と Spotlight から `Claude-2nd` を起動すると、起動中の Claude を前面に出すのではなく、ログイン画面の別ウィンドウが開く。
- 2 つ目のウィンドウで、ファイルのドラッグ&ドロップと Code タブが動く。

---

## 5. エージェント用署名鍵の GitHub 登録の自動化

- 記載: 2026-11-06（エージェント用署名鍵の生成を `scripts/macos/setup.sh` に入れた時）

鍵の生成は setup.sh と `scripts/windows/setup.ps1` で自動化したが、GitHub への Signing Key の登録は README の手作業のまま。どちらも `chezmoi init` より前に走り、その時点では `gh` が認証されていないので、スクリプトの中では登録できない。

自動化するなら、`gh` が認証された後に走る入口（chezmoi の run script など）で、`gh ssh-key add --type signing` を使う形を検討する。`gh` の token に Signing Key を書く scope が要るかは確かめていない。

---

## 6. Claude Code からの署名鍵の書き込みを制限する

- 記載: 2026-11-06（エージェント用署名鍵の security review で範囲外とした項目）

承認された書き込みで `~/.ssh/agent_signing_ed25519` の鍵ペアを置かれると、`scripts/macos/setup.sh` と `scripts/windows/setup.ps1` は既存の鍵ペアとして生成をスキップする。その後、README の登録手順で置かれた公開鍵を GitHub に登録するおそれがある。

2026-11-07 に `permissions.deny` へ `Edit(~/.ssh/**)` を足し、編集ツール、Bash のリダイレクト、`cp` は止まるようになった。`mv` と `ssh-keygen -f` は、Windows では止まらない（2026-11-07 実測）。cwd が home の外にある mac の session では、sandbox が両方を止めた（2026-11-07 実測）。cwd が home にある mac の session で sandbox が止めるかは確かめていない。範囲は `docs/notes/claude-code-settings-design.md` の「代償と失効」にある。残りを塞ぐなら、setup スクリプトが既存の鍵ペアを使う前に確かめる形などを検討する。

---

## 7. SSH agent forwarding の対象を絞る

- 記載: 2026-11-06（エージェント用署名鍵の security review で範囲外とした項目）

`private_dot_ssh/private_config.tmpl` の `Host *` に `ForwardAgent yes` がある。agent forwarding が必要な接続先を確認し、許可する範囲を検討する。

---

## 9. 鍵を作り直した後の署名 agent の扱い

- 記載: 2026-11-07（Claude Code の設定の見直しで、前の session から引き継いだ項目）

エージェント用の鍵を作り直しても、署名専用の ssh-agent が動いたままだと、新しい鍵では署名されない。`dot_config/git/executable_start-signing-agent` は、接続できる agent に今の公開鍵が無いと、鍵を渡さずに失敗する。hook は env を書かないので、その session は 1Password の署名に戻る。agent は古い鍵を持ったまま残る。mac と Windows で共通。

検討すること。

- 失効の手順に、agent を止める手順を足すか。Windows の Git Bash での止め方は確かめた（`docs/notes/claude-code-settings-design.md` の「代償と失効」）。mac での止め方は確かめていない。
- mac で agent を止めた時に、Codex の `SessionStart` hook が自分で agent を起動して鍵を載せるか。2026-11-07 に Codex の commit が `%G? = G` になった時は、Claude Code の hook が起動した agent がすでに動いていた（`docs/notes/codex-harness-operation.md` の「macOS のエージェント用署名」）。mac の止め方を確かめる時に、続けて確かめる。
- スクリプトが、古い鍵を持つ自分の agent を見分けて起動し直す形にするか。socket に別のプロセスが居座っている場合に、鍵を渡さないという今の防御を崩さないこと。
