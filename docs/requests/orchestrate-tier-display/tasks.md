# Tasks

## 実装方針

`DD-001`〜`DD-006` に沿い、`dot_codex/skills/orchestrate/SKILL.md` の `## Phase 0 -> Triage` と `## 出力` だけを最小編集する。初回表示の追加を、tier 判定条件や各 tier reference の工程変更と混ぜない。対応: `AC-001` / `AC-002` / `AC-003` / `AC-004`。

## 実装タスク

- `TASK-001`: `## Phase 0 -> Triage` に、tier 決定直後かつ該当 reference 読み込み前に最初の中途表示を行う手順を追加する。停止線により `full` へ倒す場合も同じ対象に含める。完了条件: Phase 0 手順上で表示タイミングが「tier 決定直後」「reference 読み込み前」と読める。確認方法: 対象セクションを読み、停止線 `full` の場合も対象であることを確認する。対応: `DD-001` / `DD-003`, `AC-001` / `AC-002`。
- `TASK-002`: `TASK-001` の追記文に、初回表示形式 `tier: <tier>。根拠: <短い理由>。` を明記する。完了条件: 表示形式が表記揺れなく記載されている。確認方法: `rg 'tier: <tier>。根拠: <短い理由>。' dot_codex/skills/orchestrate/SKILL.md` で確認する。対応: `DD-002`, `AC-003`。
- `TASK-003`: `## 出力` に、最終出力項目とは別に「最初の中途表示」として必須形式を追加し、既存の `tier` 最終出力項目は維持する。完了条件: `## 出力` で初回表示と最終出力の役割が区別されている。確認方法: `## 出力` セクションを読み、既存の `tier` 項目が削除・置換されていないことを確認する。対応: `DD-005`, `AC-003`。
- `TASK-004`: 初回表示の根拠文に secret 値、認証情報、private data、具体的な sensitive data を含めず、tier 判定条件または停止線カテゴリへ一般化する注意を `Phase 0 -> Triage` または `## 出力` に含める。完了条件: 根拠文の sensitive data 抑止が `SKILL.md` に明記されている。確認方法: 対象セクションを読み、根拠に sensitive data を含めないルールが確認できる。対応: `DD-002` / `DD-006`, `AC-002` / `AC-003` / `AC-004`。
- `TASK-005`: 変更範囲が対象 2 セクションに収まり、tier 判定表、Tier Map、完了方法、tier reference file、権限 / data / 外部 I/O の扱いを変更していないことを確認する。完了条件: 差分が `dot_codex/skills/orchestrate/SKILL.md` の対象記述追加に限定されている。確認方法: `git diff -- dot_codex/skills/orchestrate/SKILL.md` で、`分岐`、`Tier Map`、`完了方法`、`references/*.md`、code、config、tests、script、hook、dependency に差分がないことを確認する。対応: `DD-004` / `DD-006`, `AC-004`。

## 実装順序

1. `TASK-001`: Phase 0 / Triage の手順順序に初回表示責務を差し込む。
2. `TASK-002`: `TASK-001` の表示形式を固定文言として明記する。
3. `TASK-003`: `## 出力` に初回表示の必須形式を追加する。
4. `TASK-004`: 根拠文の sensitive data 抑止を明記する。
5. `TASK-005`: 差分境界と受入条件を確認する。

## 変更境界

- 変更対象:
  - `dot_codex/skills/orchestrate/SKILL.md`
    - `## Phase 0 -> Triage`
    - `## 出力`
- 変更しない対象:
  - `dot_codex/skills/orchestrate/SKILL.md` の tier 判定表、`Tier Map`、`完了方法`
  - `dot_codex/skills/orchestrate/references/inquiry.md`
  - `dot_codex/skills/orchestrate/references/micro.md`
  - `dot_codex/skills/orchestrate/references/standard.md`
  - `dot_codex/skills/orchestrate/references/full.md`
  - code、config、tests、script、hook、dependency

## Scope 外にしたこと

- tier 判定条件の変更。
- 各 tier reference flow の工程変更。
- `orchestrate` 以外の skill / agent / runtime config の変更。
- 新しい script、dependency、tooling、hook の追加。
- security / 権限 / data / 外部 I/O の扱い変更。

## リスク

- 初回表示を最終出力項目と混ぜると、triage 直後の表示義務が曖昧になる。
- 停止線により `full` へ倒す場合の記述が Phase 0 手順にないと、`AC-002` を満たせない。
- tier 判定表、Tier Map、完了方法まで編集すると `REQ-004` / `AC-004` の scope を超える。
- 初回表示の根拠文に secret 値、認証情報、private data、具体的な sensitive data を含めると、情報漏洩につながる。
- 既存未コミット差分がある場合でも、その差分を根拠にせず、上流 artifact と最終差分の整合で判断する必要がある。

## 未確認事項

- なし。
