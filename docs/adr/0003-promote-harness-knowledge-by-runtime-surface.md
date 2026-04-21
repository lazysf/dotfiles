# 0003: ハーネス知見は runtime surface ごとに昇格先を分ける

- Status: Accepted

## Context

ハーネスエンジニアリングの知見は、repo-level の通常知見、判断記録、再利用する作業手順、機械的なガード、専門化した補助役が混ざりやすい。
これらを同じ置き場に集めると、`dot_codex/` に repo-level の履歴が混入したり、逆に実運用物が `docs/` へ散らばったりして責務が崩れる。

現行の共通ハーネスは `core-*` を正式入口とし、旧 `entry-*` / `phase-*` を互換 wrapper として残す構成へ移行している。repo-level knowledge の置き場もその runtime surface に合わせて明確にしておきたい。

## Decision

ハーネス知見は、次の順で昇格先を判断する。

`repo-level の通常知見 -> root docs/knowledge/ -> 判断記録は root docs/adr/ -> 繰り返し手順は skills/ -> 機械的ガードは rules/ -> 専門化した補助役は agents/`

## Consequences

- `docs/knowledge/` には、この repo を保守するための通常知見を置く
- `docs/adr/` には、選択理由ごと残す判断記録を置く
- `dot_codex/skills/` には、再利用する作業手順を置く
- `dot_codex/rules/` には、破壊的操作や広域操作を機械的にガードする制約を置く
- `dot_codex/agents/` には、reviewer のような read-only の専門化した補助役を置く
- `docs/knowledge/classification-driven-workflow-surface.md` を、`core-*` 正式入口と deprecated wrapper の参照基準として扱う
