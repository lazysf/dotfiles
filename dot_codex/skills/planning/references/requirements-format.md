# Requirements Format

`docs/REQUIREMENTS.md` を作成・更新する時に使う。
`FR-*` ごとに、実現したい要件や機能を扱える粒度まで固める。

## Rules

- 要件用フォルダは作らず、`docs/REQUIREMENTS.md` を使う。
- 要件や機能は `FR-001` のような ID で追跡する。既存 ID があれば継続する。
- ID 体系が未確定なら、推測で採番せず確認する。
- 受入条件は観測可能な結果として書く。
- 未確認事項は `Open Questions` に残す。

## Template

```markdown
# Requirements

## FR-001: [Feature name]

### Background

[この要件が必要な確認済み背景。]

### Requirements

- `REQ-001`: [実現したい振る舞い。]

### Acceptance Criteria

- `AC-001`: [観測可能な受入条件。]

### Non-goals

- [この要件では扱わないこと。]

### Dependencies

- [依存する要件、外部条件、既存仕様。]

### Open Questions

- [未確認事項。]
```
