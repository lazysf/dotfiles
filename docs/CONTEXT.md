# Knowledge Ledger

Knowledge Ledger context は、この Codex ハーネスを保守するための durable な repo-level knowledge を定義する。
再利用する背景知識、判断、context language を managed runtime surface から分離するために存在する。

## Language

**Knowledge Ledger**: `docs/` 配下と root context files に置く repo-level の durable knowledge。
_Avoid_: runtime surface, managed harness artifact

**Note**: `docs/notes/` 配下に置く durable な guidance または背景知識。
_Avoid_: scratchpad, temporary memo

**ADR**: あとから変えにくく、文脈なしでは驚きがあり、実際の trade-off がある判断を記録する、`docs/adr/` 配下の番号付き decision record。
_Avoid_: general note, changelog

**Decision Status**: `Proposed`、`Accepted`、`Superseded`、`Rejected` など、ADR の lifecycle marker。
_Avoid_: commit state, merge status

**Context Map**: 複数の context files とその関係を列挙する root `CONTEXT-MAP.md`。
_Avoid_: docs index, README

**Context**: repo language の境界づけられた領域に対する `CONTEXT.md` glossary。
_Avoid_: specification, work log, implementation plan

**Grilling**: 実装や文書化の前に、scope、成功条件、制約、検証入口、実装 readiness を一問ずつ確認する workflow。
_Avoid_: docs-only update, implementation, review

**Scribing**: README、既存 docs、CONTEXT、ADR などの artifact を一次情報に沿って作成、更新、整形する workflow。
_Avoid_: requirement negotiation, implementation, commit step

## Relationships

- **Context Map** は各 **Context** を指す。
- **Context** は language を定義し、implementation decisions は定義しない。
- **Note** は decision record ではない durable guidance を記録する。
- **ADR** は意味のある decision を記録し、**Decision Status** を持つ。
- **Grilling** は、どの durable artifact を変更するべきかを会話中に切り分ける。
- **Scribing** は、確定した内容を **Note**、**ADR**、**Context** などへ反映する。

## Example dialogue

> **Maintainer:** 「この repo では multi-context docs にすると決めた。これは Context update？ ADR？」
> **Domain expert:** 「用語は Context に置く。判断と trade-off は、あとから変えにくく、意外性があり、実際の代替案があった場合だけ ADR に置く。」

## Flagged ambiguities

- 「context」は conversation context と `CONTEXT.md` glossary の両方を指しうる。Resolved: この ledger では glossary artifact だけを **Context** と呼ぶ。
