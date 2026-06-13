# ADR 0030: Split orchestrate tier flows into tier-specific references

- Status: Superseded
- Superseded-By: 0036

## Context

`orchestrate` は全依頼の入口として常時使うため、`SKILL.md` の本文が毎回 context に入る。従来は Phase 0、Triage、tier 別 flow、full tier の Phase / Gate 詳細を `references/sdlc-flow.md` にまとめていた。

Agent Skills の progressive disclosure では、`SKILL.md` は core instructions に絞り、詳細は必要時に読む `references/` へ分けるのが望ましい。一方、`sdlc-flow.md` を索引だけに縮小すると、内容は `SKILL.md` の tier reference 表と重複する。索引だけの reference は読み分けの負荷だけを増やす。

## Decision

- `orchestrate/SKILL.md` には Phase 0 -> Triage の入口 flow、Triage 停止線、tier 別 reference の読み分け、Phase / Gate の星取表を置く。
- tier 決定後の flow、分岐後停止線、agent 呼び出し、artifact、format link は tier ごとの reference に分ける。
  - `references/inquiry.md`
  - `references/micro.md`
  - `references/standard.md`
  - `references/full.md`
- `references/sdlc-flow.md` は削除する。必要な索引情報は `SKILL.md` の Triage 表に吸収する。
- Claude / Codex 両 surface の `orchestrate` skill で同じ構造を使う。

## Consequences

- inquiry / micro の軽い依頼で full tier の詳細を読まずに済む。
- full tier の Phase / Gate 詳細は `references/full.md` に隔離される。
- 現行導線では `references/sdlc-flow.md` を読まない。
- 旧 ADR や過去 request artifact には、履歴として削除前の `references/sdlc-flow.md` 参照が残る。
- 今後 tier flow、分岐後停止線、agent / artifact / format を変更する場合は該当 tier reference を確認し、入口判断や星取表が変わる場合だけ `SKILL.md` を更新する。
