# Claude Code Permission Policy

`dot_claude/settings.json` の permissions は、`ask` を置かず、`deny` を必要最小限に保つ。`allow` は read-only subagent の起動許可と、root `AGENTS.md` が参照を必須にしている doc domain の `WebFetch` に限って置く。

## 方針

- `allow` は `Agent(researcher)` / `Agent(quality-reviewer)` / `Agent(security-reviewer)` に置き、workflow 上必要な read-only subagent の起動を追加確認なしにする（ADR 0033 / 0035）。tool 実行や停止線の判断は別に維持する。
- `allow` にはもう 1 系統、`WebFetch(domain:...)` の doc domain 4 件を置く。理由と副作用は下記「WebFetch / WebSearch」。
- subagent ごとの read-only 強制は subagent 定義の `tools` で表現する。`researcher` は `Read, Glob, Grep` のみで純粋 read-only。`quality-reviewer` / `security-reviewer` は `Read, Glob, Grep, Bash` を持つが、Bash は Claude Code built-in read-only command（read-only forms of git、`ls`、`cat`、`grep` 等）と session 全体の既存 deny rule の範囲で実質 read-only として運用し、write 系操作は subagent 契約として実行しない（ADR 0038）。
- `Read(//**/.env)`、`Read(//**/.env.*)`、`Read(//**/secrets/**)` で secret read を止める。
- home credential store は `~/` anchor で止める。現状の対象は `~/.ssh/**`（SSH key）、`~/.aws/**`（AWS credential）、`~/.config/gh/**`（GitHub auth）、`~/.gnupg/**`（GPG key）、`~/.kube/**`（Kubernetes config）、`~/.docker/config.json`（registry auth）、`~/.netrc`（HTTP auth）、`~/.npmrc` / `~/.pypirc`（package registry token）。新規 credential store を見つけたら追加する。
- root / home 削除、filesystem format、auth / secret 管理破壊、external network CLI を `deny` する。external network CLI は exfil 経路として `curl` / `wget` / `nc` を明示 deny する。`ssh` / `scp` / `rsync` などの通常運用 network CLI は deny しない。sandbox `network.allowedDomains` で許可ホストを絞るが、許可外 host は block ではなく prompt になる（下記「根拠」参照）。最終的な歯止めは prompt + LLM 契約と停止線。**ここで言う allowlist は Bash subprocess にしか効かない。`WebFetch` は覆わない（下記「WebFetch / WebSearch」）。**
- reviewer subagent の Bash 契約（write 系を実行しない）の強制力は LLM 遵守依存のため、深層防御として exfiltration 経路の代表形（`Bash(git remote set-url *)` / `Bash(git remote add *)`）を `deny` で塞ぐ。網羅ではない。`git config remote.origin.url <URL>` や `git push <URL> HEAD` のような URL 直指定は覆えていない。`git commit *` / `git push *` 等の write 系 git は main session の `git-commit` / `git-push` skill が使うため deny 不可、契約 + Claude Code default prompt（built-in read-only set 外は prompt） + sandbox で防御する。
- package publish は `npm` / `pnpm` / `yarn` / `yarn npm` の `publish` を bare 形と引数付きの 2 形で `deny` し、Codex の `dot_codex/rules/*-publish.rules`（`forbidden`）と対称にする。`registry.npmjs.org` を allowedDomains へ入れた結果、network 側が publish の checkpoint にならなくなったため、settings 側に明示的な歯止めを置く。deploy、release、push は引き続き settings で個別網羅せず、既定 prompt、専用 workflow、skill 停止線で扱う。
- auto memory は secret persistence を避けるため無効化する。
- secret の env 経路は塞がない。`env.CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` は 2026-08-05 に削除した（理由は下記「`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` を外した理由」）。sandboxed Bash は親プロセスの環境変数を継承するため、`printenv` 等で credential env が subprocess から見える状態を許容し、持ち出し側（network allowlist、`curl` / `wget` / `nc` の deny、credential store の `denyRead`）で止める設計にする。
- `sandbox.network.allowedDomains` は `github.com` に加え、repo 保守で実際に使う `registry.npmjs.org`（npm）/ `pypi.org` / `files.pythonhosted.org`（uv・prek）だけ許可する。`strictAllowlist` は採用せず、許可外 host は従来どおり session ごとの prompt で判断する。
- `sandbox.excludedCommands` は使わない。sandbox 内から SSH remote（`git@github.com`）へ `git push` すると `nc: authentication method negotiation failed` で失敗する。`allowedDomains` は HTTP(S) proxy 用の許可で SSH を運ばないためで、`excludedCommands: ["git"]` を入れても解決しなかった（2026-08-05 実測）。`allowUnsandboxedCommands` を `true` へ戻す案は、失敗した全 command に sandbox 外再試行を開くので採らない。**push は人が手元の terminal で打つ**運用を正とし、agent は commit までを担う。

