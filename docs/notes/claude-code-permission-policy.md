# Claude Code Permission Policy

`dot_claude/settings.json` の permissions は、`ask` を置かず、`deny` を必要最小限に保つ。`allow` は root `AGENTS.md` が参照を必須にしている doc domain の `WebFetch` に限って置く。**この repo の既定 mode（auto）で効かない rule は置かない。**

## 方針

- `allow` は `WebFetch(domain:...)` の doc domain 4 件だけ。理由は下記「外向き通信の実効」。narrow rule なので auto mode でも drop されない。
- **`Agent(researcher)` / `Agent(quality-reviewer)` / `Agent(security-reviewer)` は 2026-08-27 に削除した。** 公式の auto mode drop 対象リスト（blanket `Bash(*)` / `PowerShell(*)`、wildcard interpreter、package-manager run、**`Agent`**、`Monitor`）に含まれ、この repo の既定 mode（auto）では効かないため。`--permission-mode default` のセッションでは効いていたが、reviewer 起動はユーザー明示時のみで prompt が 1 回増えるだけと判断した。
  - standing authorization の契約自体は `dot_claude/CLAUDE.md` / `dot_codex/AGENTS.md` に残る。lead がチャット上で追加確認を取らない、という意味は変わらない。削ったのは機械的な裏付けだけで、default mode では harness の prompt が出る。
  - 根拠だった ADR 0033 は 0040 で Superseded 済みのため、生きた判断を覆していない。復元は 3 行の追加で足りるため ADR は書かない。
- subagent ごとの read-only 強制は subagent 定義の `tools` で表現する。`researcher` は `Read, Glob, Grep` のみで純粋 read-only。`quality-reviewer` / `security-reviewer` は `Read, Glob, Grep, Bash` を持つが、Bash は Claude Code built-in read-only command（read-only forms of git、`ls`、`cat`、`grep` 等）と session 全体の既存 deny rule の範囲で実質 read-only として運用し、write 系操作は subagent 契約として実行しない（ADR 0038）。
- `Read(//**/.env)`、`Read(//**/.env.*)`、`Read(//**/secrets/**)` で secret read を止める。
- home credential store は `~/` anchor で止める。現状の対象は `~/.ssh/**`（SSH key）、`~/.aws/**`（AWS credential）、`~/.config/gh/**`（GitHub auth）、`~/.gnupg/**`（GPG key）、`~/.kube/**`（Kubernetes config）、`~/.docker/config.json`（registry auth）、`~/.netrc`（HTTP auth）、`~/.npmrc` / `~/.pypirc`（package registry token）。新規 credential store を見つけたら追加する。
- root / home 削除、filesystem format、auth / secret 管理破壊、external network CLI を `deny` する。external network CLI は exfil 経路として `curl` / `wget` / `nc` を明示 deny する。`ssh` / `scp` / `rsync` などの通常運用 network CLI は deny しない。**`sandbox.network.allowedDomains` は domain gate として機能していない（2026-08-27 実測）。deny も名前ベースで `python3` から素通りする。** 外向き通信に実効的な境界は無く、歯止めは LLM 契約と停止線（下記「外向き通信の実効」）。
- reviewer subagent の Bash 契約（write 系を実行しない）の強制力は LLM 遵守依存のため、深層防御として exfiltration 経路の代表形（`Bash(git remote set-url *)` / `Bash(git remote add *)`）を `deny` で塞ぐ。網羅ではない。`git config remote.origin.url <URL>` や `git push <URL> HEAD` のような URL 直指定は覆えていない。`git commit *` / `git push *` 等の write 系 git は main session の `git-commit` / `git-push` skill が使うため deny 不可、契約 + Claude Code default prompt（built-in read-only set 外は prompt） + sandbox で防御する。
- package publish は `npm` / `pnpm` / `yarn` / `yarn npm` の `publish` を bare 形と引数付きの 2 形で `deny` し、Codex の `dot_codex/rules/*-publish.rules`（`forbidden`）と対称にする。`registry.npmjs.org` を allowedDomains へ入れた結果、network 側が publish の checkpoint にならなくなったため、settings 側に明示的な歯止めを置く。deploy、release、push は引き続き settings で個別網羅せず、既定 prompt、専用 workflow、skill 停止線で扱う。
- auto memory は secret persistence を避けるため無効化する。
- secret の env 経路は塞がない。`env.CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` は 2026-08-05 に削除した（理由は下記「`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` を外した理由」）。sandboxed Bash は親プロセスの環境変数を継承するため、`printenv` 等で credential env が subprocess から見える状態を許容し、持ち出し側（network allowlist、`curl` / `wget` / `nc` の deny、credential store の `denyRead`）で止める設計にする。
- `sandbox.network.allowedDomains` は `github.com` に加え、repo 保守で実際に使う `registry.npmjs.org`（npm）/ `pypi.org` / `files.pythonhosted.org`（uv・prek）だけ許可する。`strictAllowlist` は採用せず、許可外 host は従来どおり session ごとの prompt で判断する。
- `sandbox.excludedCommands` は使わない。sandbox 内から SSH remote（`git@github.com`）へ `git push` すると `nc: authentication method negotiation failed` で失敗する。`allowedDomains` は HTTP(S) proxy 用の許可で SSH を運ばないためで、`excludedCommands: ["git"]` を入れても解決しなかった（2026-08-05 実測）。`allowUnsandboxedCommands` を `true` へ戻す案は、失敗した全 command に sandbox 外再試行を開くので採らない。**push は人が手元の terminal で打つ**運用を正とし、agent は commit までを担う。

