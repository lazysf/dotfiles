# Test

## Summary

- Result: pass
- Scope: `dot_claude/skills/orchestrate/SKILL.md` の Phase 0 / Triage と `## 出力`、および Codex / Claude 間の Tier 表示変更に関する反映漏れ確認。

## Test Cases

### TC-001: Claude 側 Phase 0 / Triage の初回表示

#### 対応

- `AC-001`
- `TASK-001`

#### 種別

- manual

#### 手順

1. `dot_claude/skills/orchestrate/SKILL.md` の `## Phase 0 -> Triage` を確認する。

#### 結果

- pass
- tier 決定直後かつ reference 読み込み前に `tier: <tier>。根拠: <短い理由>。` を表示する順序が確認できた。

#### 未実行理由 / 代替確認

- N/A

### TC-002: 停止線 full の初回表示

#### 対応

- `AC-002`
- `TASK-001`

#### 種別

- manual

#### 手順

1. `dot_claude/skills/orchestrate/SKILL.md` の `## Phase 0 -> Triage` を確認する。

#### 結果

- pass
- 停止線に触れるため `full` に倒す場合も同じ形式で示す記述が確認できた。

#### 未実行理由 / 代替確認

- N/A

### TC-003: 初回表示形式

#### 対応

- `AC-003`
- `TASK-001`
- `TASK-002`

#### 種別

- manual

#### 手順

1. `rg -n "tier: <tier>。根拠: <短い理由>。" dot_claude/skills/orchestrate/SKILL.md` を実行する。

#### 結果

- pass
- Phase 0 / Triage と `## 出力` の両方に表示形式が確認できた。

#### 未実行理由 / 代替確認

- N/A

### TC-004: sensitive data 抑止

#### 対応

- `AC-004`
- `TASK-001`

#### 種別

- manual

#### 手順

1. `dot_claude/skills/orchestrate/SKILL.md` の `## Phase 0 -> Triage` を確認する。

#### 結果

- pass
- 根拠には secret 値、認証情報、private data、具体的な sensitive data を含めず、tier 判定条件または停止線カテゴリへ一般化する記述が確認できた。

#### 未実行理由 / 代替確認

- N/A

### TC-005: 変更境界

#### 対応

- `AC-006`
- `TASK-003`

#### 種別

- manual

#### 手順

1. `git diff --name-only -- dot_claude/skills/orchestrate dot_codex/skills/orchestrate` を確認する。
2. `git diff -- dot_claude/skills/orchestrate/SKILL.md` を確認する。

#### 結果

- pass
- 変更対象は `dot_claude/skills/orchestrate/SKILL.md` のみ。
- 差分は Phase 0 / Triage と `## 出力` に限定されている。
- `dot_claude/skills/orchestrate/references/**` には差分なし。

#### 未実行理由 / 代替確認

- N/A

### TC-006: Claude 固有表記維持

#### 対応

- `AC-006`
- `TASK-003`

#### 種別

- manual

#### 手順

1. `rg -n "subagent 起動" dot_claude/skills/orchestrate/SKILL.md` を実行する。
2. `diff -u dot_codex/skills/orchestrate/SKILL.md dot_claude/skills/orchestrate/SKILL.md` を確認する。

#### 結果

- pass
- Claude 側 `subagent 起動` 表記は維持されている。
- Codex / Claude の `SKILL.md` 本体差分は、Codex 側 `agent 起動` と Claude 側 `subagent 起動` のみ。

#### 未実行理由 / 代替確認

- N/A

### TC-007: Tier 表示変更の反映漏れ確認

#### 対応

- `AC-005`
- `TASK-004`

#### 種別

- manual

#### 手順

1. `diff -u dot_codex/skills/orchestrate/SKILL.md dot_claude/skills/orchestrate/SKILL.md` を確認する。
2. `for f in dot_codex/skills/orchestrate/references/*.md; do b=${f#dot_codex/skills/orchestrate/references/}; diff -q "$f" "dot_claude/skills/orchestrate/references/$b"; done` を確認する。

#### 結果

- pass
- Tier 表示変更に関する `SKILL.md` 本体の反映漏れはなし。
- `references/` 配下の差分は `autonomous-loop.md`, `full.md`, `handoff.md` の Codex / Claude / subagent 表記差のみで、今回 scope 外の意図した差分として維持した。

#### 未実行理由 / 代替確認

- N/A

## Executed Checks

- `git diff -- dot_claude/skills/orchestrate/SKILL.md`: pass
- `rg -n "最初の中途表示|tier: <tier>。根拠: <短い理由>。|secret 値|private data|sensitive data|subagent 起動|## Phase 0 -> Triage|## 出力" dot_claude/skills/orchestrate/SKILL.md`: pass
- `git diff --name-only -- dot_claude/skills/orchestrate dot_codex/skills/orchestrate`: pass
- `diff -u dot_codex/skills/orchestrate/SKILL.md dot_claude/skills/orchestrate/SKILL.md`: pass
- `for f in dot_codex/skills/orchestrate/references/*.md; do b=${f#dot_codex/skills/orchestrate/references/}; diff -q "$f" "dot_claude/skills/orchestrate/references/$b"; done`: pass

## Unverified Items

- none

## Remaining Risks

- none
