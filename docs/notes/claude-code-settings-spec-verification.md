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
| `effortLevel: "xhigh"` | `settings.json.tmpl` | `"low"`, `"medium"`, `"high"`, `"xhigh"` を受け付ける |
| `disableBypassPermissionsMode: "disable"` | `settings.json.tmpl` permissions | 値は文字列 `"disable"`。`bypassPermissions` / `auto` モードの利用を防ぐためのキーで、user-level / managed-settings どちらでも有効 |
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

## 補足

- `effortLevel` の採用根拠は [model-and-effort-tuning-history.md](./model-and-effort-tuning-history.md) の 2026-06-18 エントリ（"xhigh for coding/agentic" 公式推奨に寄せた）に記録済み。
- `disableBypassPermissionsMode` は user-level 配置でも機能する。公式 docs に「A user can set it in their own settings to lock themselves out of bypass mode.」と明記。
- `model` は alias（`opus` 等）と full model name の両方を受け付ける。公式 docs は version 固定の例として `claude-opus-5` を明示している。Opus 5 の利用には Claude Code v2.1.219 以降が必要。
- 次の 3 点は公式 docs で確認できていない。実機で観測するまで「効いている」前提で書かない。
  - `PowerShell(...)` pattern 内の `\`（例: `Remove-Item -Recurse -Force C:\*`）が escape として扱われるか。escape される実装なら `*` が literal 化し、rule が silent no-op になる。
  - matcher の case sensitivity。PowerShell は case-insensitive なので `iwr` / `IWR` / `invoke-webrequest` を書ける。case-sensitive matcher なら大文字形が素通りする。
  - `sandbox.network.allowedDomains` の bare domain が subdomain を含むか。公式 example が `github.com` と `*.npmjs.org` を併記しているので wildcard 必須と読めるが明記はない。含む場合 `pypi.org` の許可で `upload.pypi.org`（認証付き upload endpoint）まで入る。
- `env.CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` は sandboxing docs に「set [...] to strip Anthropic and cloud provider credentials from all subprocesses」と記載があり、他箇所も "When ... is set" という presence 前提の書き方。**受け付ける値そのものは env-vars docs で確認できなかった**ため、他の flag と同じ慣例で `"1"` を置いている。将来 env-vars docs 側で値が明示されたら再確認する。
- 本 note は確認時点の Claude Code 公式仕様に基づく。将来仕様が変わったら出典 URL を辿り直して再確認する。
