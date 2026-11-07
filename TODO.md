# 残タスク

- Date: 2026-11-02

このファイルは、着手を保留している項目の一覧。

`CLAUDE.md` は「1 つの作業（着手から commit まで）で扱うスコープは 1 つに保つ。作業中に別の問題へ気づいたら、その場で着手せずユーザーへ伝える。今のスコープを閉じてから扱う」と定めている。**逸れた分の行き先がここ。** ある作業の途中で見つかった別スコープの問題を、その場で直さずに移し、今のスコープを閉じてから改めて扱う。

各項目に記載日と、どの作業中に見つけたかを書く。どの文脈で浮上したかが分かると、再開時に前提を取り直せる。

判断の記録は `docs/adr/`、設計の理由は `docs/notes/` を正本とし、ここには重複させない。

---

## 1. 個人用 mac での Claude Code の設定の見直し

- 記載: 2026-11-07（個人用 Windows で Claude Code の設定を見直した時）

個人用 Windows では、`dot_claude/settings.json` の各設定が実際に効いているかを、公式 docs と実機の session で確かめた。結果は `docs/notes/claude-code-settings-design.md` にある。個人用 mac でも同じ見直しをする。

- 現状を把握し、見直す候補を挙げてから、候補ごとに相談して変える。
- 判断の前に、公式 docs（settings、permissions、sandboxing、hooks）を今の版で確かめる。
- notes の mac の記述が、今の Claude Code の版と mac の実機で成り立つかを確かめる。classifier のルールの件数のように、版で動く値は数え直す。
- mac で確かめる TODO（2、5、6、11、12 など）を、この見直しの中で扱うかを決める。

---

## 2. mac の Codex のエージェント用署名の自動設定

- 記載: 2026-11-07（個人用 Windows で Claude Code の設定を見直した時）

mac の `personal` では、`run_after_zz-configure-codex-signing.sh.tmpl` が `chezmoi apply` で `~/.codex/hooks.json` の `SessionStart` と `~/.codex/config.toml` の署名の設定を足す。2026-11-06 に確かめたのは、一時ホームと、app-server の `command/exec` での署名まで。手順と結果は `docs/notes/codex-harness-operation.md` の「macOS のエージェント用署名」にある。

個人用 mac で確かめること。

- 実際の作業機で apply した後に、`hooks.json` と `config.toml` に署名の設定が入るか。
- Codex CLI の `/hooks` で hook を信頼した後の、新しい Codex の session で、commit の `%G?` が `G` になるか。push した commit が GitHub で Verified になるか。

---

## 3. Windows の Codex のエージェント用署名

- 記載: 2026-11-07（Windows の `personal` にエージェント用署名鍵を入れた時）

Windows では Claude Code だけがエージェント用の鍵で署名する。

- Codex の署名設定を入れる `scripts/macos/configure-codex-signing.py` と `run_after_zz-configure-codex-signing.sh.tmpl` は macOS 専用で、zsh のログインシェルを前提にしている。Windows の Codex で同じ鍵を使うなら、Codex の Windows の sandbox と hook の shell を公式情報で確かめてから設計する。
- `dot_codex/rules/destructive.rules` の disk 系の command は macOS のものだけで、2026-11-07 に Claude Code の `permissions.deny` へ足した Windows の command（`diskpart`、`format.com`、`convert.exe`、`wbadmin`）は入っていない。Codex の Windows の sandbox を確かめる時に、揃えるかも判断する。

---

## 4. Windows 実機での動作確認

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

## 5. mac で 1Password が未設定の時の待機

- 記載: 2026-10-22（setup で 1Password の設定を待つようにした時）

この mac は 1Password を設定済みなので、`scripts/macos/setup.sh` の `wait_for_onepassword` は「設定済み」の経路しか通していない。未設定の経路は、関数だけを取り出し、`op` を偽物にして試した範囲に留まる。

新しい mac、または 1Password の CLI 連携と SSH agent を切った状態で確かめること。

- Developer の設定画面（`onepassword://settings/developers`）が開き、やることの一覧と、未設定の項目が出る。
- 設定する前に Enter を押すと、まだ未設定の項目を出して待ち続ける。
- 両方を設定して Enter を押すと、「1Password は設定済みです」と出て先へ進む。

---

## 6. mac で Claude Desktop の 2 つ目のアカウント

- 記載: 2026-11-01（Claude Desktop の 2 つ目のアカウント用ショートカットを setup に足した時）

Windows では、`--user-data-dir` で別のインスタンスが開くことを確認した。mac の `create_claude_account_app` は実機で動かしていない。構成の理由は `docs/notes/claude-desktop-multi-account.md` にある。

mac で確かめること。

