# 0026: orchestrate に inquiry tier を追加し全依頼を入口にする

- Status: Superseded
- Superseded-By: 0036
- Amended-By: 0029
- Amends: 0025

ADR 0025 で `orchestrate` を全依頼の Phase 0 + Triage 入口とし、規模で `micro` / `standard` / `full` に振り分ける形にした。しかし Decision で「単なる質問・相談・調査だけの依頼は対象外」と例外を残したため、開発文脈にない単純な質問では `orchestrate` が発火せず、入口判断の場当たり化が再発した。実運用でも、別セッションで質問依頼に対して `orchestrate` が triage を通さずに進んだ事例が観測された。除外句が SKILL.md description にも残っており、Claude Code の skill 発火条件としても trigger を絞っていた。

入口の例外を完全に取り除き、質問・相談・調査も `orchestrate` を通すために、新 tier `inquiry` を追加する。Phase 0 + Triage は維持し、Triage に「性質」軸を加えてコード変更を伴わない依頼を `inquiry` に振り分ける。`inquiry` は Phase 0 のみで完了する軽量経路にし、Gate と request folder artifact を強制しない。これにより重工程を恐れた skill 回避を抑え、入口判断を完全に一本化する。

## Decision

- 全依頼を `orchestrate` の Phase 0 + Triage に入口を統一する。質問・相談・調査だけの依頼を例外として除外しない。
- Triage は 2 段で判定する。
  - 停止線（公開挙動 / 公開 API / data format / 永続化 / auth / 権限 / secret / 新依存 / 破壊的操作 / 本番設定）に触れるなら、規模に関わらず `full`。
  - 触れないなら性質と規模で振り分ける。
    - コード変更・差分作成・実装を伴わない質問、相談、調査 -> `inquiry`
    - 自明・単一箇所・設計判断なしのコード変更 -> `micro`
    - 複数 file または軽い設計判断あり -> `standard`
  - 迷う場合は上位 tier に倒す。
- `inquiry` tier の flow。
  - Phase 0 -> lead が直接回答（必要なら `analyst` を 1 回呼ぶ）-> 完了。
  - Gate なし。artifact 任意。triage 記録を残したい場合は `request.md` のみで十分。
  - 途中でコード変更・実装・既存機能変更が必要になった時点で、lead が tier を再判定し `micro` / `standard` / `full` のいずれかへ昇格する。
- SKILL.md description は「全依頼の進行入口」を表す内容に揃え、imperative + pushy phrasing で発火条件を明確にする。除外句は持たない。
- ADR 0025 の「単なる質問・相談・調査だけの依頼は対象外」を撤回する。`orchestrate` を通すかどうかの判断軸は、依頼種別の事前分類ではなく Triage の停止線判定と性質・規模判定に統一される。

## Consequences

- tier 別の通す Phase / Gate は引き続き `orchestrate` の `references/sdlc-flow.md` を正本にする。`inquiry` 節を追加し、Phase 1 以降は通さない旨を明示する。
- Claude / Codex 両 surface の `orchestrate` SKILL.md と `references/sdlc-flow.md`、進行節（`dot_claude/CLAUDE.md`、`dot_codex/AGENTS.md`）、`docs/notes/runtime-surface-guidance.md` を同期して 4 tier (`inquiry` / `micro` / `standard` / `full`) に更新する。
- 入口判断に「依頼種別」の事前分類を持ち込まない。skill description は trigger surface として `optimizing-descriptions` の指針（imperative phrasing、ユーザー意図、pushy さ、1024 字制限）に従う。
- 既存 `micro` / `standard` / `full` の対象、flow、Gate 構成は変更しない。`inquiry` は新規追加のみで、Gate review composition と request folder layout に影響しない。
- `inquiry` は artifact を強制しないため、Triage 記録は `request.md` を作らない経路でも許す。継続して同じテーマで質問が続く場合は昇格を検討する。
