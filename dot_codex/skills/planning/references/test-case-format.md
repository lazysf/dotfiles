# Test Case Format

`docs/TEST_CASES.md` を作成・更新する時に使う。
要件、設計、task に対応する test case と手動確認を置く。

## Rules

- test case 用フォルダは作らず、`docs/TEST_CASES.md` を使う。
- 対象の `FR-*`、`AC-*`、`TASK-*` と対応付ける。
- 自動テストできない場合は、手動確認または比較観点として残す。
- テストコードの path は確認済みの場合だけ書く。未作成なら `TBD` にする。
- 未確認事項は `Open Questions` に残す。

## Template

```markdown
# Test Cases

## FR-001: [Feature name]

### TC-001: [Test case name]

### Covers

- `AC-001`
- `TASK-001`

### Type

- [automated / manual / exploratory]

### Preconditions

- [前提条件、fixture、workbook、data など。]

### Steps

1. [確認手順。]

### Expected Result

- [観測可能な期待結果。]

### Test Code

- `TBD`

### Open Questions

- [未確認事項。]
```
