# 0013: PRD と architecture 改善の skill surface を追加する

- Status: Accepted
- Amends: 0011, 0012
- Amended by: 0017

ADR 0011 では skill / reviewer surface を整理し、正式入口を増やしすぎない方針を採った。一方で、PRD draft 生成と architecture 改善は、既存の `planning`、`research` と近いが、成果物と作業単位が異なる。PRD draft は `planning` の成果物として扱い、`architecture` は `zoom-out` 的な構造把握を探索ステップとして吸収した architecture 改善 skill とする。

## Consequences

- PRD は正式な要求文書になりうるが、生成時点では draft とし、repo の正式要求文書として保存する、issue 化する、既存 docs に反映する、といった durable 化は明示依頼がある時だけ扱う。
- `zoom-out` は独立 skill としては追加せず、architecture 改善のための module / caller / 責務の地図化として `architecture` に含める。
- `architecture` は候補出しと候補選択後の grilling まで扱い、`CONTEXT.md` や ADR 更新が必要になった時は `planning` スキルに切り替える。
