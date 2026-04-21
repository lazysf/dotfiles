---
name: research
description: 「まず調べたい」「原因や影響、選択肢を事実ベースで整理したい」といった調査依頼で使う。初見 repo の grounding を含め、facts、unknowns、options、recommendation、next_step を整理する。調査結果を前提にした実装は `code-implementation-loop`、bugfix の診断は `bug-diagnosis` など個別 skill を優先する。
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

## 対象外

- 調査結果を前提にした実装

## 基本方針

- まず調査対象と確認したい論点を一文で固定する。
- 初見 repo や規約が曖昧な場合は、規約と確認手段の grounding を先に取る。
- 確認できた事実と未確認事項を混ぜない。
- 調査だけで閉じる案件では、実装案を決め打ちしない。

## 手順

1. 調査対象と確認したい論点を一文で固定する
2. 初見 repo や規約が曖昧な場合は、次の順で grounding を取る
   - `AGENTS.md`
   - `README` や運用 docs
   - config / manifest / CI / lint / formatter
   - 関連ディレクトリと近傍実装
   - test / build / lint / smoke などの確認手段
3. repo や既存文脈から確認できる事実を `facts` として集める
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

## 停止条件

- workspace 外の前提が支配的で、根拠ある整理ができない
