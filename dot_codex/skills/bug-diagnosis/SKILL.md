---
name: bug-diagnosis
description: 「バグを切り分けたい」「再現条件と修正対象を先に固めたい」といった bugfix 前の依頼で使う。症状、再現条件、原因候補、最小の failing check、今回触る修正対象を整理する。期待状態や成功条件が未確定なら `product-planning` スキル、修正実装を進めたい時は `code-implementation-loop` スキルを使う。
metadata:
  short-description: 診断手順
---

# Bug Diagnosis

bugfix 前に、何が壊れていてどこを直すべきかを整理する。
観測事実と仮説を分け、最小の failing check と修正対象を先に固める。
期待状態や成功条件が曖昧な場合は、診断を進めすぎず `product-planning` スキルへ戻す。

## 手順

1. 期待状態と実際状態の差を `observed_gap` に書く
2. 再現条件、入力、環境差分、発生頻度を `repro_steps` に整理する
3. 観測ログ、エラーメッセージ、再現結果などの事実を整理し、原因候補を `suspected_causes` に確度順で並べる
4. 最小の failing check を決める
5. 影響範囲と緊急度を踏まえて、今回触る修正対象を `fix_target` に絞る

## 判断基準

- 症状だけでなく期待状態との差を書く
- 観測事実と仮説を混ぜない
- 再現材料がある場合は、入力やログの要点を保全する
- 再現できない場合は暫定仮説と停止条件を分ける
- failing check を置けない場合は、なぜ置けないかを明示する
- 影響範囲が広くても、修正対象は最小に絞る

## 出力フォーマット

- `observed_gap`
- `repro_steps`
- `suspected_causes`
- `failing_check`
- `fix_target`

## 停止条件

- 再現条件が取れない
- 修正対象を絞る根拠が不足している
