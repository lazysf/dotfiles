# Detailed Design

## 対象範囲

- 新規: `dot_claude/skills/orchestrate/references/stop-lines.md`、`dot_codex/skills/orchestrate/references/stop-lines.md`（共通停止線カタログ）。
- 改修（停止線セクションの参照化）: 両 surface の `SKILL.md`、`references/full.md`、`references/standard.md`、`references/micro.md`、`references/inquiry.md`。
- 改修（境界判定の入口）: 両 surface の `SKILL.md`「分岐」表近傍。
- 集約対象外（変更しない）: `references/autonomous-loop.md` L33、`references/gate-review.md`、`references/handoff.md`、`references/gate-review.md`。

## Interface 詳細

- `stop-lines.md` カタログ（参照される module）:
  - 入力: なし（静的 reference）。
  - 出力（参照側が読む内容）: ブロックA 語集合、ブロックB 語集合、遷移句テンプレ 3 種、standard/full 境界判定セクション。
  - 副作用: なし。
  - 責務: 停止線列挙語・遷移句・境界判定の単一正本。tier 固有差分・ループ制御語は持たない。
- 各停止線セクション（参照する側）:
  - 入力: lead が tier 確定後にそのセクションを読む。
  - 出力: カテゴリサマリ + カタログ参照行 + その文脈の遷移句 + tier 固有差分。
  - 責務: 当該文脈の停止条件を、語の重複なくカタログ経由で表現し、tier 固有判断のみ自前で持つ。

## 詳細設計項目

- `DD-001`（BD-001 / AC-001 / AC-003）: `stop-lines.md` の章立てを次に固定する。
  1. 見出しと役割（1 文）: このカタログが orchestrate 停止線の語の正本である旨。
  2. `## ブロックA: 公開挙動系`: 15 語を 1 つの列挙として置く。
  3. `## ブロックB: command 系`: 12 語を 1 つの列挙として置く。
  4. `## 遷移句テンプレ`: Triage 用 / 各 tier 用 / full 用の 3 句。
  5. `## standard / full 境界判定`: 判定基準 + 判定例（DD-007）。
- `DD-002`（BD-004 / AC-003）: ブロックA の 15 語を、AC-003 の語と完全一致で列挙する。順序は SKILL.md「Triage 停止線」の現行 2 行（`公開挙動` / `公開 API` / `data format` / `永続化` / `auth` / `権限` / `secret`、続けて `新依存` / `破壊的操作` / `本番設定` / `runtime guardrail` / `CI permission` / `外部送信` / `deploy` / `publish`）を 1 列挙に連結した順とする。新規語の追加・既存語の削除はしない。
- `DD-003`（BD-004 / AC-003）: ブロックB の 12 語を AC-003 と完全一致で列挙する。順序は現行（`command` / `script` / `hook` / `workflow の実行入口` / `権限` / `失敗条件` / `外部 I/O` / `security boundary` / `validation 境界` / `injection` / `path traversal` / `security-sensitive data flow`）を維持する。
- `DD-004`（BD-004 / AC-004）: `secret handling`（full.md 現行）を `secret` に統一し、カタログのブロックA では `secret` のみを持つ。full.md 停止線セクションは参照化により `secret` に揃う。捕捉対象に `secret` を含む状態は維持する。
- `DD-005`（BD-005 / AC-005）: 遷移句テンプレを次の 3 句で固定する。
  - Triage 用: 「`full` に倒す。read-only 調査と artifact 作成は進めてよいが、実行、受容、Phase 3 着手の前にユーザー確認する。」
  - 各 tier 用（standard / micro / inquiry）: 「`full` に移し、実行、受容、Phase 3 着手前にユーザー確認する。」
  - full 用: 「実行、受容、Phase 3 着手判断はユーザー確認する。」
- `DD-006`（BD-002 / BD-003 / AC-002）: 各停止線セクションのカタログ参照行を定型化し、目視で「参照 + tier 固有差分」と判別できる形にする。定型は次の 2 行構造。
  - サマリ + 参照行: 「公開挙動系（ブロックA）/ command 系（ブロックB）の停止線は [stop-lines.md](stop-lines.md) のカタログに従い、<その文脈の遷移句>」。SKILL.md からは参照を `[stop-lines.md](references/stop-lines.md)` にする。
  - 以降の行: tier 固有差分のみを箇条書きで残す。
