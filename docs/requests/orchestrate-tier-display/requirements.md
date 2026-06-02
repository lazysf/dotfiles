# Requirements

## 目的

`orchestrate` skill で進める依頼に対し、lead が最初に選択した分岐 flow (`tier`) と判定根拠をユーザーへ明示する。

## 背景 / 課題

現行の `orchestrate` skill は最終出力項目として `tier` を持つが、triage 直後に最初の中途表示として出すことは明示していない。ユーザーは、どの flow で進むかを作業開始時に把握したい。

## Scope

- `dot_codex/skills/orchestrate/SKILL.md` の Phase 0 / Triage 手順に、tier 決定直後の初回表示を明記する。
- `dot_codex/skills/orchestrate/SKILL.md` の出力項目に、初回表示の必須形式を明記する。
- 停止線により `full` へ倒す場合も、tier と根拠の初回表示対象に含める。

## Non-Scope

- tier 判定条件そのものの変更。
- `inquiry` / `micro` / `standard` / `full` 各 reference flow の工程変更。
- `orchestrate` 以外の skill / agent / runtime config の変更。
- 新しい script、dependency、tooling、hook の追加。

## 要求事項

- `REQ-001`: `orchestrate` は triage 直後、後続 reference を読む前に、選択した tier と短い根拠をユーザーへ示す。
- `REQ-002`: 停止線に触れて `full` に倒す場合も、`REQ-001` と同じ初回表示を行う。
- `REQ-003`: 初回表示の形式は、ユーザーが tier と根拠を一目で確認できる短い形式にする。
- `REQ-004`: 既存の tier 判定条件と tier reference の責務は変更しない。

## 受入条件

- `AC-001`: `REQ-001` に対し、`dot_codex/skills/orchestrate/SKILL.md` の Phase 0 / Triage 手順で、tier 決定直後かつ reference 読み込み前のユーザー表示が明記されている。
- `AC-002`: `REQ-002` に対し、停止線により `full` へ倒す場合も同じ形式で表示することが明記されている。
- `AC-003`: `REQ-003` に対し、初回表示形式として `tier: <tier>。根拠: <短い理由>。` が明記されている。
- `AC-004`: `REQ-004` に対し、tier 判定表、Tier Map、完了方法の条件が変更されていない。

## 制約

- Agent Skills 公式仕様と Codex Agent Skills 公式 docs に反しない。
- `SKILL.md` へ長い説明を追加せず、必要最小の手順文に留める。
- Phase 3 着手前に full flow の checkpoint を守る。

## 前提

- `dot_codex/skills/orchestrate/SKILL.md` は repo 管理対象の Codex skill source である。
- 現在の未コミット差分は、直前作業で作成された候補差分であり、今回の full flow の上流 artifact 完了を根拠に作られたものではない。
- 公式情報では、skill は `SKILL.md` を中心に instructions を持ち、Codex は skill の full `SKILL.md` instructions を読み込んで workflow に使う。

## 未確認事項

- Gate 1 reviewer agent を起動できるか。
