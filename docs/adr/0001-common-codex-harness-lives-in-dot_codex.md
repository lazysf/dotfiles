# 0001: 共通 Codex ハーネスは `dot_codex/` に置く

- Status: Accepted

## Context

この repo は `chezmoi` で home 配下へ設定を展開する。
Codex の共通ハーネスは、展開後に `~/.codex` としてそのまま使える必要がある。

repo-level の保守知識や判断記録まで `dot_codex/` に混ぜると、deployable artifact と保守元 repo の知見が混ざって責務が崩れる。

## Decision

共通ハーネスとして deployable な実運用物は `dot_codex/` に集約する。

## Consequences

- `dot_codex/` には展開後にも価値がある実運用物だけを置く
- repo-level の設計履歴や保守判断は `docs/` 側へ分ける
- `README.md` と `docs/README.md` では、deployable artifact と repo-level knowledge の置き場を分けて案内する
