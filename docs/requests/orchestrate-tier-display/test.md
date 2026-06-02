# Test

## Summary

- Result: pass
- Scope: `dot_codex/skills/orchestrate/SKILL.md` の Phase 0 / Triage と `## 出力` に対する文書差分確認。

## Test Cases

### TC-001: tier 決定直後の初回表示

#### 対応

- `AC-001`
- `TASK-001`

#### 種別

- manual

#### 手順

1. `dot_codex/skills/orchestrate/SKILL.md` の `## Phase 0 -> Triage` を確認する。

#### 結果

- pass
- tier 決定後、該当 reference を読む前に初回表示する手順が確認できた。

#### 未実行理由 / 代替確認

- N/A

### TC-002: 停止線 full でも同じ初回表示

#### 対応

- `AC-002`
- `TASK-001`

#### 種別

- manual

#### 手順

1. `dot_codex/skills/orchestrate/SKILL.md` の `## Phase 0 -> Triage` を確認する。

#### 結果

- pass
- 停止線に触れるため `full` に倒す場合も同じ形式で示す記述が確認できた。

#### 未実行理由 / 代替確認

- N/A

### TC-003: 初回表示形式

#### 対応

- `AC-003`
- `TASK-002`
- `TASK-003`

#### 種別

- manual

#### 手順

1. `rg -n "tier: <tier>。根拠: <短い理由>。" dot_codex/skills/orchestrate/SKILL.md` を実行する。
2. `## 出力` を確認する。

#### 結果

- pass
- Phase 0 / Triage と `## 出力` の両方で表示形式が確認できた。

#### 未実行理由 / 代替確認

- N/A

### TC-004: 根拠文の sensitive data 抑止

#### 対応

- `TASK-004`

#### 種別

- manual

#### 手順

1. `dot_codex/skills/orchestrate/SKILL.md` の `## Phase 0 -> Triage` を確認する。

#### 結果

- pass
- 根拠には secret 値、認証情報、private data、具体的な sensitive data を含めず、tier 判定条件または停止線カテゴリへ一般化する記述が確認できた。

#### 未実行理由 / 代替確認

- N/A

### TC-005: 変更境界

#### 対応

- `AC-004`
- `TASK-005`

#### 種別

- manual

#### 手順

1. `git diff -- dot_codex/skills/orchestrate/SKILL.md` を確認する。
2. `git status --short --untracked-files=all` を確認する。

#### 結果

- pass
- `dot_codex/skills/orchestrate/SKILL.md` の変更は Phase 0 / Triage と `## 出力` に限定されている。
- tier 判定表、Tier Map、完了方法、tier reference file、code、config、tests、script、hook、dependency に差分はない。
- request folder artifact は `docs/requests/orchestrate-tier-display/` 配下に限定されている。

#### 未実行理由 / 代替確認

- N/A

## Executed Checks

- `git diff -- dot_codex/skills/orchestrate/SKILL.md`: pass
- `rg -n "tier: <tier>。根拠: <短い理由>。|secret 値|private data|sensitive data|## Phase 0 -> Triage|## 出力|## 分岐|## Tier Map|## 完了方法" dot_codex/skills/orchestrate/SKILL.md`: pass
- `git status --short --untracked-files=all`: pass

## Unverified Items

- none

## Remaining Risks

- none
