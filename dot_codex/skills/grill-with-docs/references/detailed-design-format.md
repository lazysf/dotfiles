# Detailed Design Format

`docs/DETAILED_DESIGN.md` を作成・更新する時に使う。
実装可能な粒度の処理、interface、validation、edge case を置く。

## Rules

- 詳細設計用フォルダは作らず、`docs/DETAILED_DESIGN.md` を使う。
- 対象の `FR-*` と対応付ける。
- 変わりやすい code snippet は、判断を明確にする時だけ短く使う。
- 未確認事項は `Open Questions` に残す。

## Template

```markdown
# Detailed Design

## FR-001: [Feature name]

### Target Scope

- [対象 module、画面、macro、command など。]

### Interfaces

- `[interface / function / macro / endpoint]`: [入力、出力、責務。]

### Design Items

- `DD-001`: [要件に対応する詳細設計要素。]

### Processing Flow

1. [処理手順。]

### Validation / Error Handling

- [validation、例外、error 表示、fallback。]

### Data Mapping

| Source | Target | Rule | Notes |
|---|---|---|---|
| [source] | [target] | [rule] | [notes] |

### Edge Cases

- [考慮すべき edge case。]

### Open Questions

- [未確認事項。]
```
