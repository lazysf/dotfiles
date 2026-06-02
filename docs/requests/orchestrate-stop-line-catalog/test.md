# Test

## Summary

- Result: pass
- Scope: orchestrate 停止線カタログ集約（DRY 化）の AC-001..010 検証。新規 `stop-lines.md`（両 surface）、改修 SKILL.md / full / standard / micro / inquiry（両 surface）、不変であるべき autonomous-loop / gate-review / handoff。自動テストなし、`rg` / `diff` / `chezmoi` で確認。

## Test Cases

### TC-001: ブロックA/B の語列挙重複ブロックが stop-lines.md 以外に残っていない

#### 対応

- `AC-001`
- `TASK-001` / `TASK-003`..`TASK-009` / `TASK-012`

#### 種別

- manual

#### 手順

1. `rg -l "新依存 / 破壊的操作 / 本番設定"`（ブロックA 連続列挙）を両 surface の orchestrate 配下で実行。
2. `rg -l "security boundary / validation 境界"`（ブロックB 連続列挙）を同範囲で実行。

#### 結果

- pass
- ブロックA 連続列挙は `dot_claude` / `dot_codex` の `references/stop-lines.md` のみにヒット。ブロックB 連続列挙も同 2 ファイルのみ。SKILL.md / full / standard / micro / inquiry に重複列挙ブロックは残存しない。

### TC-002: 各停止線セクションがサマリ + カタログ参照行 + 文脈遷移句 + tier 固有差分のみで構成

#### 対応

- `AC-002`
- `TASK-003` / `TASK-005`..`TASK-008`

#### 種別

- manual

#### 手順

1. SKILL.md「Triage 停止線」、full.md / standard.md / micro.md / inquiry.md「停止線」セクションを目視。

#### 結果

- pass
- 各セクションは「公開挙動系（ブロックA）/ command 系（ブロックB）の停止線は [stop-lines.md] のカタログに従い、<文脈遷移句>」のサマリ + 参照行と、tier 固有差分の箇条書きのみで構成。語列挙ブロックはなし（SKILL.md Triage 固有項目、standard 自律差戻し禁止リスト、micro/inquiry トリガー文は語列挙でなく判断文として保全されており Edge Case どおり）。

### TC-003: stop-lines.md のブロックA = 15 語 / ブロックB = 12 語が AC-003 列挙と語単位一致

#### 対応

- `AC-003`
- `TASK-001` / `TASK-010`

#### 種別

- manual

#### 手順

1. `stop-lines.md` の 7 行目（ブロックA）/ 11 行目（ブロックB）を目視で AC-003 列挙と照合。
2. ブロックA 15 語・ブロックB 12 語を個別 `rg -F -c` で存在確認。
3. `権限` が両ブロックに存在することを `rg -n "権限"` で確認。
4. 語数を区切りカウント（ブロックB は "外部 I/O" を保護）。

#### 結果

- pass
- ブロックA = 15 語（`公開挙動` / `公開 API` / `data format` / `永続化` / `auth` / `権限` / `secret` / `新依存` / `破壊的操作` / `本番設定` / `runtime guardrail` / `CI permission` / `外部送信` / `deploy` / `publish`）が AC-003 / DD-002 の順序どおり一致。
- ブロックB = 12 語（`command` / `script` / `hook` / `workflow の実行入口` / `権限` / `失敗条件` / `外部 I/O` / `security boundary` / `validation 境界` / `injection` / `path traversal` / `security-sensitive data flow`）が AC-003 / DD-003 と一致。
- `権限` は 7 行目（ブロックA）と 11 行目（ブロックB）の両方に保持（DD-009 Edge Case）。過不足・新規混入ゼロ。
- autonomous-loop.md L33 は照合範囲外（DD-009）。L33 は `auth / 権限 / secret / 外部送信 / CI / runtime guardrail / deploy / publish / command / script / hook / workflow / validation 境界 / injection / path traversal` を持つが今回不変であることを git status で確認（TC-009 参照）。

### TC-004: secret が存在し secret handling が全 surface・全ファイルで残存ゼロ

#### 対応

- `AC-004`
- `TASK-001` / `TASK-005` / `TASK-010`

#### 種別

- manual

#### 手順

1. `rg -c "secret handling" dot_claude dot_codex` で残存件数を確認。
2. ブロックA に `secret` が存在することを TC-003 で確認済み。

#### 結果

- pass
- `secret handling` の残存は両 surface 全体で 0 件（rg exit=1 = no match）。カタログのブロックA に `secret` が存在。`secret handling` -> `secret` 統一（DD-004）が反映済み。

