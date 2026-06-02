# Tasks

## 実装方針

`dot_claude/skills/orchestrate/SKILL.md` の Phase 0 / Triage と `## 出力` だけを、詳細設計 `DD-001` から `DD-006` に沿って最小変更する。tier 決定、初回表示、reference 読み込みの順序を明確にし、初回表示形式 `tier: <tier>。根拠: <短い理由>。` と sensitive data 抑止を Claude 側へ反映する。

Claude 固有の `subagent` 表記は維持し、`dot_claude/skills/orchestrate/references/` は編集しない。Codex / Claude 間の Tier 表示変更に関する反映漏れ確認は Phase 3 の検証として実施し、結果を `docs/requests/claude-orchestrate-tier-display/test.md` に記録する。

対応: `DD-001`, `DD-002`, `DD-003`, `DD-004`, `DD-005`, `DD-006`, `DD-007`, `DD-008`, `DD-009`

## 実装タスク

- `TASK-001`: `dot_claude/skills/orchestrate/SKILL.md` の `## Phase 0 -> Triage` を更新し、手順 4 を tier 決定、手順 5 を初回表示、手順 6 を reference 読み込みとして分離する。手順 5 には、停止線により `full` へ倒す場合も同じ形式で表示すること、根拠に secret 値、認証情報、private data、具体的な sensitive data を含めず一般化することを含める。完了条件は、tier 決定直後かつ reference 読み込み前に `tier: <tier>。根拠: <短い理由>。` を示す順序が本文上で確認できること。確認方法は、該当セクションを読み、手順 4 から 6 の順序、停止線 `full` 時の扱い、sensitive data 抑止文言を確認する。対応: `DD-001`, `DD-002`, `DD-003`, `DD-004`, `DD-005`, `AC-001`, `AC-002`, `AC-003`, `AC-004`
- `TASK-002`: `dot_claude/skills/orchestrate/SKILL.md` の `## 出力` 先頭に、最初の中途表示として `triage` 直後に `tier: <tier>。根拠: <短い理由>。` を必ず出す旨を追加する。完了条件は、`## 出力` に初回表示の必須形式が明記され、通常の完了時 handoff 項目とは別に読めること。確認方法は、`## 出力` セクションを読み、初回表示形式が完全一致で含まれることを確認する。対応: `DD-006`, `AC-003`
- `TASK-003`: Claude 固有表記と変更境界を確認する。`dot_claude/skills/orchestrate/SKILL.md` の `subagent` 表記を `agent` に置換していないこと、`dot_claude/skills/orchestrate/references/` を編集していないことを確認する。完了条件は、Claude 固有の `subagent` 表記が維持され、references 配下に差分がないこと。確認方法は、git diff または同等の差分確認で変更対象が `dot_claude/skills/orchestrate/SKILL.md` の指定箇所に限定されていることを確認する。対応: `DD-007`, `DD-008`, `AC-006`
- `TASK-004`: `dot_codex/skills/orchestrate/` と `dot_claude/skills/orchestrate/` の差分を確認し、今回の Tier 表示変更に関する反映漏れ確認結果を `docs/requests/claude-orchestrate-tier-display/test.md` に記録する。`references/` 配下の `autonomous-loop.md`, `full.md`, `handoff.md` にある Codex / Claude / subagent 表記差は、今回 scope 外の意図した差分として分類し、編集しない。完了条件は、Tier 表示変更に関する未反映有無と、references 配下の表記差をどう扱ったかが `test.md` に記録されていること。確認方法は、`test.md` を読み、反映漏れ確認結果、変更対象境界、references 非変更、Claude 固有表記維持が記録されていることを確認する。対応: `DD-008`, `DD-009`, `AC-005`, `AC-006`

## 実装順序

1. `TASK-001`: Phase 0 / Triage の順序を先に確定する。`TASK-002` の出力項目はこの本文仕様に従う。
2. `TASK-002`: `## 出力` に初回表示の必須形式を追加し、Phase 0 / Triage と表記を揃える。
3. `TASK-003`: 実装差分が指定範囲に収まっていることと、Claude 固有表記が維持されていることを確認する。
4. `TASK-004`: Codex / Claude 間の Tier 表示変更に関する反映漏れを確認し、結果を `test.md` に記録する。

## 変更境界

- 実装変更対象:
  - `dot_claude/skills/orchestrate/SKILL.md`
    - `## Phase 0 -> Triage`
    - `## 出力`
- 検証記録対象:
  - `docs/requests/claude-orchestrate-tier-display/test.md`
- 読み取り確認対象:
  - `dot_codex/skills/orchestrate/SKILL.md`
  - `dot_codex/skills/orchestrate/references/`
  - `dot_claude/skills/orchestrate/references/`
- 編集しない:
  - `dot_codex/skills/orchestrate/**`
  - `dot_claude/skills/orchestrate/references/**`
  - `orchestrate` 以外の skill / agent / runtime config

## Scope 外にしたこと

- Codex 側 `orchestrate` skill の変更。
- Claude 側 tier 判定条件、Tier Map、完了方法、tier reference flow の変更。
- Codex / Claude 固有の表記差の統一。
- `dot_claude/skills/orchestrate/references/` の編集。
- 新しい script、dependency、tooling、hook の追加。
- 公開 API、data format、永続化、auth、権限、secret、runtime config の変更。

## リスク

- Phase 0 / Triage の順序が曖昧なままだと、reference 読み込み前に初回表示する要件を満たせない。
- `## 出力` と Phase 0 / Triage で初回表示形式がずれると、`AC-003` を満たせない。
- Claude 固有の `subagent` 表記を Codex 側の `agent` 表記へ寄せると、`REQ-006` / `AC-006` に反する。
- `references/` 配下の表記差を反映漏れとして編集すると、今回の変更境界を超える。

## 未確認事項

- なし。
