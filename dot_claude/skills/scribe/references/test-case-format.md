# Test Format

`test.md` は検証結果の正本。`TC-*`、test / lint / build / manual check、未確認事項、残リスクを置く。

## Rules

- `TC-*` は対応する `AC-*` / `TASK-*` を含める。
- 自動テスト、手動確認、確認不能または費用対効果が低いものを分ける。
- 自動化できない確認は理由と残リスクを書く。
- 仕様変更や実装ログを書かない。

## Template

```markdown
# Test

## 確認対象

- [確認した受入条件、task、差分。]

## テストケース

### TC-001: [テストケース名]

#### 対応

- `AC-001`
- `TASK-001`

#### 種別

- [automated | manual | exploratory]

#### 前提条件

- [fixture、data、権限、設定など。]

#### 手順

1. [確認手順。]

#### 期待結果

- [観測可能な期待結果。]

#### 結果

- [pass | fail | not_run] - [根拠。]

## 実行した test / lint / build

- `[command]`: [結果。]

## 自動化できない確認

- [理由、手順、残リスク。]

## 残リスク

- [残リスク。なければ none。]
```
