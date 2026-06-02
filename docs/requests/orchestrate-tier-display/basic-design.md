# Basic Design

## 設計方針

`orchestrate` skill の Phase 0 / Triage に、tier 決定直後の初回ユーザー表示を最小追記する。表示は後続の tier reference を読む前に行い、既存の tier 判定条件、tier reference、Tier Map、完了方法は変更しない。対応: `REQ-001` / `REQ-002` / `REQ-003` / `REQ-004`, `AC-001` / `AC-002` / `AC-003` / `AC-004`。

## 構成と責務

- `dot_codex/skills/orchestrate/SKILL.md`: Phase 0 / Triage の順序、tier 判定、初回表示形式、最終出力項目を定義する。
- `Phase 0 -> Triage`: tier 決定直後、reference 読み込み前に初回表示を行う責務を持つ。
- `Triage 停止線`: 停止線により `full` へ倒す条件を保持し、その場合も初回表示対象にする。
- `分岐` / `Tier Map` / `完了方法`: 既存の tier 判定条件と flow 責務を保持する。
- tier reference files: 各 tier の後続工程を定義する。今回の変更対象外。

## 基本設計項目

- `BD-001`: Phase 0 / Triage の tier 決定直後、該当 reference を読む前に、最初の中途表示を行う設計とする。対応: `REQ-001`, `AC-001`。
- `BD-002`: 初回表示形式は `tier: <tier>。根拠: <短い理由>。` に固定する。対応: `REQ-003`, `AC-003`。
- `BD-003`: 停止線に触れて `full` へ倒す場合も、同じ初回表示形式を適用する。対応: `REQ-002`, `AC-002`。
- `BD-004`: tier 判定表、Tier Map、完了方法、tier reference の工程定義は変更しない。対応: `REQ-004`, `AC-004`。
- `BD-005`: `## 出力` には、最終出力項目とは別に「最初の中途表示」として必須形式を明記する。対応: `REQ-001`, `REQ-003`, `AC-003`。
- `BD-006`: 初回表示の追加により根拠文が user-facing になるため、secret 値、認証情報、private data、具体的な sensitive data は根拠文に含めず、tier 判定条件または停止線カテゴリへ一般化する。対応: `REQ-002`, `REQ-004`。

## 主要 interface / API / data flow

- Interface: lead がユーザーへ出す最初の中途表示。
  - 入力: triage で決定した `tier` と短い判定根拠。
  - 出力: `tier: <tier>。根拠: <短い理由>。`
  - 副作用: ユーザーに進行 flow を早期明示する。
- Data flow:
  - ユーザー要求を受け取る。
  - Phase 0 で停止線を確認する。
  - tier を決定する。停止線により `full` へ倒す場合もここで扱う。
  - 初回表示を行う。
  - 該当 tier reference を読む。
  - 後続 flow に進む。

## 既存構造との接続点

- 既存の `Phase 0 -> Triage` は、tier 決定と reference 読み込みを同じ手順内で扱っているため、その間に初回表示責務を差し込む。
- 既存の `## 出力` は最終出力項目として `tier` を持つため、初回表示の必須形式を追加して役割を分ける。
- `分岐`、`Tier Map`、`完了方法` は既存構造を維持し、判定条件や工程定義の変更点にしない。

## Security / 権限 / Data / 外部 I/O

- Security: 初回表示の根拠文は user-facing output であるため、secret 値、認証情報、private data、具体的な sensitive data を含めない。根拠は tier 判定条件または停止線カテゴリへ一般化する。
- 権限: 影響なし。実行権限、承認条件、sandbox、runtime permission は変更しない。
- Data: 影響なし。永続化、data format、ユーザーデータ処理は変更しない。
- 外部 I/O: N/A。新しい network、file I/O、script、hook、dependency、tooling は追加しない。

## 主要判断と理由

- Phase 0 / Triage に追記する。理由: 要件は triage 直後の初回表示であり、後続 reference の責務ではないため。
- 表示形式を固定する。理由: ユーザーが tier と根拠を一目で確認でき、実行者ごとの表記揺れを避けられるため。
- tier 判定条件は変更しない。理由: 要件は表示タイミングと形式の追加であり、flow 選択ロジックの変更は Non-Scope のため。
- `SKILL.md` への追記は短い手順文に留める。理由: skill は full `SKILL.md` が読み込まれるため、公式方針と制約に沿って context 負荷を増やさないため。

## 未確認事項

- なし。
