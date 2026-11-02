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

## 4. Codex の reviewer を Claude 側に揃えるか

- 記載: 2026-11-02（Claude の reviewer の effort と観点を見直した時）

Claude 側では、`quality-reviewer` の effort を `high` にし、事実の根拠、参照の整合、doc の追従の観点を足した。`lapidary` の「独立 context を提案する条件」も、根拠を workspace 内に限ることに合わせた。理由は `docs/notes/reviewer-agents-design.md` にある。`security-reviewer` には、対象として AI agent の設定と install / setup script を足した。Codex 側は保留にしたので、次の箇所が古いまま残っている。

- `dot_codex/agents/quality-reviewer.toml`: 観点に事実の根拠、参照の整合、doc の追従が無い。effort（quality が `high`、security が `xhigh`）は Claude 側と同じ形なので、直さなくてよい。
- `dot_codex/agents/security-reviewer.toml`: 対象に AI agent の設定と install / setup script が無い。出力のひな形が「実害や保守負荷の根拠」のままで、本文の「実害の根拠」と合わない。（2026-11-02 追加）
- 両方の toml: Claude 側で 2026-11-02 に整理した書き方が入っていない。振る舞いが変わるのは次の 4 つ。（2026-11-02 追加）
  - 停止線にある「secret 値そのものが必要」と、security の「workspace 外の前提が無いと判断できない」を、review を止めずに「呼び出し元への推奨」へ回す形にした。代わりに進め方へ「secret 値は読まない」を足した。停止線は変更セットが無い時だけになった。quality の役割にも「secret 値を出力や log に書かない」を足した。
  - Findings を「直してから進めるべき指摘」と定義し、「根拠がある指摘を優先する」の項を消した。
  - 停止線に当たった時に、何が足りないかを返す。
  - 「指摘を挙げる前に」の節で、直さないとどの場面で何がどう変わるかを 1 文で書けるか、今回の変更や依頼に関わる問題か、に当ててから挙げる。
- 両方の toml: 書き方だけの整理。description に観点を列挙しない、役割で write 系操作と外部 I/O を分けて書く、「-relevant」を言い換える、「findings を先頭に置く」を消す、security の CI の項を分けて「外部 I/O」に揃える。（2026-11-02 追加）
- `dot_codex/skills/lapidary/SKILL.md` の「独立 context を提案する条件」: 「一次情報を取り直す」のままで、workspace 内に限っていない。条件ごとに提案する agent も書いていない。影響が広い surface の条件のうち security も提案する範囲（追跡・配布・secret scanning の範囲を決める設定を含む）と、信頼境界の外から来る入力の処理の条件も無い。toml の description から観点を外す時は、呼ぶ側が選ぶ手がかりが無くなるので、この条件ごとの agent を同時に入れる。

Codex は web を使う手段が Claude と違うので、`WebFetch` を足さない理由はそのまま移せない。揃える前に、Codex の reviewer が外部を取得できるかを確かめる。
