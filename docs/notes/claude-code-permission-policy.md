# Claude Code Permission Policy

`dot_claude/settings.json` の permissions は、`ask` を置かず、`deny` を必要最小限に保つ。`allow` は read-only subagent の起動許可に限って置く。

## 方針

- `allow` は `Agent(researcher)` / `Agent(quality-reviewer)` / `Agent(security-reviewer)` だけに置き、workflow 上必要な read-only subagent の起動を追加確認なしにする（ADR 0033 / 0035）。tool 実行や停止線の判断は別に維持する。
- subagent ごとの read-only 強制は subagent 定義の `tools` で表現する。`researcher` は `Read, Glob, Grep` のみで純粋 read-only。`quality-reviewer` / `security-reviewer` は `Read, Glob, Grep, Bash` を持つが、Bash は Claude Code built-in read-only command（read-only forms of git、`ls`、`cat`、`grep` 等）と session 全体の既存 deny rule の範囲で実質 read-only として運用し、write 系操作は subagent 契約として実行しない（ADR 0038）。
- `Read(//**/.env)`、`Read(//**/.env.*)`、`Read(//**/secrets/**)` で secret read を止める。
- home credential store は `~/` anchor で止める。現状の対象は `~/.ssh/**`（SSH key）、`~/.aws/**`（AWS credential）、`~/.config/gh/**`（GitHub auth）、`~/.gnupg/**`（GPG key）、`~/.kube/**`（Kubernetes config）、`~/.docker/config.json`（registry auth）、`~/.netrc`（HTTP auth）、`~/.npmrc` / `~/.pypirc`（package registry token）。新規 credential store を見つけたら追加する。
- root / home 削除、filesystem format、auth / secret 管理破壊、external network CLI を `deny` する。external network CLI は exfil 経路として `curl` / `wget` / `nc` を明示 deny する。`ssh` / `scp` / `rsync` などの通常運用 network CLI は deny しない。sandbox `network.allowedDomains` で許可ホストを絞るが、許可外 host は block ではなく prompt になる（下記「根拠」参照）。最終的な歯止めは prompt + LLM 契約と停止線。
- reviewer subagent の Bash 契約（write 系を実行しない）の強制力は LLM 遵守依存のため、深層防御として exfiltration 経路の代表形（`Bash(git remote set-url *)` / `Bash(git remote add *)`）を `deny` で塞ぐ。網羅ではない。`git config remote.origin.url <URL>` や `git push <URL> HEAD` のような URL 直指定は覆えていない。`git commit *` / `git push *` 等の write 系 git は main session の `git-commit` / `git-push` skill が使うため deny 不可、契約 + Claude Code default prompt（built-in read-only set 外は prompt） + sandbox で防御する。
- package publish は `npm` / `pnpm` / `yarn` / `yarn npm` の `publish` を bare 形と引数付きの 2 形で `deny` し、Codex の `dot_codex/rules/*-publish.rules`（`forbidden`）と対称にする。`registry.npmjs.org` を allowedDomains へ入れた結果、network 側が publish の checkpoint にならなくなったため、settings 側に明示的な歯止めを置く。deploy、release、push は引き続き settings で個別網羅せず、既定 prompt、専用 workflow、skill 停止線で扱う。
- auto memory は secret persistence を避けるため無効化する。
- secret の env 経路は塞がない。`env.CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` は 2026-08-05 に削除した（理由は下記「`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` を外した理由」）。sandboxed Bash は親プロセスの環境変数を継承するため、`printenv` 等で credential env が subprocess から見える状態を許容し、持ち出し側（network allowlist、`curl` / `wget` / `nc` の deny、credential store の `denyRead`）で止める設計にする。
- `sandbox.network.allowedDomains` は `github.com` に加え、repo 保守で実際に使う `registry.npmjs.org`（npm）/ `pypi.org` / `files.pythonhosted.org`（uv・prek）だけ許可する。`strictAllowlist` は採用せず、許可外 host は従来どおり session ごとの prompt で判断する。
- `sandbox.excludedCommands` は使わない。sandbox 内から SSH remote（`git@github.com`）へ `git push` すると `nc: authentication method negotiation failed` で失敗する。`allowedDomains` は HTTP(S) proxy 用の許可で SSH を運ばないためで、`excludedCommands: ["git"]` を入れても解決しなかった（2026-08-05 実測）。`allowUnsandboxedCommands` を `true` へ戻す案は、失敗した全 command に sandbox 外再試行を開くので採らない。**push は人が手元の terminal で打つ**運用を正とし、agent は commit までを担う。

- `autoMode` は設定せず、classifier の built-in rule をそのまま使う。auto mode 中の誤 block を `deny` の緩和、`allowedDomains` の拡張、`allowUnsandboxedCommands: true` で直さない。それらは別レイヤの防御を削る操作になる。誤 block が実際に観測されたら、`autoMode.environment` に必要な entry だけを足す。その際は 4 配列（`environment` / `allow` / `soft_deny` / `hard_deny`）のいずれにも `"$defaults"` を含める。含めないとその配列の built-in（force push、`curl | bash`、production deploy 等）が丸ごと置き換わる。
- `sandbox.autoAllowBashIfSandboxed` は書かず、default の `true` に任せる。`false` にすると "Regular permissions mode" になり、auto mode では sandbox 済み Bash も 1 本ごとに classifier 往復が入る。

