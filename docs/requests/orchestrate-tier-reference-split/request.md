# Request: Split orchestrate tier flow references

## User Request

Claude / Codex の `orchestrate` skill について、`SKILL.md` 本文には Phase 0 と Triage までの flow を置き、分岐後の flow は `references/` の tier 別 file に分ける。

## Triage

- tier: `standard`
- 根拠: Claude / Codex 両 surface の skill 本文と references を更新し、active note と ADR を追従する。skill 定義変更だが、新依存、secret、auth、権限、本番設定、破壊的操作には触れない。

## Scope

- `dot_codex/skills/orchestrate/SKILL.md`
- `dot_codex/skills/orchestrate/references/*.md`
- `dot_claude/skills/orchestrate/SKILL.md`
- `dot_claude/skills/orchestrate/references/*.md`
- durable docs の最小追従

## Acceptance

- `SKILL.md` に Phase 0、Triage 判定、Triage 停止線、tier reference 読み分け、Phase / Gate 単位の Tier Map がある。
- `inquiry` / `micro` / `standard` / `full` の分岐後 flow と停止線が別 file になっている。
- `references/sdlc-flow.md` の索引内容は `SKILL.md` に吸収され、現行導線から外れている。
- Codex / Claude の structure が揃っている。
