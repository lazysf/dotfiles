# Test

## Summary

- Result: pass
- Scope: agent / subagent standing authorization、Claude `Agent(...)` allow rules、停止線維持の明記。

## Test Cases

### TC-001: Claude settings JSON が妥当

#### 対応

- `AC-003`

#### 種別

- manual

#### 手順

1. `jq empty dot_claude/settings.json`

#### 結果

- pass

### TC-002: standing authorization と停止線維持が明記されている

#### 対応

- `AC-001`
- `AC-002`
- `AC-004`

#### 種別

- manual

#### 手順

1. `rg "standing authorization|追加確認なし|agent 起動だけ|subagent 起動だけ" AGENTS.md dot_codex/AGENTS.md dot_claude/CLAUDE.md dot_codex/skills/orchestrate/SKILL.md dot_claude/skills/orchestrate/SKILL.md`

#### 結果

- pass
- root / Codex / Claude の案内と orchestrate 両 surface に反映済み。

### TC-003: workflow agent が Claude permissions.allow にある

#### 対応

- `AC-003`

#### 種別

- manual

#### 手順

1. `rg "Agent\\(" dot_claude/settings.json`

#### 結果

- pass
- `architect`, `design-reviewer`, `implementer`, `inspector`, `quality-reviewer`, `repository-maintainer`, `requirements-engineer`, `requirements-reviewer`, `researcher`, `security-reviewer`, `task-planner` を確認。

## Executed Checks

- `jq empty dot_claude/settings.json`: pass。
- standing authorization の `rg`: pass。
- `Agent(...)` rules の `rg`: pass。
- `git diff --check`: pass。

## Unverified Items

- 実際の Codex / Claude runtime での agent spawn は未実行。

## Remaining Risks

- 上位 runtime / host policy が agent 起動を別途制限する場合、この repo-local standing authorization では上書きできない。
