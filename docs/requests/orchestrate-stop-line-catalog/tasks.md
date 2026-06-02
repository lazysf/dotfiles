# Tasks

## 実装方針

- detailed-design.md の処理フロー（1. カタログ新設 -> 2. SKILL.md Triage 停止線書き換え -> 3. SKILL.md 分岐表近傍に境界手掛かり -> 4. 各 tier reference 停止線書き換え -> 5. Codex 同期 -> 6. 検証）に沿って task を並べる（`DD-001`..`DD-011`）。
- 停止線語集合は security boundary であり、集約で 1 語でも欠落・新規混入させない。実装は語列挙の正本を `stop-lines.md` に閉じ、参照側は「カテゴリサマリ + カタログ参照行 + 文脈遷移句 + tier 固有差分」のみを持つ（`DD-001`/`DD-006`/`DD-008`）。
- Claude（`dot_claude`）surface を先に確定し、Codex（`dot_codex`）surface へ surface 固有語（`subagent`->`agent`、Claude->Codex）のみ差し替えて同期する（`DD-010`）。
- 検証は自動テストなし。`rg`（語列挙重複・旧参照の非残存）、両 surface diff 比較、`chezmoi diff` / `chezmoi apply --dry-run`、リンク解決目視で確認する。
- `autonomous-loop.md` L33 / `gate-review.md` / `handoff.md` は変更しない。`autonomous-loop.md` L33 は AC-003 の語単位照合の照合範囲外（`DD-009`）。

## 実装タスク

- `TASK-001`: Claude surface に停止線カタログ `dot_claude/skills/orchestrate/references/stop-lines.md` を新設する（`DD-001`/`DD-002`/`DD-003`/`DD-004`/`DD-005`）。
  - 内容: (1) 見出しと役割 1 文、(2) `## ブロックA: 公開挙動系`（15 語を 1 列挙）、(3) `## ブロックB: command 系`（12 語を 1 列挙）、(4) `## 遷移句テンプレ`（Triage 用 / 各 tier 用 / full 用の 3 句）、(5) `## standard / full 境界判定`（DD-007 の基準 + 判定例）。
  - ブロックA 順序: `公開挙動` / `公開 API` / `data format` / `永続化` / `auth` / `権限` / `secret` / `新依存` / `破壊的操作` / `本番設定` / `runtime guardrail` / `CI permission` / `外部送信` / `deploy` / `publish`。
  - ブロックB 順序: `command` / `script` / `hook` / `workflow の実行入口` / `権限` / `失敗条件` / `外部 I/O` / `security boundary` / `validation 境界` / `injection` / `path traversal` / `security-sensitive data flow`。
  - `secret` のみを持ち `secret handling` は置かない（`DD-004`）。
  - 完了条件: ブロックA = 15 語 / ブロックB = 12 語が AC-003 列挙と語単位一致。遷移句 3 種と境界判定セクションが存在。tier 固有差分・ループ制御語を含まない。
  - 確認方法: 目視で章立て確認。`rg` でブロックA/B 各語が当ファイルに存在。
  - 対応: `DD-001`/`DD-002`/`DD-003`/`DD-004`/`DD-005`、`AC-001`/`AC-003`/`AC-004`/`AC-005`/`AC-007`。

- `TASK-002`: Claude surface に `standard` / `full` 境界判定を `stop-lines.md` の `## standard / full 境界判定` セクションへ記述する（`DD-007`）。
  - 明示基準: (a) ブロックA/B の語に触れるなら常に `full`、(b) 触れない前提で複数 file でも機械的・等価変換的で公開挙動・interface・data flow を変えないなら `standard`、(c) 公開挙動・interface・data flow・永続化・互換性の設計判断を要するなら `full`。
  - 判定例 4 件: 「複数 file の文言一括置換で挙動不変」=`standard`、「複数 file だが 1 つでも公開 interface / data format を変える」=`full`、「軽い設計判断（既存パターン内の小さな選択で公開挙動不変）」=`standard`、「軽い設計判断に見えても新 interface / 新依存 / 互換性影響を含む」=`full`。
  - 完了条件: 基準 (a)(b)(c) と判定例 4 件がカタログ内に存在し、曖昧語「軽い設計判断」「複数 file」に判定例が対応している。
  - 確認方法: 目視で基準・判定例を確認。
  - 対応: `DD-007`、`AC-007`。
  - 依存: `TASK-001`（同一ファイル。`TASK-001` 内で同時記述可。分離する場合は `TASK-001` の後）。

