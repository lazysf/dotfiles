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

## 補足

- `effortLevel` の採用根拠は [model-and-effort-tuning-history.md](./model-and-effort-tuning-history.md) の 2026-06-18 エントリ（"xhigh for coding/agentic" 公式推奨に寄せた）に記録済み。
- `disableBypassPermissionsMode` は user-level 配置でも機能する。公式 docs に「A user can set it in their own settings to lock themselves out of bypass mode.」と明記。
- `model` は alias（`opus` 等）と full model name の両方を受け付ける。公式 docs は version 固定の例として `claude-opus-5` を明示している。Opus 5 の利用には Claude Code v2.1.219 以降が必要。
- 本 note は確認時点の Claude Code 公式仕様に基づく。将来仕様が変わったら出典 URL を辿り直して再確認する。
