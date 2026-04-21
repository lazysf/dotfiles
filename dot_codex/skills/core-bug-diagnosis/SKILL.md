---
name: core-bug-diagnosis
description: bugfix 案件の診断手順。症状、再現条件、原因候補、修正対象を整理する。
metadata:
  short-description: 診断手順
---

# Core Bug Diagnosis

bugfix 前に、何が壊れていてどこを直すべきかを整理する。

## 手順

1. 期待状態と実際状態の差を `observed_gap` に書く
2. 再現条件を `repro_steps` に整理する
3. 原因候補を 1 つ以上挙げ、確度順に並べる
4. 最小の failing check を決める
5. 今回触る修正対象を `fix_target` に絞る

## 判断基準

- 症状だけでなく期待状態との差を書く
- 再現できない場合は暫定仮説と停止条件を分ける
- failing check を置けない場合は、なぜ置けないかを明示する

## 出力フォーマット

- `observed_gap`
- `repro_steps`
- `suspected_causes`
- `failing_check`
- `fix_target`

## 停止条件

- 再現条件が取れない
- 修正対象を絞る根拠が不足している
