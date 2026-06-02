# Basic Design

## 設計方針

Claude 側 `orchestrate` skill の入口手順だけを、Codex 側で追加済みの tier 初回表示仕様に合わせる。対象は `dot_claude/skills/orchestrate/SKILL.md` に限定し、Phase 0 / Triage の順序と `## 出力` の必須表示項目を補うことで、`REQ-001` から `REQ-004` / `AC-001` から `AC-004` を満たす。

Codex / Claude 間の反映漏れ確認は、今回の Tier 表示変更に関係する差分だけを対象にする。Claude 固有の `subagent` 表記、および `references/` 配下の Codex / Claude / subagent 表記差は意図した差分として維持し、`REQ-005` / `REQ-006` / `AC-005` / `AC-006` を満たす。

## 構成と責務

- `dot_claude/skills/orchestrate/SKILL.md`: Claude 側 orchestrate workflow の入口、triage、tier 初回表示、handoff 用出力項目を定義する。
- `dot_codex/skills/orchestrate/SKILL.md`: 反映元として参照する。変更対象にはしない。
- `dot_claude/skills/orchestrate/references/`: tier 別 flow の正本を保持する。今回の変更対象にはしない。
- `docs/requests/claude-orchestrate-tier-display/test.md`: Phase 3 の確認結果として、Codex / Claude 間の Tier 表示変更に関する反映漏れ確認結果を記録する。

## 基本設計項目

- `BD-001`: Claude 側 Phase 0 / Triage の手順を、tier 決定と reference 読み込みの間で初回表示する構造へ分ける。対応: `REQ-001`, `REQ-002`, `REQ-003`, `REQ-004`, `AC-001`, `AC-002`, `AC-003`, `AC-004`
- `BD-002`: 初回表示の interface は `tier: <tier>。根拠: <短い理由>。` に固定する。根拠は tier 判定条件または停止線カテゴリへ一般化し、secret 値、認証情報、private data、具体的な sensitive data を含めない。対応: `REQ-003`, `REQ-004`, `AC-003`, `AC-004`
- `BD-003`: Claude 側 `## 出力` に「最初の中途表示」を必須項目として追加し、通常の完了時出力項目とは別に扱う。対応: `REQ-001`, `REQ-003`, `AC-003`
- `BD-004`: Claude 固有の `subagent` 表記は維持し、Codex 側の `agent` 表記へ統一しない。対応: `REQ-006`, `AC-006`
- `BD-005`: `references/` は変更しない。既存確認済みの `autonomous-loop.md`, `full.md`, `handoff.md` の差分は Codex / Claude / subagent 表記差として扱い、今回の反映漏れ対象から除外する。対応: `REQ-005`, `REQ-006`, `AC-005`, `AC-006`
- `BD-006`: 反映漏れ確認結果は `docs/requests/claude-orchestrate-tier-display/test.md` に記録する。設計上は記録先だけを決め、実際の確認結果は Phase 3 の検証 artifact に残す。対応: `REQ-005`, `AC-005`

## 主要 interface / API / data flow

- Claude 側 orchestrate skill の利用者向け interface:
  - 入力: ユーザー要求、背景、期待状態、不明点。
  - 出力: triage 直後の最初の中途表示 `tier: <tier>。根拠: <短い理由>。`。
  - 副作用: ユーザーへ tier と根拠を表示する。外部 I/O、永続化、認証認可、secret 取得は行わない。
- Phase 0 data flow:
  - ユーザー要求を受け取る。
  - Triage 停止線を確認する。
  - tier を決定する。停止線により `full` に倒す場合もここで扱う。
  - reference を読む前に、tier と一般化した短い根拠を表示する。
  - 該当 reference を読む。
- 反映漏れ確認 data flow:
  - `dot_codex/skills/orchestrate/SKILL.md` と `dot_claude/skills/orchestrate/SKILL.md` を比較する。
  - Tier 表示仕様に関する未反映差分と、Claude 固有表記差を分類する。
  - `references/` 配下は変更せず、既存の表記差が今回 scope 外であることを確認対象に含める。
  - 確認結果を `docs/requests/claude-orchestrate-tier-display/test.md` に記録する。

## 既存構造との接続点

- `dot_claude/skills/orchestrate/SKILL.md` の `## Phase 0 -> Triage` に接続し、既存の numbered list の流れを保つ。
- `dot_claude/skills/orchestrate/SKILL.md` の `## 出力` に接続し、既存の handoff 出力項目へ初回表示項目を追加する。
- `dot_codex/skills/orchestrate/SKILL.md` の Tier 表示文言を反映元とする。ただし、Claude 側の `subagent` 表記は既存構造として維持する。
- `dot_claude/skills/orchestrate/references/` は tier 別 flow の正本として維持し、今回の入口表示変更の接続先にしない。

## Security / 権限 / Data / 外部 I/O

- sensitive data 抑止は `SKILL.md` 本体の Phase 0 / Triage 手順に明記する。
- 初回表示の根拠は、具体値ではなく tier 判定条件または停止線カテゴリへ一般化する。
- secret 値、認証情報、private data、具体的な sensitive data を出力しない。
- 新しい dependency、script、hook、runtime config、外部送信、永続化、認証認可の変更は行わない。
- 変更対象は repo 管理下の `dot_claude/skills/orchestrate/SKILL.md` のみとし、workspace 外の書き込みは発生させない。

## 主要判断と理由

- `SKILL.md` 本体に追加する: tier 初回表示は orchestrate skill が起動した全 tier に共通する入口挙動であり、reference 読み込み前に実行されるため、本体の Phase 0 / Triage に置く必要がある。
- `references/` を変更しない: 今回の挙動は reference を読む前の初回表示で完結し、tier 別 flow の変更を必要としないため。
- Claude 固有 `subagent` 表記を維持する: `REQ-006` の通り、Codex / Claude 固有表記差の統一は non-scope であり、変更すると意図しない runtime 文脈の混同につながるため。
- 差分確認結果は `test.md` に記録する: `AC-005` は確認結果の記録を求めており、実装記録ではなく検証 artifact が最も責務に合うため。

## 未確認事項

- なし。
