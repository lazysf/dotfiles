# Requirements

## 目的

Claude 側 `orchestrate` skill に、Codex 側で追加済みの triage 直後 tier 初回表示を反映し、同種の反映漏れがないか確認する。

## 背景 / 課題

`dot_codex/skills/orchestrate/SKILL.md` では、Phase 0 / Triage で tier 決定直後かつ reference 読み込み前に `tier: <tier>。根拠: <短い理由>。` を表示する手順が追加済みである。一方、`dot_claude/skills/orchestrate/SKILL.md` は旧手順のままで、Claude 側では最初の tier 表示が明示されていない。

## Scope

- `dot_claude/skills/orchestrate/SKILL.md` の Phase 0 / Triage 手順へ、tier 決定直後の初回表示を追加する。
- `dot_claude/skills/orchestrate/SKILL.md` の `## 出力` へ、初回表示の必須形式を追加する。
- 根拠文の sensitive data 抑止を Claude 側にも反映する。
- `dot_codex/skills/orchestrate/` と `dot_claude/skills/orchestrate/` の差分を確認し、今回の Tier 表示変更に関する反映漏れが他にないか判断する。

## Non-Scope

- Codex 側 `orchestrate` skill の変更。
- Claude 側 tier 判定条件、Tier Map、完了方法、tier reference flow の変更。
- Codex / Claude 固有の表記差（`Codex` / `Claude`、`agent` / `subagent` など）の統一。
- `orchestrate` 以外の skill / agent / runtime config の変更。
- 新しい script、dependency、tooling、hook の追加。

## 要求事項

- `REQ-001`: Claude 側 `orchestrate` は triage 直後、後続 reference を読む前に、選択した tier と短い根拠をユーザーへ示す。
- `REQ-002`: 停止線に触れて `full` に倒す場合も、`REQ-001` と同じ初回表示を行う。
- `REQ-003`: 初回表示の形式は `tier: <tier>。根拠: <短い理由>。` とする。
- `REQ-004`: 初回表示の根拠文に secret 値、認証情報、private data、具体的な sensitive data を含めない。
- `REQ-005`: 今回の Tier 表示変更に関する Codex / Claude 間の反映漏れを確認する。
- `REQ-006`: Codex / Claude 固有の表記差は維持する。

## 受入条件

- `AC-001`: `REQ-001` に対し、`dot_claude/skills/orchestrate/SKILL.md` の Phase 0 / Triage 手順で、tier 決定直後かつ reference 読み込み前のユーザー表示が明記されている。
- `AC-002`: `REQ-002` に対し、停止線により `full` へ倒す場合も同じ形式で表示することが明記されている。
- `AC-003`: `REQ-003` に対し、初回表示形式として `tier: <tier>。根拠: <短い理由>。` が明記されている。
- `AC-004`: `REQ-004` に対し、根拠文の sensitive data 抑止が `dot_claude/skills/orchestrate/SKILL.md` に明記されている。
- `AC-005`: `REQ-005` に対し、`dot_codex/skills/orchestrate/` と `dot_claude/skills/orchestrate/` の差分確認結果が記録されている。
- `AC-006`: `REQ-006` に対し、reference files の Codex / Claude 固有表記差を意図的に変更していない。

## 制約

- Agent Skills 公式仕様、Agent Skills best practices、Claude Code skills docs、Claude Code best practices に反しない。
- `SKILL.md` への追記は必要最小限にする。
- Phase 3 着手前に full flow の checkpoint を守る。

## 前提

- `dot_claude/skills/orchestrate/SKILL.md` は repo 管理対象の Claude Code skill source である。
- Claude Code skills docs では、skills は `SKILL.md` の frontmatter と Markdown instructions で構成され、`SKILL.md` 本文は skill 実行時の instructions として扱われる。
- Agent Skills specification では、skill は最低限 `SKILL.md` を含み、frontmatter と Markdown body を持つ。
- 既存差分確認では、reference files の差分は Codex / Claude 固有表記に閉じていた。

## 未確認事項

- なし。
