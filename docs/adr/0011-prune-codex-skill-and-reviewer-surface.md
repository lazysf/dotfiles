# 0011: Codex skill and reviewer surface を整理する

- Date: 2026-05-18
- Status: Superseded
- Superseded-By: 0042
- Supersedes: 0009
- Amended-By: 0012, 0013, 0016, 0017, 0020, 0023, 0024, 0037

## 背景

記録に残っていない。

## 決定

共通ハーネスの user-facing skill surface は、作業入口が多すぎると発火条件と責務境界が読みにくくなるため、prefix なしの正式入口へ整理する。bug / compat / quality / security / maintenance の専用 analysis skill は削除し、事実確認は `research`、実装前 scope は `planning`、差分 review は reviewer agent に寄せる。ADR 0009 の context-aware planning と `CONTEXT-MAP.md` / 近傍 `CONTEXT.md` 方針は継承し、0011 は 0009 の「analysis 系 skill を v1 では削除しない」段階方針だけを後継判断として置き換える。

## 検討した代替案

記録に残っていない。

## 影響

後続の 0012 により、review 結果の出口整理は独立 skill ではなく reviewer agent 自身の返し方として扱う。