### TC-005: Triage / 各 tier / full の遷移句が各文脈の正しいテンプレで再掲

#### 対応

- `AC-005`
- `TASK-003` / `TASK-005`..`TASK-008`

#### 種別

- manual

#### 手順

1. SKILL.md Triage 停止線、full / standard / micro / inquiry の停止線セクションの遷移句を DD-005 の 3 テンプレと照合。

#### 結果

- pass
- Triage（SKILL.md L45）: 「`full` に倒す。read-only 調査と artifact 作成は進めてよいが、実行、受容、Phase 3 着手の前にユーザー確認する。」
- 各 tier（standard L117 / micro L41 / inquiry L31）: 「`full` に移し、実行、受容、Phase 3 着手前にユーザー確認する。」
- full（full.md L161）: 「実行、受容、Phase 3 着手判断はユーザー確認する。」
- 3 テンプレが各文脈で正しく再掲され、stop-lines.md の「## 遷移句テンプレ」と一致。

### TC-006: tier 固有差分が DD-008 どおり各 tier に保全

#### 対応

- `AC-006`
- `TASK-005`..`TASK-008`

#### 種別

- manual

#### 手順

1. full / standard / micro / inquiry の停止線セクションを DD-008 各行と照合。

#### 結果

- pass
- full（L162-165）: 要求再定義等 / secret 操作 / `repository-maintainer` blocked / Gate blocking 繰り返し の 4 行保全。
- standard（L118-121）: scope 変更等 / blocked / 自律差戻し禁止リスト（runtime guardrail..path traversal）/ Gate blocking 繰り返し の 4 行保全。自律差戻し禁止リストはカタログへ集約せず standard 固有として残存（DD-008 Edge Case）。
- micro（L42-43）: 「複数 file / 設計判断 / 影響調査が必要なら `standard` 以上へ移す」「自己確認で意図外差分 / 未確認リスク / scope ずれなら完了扱いにしない」保全。
- inquiry（L32-33）: 「コード変更 / 差分作成 / 既存機能変更が必要になったら tier 再判定」「根拠が取れない場合は不明点として返す」保全。tier 移行トリガー文は条件文として残存（DD-008 Edge Case）。

### TC-007: SKILL.md 境界手掛かり + stop-lines.md 境界判定（基準 a/b/c + 判定例 4 件）が存在

#### 対応

- `AC-007`
- `TASK-002` / `TASK-004`

#### 種別

- manual

#### 手順

1. SKILL.md「分岐」表直後（L58）の境界入口手掛かりを確認。
2. stop-lines.md「## standard / full 境界判定」の基準 (a)(b)(c) と判定例 4 件を確認。

#### 結果

- pass
- SKILL.md L58: 「ブロックA/B 接触または公開挙動・interface・data flow の設計判断なら `full`、それ以外の複数 file / 既存パターン内変更は `standard`。詳細は [stop-lines.md](references/stop-lines.md) の境界判定。」が分岐表直後に存在。
- stop-lines.md L21-29: 明示基準 (a)(b)(c) と判定例 4 件（「複数 file 一括置換で挙動不変」=standard / 「複数 file だが公開 interface/data format 変更」=full / 「軽い設計判断（既存パターン内）」=standard / 「軽い設計判断に見えても新 interface/新依存/互換性影響」=full）が DD-007 どおり存在。曖昧語「軽い設計判断」「複数 file」に判定例が対応。

### TC-008: dot_claude と dot_codex の対応ファイル diff が surface 固有語のみ。stop-lines.md は完全一致

#### 対応

- `AC-008`
- `TASK-009` / `TASK-011`

#### 種別

- manual

#### 手順

1. 対応 6 ファイル（stop-lines / SKILL / full / standard / micro / inquiry）を `diff` 比較。

#### 結果

- pass
- stop-lines.md / standard.md / micro.md / inquiry.md: 完全一致（差分ゼロ）。
- SKILL.md: 差分 2 行（L8 / L31）が `subagent`（Claude）/ `agent`（Codex）の surface 固有語のみ。
- full.md: 差分 1 行（L169「調査の扱い」）が `subagent` / `agent` のみ。
- 停止線の構造・列挙語・境界判定・遷移句・tier 固有差分に surface 間差分なし（implementation.md 記載と一致）。

### TC-009: stop-lines.md 相対リンクが全箇所で解決。旧参照・残骸が無い。不変ファイル不変

#### 対応

- `AC-009`
- `TASK-012`

#### 種別

- manual

#### 手順

