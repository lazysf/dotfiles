# Detailed Design

## 対象範囲

- `dot_claude/skills/orchestrate/SKILL.md`
  - `## Phase 0 -> Triage`
  - `## 出力`
- 読み取り確認対象:
  - `dot_codex/skills/orchestrate/SKILL.md`
  - `dot_codex/skills/orchestrate/references/`
  - `dot_claude/skills/orchestrate/references/`
- 記録先:
  - `docs/requests/claude-orchestrate-tier-display/test.md`

## Interface 詳細

- `Phase 0 -> Triage 初回表示`: 入力は triage 結果と短い根拠。出力は `tier: <tier>。根拠: <短い理由>。`。副作用はユーザーへの表示のみ。対応: `BD-001`, `BD-002`, `AC-001`, `AC-002`, `AC-003`, `AC-004`
- `SKILL.md ## 出力`: 初回表示を、完了時 handoff 項目とは別の必須出力として列挙する。対応: `BD-003`, `AC-003`
- `反映漏れ確認`: 入力は Codex / Claude の orchestrate skill 差分。出力は Tier 表示変更に関する確認結果。記録先は `docs/requests/claude-orchestrate-tier-display/test.md`。対応: `BD-005`, `BD-006`, `AC-005`, `AC-006`

## 詳細設計項目

- `DD-001`: `## Phase 0 -> Triage` の手順 4 は「停止線に触れない場合、tier を決める。」に分ける。対応: `BD-001`, `AC-001`
- `DD-002`: 手順 5 として、tier 決定直後、該当 reference を読む前に `tier: <tier>。根拠: <短い理由>。` をユーザーへ示すことを追加する。対応: `BD-001`, `BD-002`, `AC-001`, `AC-003`
- `DD-003`: 手順 5 には、停止線に触れるため `full` に倒す場合も同じ形式で示し、実行、受容、Phase 3 着手前に必要な確認を続けることを含める。対応: `BD-001`, `BD-002`, `AC-002`
- `DD-004`: 手順 5 には、根拠に secret 値、認証情報、private data、具体的な sensitive data を含めず、tier 判定条件または停止線カテゴリへ一般化することを含める。対応: `BD-002`, `AC-004`
- `DD-005`: 手順 6 として「該当 reference を読む。」を置き、初回表示が reference 読み込みより前である順序を明確にする。対応: `BD-001`, `AC-001`
- `DD-006`: `## 出力` の先頭に「最初の中途表示: triage 直後に `tier: <tier>。根拠: <短い理由>。` を必ず出す。」を追加する。対応: `BD-003`, `AC-003`
- `DD-007`: `あなたは SDLC workflow... subagent 起動...` の Claude 固有表記は変更しない。対応: `BD-004`, `AC-006`
- `DD-008`: `references/` 配下は編集対象に含めない。差分確認時は `autonomous-loop.md`, `full.md`, `handoff.md` の Codex / Claude / subagent 表記差を意図した差分として分類する。対応: `BD-005`, `AC-005`, `AC-006`
- `DD-009`: Phase 3 の検証では、Tier 表示変更に関する反映漏れ確認結果を `docs/requests/claude-orchestrate-tier-display/test.md` に記録する。対応: `BD-006`, `AC-005`

## 処理フロー

1. `dot_claude/skills/orchestrate/SKILL.md` の `## Phase 0 -> Triage` を対象にする。
2. 既存手順 4 を、tier 決定と reference 読み込みに分離する。
3. 分離した間に、初回表示の必須手順を追加する。
4. 初回表示手順には、停止線で `full` に倒す場合も同形式で表示することを含める。
5. 初回表示手順には、根拠文の sensitive data 抑止と一般化方針を含める。
6. `## 出力` の先頭に、最初の中途表示の必須形式を追加する。
7. Claude 固有の `subagent` 表記が保持されていることを確認する。
8. `dot_codex/skills/orchestrate/` と `dot_claude/skills/orchestrate/` の差分を確認し、Tier 表示変更に関する未反映が残っていないことを確認する。
9. `references/` 配下の差分は、Codex / Claude / subagent 表記差として分類し、変更しない。
10. 反映漏れ確認結果は `docs/requests/claude-orchestrate-tier-display/test.md` に記録する。

