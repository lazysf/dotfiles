---
name: phase-plan
description: Deprecated wrapper。旧 Plan 導線互換のために関連する planning 系 `core-*` へ受け渡す。
metadata:
  short-description: Plan 工程
---

# Phase Plan

旧 Plan 導線互換のために、依頼整理や要件整理を planning 系 `core-*` へ橋渡しする。
新規の正式入口としては使わず、`core-request-shaping`, `core-task-intake`, `core-product-planning`, `core-implementation-planning` を直接使う。

## 入力

- ユーザー要求
- 既存文脈
- 触ってよい範囲と制約
- 既知の前提やリスク

単独依頼では、依頼整理、要件定義、技術計画のいずれを主に求めているかをこの phase が受け止め、必要な詳細手順の選択は phase 内で行う。

## uses

- `core-request-shaping`
- `core-task-intake`
- `core-product-planning`
- `core-implementation-planning`

## 進め方

1. 依頼文が散らばっている場合は `$core-request-shaping` を使い、目的、確認済み事実、制約、仮定、未確定事項を短いブリーフへ整える
2. 今回の停止線を軽く固定するときは `$core-task-intake` を使い、今回の対象、成功条件、非目的、すぐ確認が必要な点をそろえる
3. 成功条件や非目的の整理が重い場合は `$core-product-planning` を使い、目的、成功条件、非目的、制約、優先順位、未確定事項を整理する
4. 要件が固まったら `$core-implementation-planning` を使い、実装順序、影響範囲、検証方法へ落とす
5. Open Questions が残る場合はユーザー確認へ戻し、確認不能なものは `assumptions` として明示する
6. 最後に Plan 工程の出力形式へ統合する

## 出力

- `plan_scope`
- `success_criteria`
- `constraints`
- `planning_focus`
- `implementation_outline`
- `verification_outline`
- `open_questions`
- `assumptions`

## 次に渡す情報

- 実装へ進む場合は `plan_scope`, `success_criteria`, `implementation_outline` を `phase-implement` へ渡す
- 確認重視の場合は `verification_outline` を `phase-test` や `phase-review` の起点として渡す

## 完了条件

- 何をやるかを短く説明できる
- どこを触るかと触らないかを説明できる
- 主要な依存関係とリスクが見えている
- 実装と確認の進め方を段階に分けて示せる
- Open Questions と Assumptions が分けて扱われている
- ユーザーが core 名を意識しなくても、Plan 工程としての結果を受け取れる
