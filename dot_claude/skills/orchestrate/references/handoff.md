# Handoff

agent は完了時に以下の形で lead へ返す。本文は英語でもよい。ユーザー向け表示は lead が日本語にする。

## Engineering Agent Output

対象: `analyst` / `requirements-engineer` / `architect` / `task-planner` / `developer` / `verifier`

```markdown
## Result

status: done | blocked

## Scope

- in_scope: [...]
- out_of_scope: [...]

## Updated Artifacts

- `[file]`: [created | updated | deleted | unchanged] - [変更内容と対応する finding / ID]
- none

## Target IDs

- `REQ-001`
- `AC-001`
- none

## Confirmed

- [...]

## Assumptions

- [...]
- none

## Open Questions

- [未確認だが次へ進める事項]
- none

## Blockers

- [次へ進めない理由]
- none

## Exit Criteria

- [done 判定に使った条件]

## Security-Relevant Actions

external_io: none | [...]
commands: none | [...]
files_written: none | [...]
files_deleted: none | [...]
permission_changes: none | [...]
dependency_changes: none | [...]
secret_access: none | [対象・理由。値は書かない]

## Next Action Proposal

- [lead が次に起動すべき agent / Gate / user confirmation]
```

## Reviewer Output

対象: `requirements-reviewer` / `design-reviewer` / `security-reviewer` / `quality-reviewer`

```markdown
## Review Result

result: pass | fail | not_applicable

## Reviewed Scope

- artifacts: [確認した成果物]
- ids: [確認した ID]
- diff_or_source: [確認した diff / source / command result / artifact version]
- assumptions: [review 時の前提]
- not_reviewed: [確認していない範囲。なければ none]

## Reviewer Execution Boundary

modified_artifacts: none
write_operations: none
external_io: none

## Blocking Findings

- id: `FINDING-001`
  severity: [high | medium | low]
  artifact: [対象成果物]
  location: [section / ID / file path]
  target_id: [REQ-* / AC-* / BD-* / DD-* / TASK-* / TC-* / none]
  issue: [問題]
  impact: [影響]
  required_change: [必要な修正]

## Non-Blocking Risks

- [残リスク。なければ none]

## Recommended Return

type: same-step | same-phase | previous-phase | restart | change-request-candidate | none
target: [工程 / フェーズ / agent / none]
target_artifacts: [戻す対象成果物]
expected_fix: [何が直れば解消か]
reason: [理由]

## Next Action Proposal

- [lead が次にすべきこと]
```

## Rules

- `Next Action Proposal` は提案であり、lead が最終決定する。
- 対象 ID が存在する工程で `none` を使う場合は理由を書く。
- reviewer が `write_operations` / `modified_artifacts` / `external_io` を `none` 以外で返した場合、その review は無効扱いにする。
- analyst が `external_io` / `files_written` / `secret_access` を `none` 以外で返した場合、その handoff は無効扱いにする。
- `not_reviewed` に Gate 上必須の対象が残る場合、原則 pass にしない。
- secret 値は成果物、handoff、review、log に書かない。secret の種類、保管場所、用途だけを書く。