## Validation

- 変更ファイルは `dot_claude/skills/orchestrate/SKILL.md` のみであること。
- `dot_codex/skills/orchestrate/SKILL.md` は変更されていないこと。
- `dot_claude/skills/orchestrate/references/` は変更されていないこと。
- `## Phase 0 -> Triage` で、tier 決定、初回表示、reference 読み込みの順序が明確であること。
- 初回表示形式が `tier: <tier>。根拠: <短い理由>。` と完全一致していること。
- 停止線により `full` へ倒す場合も同形式で表示する旨が含まれていること。
- 根拠文に secret 値、認証情報、private data、具体的な sensitive data を含めない旨が含まれていること。
- Claude 固有の `subagent` 表記が `agent` に置換されていないこと。
- Codex / Claude 間の差分確認結果が `docs/requests/claude-orchestrate-tier-display/test.md` に記録される設計になっていること。

## Error Handling

- Tier 表示変更以外の未反映差分が見つかった場合は、今回 scope で扱えるかを判断せず、追加確認または change request 候補として扱う。
- `references/` 配下に Codex / Claude / subagent 表記差以外の差分が見つかった場合は、今回の実装対象へ含めず、反映漏れ候補として記録し、ユーザー確認対象にする。
- 差分確認中に secret らしい値や private data が見つかった場合は、値を出力せず、種類、場所、確認不能範囲だけを記録する。
- 初回表示の根拠を具体値なしで短く表現できない場合は、停止線カテゴリまたは tier 判定条件へ一般化する。

## Edge Case

- 停止線に触れない通常 triage でも、reference 読み込み前に初回表示する。
- 停止線に触れて `full` に倒す場合でも、同じ初回表示形式を使う。
- 要求が曖昧で triage 自体を停止する場合は、secret 値や private data を出さず、停止理由を一般化して扱う。
- `inquiry` / `micro` のように request folder を強制しない tier でも、初回表示自体は必須とする。
- Claude 側では `subagent` 表記を維持し、Codex 側の `agent` 表記へ寄せない。
- `references/` の表記差は今回の変更対象外であり、Tier 表示未反映とは扱わない。

## 状態遷移 / 分岐条件

- `要求受付済み` -> `Triage 停止線確認済み`
- `Triage 停止線確認済み` -> `tier 決定済み`: 停止線に触れない場合。
- `Triage 停止線確認済み` -> `full 決定済み`: 停止線に触れるため `full` に倒す場合。
- `tier 決定済み` または `full 決定済み` -> `初回表示済み`: `tier: <tier>。根拠: <短い理由>。` を表示した場合。
- `初回表示済み` -> `reference 読み込み`: 該当 reference を読む。
- `差分確認済み` -> `記録対象`: Tier 表示変更に関する確認結果を `test.md` に記録する。
- `差分確認済み` -> `ユーザー確認対象`: scope 外または固有表記差以外の反映漏れ候補が見つかった場合。

## Test 観点

- `TC-001`: `dot_claude/skills/orchestrate/SKILL.md` の Phase 0 / Triage に、tier 決定直後かつ reference 読み込み前の初回表示が明記されている。
- `TC-002`: 停止線により `full` へ倒す場合も、初回表示形式が適用される。
- `TC-003`: `## 出力` に、最初の中途表示として `tier: <tier>。根拠: <短い理由>。` が明記されている。
- `TC-004`: 根拠文の sensitive data 抑止が `SKILL.md` 本体に明記されている。
- `TC-005`: 変更対象が `dot_claude/skills/orchestrate/SKILL.md` に限定されている。
- `TC-006`: `dot_claude/skills/orchestrate/references/` が変更されていない。
- `TC-007`: Claude 固有の `subagent` 表記が維持されている。
- `TC-008`: Codex / Claude 間の Tier 表示変更に関する反映漏れ確認結果が `docs/requests/claude-orchestrate-tier-display/test.md` に記録されている。
- `TC-009`: 差分確認で見つかる `references/` の Codex / Claude / subagent 表記差が、今回 scope 外として扱われている。

## 未確認事項

- なし。
