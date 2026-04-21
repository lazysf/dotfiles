# 0002: project-specific knowledge は project の `docs/` に置く

- Status: Accepted

## Context

共通ハーネスに project ごとの知識を混ぜると、配布先ごとの差が蓄積しやすい。
Codex に参照させたい知識は、project root の短い `AGENTS.md` から辿れる場所に置く方が運用しやすい。

## Decision

project-specific knowledge の正本は各 project の `docs/` に置く。
project root `AGENTS.md` は短いポインタとして運用する。

## Consequences

- 共通ハーネスは project 固有の知識を持たない
- `.codex/` は knowledge の標準置き場として採用しない
- 共通ハーネス側の docs や skills には、workspace 横断で使う知識だけを残す
