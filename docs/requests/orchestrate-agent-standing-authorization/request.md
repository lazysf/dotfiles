# Request

## 元の要求・要望

- 「推奨アクションを実施して」
- 直前の推奨内容は、`orchestrate` で必要な agent / subagent 起動を追加確認なしで進められるよう、standing authorization を AGENTS / orchestrate に明記し、Claude Code の `settings.json` に `Agent(...)` allow を追加すること。

## 背景

- ユーザーは、スキル経由でエージェントを呼び出すたびに許可入力をしたくない。
- Codex は `dot_codex/private_config.toml.tmpl` で `multi_agent = true`、`[agents] max_threads = 6` / `max_depth = 1`、`approvals_reviewer = "auto_review"` が既に設定済み。
- Claude Code は `dot_claude/agents/*.md` があり、`permissions.defaultMode = "auto"` だが、`Agent(...)` allow は未設定だった。

## 期待状態

- `orchestrate` workflow 上で必要な repo-local / managed agent / subagent は追加確認なしで起動できる方針になっている。
- agent 起動の許可と、agent 内の tool 実行・sandbox escalation・secret / auth / 外部 I/O / 破壊的操作の停止線は分かれている。
- Claude Code は workflow agent を `permissions.allow` の `Agent(...)` rules で許可している。

## 不明点

- none

## acceptance

- **AC-001**: root / Codex / Claude の進行案内に、workflow 上必要な agent / subagent の standing authorization が明記されている。
- **AC-002**: Codex / Claude の `orchestrate/SKILL.md` に、workflow agent / subagent は追加確認なしで起動する旨が明記されている。
- **AC-003**: Claude `settings.json` の `permissions.allow` に workflow agent の `Agent(...)` rules がある。
- **AC-004**: agent 起動の許可が、tool 実行・sandbox escalation・secret / auth / 外部 I/O / 破壊的操作の停止線を上書きしないことが明記されている。
