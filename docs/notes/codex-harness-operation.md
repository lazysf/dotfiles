# Codex harness の運用

- Date: 2026-11-09
- 出典: [Permissions](https://learn.chatgpt.com/docs/permissions) / [Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents) / [Build skills](https://learn.chatgpt.com/docs/build-skills) / [Config basics](https://learn.chatgpt.com/docs/config-file/config-basic) / [Hooks](https://learn.chatgpt.com/docs/hooks) / [Custom instructions with AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md) / [Code review](https://learn.chatgpt.com/docs/code-review) / [Personalize](https://learn.chatgpt.com/docs/personalize) / [Security review of code changes](https://learn.chatgpt.com/docs/security/plugin/code-changes)（2026-11-09 確認） / 作業機の `~/.codex/skills/.system/review-agent/SKILL.md`（2026-11-09） / 一時領域への chezmoi 展開と Codex CLI 0.162.0-alpha.2 での設定読み込みの確認（2026-10-08） / 移植時の Codex CLI 0.160.0 でのスキル発見の確認 / Windows の Codex session での署名の実測（2026-11-09）

`dot_codex/` は chezmoi で `~/.codex/` へ配布する Claude 設定の移植版。運用契約は [`dot_codex/AGENTS.md`](../../dot_codex/AGENTS.md) にある。`config.toml` 全体はこの repo から配布しない。再導入の判断は [ADR 0043](../adr/0043-reintroduce-codex-from-current-claude.md)、`config.toml` を管理しない判断は [ADR 0044](../adr/0044-manage-codex-runtime-config-per-device.md)、エージェント用の鍵で署名しない判断は [ADR 0047](../adr/0047-stop-codex-agent-signing.md) にある。

## 構成と権限

契約と skills は、Claude 側（`dot_claude/CLAUDE.md` と `dot_claude/skills/`）と同じ意図で書く。違えているのは、runtime の仕組みが違う箇所だけ。通常作業のモデル、effort、権限、自動 memory は実機側の設定に委ねる。

- 返答の文体: Claude 側は組み込みの output style（`Concise`）で決めている。Codex には output style の仕組みが無い。公式の Personalize は、Codex の個人の指示は global の `AGENTS.md` に置くとしている。そのため `AGENTS.md` の「返答」に、`Concise` の要点を書いている。
- 権限: Claude 側は `settings.json` の deny と sandbox で credential の読み取りを止めている。Codex の `config.toml` はこの repo から配布しないので、credential を読まないことと承認経路の扱いを `AGENTS.md` の「権限」に書いている。
- 独立した review: 自作の reviewer agent は置かない。Claude 側と同じく、必要になってから作る。`skills/lapidary` は組み込みの review を提案し、起動の方法を CLI の `/review`、アプリの `/review`、shell の `codex review` に分けて書いている。起動できる対象と観点の指定の仕方が、クライアントごとに違うため。CLI 0.167.0-alpha.3.2 では、`codex review` の `--uncommitted` と指示の引数を同時に渡すと拒否された（2026-11-09、Codex の session での実測）。公式 docs では、アプリの `/review` は対象（base branch との差分か未 commit の変更）を選ぶメニューを出し、既定では今の chat の中で review する。作業機のアプリでは、入力欄に `/review` と打つと、候補の一番上に組み込みの command「コードレビュー」（説明は「サブエージェントで変更内容をレビュー」）が、その下のスキルの欄に system skill の「Review Agent」が出た。「コードレビュー」を選ぶと、対象を選ぶメニューは出ず、`origin/main` を基準に今の branch の変更を review する依頼が「レビューモード」としてすぐ送られた（2026-11-09、ユーザーの目視）。そのため、アプリでは「コードレビュー」を案内し、未 commit の変更だけを見る時と観点を指定する時は、CLI か shell を案内している。アプリで未 commit の変更を対象にできるかと、観点を足せるかは確かめていない。作業機の `review-agent` system skill は、`/review` の preset と同じ対象（uncommitted changes、base branch との差分、commit、custom instructions）を扱い、正しさに加えて security、performance、保守性への影響も指摘の対象にしている。`/review` がこの skill を使うことは、docs では確かめていない。Codex Security の plugin は作業機に入っていないので、提案しない。
- commit: 既定の `workspace-write` の sandbox は、`<writable_root>/.git` を読み取り専用にする。`.git` が `gitdir:` のファイルなら、参照先も保護される（[Protected paths in writable roots](https://learn.chatgpt.com/docs/agent-approvals-security#protected-paths-in-writable-roots)）。書ける root の下に作った別の repo の `.git` には、sandbox の中から書けた（2026-11-09、`$TMPDIR` の下の使い捨ての repo での実測）。`git add` と `git commit` をいつ申請し、いつ止まるかは、`skills/git-commit` の Gotchas を正本にする。

[`destructive.rules`](../../dot_codex/rules/destructive.rules) は、列挙したディスク操作コマンドを sandbox 外で禁止する設定。コマンド名と `/bin/`、`/sbin/`、`/usr/bin/`、`/usr/sbin/` の絶対パスに対応する。未知の `mkfs.*` / `newfs_*` や任意の script は網羅しない。契約と設定は管理者による強制ではない。

## 検証範囲

2026-10-08 に macOS・Linux・Windows の 3 通りの OS 分岐で、一時領域への chezmoi 展開を確認した。`config.toml` は管理対象から除外される。既存 config の内容は保持され、存在しない場合も作成されない。AGENTS、skills、rules の配布は継続する。

移植時の記録では、Codex CLI 0.160.0 の一時 home で `~/.codex/skills/` 相当のスキル発見を確認している。公式の user skill 配置は `~/.agents/skills/`。client 更新後はスキル発見を再確認する。

2026-11-09 に、`dot_codex/` を Claude 側の設計に揃えて apply した後、作業機（macOS の `personal`）の Codex の新しい session で次を確かめた。

- session が global の `AGENTS.md` と、`~/.codex/skills/` の 4 つの skill を読み込んだ。`/skills` の画面にも 4 つが出た（ユーザーの目視）。
- skill の名前も手順も知らせずに、`$TMPDIR` の使い捨ての repo で commit を頼むと、`git-commit` が発火して `lapidary` を通し、署名付きの commit ができた。返答は `AGENTS.md` の「返答」どおり、結論から始まって短かった（ユーザーの目視）。
- 設定の key を rename して commit するよう頼むと、その key を説明する notes も直し、使い捨ての repo の `AGENTS.md` の規約どおり、設定と notes を別の commit に分けた。notes の古さに気づいたのは作業の最初の検索で、`lapidary` の手順 4 だけが拾ったとは言えない。

## 適用前後の確認

配布前に `chezmoi diff ~/.codex` でファイルの差分を確認する。`config.toml` はファイル単位の配布から除外している。

MCP、plugin、通知、モデル、権限などは、アプリまたは実機の `~/.codex/config.toml` で管理する。既存 config を手動で削除・変更する場合は、必要な追加設定を事前に退避する。個人や作業機を特定する値、秘密情報を repo の source へ取り込まない。

適用後は `chezmoi managed` と target の実体を突き合わせる。source から削除したファイルが target に残る場合がある。

実機の権限設定を変更したら、設定を読み直した新しいセッションで必要な作業とアクセス境界を検証する。既存セッションでの承認付き実行だけを根拠に、変更後の権限が有効だと判断しない。

## macOS のエージェント用署名

Codex はエージェント用の鍵で署名しない（[ADR 0047](../adr/0047-stop-codex-agent-signing.md)）。commit の署名は global の Git 設定に任せる。`chezmoi apply` は Codex の署名設定を足さない。

配布をやめる前に apply した mac の `~/.codex` には、足した設定が残る。mac で次の順に外す。

1. 配布の script を消した source を `chezmoi apply` する。先に手で外すと、古い script の apply が入れ直す。
2. `~/.codex/hooks.json` の `SessionStart` から、`start-signing-agent` を呼ぶ hook を消す。公式の Hooks に、ファイルから消す手順の記載は無い。新しい session の `/hooks` で出なくなったことを確かめる。
3. `~/.codex/config.toml` から、`shell_environment_policy.set` の `SSH_AUTH_SOCK` と `GIT_CONFIG_*`、`permissions.agent-signing.network`、`features.network_proxy` を消す。
4. `default_permissions` と `permissions.agent-signing.filesystem` は残す。
5. 新しい session で確かめる。
   - `~/.ssh` の中のファイルの読み取りが拒否される。
   - 外向きの通信が止まる。
   - commit を作ると 1Password の承認が出て、`git log -1 --format='%G? %GK'` の `%G?` が `G`、`%GK` がエージェント用の鍵と違う。

手順 4 で残す `filesystem` は、署名とは別の防御になる。mac には Claude Code のためにエージェント用の鍵が残るので、`~/.ssh` の `deny` が無いと Codex がその鍵を読める。`read` の項目は、cwd が `~` や `~/.config` の session で、Codex が Claude Code の署名の起動スクリプトと socket を書き換えることを止める。profile の名前は `agent-signing` のまま残る。

network を外すのは、Unix socket を通すためだけに有効にしていたため。公式の Permissions では、`network.enabled` の既定は `false` で、network が off の時は proxy の設定によらず通信できない。

## Windows の署名とコマンド制限

2026-11-09 の Windows の Claude Code session と Codex session で確かめた。アプリは OpenAI.Codex 26.1103.4239.0。同梱の Codex CLI は 0.167.0-alpha.3.2 で、`%LOCALAPPDATA%\OpenAI\Codex\bin\` にあり、`PATH` にはない。Git for Windows は 2.56.0.windows.4 で、同梱の OpenSSH は 10.6p1。`config.toml` の Windows の設定は `elevated` で、permission profile、明示的な network 許可、hook は入っていない。調査時に参照した Codex session の記録では shell は PowerShell、sandbox policy は `read-only`、approval policy は `never` だった。通常作業の session にもこの policy が適用されるかは未確認。Git の global 設定は `commit.gpgsign = true` で、署名に `op-ssh-sign.exe` を使う。

### コマンド制限

同梱 CLI の `codex execpolicy check --rules <一時ルール> -- <コマンドと引数>` で次を確かめた。判定対象のコマンドは実行していない。

| rule の `pattern` | 一致 | 不一致 |
| --- | --- | --- |
| `[["diskpart", "git"]]` | `diskpart`、`git push`、`git -C . push` | `diskpart.exe`、`DISKPART`、`C:\Windows\System32\diskpart.exe`、`git.exe push`、絶対パスで呼んだ `git.exe` |
| `["git", "push"]` | `git push` | `git -C . push`、`git -c a=b push` |

`powershell.exe -Command "git push"` と `bash -lc "git push"` も、この照合では一致しなかった。公式 docs の照合単位は argv のリテラルの prefix。実行時には、単純な `bash -lc`、`zsh`、`sh` の wrapper を分解して照合する場合がある。PowerShell の分解は記載されていない。[Rules](https://learn.chatgpt.com/docs/agent-configuration/rules)

Claude Code で適用後に push が実行前に止まった結果は、[push は sandbox 内で SSH を通らない](claude-code-settings-design.md#push-は-sandbox-内で-ssh-を通らない) を参照。

Windows と macOS の `workspace-write` では、sandbox 内の外向き通信は既定で無効。[Agent approvals & security](https://learn.chatgpt.com/docs/agent-approvals-security#network-access)

### 読み取りの deny

公式 docs では、Windows の `mxc` と `elevated` は読み取りの deny に対応し、`unelevated` は対応しない。`elevated` は低権限の専用ユーザーで実行する。[Windows sandbox](https://learn.chatgpt.com/docs/windows/windows-sandbox) / [Permissions](https://learn.chatgpt.com/docs/permissions#deny-reads-with-exact-paths-or-globs)

同梱 CLI の `elevated` で `:workspace` と、検証用ディレクトリを `deny` にした一時 profile を比較した。`deny` を入れると、対象ディレクトリ内の既存ファイルだけが `UnauthorizedAccessException` になった。ユーザー側では同じファイルを読めた。実在の `~/.ssh` はこの比較の対象外。

### 自動署名を入れなかった理由

Claude Code は Windows で、Git Bash から Git for Windows の `ssh-keygen` と専用の `ssh-agent` を使う（[Windows の hook](agent-commit-signing-design.md#windows-の-hook)）。同じ経路は、Codex の sandbox の中では通らなかった。検証にはすべて使い捨ての鍵と repo を使い、実在のセットアップ鍵には触れていない。

- Git for Windows の同梱ツールの起動: 通常の Codex session の `ssh-add -l`、`bash --version`、`ssh-agent -V`、`cygpath -u .` は `0xC0000142`（`STATUS_DLL_INIT_FAILED`）で終了した。この session の sandbox の実効実装は未確認。CLI に `-c windows.sandbox=mxc` を渡すと `bash --version` は同じエラーになり、`-c windows.sandbox=elevated -c features.prefer_mxc=false` を渡すと成功した。
- 専用 agent への接続: `elevated` の sandbox の中の `ssh-add -l` は `communication with agent failed` で終了し、agent は `uid mismatch` を記録した。ローカルの TCP には接続できた。OpenSSH は、接続元の実効 UID が root でも自分でもない時に接続を閉じる。`elevated` は専用ユーザーで動くので、socket の path や権限の調整では通らない。[OpenSSH 10.6p1 の `ssh-agent`](https://github.com/openssh/openssh-portable/blob/V_10_6_P1/ssh-agent.c#L1902-L1917)
- named pipe での取り次ぎ: ユーザー側の pipe の ACL で sandbox のユーザー SID に `ReadWrite` と `Synchronize` を許可すると、sandbox から接続できた（`ReadData`、`WriteData`、`Synchronize` だけでは拒否された）。この経路でユーザー側の agent が固定のデータに署名し、sandbox の中の `ssh-keygen -Y verify` が検証できた。[Named Pipe Security and Access Rights](https://learn.microsoft.com/en-us/windows/win32/ipc/named-pipe-security-and-access-rights)
- `git commit` からの取り次ぎ: Git は `gpg.ssh.program` の試作を起動したが、Windows PowerShell 5.1 が試作の `client.ps1` を実行ポリシーで拒否した。Git は `fatal: failed to write commit object` で終了した。有効な policy の値は、同じ sandbox で `Get-ExecutionPolicy` を読み込めず確認できなかった。実用にするには、起動できるクライアントと、常駐する取り次ぎ処理を新しく作ることになる。
- Windows 標準 OpenSSH: 公開実装では agent の named pipe 名が固定で、署名専用の接続先を分ける機能は確認できなかった。実機は 9.5p2。[Win32 OpenSSH の agent 実装](https://github.com/PowerShell/openssh-portable/blob/latestw_all/contrib/win32/win32compat/ssh-agent/agent.c)
- `windows.sandbox_private_desktop`: 現行の設定リファレンスと schema に無く、回避策にできる根拠は得られなかった。[Config schema](https://learn.chatgpt.com/docs/config-schema.json)

どれも sandbox の中の `git commit` の結果で、承認を得て sandbox の外で実行する `git commit` の署名は試していない。

## 未確認

- Windows の通常の Codex session での `~/.ssh` の読み取り境界、外向き通信、PowerShell 経由の rules の発火。[TODO 1](../../TODO.md#1-codex-の署名の解除と-windows-の確認) に残す。
- Codex の session の commit で、1Password の承認が出て署名できるか。Windows と、設定を外した後の mac のどちらも未確認。mac は手順 5 で確かめる。
- `extends = ":workspace"` の profile で `network` を外した時に、network が off になるか。公式の Permissions は既定を `false` と書くが、`extends` との関係は明記していない。mac は手順 5 で確かめる。
- `permissions.agent-signing.filesystem` の `read` が、親ディレクトリの rename による置き換えも防ぐか。cwd が `~` や `~/.config` のセッションで問題になる。
- `dot_config/zsh/dot_zshenv` の署名用 socket の条件は、Codex の署名のために足した。Claude Code に要るかは確かめていないので残している。