- `TASK-003`: Claude surface の `SKILL.md`「Triage 停止線」セクションを参照化する（`DD-002`/`DD-006`）。
  - 構成: Triage 文脈サマリ + カタログ参照行（参照は `[stop-lines.md](references/stop-lines.md)`、Triage 用遷移句）+ Triage 固有項目（tier 判定不能 / 要求再定義等 / secret 操作 / 不確実性が高い・影響範囲が Phase 0 だけでは絞れない）。
  - Triage 用遷移句: 「`full` に倒す。read-only 調査と artifact 作成は進めてよいが、実行、受容、Phase 3 着手の前にユーザー確認する。」
  - 語列挙ブロックを除去する。Triage 固有項目（語列挙でない判断文）は保持する（`DD-006` Edge Case）。
  - 完了条件: 停止線語の列挙ブロックが当セクションに残らない。カタログ参照行・Triage 遷移句・Triage 固有項目が揃う。
  - 確認方法: 目視。`rg` でブロックA/B 語列挙が SKILL.md に残らないこと。リンク `references/stop-lines.md` 解決を目視。
  - 対応: `DD-002`/`DD-006`、`AC-001`/`AC-002`/`AC-005`。
  - 依存: `TASK-001`。

- `TASK-004`: Claude surface の `SKILL.md`「分岐」表直後に境界判定の入口手掛かりを差し込む（`DD-007`）。
  - 内容: 1〜2 行で「ブロックA/B 接触または公開挙動・interface・data flow の設計判断なら `full`、それ以外の複数 file / 既存パターン内変更は `standard`。詳細は [stop-lines.md](references/stop-lines.md) の境界判定」。
  - 「分岐」表自体は変えず、直後に挿入する（`BD-007` 接続点）。
  - 完了条件: 分岐表直後に入口手掛かりがあり、カタログ境界判定への参照リンクが解決する。
  - 確認方法: 目視。リンク解決を目視。
  - 対応: `DD-007`、`AC-007`。
  - 依存: `TASK-002`（参照先カタログ境界判定が存在していること）。

- `TASK-005`: Claude surface の `references/full.md`「停止線」セクションを参照化する（`DD-006`/`DD-008`）。
  - 構成: カテゴリサマリ + カタログ参照行（参照は `[stop-lines.md](stop-lines.md)`、full 用遷移句「実行、受容、Phase 3 着手判断はユーザー確認する。」）+ full 固有差分。
  - full 固有差分（保全）: 「要求・要望の再定義、change request 採否、scope / non-scope 変更、未解消リスク受容が必要ならユーザー確認する」「secret を読んだ、生成した、移動した、削除した場合、値を出さずにユーザー確認する」「`repository-maintainer` が `blocked` を返した場合、Gate 3 へ進めない」「同じ Gate blocking が繰り返し残る場合はユーザー確認する」。
  - 語列挙ブロックを除去し `secret handling` を残さない（`DD-004`）。
  - 完了条件: 語列挙ブロックが残らない。full 遷移句と full 固有差分 4 行が揃う。`secret handling` が当ファイルに残らない。
  - 確認方法: 目視。`rg` でブロックA/B 語列挙 / `secret handling` が full.md に残らないこと。リンク `stop-lines.md` 解決を目視。
  - 対応: `DD-004`/`DD-006`/`DD-008`、`AC-001`/`AC-002`/`AC-004`/`AC-005`/`AC-006`。
  - 依存: `TASK-001`。

- `TASK-006`: Claude surface の `references/standard.md`「停止線」セクションを参照化する（`DD-006`/`DD-008`）。
  - 構成: カテゴリサマリ + カタログ参照行（参照は `[stop-lines.md](stop-lines.md)`、各 tier 用遷移句「`full` に移し、実行、受容、Phase 3 着手前にユーザー確認する。」）+ standard 固有差分。
  - standard 固有差分（保全）: 「scope / non-scope 変更、change request 採否、未解消リスク受容が必要ならユーザー確認する」「`repository-maintainer` が `blocked` を返した場合、Gate 3 へ進めない」「runtime guardrail / CI permission / secret / auth / 権限 / 外部送信 / deploy / publish / command / script / hook / workflow / validation 境界 / injection / path traversal に触れる blocker は自律差戻しせずユーザー確認または change-request 候補にする」「同じ Gate blocking が繰り返し残る場合はユーザー確認する」。
  - 自律差戻し禁止リスト（3 行目）は語が重なるがカタログへ集約せず standard 固有差分として残す（`DD-008` Edge Case）。
  - 完了条件: カタログ参照行・各 tier 遷移句・standard 固有差分 4 行が揃う。停止線カタログ語の重複列挙ブロックが残らない。
  - 確認方法: 目視。`rg` でブロックA/B 語列挙の重複ブロックが standard.md に残らないこと（自律差戻し禁止リストの文は除く）。リンク解決を目視。
  - 対応: `DD-006`/`DD-008`、`AC-001`/`AC-002`/`AC-005`/`AC-006`。
  - 依存: `TASK-001`。

