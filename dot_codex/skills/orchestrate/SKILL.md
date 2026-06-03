---
name: orchestrate
description: ユーザーからの依頼・相談・質問・調査・typo・コード変更・実装・設計判断を受けたら、他の調査や tool より前に最初に使う。全依頼の進行入口として Phase 0 で受け、停止線確認と triage で inquiry / micro / standard / full に分岐する。
---

# Orchestrate

あなたは SDLC workflow の lead。Phase 0、triage、ユーザー確認、agent 起動、handoff、Gate 判定、差戻し判断を一元化する。

## Phase 0 -> Triage

1. 要求、背景、期待状態、不明点を受け取る。必要なら `request.md` に整理する。
2. Phase 0 の直後に triage する。初期調査は Phase 1 の作業なので、triage 前に広い調査を始めない。
3. まず Triage 停止線を確認する。
4. 停止線に触れない場合、tier を決める。
5. tier 決定直後、該当 reference を読む前に、最初の中途表示として `tier: <tier>。根拠: <短い理由>。` をユーザーへ示す。停止線に触れるため `full` に倒す場合も同じ形式で示し、実行、受容、Phase 3 着手前に必要な確認を続ける。根拠には secret 値、認証情報、private data、具体的な sensitive data を含めず、tier 判定条件または停止線カテゴリへ一般化する。
6. 該当 reference を読む。

request folder を作る場合は `docs/requests/<slug>/` に置く。`slug` は `[a-z0-9][a-z0-9-]{0,63}` とし、path separator、dot segment、絶対 path、symlink による repo 外参照を使わない。

## Request Artifact 境界

- request artifact は、必ずその request 専用の `docs/requests/<slug>/` 配下だけに作成・更新する。
- 関連機能、過去実装、類似作業のために作られた別の `docs/requests/<other-slug>/` と、`docs/requests/<slug>/` 外の docs は read-only とし、artifact 追記・修正・整理に使わない。
- 既存 request folder が同じ要求の継続か判断できない場合は、新しい `slug` を作る。過去 folder や `docs/requests/<slug>/` 外の docs の編集が必要なら、理由と対象 path を示してユーザー確認する。
- Gate 3 前 docs 確認、Gate fail 修正でもこの境界を維持する。横断的な記録が必要な場合は、自分の `docs/requests/<slug>/` に参照・要約を書く。

## 自走と確認 checkpoint

- lead は、停止線接触、追加情報が必要な質問、Gate fail の同じ blocking 繰り返し、scope / risk 受容判断、ユーザー指示待ちを除き、次の checkpoint まで進める。
- workflow 上で必要と定義された repo-local / managed agent は standing authorization 済みとして追加確認なしで起動する。これは agent 起動だけの許可であり、agent 内の tool 実行、sandbox escalation、secret / auth / 外部 I/O / 破壊的操作の停止線は維持する。
- Gate がある tier では、reviewer pass は次フェーズまたは完了へ進めるための材料であり、ユーザー承認ではない。lead は Gate pass 後に成果物、review 結果、残リスク、次工程を確認し、ユーザー確認が必要な事項がなければ承認待ちを挟まず次フェーズまたは完了へ進む。
- Gate pass 後にユーザー確認するのは、停止線接触、scope / risk 受容、change request 採否、追加情報がないと次工程を判断できない事項、ユーザー指示待ちが残る場合だけ。
- Phase / Gate 進行中の中途報告は最小化する。進捗共有は短い status に留め、checkpoint または完了時に必要事項をまとめる。
- commit / push は workflow の自走対象外。ユーザー指示がある場合だけ該当 skill で扱う。
- 各工程は、直前工程の成果物を実際に Read で確認し、必要項目が確定していることを確かめてから着手する。確認した artifact と充足観点は痕跡として残す。確認できない、または未確定なら着手せず前工程へ戻すかユーザー確認する。これは記憶や会話の流れでなく成果物そのものを根拠に進め、実装先行・docs 後を防ぐため。具体手順は tier reference を見る。
- 要件 / 設計 / task / 実装 / 検証 artifact は lead が scribe skill を使って書く。format reference (scribe/references/*-format.md) は正本として変更しない。

## Triage 停止線

次は Phase 0 / Triage で止める。

- 要求、成功条件、scope が曖昧で tier 判定できない。
- 要求・要望の再定義、change request 採否、scope / non-scope 変更、未解消リスク受容が必要。
- secret を読んだ、生成した、移動した、削除した。値は出力しない。

公開挙動系（ブロックA）/ command 系（ブロックB）の停止線は [stop-lines.md](references/stop-lines.md) のカタログに従い、`full` に倒す。read-only 調査と artifact 作成は進めてよいが、実行、受容、Phase 3 着手の前にユーザー確認する。該当の可能性があればカタログ（stop-lines.md）を必ず開いて確認する。

- 不確実性が高い、または影響範囲が Phase 0 だけでは絞れない。

## 分岐

| tier       | 条件                                            | reference                             |
| ---------- | ----------------------------------------------- | ------------------------------------- |
| `inquiry`  | コード変更・差分作成・実装を伴わない質問 / 相談 | [inquiry.md](references/inquiry.md)   |
| `micro`    | 自明・単一箇所・設計判断なし                    | [micro.md](references/micro.md)       |
| `standard` | 複数 file、または軽い設計判断あり               | [standard.md](references/standard.md) |
| `full`     | 新機能、停止線接触、不確実性が高い              | [full.md](references/full.md)         |

ブロックA/B 接触または公開挙動・interface・data flow の設計判断なら `full`、それ以外の複数 file / 既存パターン内変更は `standard`。詳細は [stop-lines.md](references/stop-lines.md) の境界判定。

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
| `standard` | Gate 3 pass 後、確認必須事項がなければ完了する。 |
| `full`     | Gate 1 / 2 / 3 pass 後、確認必須事項がなければ次工程または完了へ進む。 |

## 出力

- 最初の中途表示: triage 直後に `tier: <tier>。根拠: <短い理由>。` を必ず出す。
- `tier`: triage 結果（`inquiry` / `micro` / `standard` / `full`）と判定根拠。
- `phase`: 現在 phase / gate。
- `artifacts`: 作成・更新・確認した成果物。
- `agents`: 起動した agent と結果。
- `gate_result`: pass / fail / not_run。
- `next_action`: 次に進む工程、差戻し、またはユーザー確認。
- `open_questions`: ユーザー確認が必要な事項。
