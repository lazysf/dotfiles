---
name: research
description: 「まず調べたい」「バグの原因を切り分けたい」「外部変化や品質・セキュリティ・保守性への影響を事実ベースで整理したい」といった調査依頼で使う。初見 repo の grounding を含め、facts、unknowns、options、recommendation、next_step を整理する。要件整理したい時は `product-planning` スキル、実装前 scope を決めたい時は `implementation-planning` スキル、実装したい時は `code-implementation-loop` スキルを使う。
metadata:
  short-description: 調査手順
---

# Research

実装や修正に入る前に、判断材料として必要な事実を整理する。
初見 repo で、何を読めば判断材料がそろうかを固める探索もこの skill で扱う。

## 対象

- 原因調査
- 影響調査
- PoC や方式比較
- 仕様確認
- バグ、外部変化、品質、セキュリティ、保守性に関する事実確認

## 対象外

- 調査結果を前提にした実装
- 実装前 scope の整理
- 差分の品質 review や security review

## 基本方針

- まず調査対象と確認したい論点を一文で固定する。
- 初見 repo や規約が曖昧な場合は、規約と確認手段の grounding を先に取る。
- 確認できた事実と未確認事項を混ぜない。
- 調査だけで閉じる案件では、実装案を決め打ちしない。
- 要件や計画を問いで鍛える段階に入ったら、`product-planning` スキルへ戻す。
- 実装範囲や検証順序を決める段階に入ったら、`implementation-planning` スキルへ進める。
- security / quality の差分 review が主目的なら、該当 reviewer agent を使う。

## 手順

1. 調査対象と確認したい論点を一文で固定する
2. 初見 repo や規約が曖昧な場合は、次の順で grounding を取る
   - `AGENTS.md`
   - `README` や運用 docs
   - config / manifest / CI / lint / formatter
   - 関連ディレクトリと近傍実装
   - test / build / lint / smoke などの確認手段
3. repo や既存文脈から確認できる事実を `facts` として集める
   - バグ: 期待状態、実際状態、再現条件、最小 failing check
   - compat: 外部変化、現状との差、影響面
   - quality: 対象品質特性、観測されたボトルネックやリスク
   - security: 認証認可、入力検証、秘密情報、権限境界、外部 I/O に関する観測事実
   - maintenance: 重複、責務分散、保護すべき既存挙動に関する事実
4. まだ分からない点を `unknowns` として分離する
5. 取りうる選択肢を `options` に分ける
6. もっとも妥当な案を `recommendation` にまとめる
7. 次に進むなら何を確認するかを `next_step` に置く

## 判断基準

- 未確認事項を事実として書かない
- grounding と設計判断を一度に済ませようとしない
- 実装方針が揺れる要因は `unknowns` に残す
- 調査だけで閉じる案件では実装案を決め打ちしない

## 出力フォーマット

- `facts`
- `unknowns`
- `options`
- `recommendation`
- `next_step`

`facts` は確認済み根拠に結び付く判断材料だけに絞り、低価値な網羅や一般論で埋めない。

## 停止条件

- workspace 外の前提が支配的で、根拠ある整理ができない
