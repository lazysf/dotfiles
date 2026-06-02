# Implementation

## 対応タスク / 対応範囲

- `TASK-001`: Claude 側 `## Phase 0 -> Triage` を、tier 決定、初回表示、reference 読み込みの順序へ分離した。
- `TASK-002`: Claude 側 `## 出力` に、最初の中途表示の必須形式を追加した。
- `TASK-003`: Claude 固有の `subagent` 表記と references 非変更を確認した。
- `TASK-004`: Codex / Claude 間の Tier 表示変更に関する反映漏れ確認を実施し、結果を `test.md` に記録した。

## 変更内容

- `dot_claude/skills/orchestrate/SKILL.md` の Phase 0 / Triage で、tier 決定直後かつ reference 読み込み前に `tier: <tier>。根拠: <短い理由>。` を表示する手順を追加した。
- 停止線により `full` に倒す場合も同じ形式で表示することを追加した。
- 根拠文に secret 値、認証情報、private data、具体的な sensitive data を含めず、tier 判定条件または停止線カテゴリへ一般化することを追加した。
- `## 出力` に「最初の中途表示」を追加した。

## 変更ファイル

- `dot_claude/skills/orchestrate/SKILL.md`: Phase 0 / Triage と `## 出力` のみ変更。

## Scope 外

- `dot_codex/skills/orchestrate/**` の変更。
- `dot_claude/skills/orchestrate/references/**` の変更。
- Claude 固有 `subagent` 表記の変更。
- tier 判定条件、Tier Map、完了方法、tier reference flow の変更。
- runtime config、script、hook、workflow、CI、dependency、外部 I/O の変更。

## 実装中に判明した事項

- 実装後の `dot_codex/skills/orchestrate/SKILL.md` と `dot_claude/skills/orchestrate/SKILL.md` の差分は、Claude 側の `subagent` 表記だけに縮小した。
- `references/` 配下の差分は `autonomous-loop.md`, `full.md`, `handoff.md` の Codex / Claude / subagent 表記差で、今回 scope 外の意図した差分として維持した。

## 実行した確認

- `git diff -- dot_claude/skills/orchestrate/SKILL.md`
- `rg -n "最初の中途表示|tier: <tier>。根拠: <短い理由>。|secret 値|private data|sensitive data|subagent 起動|## Phase 0 -> Triage|## 出力" dot_claude/skills/orchestrate/SKILL.md`
- `git diff --name-only -- dot_claude/skills/orchestrate dot_codex/skills/orchestrate`
- `diff -u dot_codex/skills/orchestrate/SKILL.md dot_claude/skills/orchestrate/SKILL.md`
- `for f in dot_codex/skills/orchestrate/references/*.md; do b=${f#dot_codex/skills/orchestrate/references/}; diff -q "$f" "dot_claude/skills/orchestrate/references/$b"; done`

## 未確認事項

- なし。
