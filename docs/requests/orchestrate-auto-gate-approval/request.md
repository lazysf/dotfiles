# request: orchestrate-auto-gate-approval

## 元要求

- Claude / Codex の orchestrate skill で、各 Gate の review が pass した場合、ユーザー確認が本当に必要な内容でなければ承認待ちを自動で skip し、次の処理へ進んでほしい。
- 目的は、できるだけ自走させること。

## triage

- 停止線接触: なし。skill の運用文言変更であり、secret / auth / 権限 / 永続化 / 公開 API / 新依存 / 破壊的操作には触れない。
- tier: `standard`
- 根拠: Codex / Claude 両 surface と orchestrate reference の複数 file にまたがるが、変更は Gate pass 後の承認 checkpoint 文言に限定する。

## scope

- `dot_codex/skills/orchestrate/SKILL.md`
- `dot_claude/skills/orchestrate/SKILL.md`
- `dot_codex/skills/orchestrate/references/gate-review.md`
- `dot_claude/skills/orchestrate/references/gate-review.md`
- `dot_codex/skills/orchestrate/references/standard.md`
- `dot_claude/skills/orchestrate/references/standard.md`
- `dot_codex/skills/orchestrate/references/full.md`
- `dot_claude/skills/orchestrate/references/full.md`
- `docs/adr/0031-add-gate-pass-user-approval-checkpoints.md`
- `docs/adr/0032-auto-skip-gate-pass-approval-when-no-user-decision.md`
- `docs/README.md`
- `docs/notes/runtime-surface-guidance.md`

## acceptance

- **AC-001**: Gate pass 後、ユーザー確認が必要な事項がなければ承認待ちを挟まず次工程または完了へ進む、と明記されている。
- **AC-002**: 確認必須の停止線、scope / risk 受容、change request、同じ Gate blocking 繰り返し、commit / push は自走対象外のまま。
- **AC-003**: Codex / Claude の orchestrate skill で同じ方針になっている。
- **AC-004**: 旧方針 ADR 0031 は本文を保持したまま superseded とし、新 ADR で今回の判断を記録している。
