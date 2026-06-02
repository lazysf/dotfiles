# Test Format

`docs/requests/<slug>/test.md` を作成・更新する時に使う。
実装後の検証結果、未確認事項、残リスクを request folder に閉じて記録する。

## Rules

- `AC-*`、`TASK-*`、実装差分と対応付ける。`micro` または `standard` 軽量時に `tasks.md` を省略した場合は、`request.md` の scope / acceptance / 実装範囲に対応付ける。該当しないものは `N/A`。
- `TC-*` は 1 つの期待結果を観測できる粒度にする。
- test / lint / build / manual check の実行結果を分ける。
- 未実行の確認は、理由と代替確認を書いて残す。
- 残リスクは、受け入れ判断が必要なものと単なる注意を分ける。
- 仕様変更、設計変更、実装修正は `test.md` に混ぜない。
- secret 値、credential、private config value、未公開個人情報を書かない。

## Template

```markdown
# Test

## Summary

- Result: [pass | fail | partial]
- Scope: [検証対象の要約]

## Test Cases

### TC-001: [観測する期待結果]

#### 対応

- `AC-001`
- `TASK-001`
- `request.md` scope / acceptance

#### 種別

- [automated | lint | build | manual | exploratory]

#### 手順

1. [確認手順、または実行コマンド。]

#### 結果

- [pass | fail | not_run]
- [観測結果。]

#### 未実行理由 / 代替確認

- [未実行の場合だけ書く。]

## Executed Checks

- `[command]`: [result]

## Unverified Items

- [未確認事項。なければ `none`。]

## Remaining Risks

- [残リスク。なければ `none`。]
```
