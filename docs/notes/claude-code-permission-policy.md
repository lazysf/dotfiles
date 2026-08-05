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
- secret の env 経路は `env` の `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` で塞ぐ。sandboxed Bash は親プロセスの環境変数を継承するため、file 側（`denyRead`）だけでは credential が subprocess から見える。
- `sandbox.network.allowedDomains` は `github.com` に加え、repo 保守で実際に使う `registry.npmjs.org`（npm）/ `pypi.org` / `files.pythonhosted.org`（uv・prek）だけ許可する。`strictAllowlist` は採用せず、許可外 host は従来どおり session ごとの prompt で判断する。

## `autoMode`（classifier 層）

permissions とは別レイヤとして扱う。permissions（`deny` / `allow` / 既定 prompt）は tool call 前に pattern で解決し、`autoMode` は auto mode 中に classifier が読む自然文の文脈と rule を与える。評価順は permissions が先で、`deny` と内容指定 `ask` は classifier より前に効く。

- `autoMode.environment` だけを設定し、`allow` / `soft_deny` / `hard_deny` は built-in のまま使う。設定するのは信頼範囲と sensitive 範囲の宣言までとし、block rule 自体は上書きしない。
- **4 配列のいずれを設定する場合も `"$defaults"` を含める。** 含めないとその配列の built-in rule が丸ごと置き換わる。force push、`curl | bash`、production deploy などは `soft_deny` の built-in に入っている。
- `environment` の entry は、実機 `claude auto-mode defaults` が使う slot 名（`Organization`、`Repository visibility`、`Source control`、`Sensitive data locations & audiences` 等）に合わせて書く。slot 名が一致した時だけ、その slot の `None configured` や既定 heuristic が置き換わる。
- 宣言は緩める方向だけでなく締める方向にも使う。credential store を `Sensitive data locations & audiences` に具体 path で列挙し、dotfiles repo の「自身の subject matter なら個人データも可」という built-in 例外に飲み込ませない。`Repository visibility: public` も事実として明示し、public repo への secret 混入を classifier に厳しく見させる。
- **classifier の誤 block を permission 緩和で直さない。** `deny` を外す、`allowedDomains` を広げる、`allowUnsandboxedCommands` を `true` にする、はいずれも別レイヤの防御を削る操作になる。誤 block は `autoMode.environment` の文脈不足として扱い、`environment` への追記で直す。
- `autoMode.classifyAllShell` は採用しない。narrow allow rule まで classifier 経由になり latency が増える。
- `autoMode` は user settings と managed settings からしか読まれない。`.claude/settings.json` / `.claude/settings.local.json` へ置いても無視される。

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