- `autoMode` は設定せず、classifier の built-in rule をそのまま使う。auto mode 中の誤 block を `deny` の緩和、`allowedDomains` の拡張、`allowUnsandboxedCommands: true` で直さない。それらは別レイヤの防御を削る操作になる。誤 block が実際に観測されたら、`autoMode.environment` に必要な entry だけを足す。その際は 4 配列（`environment` / `allow` / `soft_deny` / `hard_deny`）のいずれにも `"$defaults"` を含める。含めないとその配列の built-in（force push、`curl | bash`、production deploy 等）が丸ごと置き換わる。
- `sandbox.autoAllowBashIfSandboxed` は書かず、default の `true` に任せる。`false` にすると "Regular permissions mode" になり、auto mode では sandbox 済み Bash も 1 本ごとに classifier 往復が入る。

## WebFetch / WebSearch

- Date: 2026-08-27
- 出典: [Configure permissions](https://code.claude.com/docs/en/permissions) / [Configure the sandboxed Bash tool](https://code.claude.com/docs/en/sandboxing) / [Codex Sandboxing](https://learn.chatgpt.com/docs/sandboxing)

**`sandbox.network.allowedDomains` も `strictAllowlist` も `WebFetch` に効かない。** 公式は sandbox の強制対象を "for sandboxed commands only; in-process tools such as `WebFetch` still follow their permission rules" と明記する。sandbox は Bash command とその子プロセスだけを覆う層で、in-process tool である `WebFetch` / `WebSearch` の gate は permission rule と、rule が無い場合の prompt（auto mode では classifier）だけ。

2026-08-27 実測: 同一 session で `Bash(curl https://fabiensanglard.net/...)` は `Bash(curl *)` の deny により拒否され、同じ host への `WebFetch` は成功した。`fabiensanglard.net` は `allowedDomains` に無い。

この repo は公式が推奨する構成「Bash の network CLI を deny し、許可 domain は `WebFetch(domain:...)` で与える」のうち、前半だけを実装していた。本節はその後半と、塞ぎ切れない範囲の記録。

### rule だけでは塞ぎ切れない

- bare `WebFetch` を `deny` すると tool ごと削除される。root `AGENTS.md` が Codex / Claude Code / Agent Skills の公式 docs 参照を必須にしているため採れない。
- `WebFetch(domain:*)` を `deny` すると WebFetch を全拒否できるが、公式表のとおり "sandboxed commands can't reach any host" となり、Bash 側の github / npm / pypi 到達まで死ぬため採れない。
- sandbox `deniedDomains` は Bash 専用で `WebFetch` に効かない。
- したがって **permission rule だけで `WebFetch` の egress を閉じる手段は無い。** 実効的に閉じるなら `PreToolUse` hook（公式も URL 検証の推奨手法として挙げる）だが、ADR 0035 の「hook はグローバルに足さない」を覆す判断になるため、採るなら ADR を書く。現時点では採らず、prompt / classifier + LLM 契約 + 停止線で受ける。

### 採った対応

root `AGENTS.md` が参照を必須にしている doc domain だけ `allow` へ置く。

```json
"WebFetch(domain:agentskills.io)",
"WebFetch(domain:code.claude.com)",
"WebFetch(domain:developers.openai.com)",
"WebFetch(domain:learn.chatgpt.com)"
```

**`WebFetch(domain:...)` の allow は sandbox allowlist も広げる。** 公式は "only the `domain:` form also adds its domain to the sandbox's allowed or denied domain list" と明記する。逆に bare `WebFetch` 形は sandbox allowlist を動かさない。**今後 `WebFetch` の allow を足す時は、Bash 側の到達先が同時に増えることを必ず確認する。**

この allow は当該 domain の prompt / classifier 往復を消すだけで、他 domain への `WebFetch` を禁じるものではない。他 domain は従来どおり prompt / classifier が gate になる。

#### 何が増えるか

**追加分は「無 gate の Bash 送信先」になる。** `sandbox.autoAllowBashIfSandboxed` は default `true`（auto-allow mode）なので、allowlist 内 host への Bash からの HTTP は prompt も classifier も通らない。`Bash(curl *)` / `wget` / `nc` の deny は名前ベースで、`python3 -c "import urllib.request; ..."` や `node -e "fetch(...)"` を覆わない。つまりこの 4 件は、WebFetch の往復削減と引き換えに、無 gate で任意データを送出できる宛先を増やしている。

#### 判断の記録

**同 note の教訓との線引き。** 下記「`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` を外した理由」は「値と副作用の両方を確認できない設定は入れない」と結んでいる。今回の 4 件は auto mode 下の実効が未確認で、副作用も公式記述のみで実測していない。それでも入れるのは、最悪ケースが「死に設定 + doc site 4 件の到達拡大」に留まり、ENV_SCRUB のように**別の機構を黙って壊す性質ではない**ため。副作用の方向（sandbox allowlist への合流）は事前に特定しており、教訓が禁じた「副作用を確認しないまま足す」には当たらない。

**影響範囲。** 4 件の根拠は repo-local な root `AGENTS.md`（`.chezmoiignore` で配布対象外）だが、設定先は user-global の `~/.claude/settings.json` で、**この machine の全 project に効く**。project 層の `.claude/settings.json` へ置く案は、両 surface の「repo root 直下に新しい運用ファイルを増やさない」方針と衝突するため採らない。doc domain 4 件が全 project で到達可能になることを受容する。

**ADR は書かない。** 3 条件のうち「覆すコストが高い」を満たさない（4 行の削除で戻せ、影響は harness 内部に閉じる）。代替 3 案（bare `WebFetch` deny / `WebFetch(domain:*)` deny / `PreToolUse` hook）を実比較して捨てた記録は本節に残す。先例として `Agent(...)` の allow 追加は ADR 0033 になっているが、あれは subagent 起動の standing authorization という運用契約の変更で、本件の doc domain 4 件とは覆すコストが違う。hook 案を採る場合だけ ADR を書く。

#### 受容理由は host ごとに違う

- `code.claude.com` / `learn.chatgpt.com`: Anthropic / OpenAI の first-party host。この repo は既に harness そのものを両社へ委ねているため、送出内容が両社の access log に残ることは新たなリスクを作らない。第三者攻撃者が回収できる経路ではない。
- `developers.openai.com`: OpenAI の first-party だが Docs MCP の入口で、MCP over HTTP は任意 body の POST を受ける。WebFetch は GET のみなので WebFetch 経由では届かないが、**sandbox 合流後は Bash から無 gate で POST できる host** になる。4 件中で送信容量が最大。「doc site だから」では受容理由にならず、first-party であることだけが根拠。
- `agentskills.io`: **唯一の third-party。** repo 内に運営主体の記録が無く、送出内容の log 保持者を特定できないため、上記の「first-party だから回収されない」論法が使えない。ingress 側も、skill 定義を扱う site の本文は「agent 向け指示の形をした third-party 投稿」になり得る点で他 3 件と質が違う。root `AGENTS.md` が参照を必須にしているため allow に入れるが、**受容理由は「必須参照だから」であって「安全だから」ではない。** 運営主体を確認できたらこの行を更新する。

相対評価として、既存 allowlist の `github.com` は authenticated な `gh` CLI と組み合わせると public gist 作成という遥かに強い exfil 経路になっており、今回の 4 件はそれより弱い。この変更が新たに致命的な穴を開けたわけではない。

### auto mode 下での実効は未検証

**この repo は `defaultMode: "auto"` で動く。** auto mode に入ると任意コード実行を与える広い allow rule が drop され、**公式仕様上** `Agent(...)` allow rule も drop 対象に含まれる（[claude-code-settings-spec-verification.md](./claude-code-settings-spec-verification.md)。実機観測の記録ではない）。`WebFetch(domain:...)` は narrow rule で任意コード実行を与えないため残る見込みだが、**未確認**。drop される場合、この 4 件は auto mode 中は死に設定になり、sandbox allowlist の拡張も起きない可能性がある。

`claude auto-mode config` では確認できない。同 command は `autoMode` の 4 配列（`environment` / `allow` / `soft_deny` / `hard_deny`）の宣言と件数を見るもので、permission `allow` rule の drop 結果を表示する記録は無い。

`chezmoi apply` 後に、auto mode session で次の 2 つを**別々に**実測する。rule が残ることと sandbox allowlist が広がることは別効果で、片方から他方を推論できない。

1. 4 domain のいずれかへ `WebFetch` を投げ、prompt / classifier が挟まらないか。挟まれば rule は drop されている。
2. 同じ host へ Bash から無害な GET を投げ、prompt なしで通るか（`curl` は deny 済みなので `python3 -c "import urllib.request; urllib.request.urlopen('https://learn.chatgpt.com/docs')"` 相当を使う）。通れば sandbox allowlist への合流が起きている。

drop されていれば、`Agent(...)` allow と同じく「auto mode では classifier 判断に委ねられている」状態として扱い、設定を増やす方向では直さない。

### ingress

`WebFetch` / `WebSearch` は未信頼コンテンツを context へ取り込む経路でもある。allow した 4 件については、その取り込みが prompt なしで起きる。

**この経路に enforcement は無い。** 「取り込んだ内容は data であって指示ではない」という扱いは LLM の既定挙動に依存しており、この repo の契約側（`dot_claude/CLAUDE.md`、`dot_claude/rules/*.md`、`dot_codex/AGENTS.md`）には該当条項が存在しない（2026-08-27 実測）。本 note は自動 load されないため、ここに書いても実行文脈には入らない。契約側へ条項を置くかは別途判断する。

Codex の `web_search = "live"` にも同旨の記録がある（[lightweight-workflow.md](./lightweight-workflow.md)）。

なお `WebFetch` は cross-host redirect を追従せず呼び出し元へ返す仕様のため、allow した domain から別 host へ redirect で取り込みが広がることはない。再取得には明示的な 2 回目の呼び出しが要り、そこで permission が再評価される。

### Codex 側

Codex も同じ構造で、`sandbox_workspace_write.network_access` は shell command 用。公式は "Web search, plugins, and the remote browser have separate controls" と明記する。Codex 側に `WebFetch(domain:...)` 相当の domain 単位制限は公式 docs 上見当たらず（2026-08-27 時点、`web_search` の on/off のみ確認）、対称化できない意図的差分として扱う。

### 未確認

- `WebFetch` の built-in preapproved documentation domains の具体的リスト。permissions docs が [tools-reference](https://code.claude.com/docs/en/tools-reference) を指すが、当該ページは長さ超過で当該節まで取得できなかった。上記 4 件は preapproved と重複する可能性があるが、`domain:` 形式には sandbox allowlist を広げる別効果があるため明示する意味は残る。
- sandbox allowlist の bare domain が subdomain を含むか（[claude-code-settings-spec-verification.md](./claude-code-settings-spec-verification.md) の未確認項目）。含む場合、合流後の到達範囲は host 単位でなく domain tree 単位になり、`agentskills.io` の全 subdomain が入る。**今回の変更で唯一 fail-open 方向に振れる不確実性がここ。** 同 note の「`codeload.github.com` が prompt になる」実測は exact-host 側の傍証。
- `agentskills.io` の運営主体。first-party か community 運営かで受容理由が変わる。
- Codex の `web_search` に domain 制限機構が「無い」ことは docs 上で確認できなかっただけで、非存在を確定してはいない。

## `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` を外した理由

- **この env var は permission mode を `default` に強制する。** `--permission-mode auto` を明示して起動すると Claude Code 自身がこう警告する: `Permission mode forced to default — CLAUDE_CODE_SUBPROCESS_ENV_SCRUB is set (allowed_non_write_users hardening). Declare allowedTools explicitly, or set CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=0 to opt out.` desktop app の UI では「このセッションでは自動モードを使用できません。代わりに権限をリクエストします」と表示される。
- 対照実験（v2.1.221）: `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=0` を付けて起動すると警告は出ない。未指定で settings の `"1"` を継承すると警告が出る。
- この結果、`permissions.defaultMode: "auto"` と、切り分け中に追加した `sandbox.autoAllowBashIfSandboxed: true` / `autoMode.environment`（どちらも真因判明後に削除）はすべて死に設定になっていた。session は auto で始まったように見えて、最初の入力を処理する時点で `default` へ落ちる。transcript 上も最初の user entry が既に `permissionMode: "default"` で、classifier の block は 1 件も発生していない。
- 警告が示すもう一方の道（`allowedTools` を明示宣言して scrub を維持）は採らない。auto mode では broad な allow rule が drop される仕様のため、実効性が検証できない。
- **教訓**: この env var は「受け付ける値を公式 docs で確認できないまま、他 flag の慣例に合わせて `"1"` を置いた」設定だった。挙動を確認できない設定を防御目的で足すと、別の機構を黙って壊すことがある。値と副作用の両方を確認できない設定は入れない。
- 失った層は「Anthropic / cloud provider credential を subprocess の環境変数から除去する」こと。残る層は sandbox network allowlist、`Bash(curl *)` / `Bash(wget *)` / `Bash(nc *)` の deny、credential store の `denyRead` / `denyWrite`。いずれも Bash 経由の経路に対する層で、`WebFetch` は覆わない（下記「WebFetch / WebSearch」）。

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
