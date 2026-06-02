# Implementation

## 対応タスク / 対応範囲

- `TASK-001`: `## Phase 0 -> Triage` で、tier 決定と reference 読み込みを分け、tier 決定直後の初回表示を追加した。
- `TASK-002`: 初回表示形式 `tier: <tier>。根拠: <短い理由>。` を明記した。
- `TASK-003`: `## 出力` に、最終出力項目とは別の「最初の中途表示」を追加した。
- `TASK-004`: 根拠文に secret 値、認証情報、private data、具体的な sensitive data を含めず、tier 判定条件または停止線カテゴリへ一般化する注意を追加した。
- `TASK-005`: 実装後に差分境界を確認した。

## 変更内容

- `orchestrate` の Phase 0 / Triage 手順で、tier 決定直後かつ tier reference 読み込み前に初回表示することを明記した。
- 停止線により `full` へ倒す場合も、同じ形式で表示することを明記した。
- 根拠文の sensitive data 抑止を明記した。
- `## 出力` に、初回表示の必須形式を追加した。

## 変更ファイル

- `dot_codex/skills/orchestrate/SKILL.md`: Phase 0 / Triage 手順と `## 出力` のみ変更。

## Scope 外

- tier 判定条件の変更。
- tier reference flow の変更。
- `Tier Map`、`完了方法` の変更。
- `orchestrate` 以外の skill / agent / runtime config の変更。
- 新しい script、dependency、tooling、hook の追加。

## 実装中に判明した事項

- 直前の候補差分は、`TASK-001`〜`TASK-003` と一致していたが、`TASK-004` の sensitive data 抑止文が不足していた。

## 実行した確認

- `git diff -- dot_codex/skills/orchestrate/SKILL.md`
- `rg -n "tier: <tier>。根拠: <短い理由>。|secret 値|private data|sensitive data|## Phase 0 -> Triage|## 出力|## 分岐|## Tier Map|## 完了方法" dot_codex/skills/orchestrate/SKILL.md`
- `git status --short --untracked-files=all`

## 未確認事項

- なし。
