# Claude Code Settings 公式仕様確認

- Date: 2026-06-18
- 出典:
  - [Claude Code Settings](https://code.claude.com/docs/en/settings)
  - [Configure permissions](https://code.claude.com/docs/en/permissions)
  - [Create custom subagents](https://code.claude.com/docs/en/sub-agents)

`dot_claude/settings.json.tmpl` と `dot_claude/agents/*.md` で採用しているキー・値が、Claude Code 公式仕様に準拠しているかを 1 度確認した記録。次に同じ確認を行う時の出発点として残す。

## 確認結果

すべて公式仕様準拠。修正は不要。

| 確認対象 | 場所 | 公式仕様 |
| --- | --- | --- |
| `effortLevel: "high"` | `settings.json.tmpl` | `"low"`, `"medium"`, `"high"`, `"xhigh"` を受け付ける |
| `disableBypassPermissionsMode: "disable"` | `settings.json.tmpl` permissions | 値は文字列 `"disable"`。user-level / managed-settings どちらでも有効。**このキーが防ぐのは `bypassPermissions` だけ**で、`auto` を防ぐのは別キーの `permissions.disableAutoMode`（2026-08-05 追記。実機でもこの設定下で auto mode が動作している） |
| `permissions.defaultMode: "auto"` | `settings.json.tmpl` permissions | `default` / `acceptEdits` / `plan` / `auto` / `dontAsk` / `bypassPermissions` を受け付ける |
| `language: "japanese"` | `settings.json.tmpl` | 応答言語、voice dictation、自動生成セッションタイトルに反映される正式キー |
| `model: "claude-opus-5"` | `settings.json.tmpl` / agent frontmatter | full model ID 形式。`--model` フラグと同じ値域を受け付ける |
| subagent `effort: xhigh` / `high` | `agents/*.md` frontmatter | `low` / `medium` / `high` / `xhigh` / `max`。利用可能な値はモデル依存。`max` は settings.json では不可だが subagent frontmatter では受け付ける |
| subagent `permissionMode: plan` | `agents/*.md` frontmatter | `default` / `acceptEdits` / `auto` / `dontAsk` / `bypassPermissions` / `plan`。plugin subagent では無視される |
| subagent `color: orange` / `cyan` / `red` | `agents/*.md` frontmatter | `red` / `blue` / `green` / `yellow` / `purple` / `orange` / `pink` / `cyan` |

## 2026-07-30 追加分

- 出典: [Configure permissions](https://code.claude.com/docs/en/permissions) / [Configure the sandboxed Bash tool](https://code.claude.com/docs/en/sandboxing) / [How Claude remembers your project](https://code.claude.com/docs/en/memory)

| 確認対象 | 場所 | 公式仕様 |
| --- | --- | --- |
| `Bash(curl *)` 形式 | `settings.json.tmpl` deny | `*` は任意位置で使え、末尾 `*` の前に空白があると word boundary を要求する（`Bash(ls *)` は `ls -la` に match、`lsof` には match しない）。`:*` suffix は末尾限定で同義 |
| `PowerShell(...)` rule | `settings.json.tmpl` deny | 「PowerShell permission rules use the same shape as Bash rules」。`Bash(...)` とは別 namespace なので、Windows の PowerShell 経路は `Bash(...)` deny では覆えない |
| `sandbox.enabled` の Windows 挙動 | `settings.json.tmpl` | sandbox は macOS / Linux / WSL2 のみ。native Windows 非対応で、公式は WSL2 上での実行を案内している |
| `sandbox.network.allowedDomains` | `settings.json.tmpl` | 許可外 host は初回に prompt。許可すると当該 session 中は再 prompt しない。hard block は `strictAllowlist`（v2.1.219+、user / managed / CLI settings のみ）が必要 |
| rule frontmatter `paths` | `rules/*.md` | 正式キー。glob で指定し、`paths` なしの rule は launch 時に無条件 load。path 条件付き rule は「Claude が match するファイルを読んだ時」に load される |

## 2026-08-05 追加分

- 出典: [Choose a permission mode](https://code.claude.com/docs/en/permission-modes) / [Configure the sandboxed Bash tool](https://code.claude.com/docs/en/sandboxing) / [Configure permissions](https://code.claude.com/docs/en/permissions)
- 契機: `defaultMode: "auto"` を設定しているのに session が Manual に落ち、応答が遅くなる事象の切り分け。

| 確認対象 | 場所 | 公式仕様 |
| --- | --- | --- |
| `sandbox.autoAllowBashIfSandboxed` | `settings.json.tmpl` sandbox | default は `true`。`true` は auto-allow mode で、sandbox 内で実行できる Bash を prompt なしで自動承認する。`false` は "Regular permissions mode" となり、sandbox 済み Bash も通常の permission flow を通る（auto mode ではその flow が classifier） |
| auto mode の fallback 閾値 | 挙動 | classifier が **3回連続** または **累計20回** block すると auto mode が pause し、prompt が再開する。閾値は設定不可。prompt を承認すると auto に戻る。allow が 1 回入ると連続カウンタは reset、累計カウンタは session 中保持。`-p` の非対話実行では pause でなく session abort |
| auto mode 進入時の allow rule 除外 | `settings.json.tmpl` permissions | auto mode に入ると、任意コード実行を与える広い allow rule（blanket `Bash(*)` / `PowerShell(*)`、`Bash(python*)` 等の wildcard interpreter、package manager の run command、**`Agent` allow rule**）が drop される。auto mode を抜けると復帰。`Bash(npm test)` のような narrow rule は残る |
| `sandbox.allowUnsandboxedCommands: false` | `settings.json.tmpl` sandbox | `/sandbox` の Overrides タブで **Strict sandbox mode** と表示される状態。`dangerouslyDisableSandbox` parameter が完全に無視され、`excludedCommands` に列挙したもの以外は必ず sandbox 内で実行される（sandbox 制約で失敗した command を sandbox 外で retry できない） |
| auto mode 下の sandbox network 要求 | 挙動 | sandbox の network access 要求は default 許可ではなく classifier に routed される。verdict は host + port 単位で再利用され、allow は新しい content が会話に入るまで、deny は対話 CLI では turn 終了まで（非対話 / Agent SDK では run 終了まで）保持される。permission mode や rule を変えると cache は全破棄 |
| `defaultMode: "auto"` の置き場 | `settings.json.tmpl` | v2.1.142 以降、`.claude/settings.json` / `.claude/settings.local.json` の `auto` は無視される（repo が自分に auto を与えられないようにするため）。user settings（`~/.claude/settings.json`）に置く必要がある |
| `autoMode.environment` | `settings.json.tmpl` | classifier に渡す自然文の環境宣言。20 個の slot（`Organization` / `Repository visibility` / `Source control` / `Sensitive data locations & audiences` 等）があり、既定は 17 slot が `None configured`、残りは保守的 heuristic。slot 名を一致させて書くとその slot が置き換わる |
| `autoMode` の `"$defaults"` | `settings.json.tmpl` | `environment` / `allow` / `soft_deny` / `hard_deny` の 4 配列は、`"$defaults"` を含めない設定を書くとその配列の built-in が丸ごと置き換わる。配置位置に built-in が splice される |
| `autoMode` の読み取り scope | `settings.json.tmpl` | user settings、managed settings、`--settings` / Agent SDK の inline JSON からのみ読む。`.claude/settings.json` / `.claude/settings.local.json` は無視（後者は v2.1.207 以降）。各 scope の entry は結合され、developer 側の追記で managed の entry は消せない |

- 上記を受けて `sandbox.autoAllowBashIfSandboxed` を `false` から default の `true` に戻した。`false` のままだと Bash 1 本ごとに classifier の往復が入って遅く、classifier block が fallback カウンタに積まれて auto mode が pause しやすい。`true` に戻しても sandbox 境界（`denyRead` / `denyWrite` / `allowedDomains`）は OS が強制し、`permissions.deny`、内容指定 ask rule、`rm -rf /` 等の circuit breaker は従来どおり効く。
- `allowUnsandboxedCommands: false` と `failIfUnavailable: true` は据え置き。`allowedDomains` の拡張で解決しないことは [harness-regression-checks.md](./harness-regression-checks.md) の項目 23 で既に方針化済み（`github.com` / npm / PyPI の 3 系統に保ち、prompt になる host を許可で潰さない）。sandbox 外実行がどうしても要る場合の選択肢は `excludedCommands` だけで、これも実害が出てから検討する。
- `permissions.allow` の `Agent(researcher)` / `Agent(quality-reviewer)` / `Agent(security-reviewer)` は auto mode 下では drop されるため、auto mode で動いている限り standing authorization の実効は classifier 判断に委ねられている。今回は rule を変更していない。
- 実機 version は **2.1.221**。desktop app 経由の install で `claude` は PATH に無く、実体は `~/Library/Application Support/Claude/claude-code/<version>/claude.app/Contents/MacOS/claude`。このフルパスで `auto-mode defaults` / `auto-mode config` / `auto-mode critique` を実行できる。上記の version 依存挙動はすべて 2.1.221 で満たす。
- 実機 `claude auto-mode defaults` の built-in 件数は `allow` 17 / `soft_deny` 65 / `hard_deny` 1 / `environment` 20。`"$defaults"` の書き損じ検出はこの件数と突き合わせる。

## 補足

- `effortLevel` の採用根拠は [model-and-effort-tuning-history.md](./model-and-effort-tuning-history.md) の 2026-08-05 エントリ（Opus 5 の default effort `high` に合わせた）に記録済み。`xhigh` を採用していた経緯は同 notes の 2026-06-18 / 2026-07-28 エントリ。
- `disableBypassPermissionsMode` は user-level 配置でも機能する。公式 docs に「A user can set it in their own settings to lock themselves out of bypass mode.」と明記。
- `model` は alias（`opus` 等）と full model name の両方を受け付ける。公式 docs は version 固定の例として `claude-opus-5` を明示している。Opus 5 の利用には Claude Code v2.1.219 以降が必要。
- 次の 3 点は公式 docs で確認できていない。実機で観測するまで「効いている」前提で書かない。
  - `PowerShell(...)` pattern 内の `\`（例: `Remove-Item -Recurse -Force C:\*`）が escape として扱われるか。escape される実装なら `*` が literal 化し、rule が silent no-op になる。
  - matcher の case sensitivity。PowerShell は case-insensitive なので `iwr` / `IWR` / `invoke-webrequest` を書ける。case-sensitive matcher なら大文字形が素通りする。
  - `sandbox.network.allowedDomains` の bare domain が subdomain を含むか。公式 example が `github.com` と `*.npmjs.org` を併記しているので wildcard 必須と読めるが明記はない。含む場合 `pypi.org` の許可で `upload.pypi.org`（認証付き upload endpoint）まで入る。
- `env.CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` は sandboxing docs に「set [...] to strip Anthropic and cloud provider credentials from all subprocesses」と記載があり、他箇所も "When ... is set" という presence 前提の書き方。**受け付ける値そのものは env-vars docs で確認できなかった**ため、他の flag と同じ慣例で `"1"` を置いている。将来 env-vars docs 側で値が明示されたら再確認する。
- 本 note は確認時点の Claude Code 公式仕様に基づく。将来仕様が変わったら出典 URL を辿り直して再確認する。