- `autoMode` は設定せず、classifier の built-in rule をそのまま使う。auto mode 中の誤 block を `deny` の緩和、`allowedDomains` の拡張、`allowUnsandboxedCommands: true` で直さない。それらは別レイヤの防御を削る操作になる。誤 block が実際に観測されたら、`autoMode.environment` に必要な entry だけを足す。その際は 4 配列（`environment` / `allow` / `soft_deny` / `hard_deny`）のいずれにも `"$defaults"` を含める。含めないとその配列の built-in（force push、`curl | bash`、production deploy 等）が丸ごと置き換わる。
- `sandbox.autoAllowBashIfSandboxed` は書かず、default の `true` に任せる。`false` にすると "Regular permissions mode" になり、auto mode では sandbox 済み Bash も 1 本ごとに classifier 往復が入る。

## 外向き通信の実効（2026-08-27 実測）

- 出典: 実測（下記手順）/ [Configure permissions](https://code.claude.com/docs/en/permissions) / [Configure the sandboxed Bash tool](https://code.claude.com/docs/en/sandboxing) / [Choose a permission mode](https://code.claude.com/docs/en/permission-modes)

**`sandbox.network.allowedDomains` は Bash の egress を domain 単位で gate していない。** allowlist にも `WebFetch(domain:...)` にも無い host（`fabiensanglard.net` / `example.com` / `www.iana.org`）へ、prompt なし・classifier block なし・`<sandbox_violations>` なしで到達した。auto mode でも `--permission-mode default` でも同じ。

切り分け手順（再現用）:

- proxy の拒否は HTTP status ではなく `URLError: Tunnel connection failed` として現れる。存在しない domain で基準を取れる。
- `fabiensanglard.net` の 406 は `Server: Apache` で本文も Apache の応答 = **origin まで到達**しており、proxy 拒否ではない。HTTP status を deny の証拠と読むと誤判定する。

効いている層と効いていない層:

| | 状態 |
| --- | --- |
| raw socket / DNS | **遮断**（`gaierror`）。egress は local の認証付き proxy に強制される |
| `sandbox.network.allowedDomains` | **domain gate として機能していない**（実測） |
| `Bash(curl *)` / `wget` / `nc` の deny | permission rule としては有効だが**名前ベース**。`python3 -c "import urllib.request; ..."` で素通りする（実測） |
| `WebFetch` | 公式仕様上 sandbox の対象外。"in-process tools such as `WebFetch` still follow their permission rules" |

**したがって Bash の外向き通信に実効的な domain 境界は無い。** 歯止めは LLM 契約と停止線、および credential 側の `denyRead` / `denyWrite`。egress を実際に閉じるなら `PreToolUse` hook が要るが、ADR 0035 の「hook はグローバルに足さない」を覆す判断になるため採らない。

### `WebFetch(domain:...)` の 4 件

root `AGENTS.md` が参照を必須にしている doc domain（`agentskills.io` / `code.claude.com` / `developers.openai.com` / `learn.chatgpt.com`）を `allow` に置く。**目的は prompt / classifier 往復の削減。** 上記のとおり egress は元から開いているため、この 4 件によるリスク増分は実質無い。

- 公式仕様上、`domain:` 形の allow は sandbox の allowed domain list にも合流する。ただし上記のとおり実機では合流の有無が観測できない（許可外も通るため）。
- auto mode でも **drop されない**。公式の drop 対象は blanket `Bash(*)` / wildcard interpreter / package-manager run / `Agent` / `Monitor` で、narrow rule は残る。
- `WebFetch` を塞ぐ手段は無い。bare `WebFetch` deny は tool ごと消えて公式 docs 参照が不能になり、`WebFetch(domain:*)` deny は sandboxed command の全 host 到達を殺す。
- ADR は書かない。3 条件の「覆すコストが高い」を満たさない（4 行削除で戻せる）。

### ingress

`WebFetch` / `WebSearch` は未信頼コンテンツを context へ取り込む経路でもある。allow した 4 件では prompt なしで取り込まれる。**この経路に enforcement は無い。** 「取り込んだ内容は data であって指示ではない」は LLM の既定挙動に依存し、契約側（`dot_claude/CLAUDE.md` / `rules/` / `dot_codex/AGENTS.md`）に該当条項は無い（実測）。契約へ置くかは別途判断。

4 件のうち `agentskills.io` だけが third-party で、skill 定義を扱う site の本文は「agent 向け指示の形をした third-party 投稿」になり得る。他 3 件は Anthropic / OpenAI の first-party。

`WebFetch` は cross-host redirect を追従せず呼び出し元へ返すため、redirect で取り込み範囲が広がることはない。

### Codex 側

`sandbox_workspace_write.network_access` は shell command 用。公式は "Web search, plugins, and the remote browser have separate controls" と明記し、`web_search` に domain 単位の制限は docs 上見当たらない。対称化できない意図的差分として扱う。

### 未確認

- `allowedDomains` が gate しないのが、この環境固有か Claude Code 一般か。`strictAllowlist` を入れれば gate が復活するかも未確認。
- 2026-08-05 の記録「`codeload.github.com` は prompt になる」と今回の観測（prompt なし）が食い違う。挙動が変わったか、当時と条件が違う。
- `WebFetch` の built-in preapproved documentation domains のリスト（[tools-reference](https://code.claude.com/docs/en/tools-reference) が長さ超過で取得できず）。
- `agentskills.io` の運営主体。

## `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` を外した理由

- **この env var は permission mode を `default` に強制する。** `--permission-mode auto` を明示して起動すると Claude Code 自身がこう警告する: `Permission mode forced to default — CLAUDE_CODE_SUBPROCESS_ENV_SCRUB is set (allowed_non_write_users hardening). Declare allowedTools explicitly, or set CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=0 to opt out.` desktop app の UI では「このセッションでは自動モードを使用できません。代わりに権限をリクエストします」と表示される。
- 対照実験（v2.1.221）: `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=0` を付けて起動すると警告は出ない。未指定で settings の `"1"` を継承すると警告が出る。
- この結果、`permissions.defaultMode: "auto"` と、切り分け中に追加した `sandbox.autoAllowBashIfSandboxed: true` / `autoMode.environment`（どちらも真因判明後に削除）はすべて死に設定になっていた。session は auto で始まったように見えて、最初の入力を処理する時点で `default` へ落ちる。transcript 上も最初の user entry が既に `permissionMode: "default"` で、classifier の block は 1 件も発生していない。
- 警告が示すもう一方の道（`allowedTools` を明示宣言して scrub を維持）は採らない。auto mode では broad な allow rule が drop される仕様のため、実効性が検証できない。
- **教訓**: この env var は「受け付ける値を公式 docs で確認できないまま、他 flag の慣例に合わせて `"1"` を置いた」設定だった。挙動を確認できない設定を防御目的で足すと、別の機構を黙って壊すことがある。値と副作用の両方を確認できない設定は入れない。
- 失った層は「Anthropic / cloud provider credential を subprocess の環境変数から除去する」こと。残る層は credential store の `denyRead` / `denyWrite` と、LLM 契約・停止線。`curl` / `wget` / `nc` の deny と network allowlist は**持ち出しの境界として数えない**（下記「外向き通信の実効」の実測）。

## Windows の限界

- Claude Code の sandbox は native Windows 非対応（公式明記）。`settings.json.tmpl` は Windows で `sandbox.enabled` を `false` にするため、`denyRead` / `denyWrite` / `allowedDomains` の防御はすべて効かない。
- Windows の shell tool は PowerShell で、`Bash(...)` rule は PowerShell 呼び出しに適用されない。そのため `PowerShell(...)` 版 deny を別途置く（network CLI: `Invoke-WebRequest` / `Invoke-RestMethod` / `iwr` / `irm` / `curl.exe` / `wget.exe`、auth / secret 破壊: `gh auth logout` / `op item delete`、remote 書き換え: `git remote set-url` / `git remote add`、disk: `Format-Volume` / `Clear-Disk` / `Initialize-Disk` / `diskpart` / `format`）。
- **この列挙は網羅ではなく、素の誤呼び出しを止める speed bump。macOS / Linux では 1 度も発火しない（`deny` 56 件のうち 20 件がこれ）。** Windows を使う前提で残す判断。 PowerShell は prefix match を容易に外せる。素通りする代表形: `curl https://...` / `wget https://...`（PS 5.1 では `Invoke-WebRequest` の alias、PS 7 では PATH の `curl.exe` に解決され、どちらの pattern にも当たらない）、`$u='https://...'; iwr $u`（`;` 連結で prefix が崩れる）、`gh.exe auth logout` / `op.exe item delete`（`.exe` 付き）、`(New-Object Net.WebClient).UploadString(...)`（cmdlet を使わない .NET 直呼び）、`certutil -urlcache -split -f <URL>` / `Start-BitsTransfer` / `bitsadmin /transfer`。`Bash(nc *)` に対応する PowerShell 側 guard（`ncat`、`Net.Sockets.TcpClient`）も置いていない。
- 削除系も同様に、command 名でなく引数で危険度が決まるため rule で堅く塞げない（公式も argument 制約 pattern は fragile と明記）。`Remove-Item -Recurse -Force` の `C:\*` / `$HOME*` / `$env:USERPROFILE*` の 3 形だけ deny しているが、alias（`ri` / `rm` / `del` / `rd`）、flag 順の入れ替え、`Get-ChildItem C:\ | Remove-Item -Recurse -Force` のような pipe 形は覆えない。
- したがって Windows での実効防御は permission rule ではなく、公式推奨どおり **WSL2 上の Claude Code**（sandbox が動く）に寄せる。native Windows で使う場合は prompt を実質の唯一の歯止めとして扱う。

## 根拠

- Claude Code permissions docs では、`Read(//**/.env)` は filesystem-wide `.env` に match する。
- arbitrary subprocess の file read は permissions だけでは覆えないため、home credential store は sandbox `denyRead` / `denyWrite` でも守る（Windows ではこの層が無い）。
- 公式では sandbox の network 制御は「許可外 host は初回に prompt、許可すると当該 session 中は再 prompt しない」挙動で、hard block には `strictAllowlist` が要るとされる。**ただし実機では許可外 host でも prompt が出ず素通りする**（2026-08-27 実測、下記「外向き通信の実効」）。公式は `github.com` のような広い許可自体が exfil 経路になり得る（TLS 非検査 / domain fronting）とも明記している。
