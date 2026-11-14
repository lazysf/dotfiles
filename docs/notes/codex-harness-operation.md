# Codex harness の運用

- Date: 2026-11-14
- 出典: [Permissions](https://learn.chatgpt.com/docs/permissions) / [Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents) / [Build skills](https://learn.chatgpt.com/docs/build-skills) / [Config basics](https://learn.chatgpt.com/docs/config-file/config-basic) / [Hooks](https://learn.chatgpt.com/docs/hooks) / [Custom instructions with AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md) / [Code review](https://learn.chatgpt.com/docs/code-review) / [Personalize](https://learn.chatgpt.com/docs/personalize) / [Security review of code changes](https://learn.chatgpt.com/docs/security/plugin/code-changes)（2026-11-09 確認） / 作業機の `~/.codex/skills/.system/review-agent/SKILL.md`（2026-11-09） / 一時領域への chezmoi 展開と Codex CLI 0.162.0-alpha.2 での設定読み込みの確認（2026-10-08） / 移植時の Codex CLI 0.160.0 でのスキル発見の確認 / Windows と mac の Codex session での署名の実測（2026-11-09）

`dot_codex/` は chezmoi で `~/.codex/` へ配布する Claude 設定の移植版。運用契約は [`dot_codex/AGENTS.md`](../../dot_codex/AGENTS.md) にある。`config.toml` 全体はこの repo から配布せず、決めたキーだけを上書きする。再導入の判断は [ADR 0043](../adr/0043-reintroduce-codex-from-current-claude.md)、`config.toml` を作業機ごとに管理する判断は [ADR 0044](../adr/0044-manage-codex-runtime-config-per-device.md)、一部のキーだけを上書きする判断は [ADR 0049](../adr/0049-manage-selected-codex-config-keys.md)、エージェント用の鍵で署名しない判断は [ADR 0047](../adr/0047-stop-codex-agent-signing.md)、commit を sandbox の外で都度承認する判断は [ADR 0048](../adr/0048-approve-codex-commits-outside-sandbox.md) にある。

## 構成と権限

契約と skills は、Claude 側（`dot_claude/CLAUDE.md` と `dot_claude/skills/`）と同じ意図で書く。違えているのは、runtime の仕組みが違う箇所だけ。model、reasoning effort、sandbox の設定は、決めたキーだけを repo から上書きする（[config.toml の一部のキーの管理](#configtoml-の一部のキーの管理)）。permission profile と自動 memory は実機側の設定に委ねる。

- 返答の文体: Claude 側は組み込みの output style（`Concise`）で決めている。Codex には output style の仕組みが無い。公式の Personalize は、Codex の個人の指示は global の `AGENTS.md` に置くとしている。そのため `AGENTS.md` の「返答」に、`Concise` の要点を書いている。
- 権限: Claude 側は `settings.json` の deny と sandbox で credential の読み取りを止めている。Codex の permission profile はこの repo から配布しないので、credential を読まないことと承認経路の扱いを `AGENTS.md` の「権限」に書いている。
- 独立した review: 自作の reviewer agent は置かない。Claude 側と同じく、必要になってから作る。`skills/lapidary` は組み込みの review を提案し、起動の方法を CLI の `/review`、アプリの `/review`、shell の `codex review` に分けて書いている。起動できる対象と観点の指定の仕方が、クライアントごとに違うため。CLI 0.167.0-alpha.3.2 では、`codex review` の `--uncommitted` と指示の引数を同時に渡すと拒否された（2026-11-09、Codex の session での実測）。公式 docs では、アプリの `/review` は対象（base branch との差分か未 commit の変更）を選ぶメニューを出し、既定では今の chat の中で review する。作業機のアプリでは、入力欄に `/review` と打つと、候補の一番上に組み込みの command「コードレビュー」（説明は「サブエージェントで変更内容をレビュー」）が、その下のスキルの欄に system skill の「Review Agent」が出た。「コードレビュー」を選ぶと、対象を選ぶメニューは出ず、`origin/main` を基準に今の branch の変更を review する依頼が「レビューモード」としてすぐ送られた（2026-11-09、ユーザーの目視）。そのため、アプリでは「コードレビュー」を案内し、未 commit の変更だけを見る時と観点を指定する時は、CLI か shell を案内している。アプリで未 commit の変更を対象にできるかと、観点を足せるかは確かめていない。作業機の `review-agent` system skill は、`/review` の preset と同じ対象（uncommitted changes、base branch との差分、commit、custom instructions）を扱い、正しさに加えて security、performance、保守性への影響も指摘の対象にしている。`/review` がこの skill を使うことは、docs では確かめていない。Codex Security の plugin は作業機に入っていないので、提案しない。
- commit: 既定の `workspace-write` の sandbox は、`<writable_root>/.git` を読み取り専用にする。`.git` が `gitdir:` のファイルなら、参照先も保護される（[Protected paths in writable roots](https://learn.chatgpt.com/docs/agent-approvals-security#protected-paths-in-writable-roots)）。書ける root の下に作った別の repo の `.git` には、sandbox の中から書けた（2026-11-09、`$TMPDIR` の下の使い捨ての repo での実測）。`git add` と `git commit` をいつ申請し、いつ止まるかは、`skills/git-commit` の Gotchas を正本にする。

[`destructive.rules`](../../dot_codex/rules/destructive.rules) は、列挙したディスク操作コマンドと Git の push を Codex のコマンド実行で禁止する。Unix 系のディスク操作はコマンド名と `/bin/`、`/sbin/`、`/usr/bin/`、`/usr/sbin/` の絶対パスに対応する。Windows のディスク操作と push の対象は [コマンド制限](#コマンド制限) を参照。契約と設定は管理者による強制ではない。

## 検証範囲

2026-10-08 に macOS・Linux・Windows の 3 通りの OS 分岐で、一時領域への chezmoi 展開を確認した。`config.toml` は管理対象から除外される。既存 config の内容は保持され、存在しない場合も作成されない。AGENTS、skills、rules の配布は継続する。

移植時の記録では、Codex CLI 0.160.0 の一時 home で `~/.codex/skills/` 相当のスキル発見を確認している。公式の user skill 配置は `~/.agents/skills/`。client 更新後はスキル発見を再確認する。

skills の配布先は `~/.codex/skills/` のまま移さない。移すと、契約と rules は `~/.codex/`、skills は `~/.agents/` と、Codex の設定が 2 か所に分かれる。その手間が、公式の配置に揃える利点より大きいというユーザーの判断による（2026-11-14）。[Build skills](https://learn.chatgpt.com/docs/build-skills) は `~/.codex/skills` に触れておらず、使えるとも廃止とも書いていない（2026-11-13 確認）。スキル発見で 4 つの skill が出なくなったら、移すことを考え直す。

2026-11-09 に、`dot_codex/` を Claude 側の設計に揃えて apply した後、作業機（macOS の `personal`）の Codex の新しい session で次を確かめた。

- session が global の `AGENTS.md` と、`~/.codex/skills/` の 4 つの skill を読み込んだ。`/skills` の画面にも 4 つが出た（ユーザーの目視）。
- skill の名前も手順も知らせずに、`$TMPDIR` の使い捨ての repo で commit を頼むと、`git-commit` が発火して `lapidary` を通し、署名付きの commit ができた。返答は `AGENTS.md` の「返答」どおり、結論から始まって短かった（ユーザーの目視）。
- 設定の key を rename して commit するよう頼むと、その key を説明する notes も直し、使い捨ての repo の `AGENTS.md` の規約どおり、設定と notes を別の commit に分けた。notes の古さに気づいたのは作業の最初の検索で、`lapidary` の手順 4 だけが拾ったとは言えない。

## 適用前後の確認

配布前に `chezmoi diff ~/.codex` でファイルの差分を確認する。`config.toml` の差分は、管理するキーの値が実機と違う時か、以前の生成結果から字下げを外す時に出る。

MCP、plugin、通知、権限などの、管理するキー以外は、アプリまたは実機の `~/.codex/config.toml` で管理する。既存 config を手動で削除・変更する場合は、必要な追加設定を事前に退避する。個人や作業機を特定する値、秘密情報を repo の source へ取り込まない。

適用後は `chezmoi managed` と target の実体を突き合わせる。source から削除したファイルが target に残る場合がある。

実機の権限設定を変更したら、設定を読み直した新しいセッションで必要な作業とアクセス境界を検証する。既存セッションでの承認付き実行だけを根拠に、変更後の権限が有効だと判断しない。

## config.toml の一部のキーの管理

[`modify_private_config.toml`](../../dot_codex/modify_private_config.toml) は chezmoi の modify テンプレート。apply の時に実機の `config.toml` を読み、テンプレートに並べたキーだけを上書きして書き戻す。管理するキーと値の正本はこのテンプレート。[Manage different types of file](https://www.chezmoi.io/user-guide/manage-different-types-of-file/)

- 管理するのは、model、reasoning effort、sandbox mode、workspace-write の network、アプリの表示の設定。作業機の間で揃えたい値で、作業機固有のパスを含まない。
- 個人用 Windows は MXC を明示する。端末やポリシーが MXC に対応しない場合、sandbox の起動は失敗する。仕事用 Windows は `elevated` を選ぶ。デスクトップアプリによる MXC の自動選択を避けるため、仕事用 Windows では `features.prefer_mxc` も無効にする。Windows 以外では両キーを実機側で管理する。[Windows sandbox](https://learn.chatgpt.com/docs/windows/windows-sandbox) / [Configuration Reference](https://learn.chatgpt.com/docs/config-file/config-reference)
- permission profile は入れない。ADR 0044 の起動しなかった配布に入っていたため。
- 実機にファイルが無い時は、管理するキーだけのファイルを作る。
- `setValueAtPath` は、パスの途中にあるテーブル以外の値を、黙ってテーブルに置き換える。テンプレートは、置き換える前にエラーで apply を止める。
- `toToml` はキーの並びと引用符を変え、コメントを消す。生成時は元の Codex 設定に合わせて字下げを外す。字下げを外した結果を再度 TOML として読み、同じデータに戻ることを確かめてから出力する。管理する値が既に同じ場合は、従来の `toToml` 出力と完全に一致するファイルだけを整形する。

2026-11-10 に chezmoi v2.74.0 で、この Windows 機の `config.toml` を入力にして確かめた。値が同じ時の出力は、実機のファイルとバイト単位で一致した。reasoning effort だけを変えた写しでは、その値だけが戻り、MCP のテーブルは残った。別の写しで、往復の前後を JSON にして比べると、足したキー以外は一致した。空の入力、`desktop` が文字列の入力、`.chezmoi.os` を `darwin` にした入力も試した。macOS の実機での apply は確かめていない。

## macOS のエージェント用署名

Codex はエージェント用の鍵で署名しない（[ADR 0047](../adr/0047-stop-codex-agent-signing.md)）。commit の署名は global の Git 設定に任せる。`chezmoi apply` は Codex の署名設定を足さない。

mac の Codex の commit は、承認を受けて sandbox の外で実行する（[ADR 0048](../adr/0048-approve-codex-commits-outside-sandbox.md)）。sandbox の中からは 1Password に届かないため。

2026-11-09 に、mac の Codex CLI 0.167.0-alpha.3.2 の環境で、profile と hook を外した新しい session を使って確かめた。session の実効の設定は、sandbox が `workspace-write`、permission profile が `managed`、filesystem が `restricted` だった。

- 使い捨ての repo で sandbox の中から `git commit` を実行すると、`1Password: Could not connect to socket` に続けて `fatal: failed to write commit object` で失敗した。
- 同じ条件で別の session を開き、承認を受けて sandbox の外で `git commit` を実行すると署名できた。`git log -1 --format='%G? %GK'` の `%G?` は `G` で、`%GK` は 1Password の鍵だった。
- `~/.ssh/config` のバイト数を読めた。実在の秘密鍵は開いていない。
- sandbox の中の `curl https://example.com` は、名前解決に失敗して HTTP の応答が無かった。

配布をやめる前に apply した mac の `~/.codex` には、足した設定が残る。mac で次の順に外す。

1. 配布の script を消した source を `chezmoi apply` する。先に手で外すと、古い script の apply が入れ直す。
2. `~/.codex/hooks.json` の `SessionStart` から、`start-signing-agent` を呼ぶ hook を消す。他に hook が無ければファイルごと消してよい。公式の Hooks に、ファイルから消す手順の記載は無い。新しい session の `/hooks` で出なくなったことを確かめる。
3. `~/.codex/config.toml` から、`default_permissions`、`features.network_proxy`、`shell_environment_policy.set` の `SSH_AUTH_SOCK` と `GIT_CONFIG_*`、`permissions.agent-signing` の全体、消した hook の `hooks.state` を消す。
4. 新しい session で、承認を受けて sandbox の外で使い捨ての repo に commit し、`%G?` が `G`、`%GK` がエージェント用の鍵と違うことを確かめる。

## Windows の署名とコマンド制限

2026-11-09 の Windows の Claude Code session と Codex session で確かめた。アプリは OpenAI.Codex 26.1103.4239.0。同梱の Codex CLI は 0.167.0-alpha.3.2 で、`%LOCALAPPDATA%\OpenAI\Codex\bin\` にあり、`PATH` にはない。Git for Windows は 2.56.0.windows.4 で、同梱の OpenSSH は 10.6p1。`config.toml` の Windows の設定は `elevated` で、permission profile、明示的な network 許可、hook は入っていない。調査時に参照した Codex session の記録では shell は PowerShell、sandbox policy は `read-only`、approval policy は `never` だった。通常作業の session にもこの policy が適用されるかは未確認。Git の global 設定は `commit.gpgsign = true` で、署名に `op-ssh-sign.exe` を使う。

### コマンド制限

同梱 CLI の `codex execpolicy check --rules <一時ルール> -- <コマンドと引数>` で次を確かめた。判定対象のコマンドは実行していない。

| rule の `pattern` | 一致 | 不一致 |
| --- | --- | --- |
| `[["diskpart", "git"]]` | `diskpart`、`git push`、`git -C . push` | `diskpart.exe`、`DISKPART`、`C:\Windows\System32\diskpart.exe`、`git.exe push`、絶対パスで呼んだ `git.exe` |
| `["git", "push"]` | `git push` | `git -C . push`、`git -c a=b push` |

`powershell.exe -Command "git push"` と `bash -lc "git push"` も、この照合では一致しなかった。公式 docs の照合単位は argv のリテラルの prefix。実行時には、単純な `bash -lc`、`zsh`、`sh` の wrapper を分解して照合する場合がある。PowerShell の分解は記載されていない。[Rules](https://learn.chatgpt.com/docs/agent-configuration/rules)

2026-11-09 に Codex CLI 0.167.0-alpha.3.2 と Git for Windows 2.56.0.windows.4 で確認した。`git version --build-options` を `forbidden` にする一時 rule を置いた。`execpolicy check` では `git` から始まる argv に一致し、`pwsh.exe -NoProfile -Command` で包んだ argv には一致しなかった。

新しい `codex exec` の session（`workspace-write`、`mxc`）では、実行ツールがコマンドを `pwsh.exe -NoProfile -Command` で包んだ。`git --version` は終了コード 0 だった。`git version --build-options` は一時 rule の `justification` を返してプロセス作成前に拒否された。検証後に一時 rule を削除した。

Windows のディスク操作は Claude Code 側と同じ名前を小文字と全大文字で列挙する。拡張子なしの `convert` は macOS の ImageMagick と名前が重なるため、対象は `convert.exe` に絞る。push はユーザーが手元の terminal で行う方針に合わせ、全 OS で `git push` と `git.exe push` を止める。

2026-11-09 に配布元の rule を Codex CLI 0.167.0-alpha.3.2 の `execpolicy check` で確認した。Windows の絶対パスや大小文字が混在する名前、`git -C . push` のように Git の前置き option がある呼び出しには別のパターンが要る。

Claude Code で適用後に push が実行前に止まった結果は、[push は sandbox 内で SSH を通らない](claude-code-settings-design.md#push-は-sandbox-内で-ssh-を通らない) を参照。

### 外向き通信

Windows と macOS の `workspace-write` では、sandbox 内の外向き通信は既定で無効。[Agent approvals & security](https://learn.chatgpt.com/docs/agent-approvals-security#network-access)

`modify_private_config.toml` は `sandbox_workspace_write.network_access` を `true` にして、sandbox 内の外向き通信を有効にする。依存の取得や `git fetch` のような通常の作業を、承認の往復なしで通すため（2026-11-10 のユーザー判断）。

**代償として、Codex の sandbox 内のコマンドは、読めた credential を外へ送れる。受け入れている（2026-11-10 のユーザー判断）。** 読み取りの deny を持つ permission profile は repo から配らない（[ADR 0044](../adr/0044-manage-codex-runtime-config-per-device.md)、[ADR 0049](../adr/0049-manage-selected-codex-config-keys.md)）。Windows の実測では、sandbox 内から `~/.ssh` の検証用ファイルを読めた（[読み取りの deny](#読み取りの-deny)）。歯止めは `AGENTS.md` の「権限」の契約だけで、強制ではない。Claude Code も Windows では同じ状態を受け入れている（[Windows では鍵を持ち出せる](agent-commit-signing-design.md#windows-では鍵を持ち出せる)）。見直すのは、秘密を含む repo で Codex を使い始める時。その時は作業機の config に読み取りの deny を入れるか、このキーを管理から外す。

この節の下の実測と、[macOS のエージェント用署名](#macos-のエージェント用署名) の `curl` の実測は、このキーを管理に入れる前のもの。

2026-11-09 に Windows の Codex session（`workspace-write`、permission profile は `managed`）で、PowerShell 7.6.9 から `curl.exe` で `https://example.com/` に HTTPS GET を送った。接続 timeout は 5 秒、全体の timeout は 10 秒にした。承認を受けた sandbox 外の対照では HTTP 200 だった。sandbox 内では名前解決に失敗し、curl の終了コードは 6 で HTTP 応答は無かった。

### 読み取りの deny

公式 docs では、Windows の `mxc` と `elevated` は読み取りの deny に対応し、`unelevated` は対応しない。`elevated` は低権限の専用ユーザーで実行する。[Windows sandbox](https://learn.chatgpt.com/docs/windows/windows-sandbox) / [Permissions](https://learn.chatgpt.com/docs/permissions#deny-reads-with-exact-paths-or-globs)

同梱 CLI の `elevated` で `:workspace` と、検証用ディレクトリを `deny` にした一時 profile を比較した。`deny` を入れると、対象ディレクトリ内の既存ファイルだけが `UnauthorizedAccessException` になった。ユーザー側では同じファイルを読めた。実在の `~/.ssh` はこの比較の対象外。

2026-11-09 に Windows の Codex session（`workspace-write`、permission profile は `managed`）から、実際のユーザーの `~/.ssh` を PowerShell 7.6.9 で確認した。`File.OpenRead` で存在しない `claude-probe-missing` を開くと `FileNotFoundException` になった。ユーザーの承認を受けて作った検証用ファイルは、sandbox 内の `File.ReadAllText` で読めた。固定文字列との一致だけを確認し、検証後にファイルを削除した。

### 自動署名を入れなかった理由

Claude Code は Windows で、Git Bash から Git for Windows の `ssh-keygen` と専用の `ssh-agent` を使う（[Windows の hook](agent-commit-signing-design.md#windows-の-hook)）。同じ経路は、Codex の sandbox の中では通らなかった。検証にはすべて使い捨ての鍵と repo を使い、実在のセットアップ鍵には触れていない。

- Git for Windows の同梱ツールの起動: 通常の Codex session の `ssh-add -l`、`bash --version`、`ssh-agent -V`、`cygpath -u .` は `0xC0000142`（`STATUS_DLL_INIT_FAILED`）で終了した。この session の sandbox の実効実装は未確認。CLI に `-c windows.sandbox=mxc` を渡すと `bash --version` は同じエラーになり、`-c windows.sandbox=elevated -c features.prefer_mxc=false` を渡すと成功した。
- 専用 agent への接続: `elevated` の sandbox の中の `ssh-add -l` は `communication with agent failed` で終了し、agent は `uid mismatch` を記録した。ローカルの TCP には接続できた。OpenSSH は、接続元の実効 UID が root でも自分でもない時に接続を閉じる。`elevated` は専用ユーザーで動くので、socket の path や権限の調整では通らない。[OpenSSH 10.6p1 の `ssh-agent`](https://github.com/openssh/openssh-portable/blob/V_10_6_P1/ssh-agent.c#L1902-L1917)
- named pipe での取り次ぎ: ユーザー側の pipe の ACL で sandbox のユーザー SID に `ReadWrite` と `Synchronize` を許可すると、sandbox から接続できた（`ReadData`、`WriteData`、`Synchronize` だけでは拒否された）。この経路でユーザー側の agent が固定のデータに署名し、sandbox の中の `ssh-keygen -Y verify` が検証できた。[Named Pipe Security and Access Rights](https://learn.microsoft.com/en-us/windows/win32/ipc/named-pipe-security-and-access-rights)
- `git commit` からの取り次ぎ: Git は `gpg.ssh.program` の試作を起動したが、Windows PowerShell 5.1 が試作の `client.ps1` を実行ポリシーで拒否した。Git は `fatal: failed to write commit object` で終了した。有効な policy の値は、同じ sandbox で `Get-ExecutionPolicy` を読み込めず確認できなかった。実用にするには、起動できるクライアントと、常駐する取り次ぎ処理を新しく作ることになる。
- Windows 標準 OpenSSH: 公開実装では agent の named pipe 名が固定で、署名専用の接続先を分ける機能は確認できなかった。実機は 9.5p2。[Win32 OpenSSH の agent 実装](https://github.com/PowerShell/openssh-portable/blob/latestw_all/contrib/win32/win32compat/ssh-agent/agent.c)
- `windows.sandbox_private_desktop`: 現行の設定リファレンスと schema に無く、回避策にできる根拠は得られなかった。[Config schema](https://learn.chatgpt.com/docs/config-schema.json)

### sandbox 外での 1Password 署名

2026-11-09 に Windows の Codex CLI 0.167.0-alpha.3.2、Git for Windows 2.56.0.windows.4、PowerShell 7.6.9 で確認した。session の権限は `workspace-write`、permission profile は `managed`、承認の審査は `auto_review` だった。

使い捨ての repo で、承認を経て sandbox の外から `git commit --allow-empty` を実行した。Git の設定で署名には `op-ssh-sign.exe` が選ばれていた。ユーザーは 1Password の署名承認画面が表示されたことを確認した。sandbox の外で `git log -1 --format='%G? %GK'` を実行すると、`%G?` は `G` だった。`%GK` は Git に設定した公開鍵の fingerprint と一致した。

sandbox 内で同じ `git log` を実行すると、Git が `op-ssh-sign.exe` を起動できず、`Function not implemented` が出た。署名の判定は sandbox 外での検証結果を使う。

## 未確認

- `sandbox_workspace_write.network_access` を `true` にした後、sandbox 内の外向き通信が実際に通るか。この Windows 機の `config.toml` の値が `true` であることは、`chezmoi diff ~/.codex` が空であることで確かめた（2026-11-10）。
- mac の Codex が `~/.ssh` の秘密鍵を実際に読めるか。`~/.ssh/config` までしか確かめていない。
- `dot_config/zsh/dot_zshenv` の署名用 socket の条件は、Codex の署名のために足した。Claude Code に要るかは確かめていないので残している。

## git-commit の識別子検査

Windows は既存セットアップ対象の PowerShell 7、macOS は sh で同梱 script を呼ぶ。配置の解決と停止条件は `dot_codex/skills/git-commit/SKILL.md`、二つの実装を持つ理由と回帰検査は [git-commit-skill-design.md](./git-commit-skill-design.md#codex-の-os-ごとの識別子検査) にある。

2026-11-11 に Windows の `workspace-write`（Windows sandbox の設定値 `mxc`）で PowerShell 7 の `-File` による検査を確認した。実行ポリシーは RemoteSigned。前版の Windows target の一致と配布先の検査、子 agent の初期一覧からの skill 発見と最新版本文の読み取りは確認済み。helper 一式と Claude 側の sh は apply 後に正本との一致を確認済み。配布済み Windows 版の 54 ケースも成功した。macOS の配布先と sandbox 内の実行も確認済み。実測は [git-commit-skill-design.md](./git-commit-skill-design.md#codex-の-os-ごとの識別子検査) にある。apply はユーザーが行う。
