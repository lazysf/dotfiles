# Implementation

## 対応タスク / 対応範囲

- `request.md` scope / acceptance: Claude Code main session と custom agents の model を `claude-opus-4-6` に pin し、effort は既存値のまま維持した。

## 変更内容

- `dot_claude/settings.json` の `model` を `opus` alias から `claude-opus-4-6` に変更した。
- `dot_claude/agents/*.md` の frontmatter `model` を `opus` alias から `claude-opus-4-6` に変更した。

## 変更ファイル

- `dot_claude/settings.json`: main session の default model を pin。
- `dot_claude/agents/design-reviewer.md`: agent model を pin。
- `dot_claude/agents/inspector.md`: agent model を pin。
- `dot_claude/agents/quality-reviewer.md`: agent model を pin。
- `dot_claude/agents/requirements-reviewer.md`: agent model を pin。
- `dot_claude/agents/researcher.md`: agent model を pin。
- `dot_claude/agents/security-reviewer.md`: agent model を pin。
- `docs/requests/change-claude-model-opus-46/request.md`: request scope と検証入口を記録。

## Scope 外

- `effortLevel` と各 agent の `effort` 変更。
- permissions、sandbox、env、tools、agent body の変更。
- Codex 側の model 設定変更。

## 実装中に判明した事項

- Claude Code 公式 docs では、model は alias または model name を設定できる。
- Claude Code 公式 docs では、subagent model は `CLAUDE_CODE_SUBAGENT_MODEL`、per-invocation model、agent frontmatter、main conversation model の順で解決される。
- 現在の `dot_claude/settings.json` には `CLAUDE_CODE_SUBAGENT_MODEL` は設定されていない。

## 実行した確認

- `jq . dot_claude/settings.json`
- `rg -n '^(  "model"|  "effortLevel"|model:|effort:)' dot_claude/settings.json dot_claude/agents/*.md`
- `rg -n 'model: opus|"model": "opus"' dot_claude`
- `git diff --check`
- `mise run test`
- `mise run lint`

## 未確認事項

- なし。
