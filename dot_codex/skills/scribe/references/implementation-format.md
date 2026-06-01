# Implementation Format

`implementation.md` は実装内容の記録。何を変えたか、どこまで実装したかを置く。

## Rules

- 対応する `TASK-*` を含める。
- 要件変更や設計変更を勝手に書かない。
- 実装中に判明した上流問題は、変更せず未確認事項や blocker として残す。
- test / lint / build の最終検証記録は `test.md` に任せる。

## Template

```markdown
# Implementation

## 対応タスク

- `TASK-001`: [対応内容。]

## 変更内容

- [何を変えたか。]

## 変更ファイル

- `[path]`: [変更内容。]

## Scope 外

- [意図的に変更しなかったこと。]

## 実装中に判明した事項

- [実装中に確認した事実。]

## 実行した確認

- [implementer が実行した確認。inspector の最終結果は `test.md` に置く。]

## 未確認事項

- [未確認事項。]
```
