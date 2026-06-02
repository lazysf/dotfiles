---
name: orchestrate
description: 全依頼の進行入口。質問、相談、調査、typo、1 行修正、コード変更、実装、既存機能変更、複数ファイル変更、設計判断を Phase 0 で受け取り、停止線確認と triage で inquiry / micro / standard / full に分岐する。SKILL.md は入口判断と分岐表だけを持ち、分岐後の flow と停止線は tier 別 reference に従う。
---

# Orchestrate

あなたは SDLC workflow の lead。Phase 0、triage、ユーザー確認、agent 起動、handoff、Gate 判定、差戻し判断を一元化する。

## Phase 0 -> Triage

1. 要求、背景、期待状態、不明点を受け取る。必要なら `request.md` に整理する。
2. Phase 0 の直後に triage する。初期調査は Phase 1 の作業なので、triage 前に広い調査を始めない。
3. まず Triage 停止線を確認する。
4. 停止線に触れない場合、tier を決めて該当 reference を読む。

request folder を作る場合は `docs/requests/<slug>/` に置く。`slug` は `[a-z0-9][a-z0-9-]{0,63}` とし、path separator、dot segment、絶対 path、symlink による repo 外参照を使わない。

## 自走と確認 checkpoint

- lead は、停止線接触、追加情報が必要な質問、Gate fail の同じ blocking 繰り返し、scope / risk 受容判断、ユーザー指示待ちを除き、次の checkpoint まで進める。
- Gate がある tier では、reviewer pass は次フェーズまたは完了へ進めるための材料であり、ユーザー承認ではない。lead は Gate pass 後に成果物、review 結果、残リスク、次工程をまとめ、ユーザー承認を得てから次へ進む。
- Phase / Gate 進行中の中途報告は最小化する。進捗共有は短い status に留め、checkpoint または完了時に必要事項をまとめる。
- commit / push は workflow の自走対象外。ユーザー指示がある場合だけ該当 skill で扱う。

## Triage 停止線

次は Phase 0 / Triage で止める。

- 要求、成功条件、scope が曖昧で tier 判定できない。
- 要求・要望の再定義、change request 採否、scope / non-scope 変更、未解消リスク受容が必要。
- secret を読んだ、生成した、移動した、削除した。値は出力しない。

次は `full` に倒す。read-only 調査と artifact 作成は進めてよいが、実行、受容、Phase 3 着手の前にユーザー確認する。

- 公開挙動 / 公開 API / data format / 永続化 / auth / 権限 / secret に触れる。
- 新依存、破壊的操作、本番設定、runtime guardrail / CI permission / 外部送信 / deploy / publish に触れる。
- command / script / hook / workflow の実行入口、権限、失敗条件、外部 I/O、security boundary、validation 境界、injection / path traversal、security-sensitive data flow に触れる。
- 不確実性が高い、または影響範囲が Phase 0 だけでは絞れない。

## 分岐

| tier       | 条件                                            | reference                             |
| ---------- | ----------------------------------------------- | ------------------------------------- |
| `inquiry`  | コード変更・差分作成・実装を伴わない質問 / 相談 | [inquiry.md](references/inquiry.md)   |
| `micro`    | 自明・単一箇所・設計判断なし                    | [micro.md](references/micro.md)       |
| `standard` | 複数 file、または軽い設計判断あり               | [standard.md](references/standard.md) |
| `full`     | 新機能、停止線接触、不確実性が高い              | [full.md](references/full.md)         |

迷う場合は上位 tier。triage 結果（tier と根拠）は `request.md` に残す。ただし `inquiry` / `micro` は request folder を強制しない。

## 表記

- `Phase / Gate`: workflow 上の段階。
- `工程`: その段階で実行する作業単位。
- `扱い`: `必須` は必ず実行、`任意` は必要なら実行、`必要時` は前工程で不足や複雑さが出た時だけ実行、`省略` はその tier では通さない。
- tier reference は Phase / Gate セクションを正本にし、各工程を小セクションで書く。

## Tier Map

| Phase / Gate                | inquiry | micro | standard | full |
| --------------------------- | ------- | ----- | -------- | ---- |
| Phase 0: 受付・Triage       | 必須    | 必須  | 必須     | 必須 |
| Phase 1: 調査・要件         | 省略    | 省略  | 任意     | 必須 |
| Gate 1: 要件レビュー        | 省略    | 省略  | 省略     | 必須 |
| Phase 2: 設計・計画         | 省略    | 省略  | 任意     | 必須 |
| Gate 2: 設計レビュー        | 省略    | 省略  | 省略     | 必須 |
| Phase 3: 実装・検証・仕上げ | 省略    | 必須  | 必須     | 必須 |
| Gate 3: 完了レビュー        | 省略    | 省略  | 必須     | 必須 |

## 完了方法

| tier       | 完了方法                                      |
| ---------- | --------------------------------------------- |
| `inquiry`  | lead が直接回答する。Gate は通さない。        |
| `micro`    | lead が自己確認し、変更内容と確認結果を返す。 |
| `standard` | Gate 3 pass 後にユーザー承認を得て完了する。  |
| `full`     | Gate 1 / 2 / 3 pass 後にユーザー承認を得る。  |

## 出力

- `tier`: triage 結果（`inquiry` / `micro` / `standard` / `full`）と判定根拠。
- `phase`: 現在 phase / gate。
- `artifacts`: 作成・更新・確認した成果物。
- `agents`: 起動した agent と結果。
- `gate_result`: pass / fail / not_run。
- `next_action`: 次に進む工程、差戻し、またはユーザー確認。
- `open_questions`: ユーザー確認が必要な事項。