## `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` を外した理由

- **この env var は permission mode を `default` に強制する。** `--permission-mode auto` を明示して起動すると Claude Code 自身がこう警告する: `Permission mode forced to default — CLAUDE_CODE_SUBPROCESS_ENV_SCRUB is set (allowed_non_write_users hardening). Declare allowedTools explicitly, or set CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=0 to opt out.` desktop app の UI では「このセッションでは自動モードを使用できません。代わりに権限をリクエストします」と表示される。
- 対照実験（v2.1.221）: `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=0` を付けて起動すると警告は出ない。未指定で settings の `"1"` を継承すると警告が出る。
- この結果、`permissions.defaultMode: "auto"` と、切り分け中に追加した `sandbox.autoAllowBashIfSandboxed: true` / `autoMode.environment`（どちらも真因判明後に削除）はすべて死に設定になっていた。session は auto で始まったように見えて、最初の入力を処理する時点で `default` へ落ちる。transcript 上も最初の user entry が既に `permissionMode: "default"` で、classifier の block は 1 件も発生していない。
- 警告が示すもう一方の道（`allowedTools` を明示宣言して scrub を維持）は採らない。auto mode では broad な allow rule が drop される仕様のため、実効性が検証できない。
- **教訓**: この env var は「受け付ける値を公式 docs で確認できないまま、他 flag の慣例に合わせて `"1"` を置いた」設定だった。挙動を確認できない設定を防御目的で足すと、別の機構を黙って壊すことがある。値と副作用の両方を確認できない設定は入れない。
- 失った層は「Anthropic / cloud provider credential を subprocess の環境変数から除去する」こと。残る層は sandbox network allowlist（4 host）、`Bash(curl *)` / `Bash(wget *)` / `Bash(nc *)` の deny、credential store の `denyRead` / `denyWrite`。

## Windows の限界

- Claude Code の sandbox は native Windows 非対応（公式明記）。`settings.json.tmpl` は Windows で `sandbox.enabled` を `false` にするため、`denyRead` / `denyWrite` / `allowedDomains` の防御はすべて効かない。
- Windows の shell tool は PowerShell で、`Bash(...)` rule は PowerShell 呼び出しに適用されない。そのため `PowerShell(...)` 版 deny を別途置く（network CLI: `Invoke-WebRequest` / `Invoke-RestMethod` / `iwr` / `irm` / `curl.exe` / `wget.exe`、auth / secret 破壊: `gh auth logout` / `op item delete`、remote 書き換え: `git remote set-url` / `git remote add`、disk: `Format-Volume` / `Clear-Disk` / `Initialize-Disk` / `diskpart` / `format`）。
- **この列挙は網羅ではなく、素の誤呼び出しを止める speed bump。** PowerShell は prefix match を容易に外せる。素通りする代表形: `curl https://...` / `wget https://...`（PS 5.1 では `Invoke-WebRequest` の alias、PS 7 では PATH の `curl.exe` に解決され、どちらの pattern にも当たらない）、`$u='https://...'; iwr $u`（`;` 連結で prefix が崩れる）、`gh.exe auth logout` / `op.exe item delete`（`.exe` 付き）、`(New-Object Net.WebClient).UploadString(...)`（cmdlet を使わない .NET 直呼び）、`certutil -urlcache -split -f <URL>` / `Start-BitsTransfer` / `bitsadmin /transfer`。`Bash(nc *)` に対応する PowerShell 側 guard（`ncat`、`Net.Sockets.TcpClient`）も置いていない。
- 削除系も同様に、command 名でなく引数で危険度が決まるため rule で堅く塞げない（公式も argument 制約 pattern は fragile と明記）。`Remove-Item -Recurse -Force` の `C:\*` / `$HOME*` / `$env:USERPROFILE*` の 3 形だけ deny しているが、alias（`ri` / `rm` / `del` / `rd`）、flag 順の入れ替え、`Get-ChildItem C:\ | Remove-Item -Recurse -Force` のような pipe 形は覆えない。
- したがって Windows での実効防御は permission rule ではなく、公式推奨どおり **WSL2 上の Claude Code**（sandbox が動く）に寄せる。native Windows で使う場合は prompt を実質の唯一の歯止めとして扱う。

## 根拠

- Claude Code permissions docs では、`Read(//**/.env)` は filesystem-wide `.env` に match する。
- arbitrary subprocess の file read は permissions だけでは覆えないため、home credential store は sandbox `denyRead` / `denyWrite` でも守る（Windows ではこの層が無い）。
- sandbox の network 制御は「許可外 host は初回に prompt、許可すると当該 session 中は再 prompt しない」挙動。hard block は `strictAllowlist` が必要で、公式は `github.com` のような広い許可自体が exfil 経路になり得る（TLS 非検査 / domain fronting）と明記している。
