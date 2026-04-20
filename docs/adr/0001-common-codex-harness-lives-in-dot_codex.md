# 0001: 共通 Codex ハーネスは `dot_codex/` に置く

- Status: Accepted

## Context

この repo は `chezmoi` で home 配下へ設定を展開する。
Codex の共通ハーネスは、展開後に `~/.codex` としてそのまま使える必要がある。

## Decision

共通ハーネスとして deployable な実運用物は `dot_codex/` に集約する。

## Consequences

- `dot_codex/` は展開後にも価値がある実運用物だけを置く
- repo-level の設計履歴や保守判断は別の置き場に分ける
