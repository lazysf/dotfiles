# 0011: Codex skill and reviewer surface を整理する

- Status: Accepted
- Supersedes: 0009

共通ハーネスの user-facing skill surface は、作業入口が多すぎると発火条件と責務境界が読みにくくなるため、`dot_codex/skills/` を 13 個の正式入口へ整理する。bug / compat / quality / security / maintenance の専用 analysis skill は削除し、事実確認は `research`、実装前 scope は `implementation-planning`、差分 review は reviewer agent に寄せる一方、`grill-me`、`coding-standards`、`change-verification`、`review-findings-summary` は入口が途切れないよう維持する。ADR 0009 の context-aware planning と `CONTEXT-MAP.md` / 近傍 `CONTEXT.md` 方針は継承し、0011 は 0009 の「analysis 系 skill を v1 では削除しない」段階方針だけを後継判断として置き換える。
