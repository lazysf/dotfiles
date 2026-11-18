# 残タスク

- Date: 2026-11-16

着手を保留した項目を、記載日と見つけた時の作業が分かるように並べる。

## OS と harness ごとの apply 後の確認

- 記載: 2026-11-15（2026-11-09〜11-14 の commit と notes の「未確認」の振り返り）

結果は、括弧の notes に書く。

### Windows / Claude Code

- [x] **`settings.json.tmpl` の展開**（`eb2779a`）。2026-11-16 に、JSON として正しく、`chezmoi diff` が空で、xlwright の plugin が有効なことを確かめた（`claude-code-settings-design.md`）。
- [x] **識別子の検査の sh suite**。2026-11-16 に、`"` を含む名前の 1 ケースを除く 9 ケースが通った。その 1 ケースは NTFS と `core.protectNTFS` のため Windows では実行できず、suite は変えない（`git-commit-skill-design.md`）。

### 両 OS

- [x] **エージェント署名の廃止の片付け**。2026-11-16 に mac と Windows で終え、エージェントの commit が 1Password の承認で署名されることを確かめた（`agent-commit-signing-design.md` の「廃止の後の片付け」）。
- [x] **gh の撤去の片付け**。2026-11-16 に mac と Windows で終えた（`gh-authentication-design.md` の「廃止の後の片付け」）。
- [x] **過去の commit の署名し直し**。2026-11-16 に、dotfiles の全 commit と xlwright の `mcp` branch の 4 commit を 1Password の鍵で署名し直した（`agent-commit-signing-design.md` の「過去の commit の署名し直し」）。
- [x] **`chezmoi status` を repo 全体に打てるか**（mac）。2026-11-16 に、`~/.config/gh` の読み取り拒否では止まらなくなったことを確かめた。ただし sandbox の中では、`allowed_signers.tmpl` の `onepasswordRead` が 1Password の app に届かずに止まる。root の `AGENTS.md` の path を絞る指示は残し、理由を書き換えた（`claude-code-settings-design.md`）。
- [ ] **git-commit の commit の単位**（`12cf37b`）。doc や試験を、それが説明する変更と同じ commit に入れるか。Claude Code で、次に commit を頼んだ時に分け方を見る。mac の Claude Code では、2026-11-15 に apply した後の session で 1 回、記録 2 つと TODO を別の commit に分けた（`git-commit-skill-design.md`）。

## Windows の初回セットアップ

- 記載: 2026-10-22（machine profile の導入、セットアップスクリプトの統合、`chezmoi apply` からのセットアップ実行）

条件がそろった項目は、ユーザーが `setup.ps1` を `personal` 指定で手動実行して確認する。

- [ ] **1Password**。未設定の状態で Developer の設定画面が開く。CLI 連携と SSH agent を設定して Enter を押すと setup が再開する。
- [ ] **Parsec**。未導入の状態で管理者権限のない Windows PowerShell から実行すると UAC が表示される。承認するとインストールが進む。（2026-11-02 追加）
- [ ] **VB-CABLE**。未導入の状態で手動 setup を実行すると公式ページがブラウザーで開く。（2026-11-02 追加）

## skill と契約の見直しで保留したもの

- 記載: 2026-11-11（Claude と Codex の設定と skill の見直し、coding の `paths`、識別子の検査の同梱）

どれも急がない。surface に触れる項目は、着手する時に `AGENTS.md` の「surface を直す時」の確認を通す。

- [ ] **coding の `paths` を残すか判断する**。`paths` を付けた後（2026-11-10 以降）に、コードを編集した session が 10 本たまったら、`docs/notes/coding-skill-design.md` と同じ集計（コードを編集した session のうち、skill が発火した数）で比べる。増えていなければ外す。2026-11-14 時点で、この repo の mac の session では、コードを編集した session が 3 本、発火は 1 本。
- [ ] **契約の優先の明記が効いたかを確かめる**。2026-11-13 に、harness が shell を勧めても Read / Edit / Write を優先すると契約へ明記した。apply 後の auto mode の session の記録で、`cat`、`sed -n`、heredoc でのファイルの読み書きが減ったかを数える。減っていなければ、PreToolUse hook で止めるかを判断する（`docs/notes/claude-md-design.md` の「tool の使い分けを契約に置く理由」）。2026-11-14 時点で、この repo の mac の session では、契約を変えた commit `4b87314` の前（11-08 以降の 9 本）は Bash 403 回のうち読み取り 57、書き込み 55。後（4 本）は Bash 74 回のうち読み取り 9、書き込み 1。再開した session に写った呼び出しは、最初の session でだけ数えた。
