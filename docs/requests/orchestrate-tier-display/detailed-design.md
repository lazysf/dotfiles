# Detailed Design

## 対象範囲

- `dot_codex/skills/orchestrate/SKILL.md`
  - `## Phase 0 -> Triage`
  - `## 出力`
- 対象外:
  - tier 判定表
  - Tier Map
  - 完了方法
  - `references/inquiry.md`
  - `references/micro.md`
  - `references/standard.md`
  - `references/full.md`
  - code、config、tests、script、hook、dependency

## Interface 詳細

- `Phase 0 -> Triage`: ユーザー要求、停止線確認結果、tier 判定結果を入力し、後続 reference 読み込み前に初回表示を行う。
- `初回表示`: `tier` と短い根拠を入力し、`tier: <tier>。根拠: <短い理由>。` をユーザーへ出力する。
- `## 出力`: 最終出力項目とは別に、最初の中途表示として必須形式を定義する。

## 詳細設計項目

- `DD-001`: `Phase 0 -> Triage` では、停止線確認後に tier を決定し、reference を読む前に初回表示を行う。対応: `BD-001`, `AC-001`。
- `DD-002`: 初回表示の文字列は `tier: <tier>。根拠: <短い理由>。` とする。対応: `BD-002`, `AC-003`。
- `DD-003`: 停止線に触れて `full` へ倒す場合も、`tier: full。根拠: <短い理由>。` を表示する。対応: `BD-003`, `AC-002`。
- `DD-004`: tier 判定表、Tier Map、完了方法、tier reference file の内容は変更しない。対応: `BD-004`, `AC-004`。
- `DD-005`: `## 出力` には `最初の中途表示` として初回表示を明記し、既存の `tier` 最終出力項目は維持する。対応: `BD-005`, `AC-003`。
- `DD-006`: security / 権限 / data / 外部 I/O は変更なしとして扱う。対応: `BD-006`。

## 処理フロー

1. lead が要求、背景、期待状態、不明点を受け取る。
2. Phase 0 の直後に triage する。
3. Triage 停止線を確認する。
4. 要求、成功条件、scope が曖昧で tier 判定できない場合は、tier を作らず停止して確認する。
5. secret を読んだ、生成した、移動した、削除した場合は、値を出力せず停止する。
6. 停止線により `full` へ倒す条件に触れる場合は、tier を `full` として決定する。
7. 停止線に触れない場合は、既存の分岐表に従って `inquiry` / `micro` / `standard` / `full` を決定する。
8. tier 決定直後、該当 reference を読む前に `tier: <tier>。根拠: <短い理由>。` を表示する。
9. 該当 tier reference を読む。
10. 既存 flow に従って後続 phase / gate へ進む。

## Validation

- `tier` は `inquiry` / `micro` / `standard` / `full` のいずれかに限る。
- `<短い理由>` は非空の短い日本語理由とし、tier 判定条件または停止線に基づく。
- 初回表示は tier 決定後、reference 読み込み前に行う。
- 停止線により `full` へ倒す場合も初回表示対象にする。
- tier 判定表、Tier Map、完了方法の条件文は変更しない。
- secret 値、認証情報、private data を根拠文に含めない。

## Error Handling

- tier 判定に必要な要求、成功条件、scope が不足する場合は、tier を推測せず確認する。
- secret を扱った場合は、値を出力せず停止線に従う。
- 根拠に sensitive data が入り得る場合は、値ではなく一般化した理由にする。
- 初回表示前に reference を読みそうになった場合は、先に初回表示を行ってから続行する。
- 既存 tier 条件の変更が必要になった場合は、今回 scope 外として停止し、上流 artifact の変更確認に戻す。

## Edge Case

- `inquiry` / `micro` で request folder を強制しない場合でも、triage 直後の初回表示は行う。
- 停止線により `full` へ倒す場合、初回表示後も、実行、受容、Phase 3 着手前の確認 checkpoint は維持する。
- 複数の停止線に触れる場合、tier は `full` とし、根拠は最も説明力のある短い理由にまとめる。
- ユーザー要求の変更で再 triage が必要になった場合は、新しい triage 結果に対して初回表示を再度行う。
- hard stop に該当して tier 判定できない場合は、`tier: <tier>` 形式を無理に出さない。

## 状態遷移 / 分岐条件

- `受付済み` -> `triage中`: 要求を受け取った直後。
- `triage中` -> `hard stop`: tier 判定不能、scope 不明、secret 取り扱いなどで停止線に該当する場合。
- `triage中` -> `tier決定済み`: `inquiry` / `micro` / `standard` / `full` のいずれかを決定した場合。
- `tier決定済み` -> `初回表示済み`: `tier: <tier>。根拠: <短い理由>。` を表示した場合。
- `初回表示済み` -> `reference読込済み`: 該当 tier reference を読んだ場合。
- `reference読込済み` -> `後続flow進行中`: 既存の phase / gate に従って進行する場合。

## Test 観点

- `Phase 0 -> Triage` に、tier 決定直後かつ reference 読み込み前の初回表示が明記されていること。
- `## 出力` に、`tier: <tier>。根拠: <短い理由>。` が最初の中途表示として明記されていること。
- 停止線により `full` へ倒す場合も同じ形式で表示する記述があること。
- tier 判定表、Tier Map、完了方法、tier reference file が変更対象になっていないこと。
- `inquiry` / `micro` / `standard` / `full` の各 tier で表示形式が成立すること。
- secret 値や private data が根拠文に出ない設計になっていること。
- 新しい script、dependency、hook、外部 I/O、runtime permission の追加がないこと。

## 未確認事項

- なし。
