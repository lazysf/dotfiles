---
name: core-task-classification
description: 要求分類の補助手順。ユーザー要求を単一主分類へ倒し、関連する `core-*` 候補を整理する。
metadata:
  short-description: 要求分類
---

# Core Task Classification

ユーザー要求を `research` / `bugfix` / `feature` / `security` / `quality` / `maintenance` / `compat` のいずれか 1 つへ分類し、関連する `core-*` 候補を整理する。

## 対象

- 開発依頼の入口整理
- 境界が迷いやすい案件の主分類決定

## 対象外

- 実装方針の詳細決定
- 各分類内の具体手順

## 入力の読み方

- まず主目的を見る
- 次に制約と期待結果を見る
- 原因や方針が固まっていないかを確認する

## 手順

1. 主目的が事実確認や原因調査なら `research`
2. 壊れているものを期待状態へ戻すのが主目的なら `bugfix`
3. 新しい価値や振る舞いを増やすのが主目的なら `feature`
4. セキュリティリスク低減が主目的なら `security`
5. 性能、安定性、可用性、可観測性、運用性の改善が主目的なら `quality`
6. 将来の変更容易性や保守性向上が主目的なら `maintenance`
7. 外部 API、依存、ランタイム、EOL など外部変化への追従が主目的なら `compat`
8. 迷う場合は `reason` と `boundary_note` を明示し、原因や方針が未確定なら `research` に倒す

## 判断基準

- `security` は `bugfix` より優先する
- `compat` は `feature` や `quality` より優先する
- `quality` は `maintenance` より優先する
- 追加のための内部整理は `feature`
- 通常不具合は `bugfix`

## 出力フォーマット

- `primary_category`
- `reason`
- `boundary_note`
- `suggested_core_skills`
- `stop_conditions`

## 停止条件

- 主目的が複数あり、どちらを優先するかで結果が変わる
- 制約が不足していて分類が大きく揺れる
