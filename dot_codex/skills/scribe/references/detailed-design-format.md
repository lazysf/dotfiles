# Detailed Design Format

`detailed-design.md` は詳細設計の正本。実装者が迷わない具体仕様を置く。

## Rules

- `DD-*` は対応する `BD-*` / `AC-*` を含める。
- 実装ログ、テスト結果、作業記録を書かない。
- validation、error handling、edge case、状態遷移や分岐条件、test 観点を必要範囲で書く。

## Template

```markdown
# Detailed Design

## 対象範囲

- [対象 module、画面、command、endpoint など。]

## Interface 詳細

- `[interface / function / endpoint]`: [入力、出力、副作用、責務。]

## 詳細設計項目

- `DD-001`: [処理、分岐、状態、連携などの設計要素。対応する `BD-*` / `AC-*` を含める。]

## 処理フロー

1. [処理手順。]

## Validation

- [入力検証、制約、許容値。]

## Error Handling

- [例外、error 表示、fallback。]

## Edge Case

- [境界条件、例外的な入力、特殊状態。]

## 状態遷移 / 分岐条件

- [状態遷移や分岐条件。該当しない場合は `N/A`。]

## Test 観点

- [実装後に確認すべき観点。]

## 未確認事項

- [未確認事項。]
```