- `scripts/macos/setup.sh` を実行すると、`~/Applications/Claude-2nd.app` ができる。
- Raycast と Spotlight から `Claude-2nd` を起動すると、起動中の Claude を前面に出すのではなく、ログイン画面の別ウィンドウが開く。
- 2 つ目のウィンドウで、ファイルのドラッグ&ドロップと Code タブが動く。

---

## 7. エージェント用署名鍵の GitHub 登録の自動化

- 記載: 2026-11-06（エージェント用署名鍵の生成を `scripts/macos/setup.sh` に入れた時）

鍵の生成は setup.sh と `scripts/windows/setup.ps1` で自動化したが、GitHub への Signing Key の登録は README の手作業のまま。どちらも `chezmoi init` より前に走り、その時点では `gh` が認証されていないので、スクリプトの中では登録できない。

自動化するなら、`gh` が認証された後に走る入口（chezmoi の run script など）で、`gh ssh-key add --type signing` を使う形を検討する。`gh` の token に Signing Key を書く scope が要るかは確かめていない。

---

## 8. Claude Code からの署名鍵の書き込みを制限する

- 記載: 2026-11-06（エージェント用署名鍵の security review で範囲外とした項目）

承認された書き込みで `~/.ssh/agent_signing_ed25519` の鍵ペアを置かれると、`scripts/macos/setup.sh` と `scripts/windows/setup.ps1` は既存の鍵ペアとして生成をスキップする。その後、README の登録手順で置かれた公開鍵を GitHub に登録するおそれがある。

2026-11-07 に `permissions.deny` へ `Edit(~/.ssh/**)` を足し、編集ツール、Bash のリダイレクト、`cp` は止まるようになった。`mv` と `ssh-keygen -f` は、Windows では止まらない（2026-11-07 実測）。cwd が home にある mac の session で sandbox が止めるかは確かめていない。範囲は `docs/notes/claude-code-settings-design.md` の「代償と失効」にある。残りを塞ぐなら、setup スクリプトが既存の鍵ペアを使う前に確かめる形などを検討する。

---

## 9. SSH agent forwarding の対象を絞る

- 記載: 2026-11-06（エージェント用署名鍵の security review で範囲外とした項目）

`dot_ssh/private_config.tmpl` の `Host *` に `ForwardAgent yes` がある。agent forwarding が必要な接続先を確認し、許可する範囲を検討する。

---

## 10. chezmoi が管理する `~/.ssh` の権限を見直す

- 記載: 2026-11-06（エージェント用署名鍵の security review で範囲外とした項目）

chezmoi の source が `dot_ssh` のため、apply で `~/.ssh` の権限が `755` になる。source を `private_dot_ssh` に改名する案を検討する。

---

## 11. mac の disk 系 deny rule の大文字と絶対パス

- 記載: 2026-11-07（Windows の disk 系 command を `permissions.deny` に足した時の security review）

Windows では、`Bash(...)` rule の照合が大文字と小文字を区別する一方、command の解決は区別しないので、大文字の `WBADMIN` が rule に当たらずに実行された。絶対パスの `/c/Windows/System32/wbadmin.exe` は拒否された。経緯は `docs/notes/claude-code-settings-design.md` の「auto mode の built-in ルール」にある。

mac で確かめること。

- APFS が大文字と小文字を区別しない既定の volume で、`DISKUTIL list` のような大文字の形が `Bash(diskutil *)` に当たらずに実行されるか。実行されるなら、大文字の形を rule に足すかを決める。
- `/usr/sbin/diskutil list` のような絶対パスの形が拒否されるか。notes の mac の節は、公式仕様から「絶対パスは覆わない」と書いている。拒否されるなら、止めたのが rule か classifier かを Manual mode の session で切り分け、notes を直す。

---

## 12. 鍵を作り直した後の署名 agent の扱い

- 記載: 2026-11-07（Claude Code の設定の見直しで、前の session から引き継いだ項目）

エージェント用の鍵を作り直しても、署名専用の ssh-agent が動いたままだと、新しい鍵では署名されない。`dot_config/git/executable_start-signing-agent` は、接続できる agent に今の公開鍵が無いと、鍵を渡さずに失敗する。hook は env を書かないので、その session は 1Password の署名に戻る。agent は古い鍵を持ったまま残る。mac と Windows で共通。

検討すること。

- 失効の手順に、agent を止める手順を足すか。Windows の Git Bash での止め方は確かめた（`docs/notes/claude-code-settings-design.md` の「代償と失効」）。mac での止め方は確かめていない。
- スクリプトが、古い鍵を持つ自分の agent を見分けて起動し直す形にするか。socket に別のプロセスが居座っている場合に、鍵を渡さないという今の防御を崩さないこと。
