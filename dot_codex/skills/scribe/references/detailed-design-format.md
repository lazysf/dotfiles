# Detailed Design Format

`docs/DETAILED_DESIGN.md` を作成・更新する時に使う。
実装可能な処理、interface、validation、edge case を置く。

## Rules

- 詳細設計用フォルダは作らず、`docs/DETAILED_DESIGN.md` を使う。
- 対象の `FR-*` と対応付ける。
- code snippet は判断を明確にする時だけ短く使う。
- 該当するデータ対応がない場合は `N/A` と書く。
- 未確認事項は `未確認事項` に残す。
- 詳細設計の責務外の内容は書かない。

## Template

```markdown
# 詳細設計

## FR-001: [機能または要件領域名]

### 対象範囲

- [対象 module、画面、macro、command など。]

### インターフェース

- `[interface / function / macro / endpoint]`: [入力、出力、副作用、責務。]

### 詳細設計項目

- `DD-001`: [実装へ落とすための処理、分岐、状態、連携などの設計要素。]

### 処理フロー

1. [処理手順。]

### 検証・エラー処理

- [validation、例外、error 表示、fallback。]

### データ対応

| 変換元 | 変換先 | ルール | 備考 |
|---|---|---|---|
| [変換元] | [変換先] | [ルール] | [備考] |

### 考慮ケース

- [考慮すべき edge case、境界条件、例外的な入力。]

### 未確認事項

- [未確認事項。]
```
