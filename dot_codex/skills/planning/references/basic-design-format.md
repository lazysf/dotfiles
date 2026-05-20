# Basic Design Format

`docs/BASIC_DESIGN.md` を作成・更新する時に使う。
要件を満たすための全体方針、責務分担、主要な構成を置く。

## Rules

- 基本設計用フォルダは作らず、`docs/BASIC_DESIGN.md` を使う。
- 詳細な処理順や実装手順は入れすぎない。
- 対象の `FR-*` と対応付ける。
- 未確認事項は `Open Questions` に残す。

## Template

```markdown
# Basic Design

## FR-001: [Feature name]

### Design Goal

[この設計で達成すること。]

### Approach

[採用する基本方針。]

### Components / Responsibilities

- `[component]`: [責務。]

### Design Items

- `BD-001`: [要件に対応する基本設計要素。]

### Data / State

- [扱う主な data、state、保存先。]

### User / System Flow

1. [主要な流れ。]

### Alternatives Considered

- [検討した代替案と見送った理由。]

### Open Questions

- [未確認事項。]
```
