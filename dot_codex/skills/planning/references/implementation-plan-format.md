# Implementation Plan Format

`docs/IMPLEMENTATION_PLAN.md` を作成・更新する時に使う。
詳細設計から実装スライス、確認入口、作業境界を置く。

## Rules

- 実装計画用フォルダは作らず、`docs/IMPLEMENTATION_PLAN.md` を使う。
- 実装結果、日報、作業ログは混ぜない。
- 対象の `FR-*` と対応付ける。
- `TASK-*` は実行しやすく検証可能な粒度にする。
- 未確認事項は `Open Questions` に残す。

## Template

```markdown
# Implementation Plan

## FR-001: [Feature name]

### Scope

- [今回実装すること。]

### Non-scope

- [今回実装しないこと。]

### Implementation Slices

1. [実装のまとまり、順序、依存。]

### Tasks

- `TASK-001`: [完了条件と確認方法が見える作業単位。]

### Verification

- [test、lint、build、手動確認、比較観点。]

### Risks

- [失敗しやすい点、既存挙動への影響。]

### Open Questions

- [未確認事項。]
```
