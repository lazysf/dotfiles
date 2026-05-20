# Traceability Matrix Format

`docs/TRACEABILITY_MATRIX.md` を作成・更新する時に使う。
PRD、要件、設計、タスク、テストケース、テストコードの対応関係を一覧化する。

## Rules

- traceability 用フォルダは作らず、`docs/TRACEABILITY_MATRIX.md` を使う。
- 追跡対象が存在しない場合は空欄にせず `N/A` または `TBD` を使う。
- 対応が不明なものを推測で埋めない。
- status は必要最小限にする。

## Template

```markdown
# Traceability Matrix

| Feature | Requirement | Acceptance Criteria | Basic Design | Detailed Design | Task | Test Case | Test Code | Status |
|---|---|---|---|---|---|---|---|---|
| `FR-001` | `REQ-001` | `AC-001` | `BD-001` | `DD-001` | `TASK-001` | `TC-001` | `TBD` | `planned` |
```

## Status

- `draft`: まだ問い詰め中
- `planned`: 実装計画まである
- `implemented`: 実装済み
- `verified`: 確認済み
- `deferred`: 後回し
