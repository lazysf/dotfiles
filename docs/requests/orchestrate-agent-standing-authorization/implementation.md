# Implementation

## 対応タスク / 対応範囲

- `AC-001`: root / Codex / Claude の進行案内へ standing authorization を追加。
- `AC-002`: Codex / Claude の `orchestrate/SKILL.md` に agent / subagent 起動の事前許可を追加。
- `AC-003`: Claude `settings.json` に workflow agent の `Agent(...)` allow rules を追加。
- `AC-004`: agent 起動の許可が tool 実行や停止線を上書きしないことを各 surface に明記。

## 変更内容

- root `AGENTS.md` に repo-local 契約として Agent / Subagent 起動節を追加。
- `dot_codex/AGENTS.md` と `dot_claude/CLAUDE.md` に、workflow agent / subagent の追加確認なし起動を明記。
- `dot_codex/skills/orchestrate/SKILL.md` と `dot_claude/skills/orchestrate/SKILL.md` に、standing authorization 済みの agent / subagent 起動を明記。
- `dot_claude/settings.json` の `permissions.allow` に 11 個の workflow agent を `Agent(...)` rule で追加。
- ADR 0033 と docs index / runtime surface guidance を追従。

## Scope 外

- Codex `private_config.toml.tmpl` の設定変更。既に `multi_agent = true`、`approvals_reviewer = "auto_review"`、`[agents]` が設定済みのため。
- agent / subagent 定義本文の変更。
- sandbox / deny rule / secret / auth / 外部 I/O / 破壊的操作の停止線緩和。

## 実行した確認

- JSON parse、文言検索、diff check。最終結果は `test.md` に記録。

## 未確認事項

- none
