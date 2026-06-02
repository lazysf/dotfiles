# test: orchestrate-auto-gate-approval

## Summary

- Result: pass
- Scope: Gate pass 後の承認 skip 方針、Codex / Claude surface の一致、ADR / docs 追従。

## Test Cases

### TC-001: 固定の必須承認文が残っていない

#### 対応

- `AC-001`
- `AC-003`

#### 種別

- manual

#### 手順

1. `rg "ユーザー承認を得て|承認を得てから|Gate 1 / 2 / 3 pass 後にユーザー承認|Gate 3 pass 後にユーザー承認" dot_codex/skills/orchestrate dot_claude/skills/orchestrate`

#### 結果

- pass
- 固定の必須承認文なし。

### TC-002: 自動継続方針が両 surface に反映されている

#### 対応

- `AC-001`
- `AC-002`
- `AC-003`

#### 種別

- manual

#### 手順

1. `rg "確認必須事項がなければ|承認待ちを挟まず|ユーザー判断が必要な場合だけ" dot_codex/skills/orchestrate dot_claude/skills/orchestrate`

#### 結果

- pass
- Codex / Claude 両 surface に反映済み。

### TC-003: ADR 追従がある

#### 対応

- `AC-004`

#### 種別

- manual

#### 手順

1. `rg "Superseded|ADR 0032|0032-auto|確認必須事項がなければ|承認待ちを挟まず" docs/adr/0031-add-gate-pass-user-approval-checkpoints.md docs/adr/0032-auto-skip-gate-pass-approval-when-no-user-decision.md docs/README.md docs/notes/runtime-surface-guidance.md`

#### 結果

- pass
- ADR 0031 は superseded、ADR 0032 と docs index / notes 参照を確認。

## Executed Checks

- `git diff --check`: pass。
- 固定必須承認文の `rg`: pass。
- 自動継続方針の `rg`: pass。
- ADR / docs 追従の `rg`: pass。

## Unverified Items

- N/A。実行テスト対象ではない。

## Remaining Risks

- 実行テスト対象ではないため、確認は Markdown diff と文言検索中心。
- subagent reviewer は、この turn でユーザーが明示的に依頼していないため起動していない。
