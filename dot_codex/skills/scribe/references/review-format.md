# Review Format

`review.md` は Gate の最終状態だけを記録する。reviewer の全文や修正済み指摘詳細は残さない。

## Rules

- lead が記録する。
- Gate ごとに最終判定、reviewer、対象 artifact、主要な未解消リスクだけを書く。
- 修正済み finding の詳細ログを残さない。
- secret 値を書かない。

## Template

```markdown
# Review

## Gate 1

- result: [pass | fail | not_run]
- reviewers: `requirements-reviewer`
- reviewed_artifacts: `request.md`, `requirements.md`
- unresolved_risks: [none または残リスク]
- user_confirmation: [not_required | approved | pending | rejected]

## Gate 2

- result: [pass | fail | not_run]
- reviewers: `design-reviewer`, `security-reviewer`
- reviewed_artifacts: `requirements.md`, `basic-design.md`, `detailed-design.md`, `tasks.md`
- unresolved_risks: [none または残リスク]
- user_confirmation: [not_required | approved | pending | rejected]

## Gate 3

- result: [pass | fail | not_run]
- reviewers: `quality-reviewer`, `security-reviewer`
- reviewed_artifacts: [対象成果物と差分]
- unresolved_risks: [none または残リスク]
- user_confirmation: [not_required | approved | pending | rejected]
```