1. `rg -n "stop-lines.md"` で全参照表記を確認。
2. SKILL.md は `references/stop-lines.md`、reference 間は `stop-lines.md` であることを確認。参照先ファイルの実在を確認。
3. 旧参照・表記ゆれ（`stop_line` / `stoplines` 等）を `rg` で確認。
4. 外部 doc（dot_claude/CLAUDE.md 等）から orchestrate references への参照 drift を `rg` で確認。
5. autonomous-loop / gate-review / handoff が git status で不変であることを確認。

#### 結果

- pass
- SKILL.md（両 surface L45 / L58）は `references/stop-lines.md`、full / standard / micro / inquiry（両 surface）は `stop-lines.md`。path 深さが正しく、参照先は両 surface に実在。
- 表記ゆれ（`stop_line` / `stoplines` / 単独 `stop-line`）はヒットなし。
- orchestrate references を外部から参照する箇所はなし（参照 drift なし）。
- git status: 変更は新規 2（stop-lines.md ×2）+ 改修 10 のみ。autonomous-loop.md / gate-review.md / handoff.md は両 surface とも不変。autonomous-loop.md L33 も不変。

### TC-010: chezmoi diff / apply --dry-run がエラーなく両 surface に反映

#### 対応

- `AC-010`
- `TASK-012`

#### 種別

- manual

#### 手順

1. `chezmoi diff`（read-only）で反映先を確認。
2. `chezmoi apply --dry-run --verbose` でエラー有無を確認（apply 本体は実行しない）。

#### 結果

- pass
- `chezmoi diff` / `chezmoi apply --dry-run` とも `.claude/skills/orchestrate/*` と `.codex/skills/orchestrate/*` の両 surface に対応反映。stop-lines.md 新設も両 surface に出力。dry-run exit=0、想定外エラーなし。apply 本体は未実行。

### TC-011: NB-1 到達指示が各停止線セクションに一貫して入っている

#### 対応

- `AC-002`（NB-1 反映）
- `implementation.md` 変更内容 NB-1

#### 種別

- manual

#### 手順

1. SKILL.md Triage / full / standard / micro / inquiry の各カタログ参照行末尾と stop-lines.md 冒頭の到達指示を確認。

#### 結果

- pass
- SKILL.md L45 / full L161 / standard L117 / micro L41 / inquiry L31 の各参照行末尾に「該当の可能性があればカタログ（stop-lines.md）を必ず開いて確認する。」が一貫して付与。stop-lines.md L3 冒頭の役割文にも「該当の可能性があればこのカタログを必ず開いて確認する。」を記載。

## Executed Checks

- `diff`（両 surface 6 ファイル対）: stop-lines / standard / micro / inquiry 完全一致、SKILL.md 2 行 / full.md 1 行が surface 固有語（subagent/agent）のみ。
- `rg -l "新依存 / 破壊的操作 / 本番設定"` / `rg -l "security boundary / validation 境界"`: ブロックA/B 連続列挙は両 surface とも stop-lines.md のみ。
- `rg -c "secret handling" dot_claude dot_codex`: no match（exit=1）。
- `rg -F -c <各語>`（ブロックA 15 / ブロックB 12, Claude カタログ）: 全語存在、`権限` は両ブロック。
- 語数カウント（区切り分割, "外部 I/O" 保護）: ブロックA=15 / ブロックB=12。
- `rg -n "stop-lines.md"`: 参照 path 深さ正常（SKILL.md=references/ 前置、reference 間=前置なし）。
- `rg "orchestrate/references|orchestrate/skills"`（外部 doc 範囲）: 外部参照なし。
- `rg "stop_line|stoplines|stop-line\b"`: 残骸なし。
- `git status --short`（orchestrate 配下）: 新規 2 + 改修 10、autonomous-loop / gate-review / handoff 不変。
- `chezmoi diff` / `chezmoi apply --dry-run --verbose`: 両 surface 反映、エラーなし、exit=0（apply 本体未実行）。

## Unverified Items

- `chezmoi apply` 本体（実適用）は scope どおり未実行。dry-run のみで反映先・エラー有無を確認。実適用時の挙動は対象外。

## Remaining Risks

### 受け入れ判断が必要

- none

### 注意

- 語数カウントは区切り（`/`）分割で行ったため、"外部 I/O" のような語内スラッシュは手動で保護した。語単位一致は目視照合（TC-003）と組み合わせて確定しており、機械カウント単独に依存していない。
- 等価維持（網羅範囲不変）は集約前語集合との照合で確認したが、集約前の元ファイル内容は git 履歴ベースであり、本検証は requirements AC-003 / detailed-design DD-002/003 の語集合を正本として照合した。