- `TASK-007`: Claude surface の `references/micro.md`「停止線」セクションを参照化する（`DD-006`/`DD-008`）。
  - 構成: カテゴリサマリ + カタログ参照行（参照は `[stop-lines.md](stop-lines.md)`、各 tier 用遷移句）+ micro 固有差分。
  - micro 固有差分（保全）: 「複数 file / 設計判断 / 影響調査が必要になったら `standard` 以上へ移す」「自己確認で意図外差分、未確認リスク、scope ずれが出たら完了扱いにしない」。
  - tier 移行トリガー行は語が重なるが列挙ブロックでなく条件文のため保全する（`DD-008` Edge Case）。
  - 完了条件: カタログ参照行・各 tier 遷移句・micro 固有差分 2 行が揃う。語列挙ブロックが残らない。
  - 確認方法: 目視。`rg` でブロックA/B 語列挙ブロックが micro.md に残らないこと。リンク解決を目視。
  - 対応: `DD-006`/`DD-008`、`AC-001`/`AC-002`/`AC-005`/`AC-006`。
  - 依存: `TASK-001`。

- `TASK-008`: Claude surface の `references/inquiry.md`「停止線」セクションを参照化する（`DD-006`/`DD-008`）。
  - 構成: カテゴリサマリ + カタログ参照行（参照は `[stop-lines.md](stop-lines.md)`、各 tier 用遷移句）+ inquiry 固有差分。
  - inquiry 固有差分（保全）: 「コード変更、差分作成、既存機能変更が必要になった時点で tier を再判定する」「回答に未確認の事実が必要で、調査しても根拠が取れない場合は不明点として返す」。
  - 完了条件: カタログ参照行・各 tier 遷移句・inquiry 固有差分 2 行が揃う。語列挙ブロックが残らない。
  - 確認方法: 目視。`rg` でブロックA/B 語列挙ブロックが inquiry.md に残らないこと。リンク解決を目視。
  - 対応: `DD-006`/`DD-008`、`AC-001`/`AC-002`/`AC-005`/`AC-006`。
  - 依存: `TASK-001`。

- `TASK-009`: Codex surface へ同一構造で同期反映する（`DD-010`）。
  - 対象: `dot_codex/skills/orchestrate/references/stop-lines.md`（新設）、同 surface の `SKILL.md` / `references/{full,standard,micro,inquiry}.md`。
  - `TASK-001`..`TASK-008` の確定内容を Codex surface に複製し、surface 固有語のみ差し替える（`subagent`->`agent`、Claude->Codex）。停止線語・遷移句・境界判定・章立て・tier 固有差分は両 surface で一致させる。
  - `autonomous-loop.md` / `gate-review.md` / `handoff.md` は両 surface とも変更しない。
  - 完了条件: Codex surface の 6 ファイルが Claude surface と同一構造で、差分が surface 固有語のみ。
  - 確認方法: 目視。`rg` で Codex surface のブロックA/B 語列挙ブロックが `stop-lines.md` 以外に残らないこと。詳細比較は `TASK-011`。
  - 対応: `DD-010`、`AC-008`/`AC-010`。
  - 依存: `TASK-001`..`TASK-008`（Claude surface 確定後）。

- `TASK-010`: AC-003 語単位一致の検証（独立検証タスク・security boundary 中核）（`DD-002`/`DD-003`/`DD-009`）。
  - 検証: 両 surface の `stop-lines.md` のブロックA 15 語 / ブロックB 12 語が AC-003 列挙と語単位で完全一致（過不足ゼロ、新規混入ゼロ、`secret handling` 不在 / `secret` 存在）。
  - 照合範囲: SKILL.md / full.md / standard.md / micro.md / inquiry.md / stop-lines.md のブロックA/B のみ。`autonomous-loop.md` L33 は照合範囲外（`DD-009`）。
  - 完了条件: 両 surface のカタログで 15 語 / 12 語が AC-003 と一致。語欠落・新規混入が無い。共通語 `権限`（ブロックA/B 双方）が両方保持されている（`DD-009` Edge Case）。
  - 確認方法: `rg` で各語の存在確認、目視で過不足ゼロ照合。欠落・混入を検出した場合は集約を確定せず原因セクションへ戻す（Error Handling）。
  - 対応: `DD-002`/`DD-003`/`DD-004`/`DD-009`、`AC-003`/`AC-004`。
  - 依存: `TASK-001`/`TASK-009`。

