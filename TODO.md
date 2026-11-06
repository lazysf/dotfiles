# 残タスク

- Date: 2026-11-02

このファイルは、着手を保留している項目の一覧。

`CLAUDE.md` は「1 つの作業（着手から commit まで）で扱うスコープは 1 つに保つ。作業中に別の問題へ気づいたら、その場で着手せずユーザーへ伝える。今のスコープを閉じてから扱う」と定めている。**逸れた分の行き先がここ。** ある作業の途中で見つかった別スコープの問題を、その場で直さずに移し、今のスコープを閉じてから改めて扱う。

各項目に記載日と、どの作業中に見つけたかを書く。どの文脈で浮上したかが分かると、再開時に前提を取り直せる。

判断の記録は `docs/adr/`、設計の理由は `docs/notes/` を正本とし、ここには重複させない。

---

## 1. Windows 実機での動作確認

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

仕事の Windows では、`work` を選んだ時に 1Password と Zotero と Parsec が入らず、git の identity と署名の設定が出ないことを確かめる。

---

## 2. mac で 1Password が未設定の時の待機

- 記載: 2026-10-22（setup で 1Password の設定を待つようにした時）

この mac は 1Password を設定済みなので、`scripts/macos/setup.sh` の `wait_for_onepassword` は「設定済み」の経路しか通していない。未設定の経路は、関数だけを取り出し、`op` を偽物にして試した範囲に留まる。

新しい mac、または 1Password の CLI 連携と SSH agent を切った状態で確かめること。

- Developer の設定画面（`onepassword://settings/developers`）が開き、やることの一覧と、未設定の項目が出る。
- 設定する前に Enter を押すと、まだ未設定の項目を出して待ち続ける。
- 両方を設定して Enter を押すと、「1Password は設定済みです」と出て先へ進む。

---

## 3. mac で Claude Desktop の 2 つ目のアカウント

- 記載: 2026-11-01（Claude Desktop の 2 つ目のアカウント用ショートカットを setup に足した時）

Windows では、`--user-data-dir` で別のインスタンスが開くことを確認した。mac の `create_claude_account_app` は実機で動かしていない。構成の理由は `docs/notes/claude-desktop-multi-account.md` にある。

mac で確かめること。

- `scripts/macos/setup.sh` を実行すると、`~/Applications/Claude-2nd.app` ができる。
- Raycast と Spotlight から `Claude-2nd` を起動すると、起動中の Claude を前面に出すのではなく、ログイン画面の別ウィンドウが開く。
- 2 つ目のウィンドウで、ファイルのドラッグ&ドロップと Code タブが動く。

---

## 5. エージェント用署名鍵の GitHub 登録の自動化

- 記載: 2026-11-06（エージェント用署名鍵の生成を `scripts/macos/setup.sh` に入れた時）

鍵の生成は setup.sh で自動化したが、GitHub への Signing Key の登録は README の手作業のまま。setup.sh は `chezmoi init` より前に走り、その時点では `gh` が認証されていないので、setup.sh の中では登録できない。

自動化するなら、`gh` が認証された後に走る入口（chezmoi の run script など）で、`gh ssh-key add --type signing` を使う形を検討する。`gh` の token に Signing Key を書く scope が要るかは確かめていない。

---

## 6. Claude Code からの署名鍵の書き込みを制限する

- 記載: 2026-11-06（エージェント用署名鍵の security review で範囲外とした項目）

`dot_claude/settings.json` の `permissions.deny` は `~/.ssh` 配下の `Read` を拒否する。`Edit` を拒否するルールはない。承認された書き込みで `~/.ssh/agent_signing_ed25519` の鍵ペアを置かれると、`scripts/macos/setup.sh` は既存の鍵ペアとして生成をスキップする。その後、README の登録手順で置かれた公開鍵を GitHub に登録するおそれがある。鍵の配置先への書き込みを制限する方法を検討する。

---

## 7. SSH agent forwarding の対象を絞る

- 記載: 2026-11-06（エージェント用署名鍵の security review で範囲外とした項目）

`dot_ssh/private_config.tmpl` の `Host *` に `ForwardAgent yes` がある。agent forwarding が必要な接続先を確認し、許可する範囲を検討する。

---

## 8. chezmoi が管理する `~/.ssh` の権限を見直す

- 記載: 2026-11-06（エージェント用署名鍵の security review で範囲外とした項目）

chezmoi の source が `dot_ssh` のため、apply で `~/.ssh` の権限が `755` になる。source を `private_dot_ssh` に改名する案を検討する。
