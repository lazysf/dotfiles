# Basic Design Format

`basic-design.md` は基本設計の正本。全体方針と責務境界を置く。

## Rules

- `BD-*` は対応する `REQ-*` / `AC-*` を含める。
- 詳細な処理順や実装手順は入れすぎず、`detailed-design.md` へ送る。
- 主要な設計判断には理由を書く。
- security / 権限 / data / 外部 I/O の設計上の扱いを書く。

## Template

```markdown
# Basic Design

## 設計方針

[要件を満たすための基本方針。対応する `REQ-*` / `AC-*` を含める。]

## 構成と責務

- `[component]`: [責務。]

## 基本設計項目

- `BD-001`: [主要な設計判断または構成要素。対応する `REQ-*` / `AC-*` を含める。]

## 主要 interface / API / data flow

- [主要な interface、API、data flow。]

## 既存構造との接続点

- [既存 module、既存 API、既存 data との接続点。]

## Security / 権限 / Data / 外部 I/O

- [security、権限、data、外部 I/O の設計上の扱い。]

## 主要判断と理由

- [採用する大きな設計判断と理由。]

## 未確認事項

- [未確認事項。]
```