- `TASK-011`: 両 surface 差分が surface 固有語のみであることの検証（独立検証タスク）（`DD-010`）。
  - 検証: `dot_claude` / `dot_codex` の対応 6 ファイル（stop-lines.md / SKILL.md / full.md / standard.md / micro.md / inquiry.md）を比較し、差分が surface 固有語（`subagent` / `agent`・Claude / Codex 語）のみであること。停止線の構造・列挙語・境界判定・遷移句・tier 固有差分が一致すること。
  - 完了条件: 両 surface 比較で差分が surface 固有語のみ。
  - 確認方法: 両 surface diff 比較（surface 固有語以外の差分が無いこと）。
  - 対応: `DD-010`、`AC-008`。
  - 依存: `TASK-009`。

- `TASK-012`: 参照解決・残骸非残存・chezmoi 反映の検証（`DD-011`）。
  - 検証: (1) `rg` でブロックA/B の語列挙重複ブロックが両 surface とも `stop-lines.md` 以外に残らない、(2) `stop-lines.md` への参照が全箇所で解決（SKILL.md は `references/stop-lines.md`、reference 間は `stop-lines.md`）、旧参照・残骸が `rg` で無い、(3) `chezmoi diff` / `chezmoi apply --dry-run` が想定外エラーなく完了し両 surface に対応して反映。
  - 完了条件: 語列挙重複なし、リンク全解決、旧参照残骸なし、chezmoi 検証がエラーなし。
  - 確認方法: `rg`（語列挙重複・旧参照）、リンク解決目視、`chezmoi diff` / `chezmoi apply --dry-run`。
  - 対応: `DD-011`、`AC-001`/`AC-009`/`AC-010`。
  - 依存: `TASK-001`..`TASK-011`。

## 実装順序

1. `TASK-001`: Claude surface に `stop-lines.md` 新設（ブロックA/B 語集合・遷移句テンプレ）。
2. `TASK-002`: 同カタログに standard/full 境界判定を記述（`TASK-001` と同一ファイル。同時または直後）。
3. `TASK-003`: SKILL.md「Triage 停止線」参照化（`TASK-001` 依存）。
4. `TASK-004`: SKILL.md「分岐」表直後に境界入口手掛かり挿入（`TASK-002` 依存。`TASK-003` と同一 file のため `TASK-003` の後に直列）。
5. `TASK-005`..`TASK-008`: full / standard / micro / inquiry の各「停止線」参照化（`TASK-001` 依存。互いに別 file のため並列可）。
6. `TASK-009`: Codex surface へ同期（`TASK-001`..`TASK-008` 確定後）。
7. `TASK-010`/`TASK-011`/`TASK-012`: 検証（実装完了後。`TASK-010`/`TASK-011` は `TASK-012` の前に実施）。

- 同一 file 競合回避: `TASK-003` と `TASK-004` は同じ SKILL.md を編集するため直列にする。`TASK-001` と `TASK-002` は同じ stop-lines.md のため直列または 1 task として実施。`TASK-005`..`TASK-008` は各々独立 file で並列可。

## 変更境界

- 新規 2: `dot_claude/skills/orchestrate/references/stop-lines.md`、`dot_codex/skills/orchestrate/references/stop-lines.md`。
- 改修 10: 両 surface の `SKILL.md`、`references/full.md`、`references/standard.md`、`references/micro.md`、`references/inquiry.md`。
- 参照 path: reference 間は `stop-lines.md`、SKILL.md からは `references/stop-lines.md`。

## Scope 外にしたこと

- `references/autonomous-loop.md`（L33 含む）、`references/gate-review.md`、`references/handoff.md` の編集（変更しない）。
- 停止線の意味的な網羅範囲の拡張・縮小（等価維持が前提）。
- 検証自動化の追加（自動テストなし）。
- AC-003 語単位照合範囲への `autonomous-loop.md` L33 の追加（照合範囲外）。
- agent の model / effort 配分、並列化制約、inquiry triage overhead の見直し。

## リスク

- 語の欠落・新規混入は AC-003 違反 = security 後退。`TASK-010` を独立検証として必ず実施し、fail なら Gate を通さず原因セクションへ戻す。
- 参照行の相対 path 不整合（SKILL.md のみ `references/` 前置、reference 間は前置なし）はリンク解決失敗になる。`TASK-012` で全箇所のリンク解決を確認する。
- 両 surface 同期漏れ（surface 固有語以外の差分混入）。`TASK-011` で diff 比較する。
- `secret` 統一が full.md の文意を壊す兆候があれば停止して確認（lead 確定済みのため通常は発生しない想定）。
- 自律差戻し禁止リスト（standard）/ tier 移行トリガー（micro・inquiry）は語が重なるが責務が異なるためカタログへ誤集約しない（`DD-008` Edge Case）。

## 未確認事項

- なし。実装時の正確な見出し文言・列挙の体裁（中黒区切り / 箇条書き）は実装工程で確定するが、語集合・順序・遷移句・境界判定の内容は detailed-design.md で確定済み。