- `DD-007`（BD-007 / AC-007）: `standard` / `full` 境界判定を次で定義する。
  - 明示基準: (a) ブロックA / ブロックB の語に触れるなら常に `full`。(b) 触れない前提で、複数 file でも機械的・等価変換的で公開挙動・interface・data flow を変えないなら `standard`。(c) 公開挙動・interface・data flow・永続化・互換性の設計判断を要するなら `full`。
  - 判定例: 「複数 file の文言一括置換で挙動不変」=`standard`、「複数 file だが 1 つでも公開 interface / data format を変える」=`full`、「軽い設計判断＝既存パターン内の小さな選択で公開挙動不変」=`standard`、「軽い設計判断に見えても新 interface / 新依存 / 互換性影響を含む」=`full`。
  - SKILL.md 側: 分岐表直後に 1〜2 行の入口手掛かり（「ブロックA/B 接触または公開挙動・interface・data flow の設計判断なら `full`、それ以外の複数 file / 既存パターン内変更は `standard`。詳細は [stop-lines.md](references/stop-lines.md) の境界判定」）を置く。
- `DD-008`（BD-006 / AC-006）: 各 tier の固有差分を、カタログ参照行とは別の箇条書きで保全する。保全する行は次。
  - micro: 「複数 file / 設計判断 / 影響調査が必要になったら `standard` 以上へ移す」「自己確認で意図外差分、未確認リスク、scope ずれが出たら完了扱いにしない」。
  - inquiry: 「コード変更、差分作成、既存機能変更が必要になった時点で tier を再判定する」「回答に未確認の事実が必要で、調査しても根拠が取れない場合は不明点として返す」。
  - standard: 「scope / non-scope 変更、change request 採否、未解消リスク受容が必要ならユーザー確認する」「`repository-maintainer` が `blocked` を返した場合、Gate 3 へ進めない」「runtime guardrail / CI permission / secret / auth / 権限 / 外部送信 / deploy / publish / command / script / hook / workflow / validation 境界 / injection / path traversal に触れる blocker は自律差戻しせずユーザー確認または change-request 候補にする」「同じ Gate blocking が繰り返し残る場合はユーザー確認する」。
  - full: 「要求・要望の再定義、change request 採否、scope / non-scope 変更、未解消リスク受容が必要ならユーザー確認する」「secret を読んだ、生成した、移動した、削除した場合、値を出さずにユーザー確認する」「`repository-maintainer` が `blocked` を返した場合、Gate 3 へ進めない」「同じ Gate blocking が繰り返し残る場合はユーザー確認する」。
- `DD-009`（BD-008 / AC-001 / AC-003）: `autonomous-loop.md` L33 は変更せず、カタログ参照化もしない。AC-003 の語単位照合は SKILL.md / full.md / standard.md / micro.md / inquiry.md のブロックA / ブロックB のみを対象とし、autonomous-loop.md L33 は照合範囲外と明記する。
- `DD-010`（BD-009 / AC-008 / AC-010）: Codex surface のカタログ・各セクションを Claude と同一構造にし、`subagent`→`agent`、Claude→Codex の surface 固有語のみ差し替える。停止線語・遷移句・境界判定・章立ては両 surface で一致させる。
- `DD-011`（BD-010 / AC-009）: 参照 path は reference 間 `stop-lines.md`、SKILL.md から `references/stop-lines.md`。旧停止線の語列挙ブロック除去後、`rg` でブロックA / ブロックB の語列挙が他ファイルに残らないこと、`stop-lines.md` への参照が解決することを確認できる構造にする。

## 処理フロー

1. 両 surface に `stop-lines.md` を新設し、DD-001〜DD-007 の内容を置く（語・遷移句・境界判定の正本確定）。
2. SKILL.md「Triage 停止線」を、Triage 文脈サマリ + カタログ参照行（Triage 用遷移句）+ Triage 固有項目（tier 判定不能 / 要求再定義等 / secret 操作 / 不確実性が高い）へ書き換える。Triage 固有項目は語列挙ではないため保持する。
3. SKILL.md「分岐」表直後に DD-007 の境界入口手掛かりを差し込む。
4. full.md / standard.md / micro.md / inquiry.md の各「停止線」セクションを DD-006 の定型（サマリ + 参照行 + 文脈遷移句）+ DD-008 の tier 固有差分へ書き換える。語列挙ブロックを除去する。
5. Codex surface へ DD-010 に従い同期反映する。
6. 検証: `rg` で語列挙の重複ブロック残存と旧参照を確認、`chezmoi diff` / `chezmoi apply --dry-run` で両 surface 反映を確認（検証工程の責務）。

## Validation

- ブロックA = 15 語、ブロックB = 12 語であり、AC-003 列挙と語単位で一致する（過不足ゼロ）。
- 各停止線セクションに語の列挙ブロックが残っていない（カテゴリサマリのカテゴリ名のみ許容）。
- 遷移句が文脈ごとに正しいテンプレ（Triage / tier / full）で再掲されている。
- tier 固有差分が DD-008 の各行どおり保全されている。
- 両 surface の差分が surface 固有語のみ。

## Error Handling

- 語の欠落・新規混入を検出したら集約を確定しない（AC-003 違反 = security 後退）。検証工程で語単位照合 fail なら Gate を通さず原因セクションへ戻す。
- 参照行の相対 path 不整合（reference 間で `references/stop-lines.md` を書く等）はリンク解決失敗として修正対象。SKILL.md とその他 reference で path 深さが異なる点に注意（SKILL.md のみ `references/` を前置）。
- `secret` 統一が full.md の文意を壊す兆候があれば停止して確認（lead 確定済みのため通常は発生しない想定）。

## Edge Case

- ブロックA とブロックB に共通して現れる `権限`: ブロックA の `権限` とブロックB の `権限` は別文脈（公開挙動側 / command 側）で重複しているが、カタログでは各ブロックの語集合として両方保持する（AC-003 の語集合に両方含まれる）。集約で片方を削らない。
- SKILL.md「Triage 停止線」の「不確実性が高い、または影響範囲が Phase 0 だけでは絞れない」は語列挙ではなく Triage 固有判断のため、カタログに移さず SKILL.md に残す。
- standard.md の自律差戻し禁止リスト（DD-008 standard 3 行目）は語列挙に見えるが、文脈は「blocker の自律差戻し可否」であり停止線カタログ（触れたら full / ユーザー確認）とは責務が異なるため、カタログへ集約せず standard 固有差分として残す。
- micro / inquiry の「tier 移行トリガー」行はカタログ語と語が重なるが、トリガー条件の文（"…なら standard 以上へ" 等）であり列挙ブロックではないため保全する。

## 状態遷移 / 分岐条件

- 停止線判定の分岐（参照側の判断）: ブロックA / ブロックB の語に触れる -> 文脈別遷移句に従う（Triage は `full` に倒す、tier は `full` に移す、full はユーザー確認）。触れない -> tier 通常フロー継続。
- standard/full 振り分け分岐: DD-007 (a)(b)(c) に従う。

## Test 観点

- `AC-001`: `rg` でブロックA / ブロックB の語列挙の重複ブロックが `stop-lines.md` 以外に無い。
- `AC-002`: 各停止線セクションがサマリ + 参照行 + tier 固有差分のみで構成（目視）。
- `AC-003`: 集約後カタログのブロックA 15 語 / ブロックB 12 語が AC-003 列挙と語単位一致。autonomous-loop.md L33 は照合範囲外。
- `AC-004`: カタログに `secret` が存在し `secret handling` が残っていない。
- `AC-005`: Triage / 各 tier / full の遷移句が各文脈で正しい。
- `AC-006`: DD-008 の tier 固有差分が各 tier に残存。
- `AC-007`: SKILL.md 近傍の境界手掛かり + カタログ境界判定で `standard`/`full` を判断できる（判定例で曖昧語に対応）。
- `AC-008`: 両 surface 比較で差分が surface 固有語のみ。
- `AC-009`: `stop-lines.md` 参照が全箇所で解決、旧参照・残骸が `rg` で無い。
- `AC-010`: `chezmoi diff` / `chezmoi apply --dry-run` がエラーなく両 surface に反映。

## 未確認事項

- なし。実装時の正確な見出し文言・列挙の体裁（中黒区切り / 箇条書き）は実装工程で確定するが、DD-001〜DD-008 の内容・順序・語集合は本設計で確定する。
