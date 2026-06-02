# Basic Design

## 設計方針

- `orchestrate` skill の停止線を、共通列挙語集合を 1 つの「停止線カタログ」reference に集約し、SKILL.md / 各 tier reference は「カタログ参照 + tier 固有差分」だけを持つ構造へ移す（REQ-001 / REQ-002 / AC-001 / AC-002）。
- 集約しても停止線が捕捉する語集合を変更前と等価に保ち、語の追加・修正を単一箇所に閉じる（REQ-003 / AC-003 / AC-004）。
- 末尾遷移句の文脈差（Triage / 各 tier / full）と tier 固有差分（micro / inquiry / standard / full）は集約せず各箇所に保全する（REQ-004 / REQ-005 / AC-005 / AC-006）。
- `standard` / `full` 境界の判定を、判定例と明示基準により曖昧さが減る形で提示する（REQ-006 / AC-007）。
- Claude（`dot_claude`）/ Codex（`dot_codex`）両 surface を同期し、実差分を surface 固有語（`subagent` / `agent`・Claude / Codex 語）のみに保つ（REQ-007 / AC-008 / AC-010）。
- 追加・rename する reference の相対リンクを drift させない（REQ-008 / AC-009）。
- skill best practice（progressive disclosure / gotchas を別 reference へ切り出すと読むトリガーを失うリスク）を踏まえ、停止線という security boundary を「必ずカタログへ到達する導線」付きで切り出す（AC-002 / AC-003）。

## 構成と責務

- `references/stop-lines.md`（新規、共通停止線カタログ module）: ブロックA（公開挙動系）/ ブロックB（command 系）の停止線列挙語集合を単一定義し、語ごとの捕捉対象を保持する正本。末尾遷移句のテンプレ（文脈差の形）も定義側に置き、参照側が文脈名で選べるようにする。tier 固有差分は持たない。
- `SKILL.md`「Triage 停止線」: Triage 文脈（Phase 0 で止める / `full` に倒す）の停止線。カタログを参照し、Triage 固有の遷移句と Triage 専用項目（tier 判定不能 / 不確実性が高い）を保持する。
- `references/full.md`「停止線」: full 文脈（実行・受容・Phase 3 着手判断はユーザー確認）の停止線。カタログ参照 + full 固有差分（要求再定義 / change request / scope 変更 / 未解消リスク受容、secret 操作、repository-maintainer blocked、Gate blocking 繰り返し）を保持。
- `references/standard.md`「停止線」: standard 文脈（`full` に移し、実行・受容・Phase 3 着手前にユーザー確認）の停止線。カタログ参照 + standard 固有差分（scope 変更・change request・未解消リスク受容、repository-maintainer blocked、自律差戻し禁止リスト、Gate blocking 繰り返し）を保持。
- `references/micro.md`「停止線」: micro 文脈（`full` に移し…）の停止線。カタログ参照 + micro 固有差分（複数 file / 設計判断 / 影響調査で standard 以上、自己確認の未確認リスクで完了扱いにしない）を保持。
- `references/inquiry.md`「停止線」: inquiry 文脈（`full` に移し…）の停止線。カタログ参照 + inquiry 固有差分（コード変更等で tier 再判定、根拠が取れない場合は不明点として返す）を保持。
- `references/autonomous-loop.md` L33: ループ制御文脈の sensitive 語列挙。本集約の対象外（別系統）。
- `dot_codex/skills/orchestrate/**`: 上記と同一構造の Codex surface。surface 固有語のみ差し替える。

## 基本設計項目

- `BD-001`（REQ-001 / AC-001 / AC-003）: 共通停止線カタログを `dot_claude/skills/orchestrate/references/stop-lines.md` と `dot_codex/skills/orchestrate/references/stop-lines.md` に新設し、ブロックA / ブロックB の列挙語集合をここだけで定義する。他ファイルから同一語列挙ブロックを除去する。
- `BD-002`（REQ-002 / AC-001 / AC-002）: SKILL.md / full.md / standard.md / micro.md / inquiry.md の停止線セクションを「定型のカタログ参照行 + tier 固有差分行」へ書き換える。列挙語そのものは各箇所に再掲しない。
- `BD-003`（REQ-002 / AC-002 / progressive disclosure リスク対応）: progressive disclosure で停止線を切り出すと「読むトリガー喪失」が起きる risk に対し、各停止線セクションへ「カテゴリ名の 1 行サマリ（公開挙動系 / command 系）」を残し、詳細語はカタログへ展開する折衷を採用する。サマリは語の正本ではなく到達導線であり、AC-003 の照合対象は常にカタログとする。
- `BD-004`（REQ-003 / AC-003 / AC-004）: カタログのブロックA に AC-003 列挙の 15 語、ブロックB に 12 語を過不足なく置く。`secret` / `secret handling` の語彙ゆれは `secret` に統一し、`secret` が handling を包含するため捕捉範囲は不変とする（lead 確定）。
- `BD-005`（REQ-004 / AC-005）: 末尾遷移句の文脈差は、カタログ側に「遷移句テンプレ（Triage 用 / 各 tier 用 / full 用）」を定義し、参照側が文脈名で選んで再掲する。文脈差そのものは各セクションに残し、集約で平坦化しない。
- `BD-006`（REQ-005 / AC-006）: tier 固有差分（AC-006 の micro / inquiry / standard / full の各項目）はカタログに溶かさず、各 tier 停止線セクションに保全する。
- `BD-007`（REQ-006 / AC-007）: `standard` / `full` 境界の判定例 + 明示基準を SKILL.md の分岐表近傍に置き、詳細な判定例はカタログ内の専用セクションへ展開する。「軽い設計判断」「複数 file」の曖昧語に対応する手掛かりを与える。
- `BD-008`（REQ-001 / AC-001 / AC-009）: `autonomous-loop.md` L33 は集約対象外とし、AC-003 の等価照合範囲からも除外する。理由は語順 / 粒度が別系統（ループ中の自律実施可否の判定基準）で、カタログの triage / tier 停止線とは責務が異なるため。
- `BD-009`（REQ-007 / AC-008 / AC-010）: 両 surface のカタログ・各停止線セクションを同一構造で同期し、差分を surface 固有語のみに保つ。Codex 側は `agent` / Codex 語、Claude 側は `subagent` / Claude 語。
- `BD-010`（REQ-008 / AC-009）: カタログ reference への参照行は、reference 間は `stop-lines.md`、SKILL.md からは `references/stop-lines.md` の相対 path を使う。新規追加であり rename / 移動は発生しないが、参照を追加した全箇所と旧記述除去後の残骸を `rg` で確認できる形にする。

## 主要 interface / API / data flow

- カタログの公開 interface（参照側が知るべきこと）:
  - ブロックA 語集合（公開挙動系 15 語）。
  - ブロックB 語集合（command 系 12 語）。
  - 遷移句テンプレ 3 種（Triage 用「`full` に倒す。read-only 調査と artifact 作成は進めてよいが、実行・受容・Phase 3 着手の前にユーザー確認」/ 各 tier 用「`full` に移し、実行・受容・Phase 3 着手前にユーザー確認」/ full 用「実行・受容・Phase 3 着手判断はユーザー確認」）。
  - standard/full 境界の判定例・基準（BD-007）。
- data flow（lead が停止線を確認する読み順）:
  1. lead が SKILL.md「Triage 停止線」を読む -> カテゴリサマリ + カタログ参照行に到達。
  2. lead がカタログ参照行から `references/stop-lines.md` を開き、ブロックA / ブロックB の語と該当遷移句テンプレを確認する。
  3. tier 確定後、該当 tier reference の「停止線」セクションを読む -> 同じカテゴリサマリ + カタログ参照行 + tier 固有差分に到達。
  4. `standard`/`full` の振り分けに迷う場合、SKILL.md 分岐表近傍の境界手掛かり -> カタログの境界判定セクションに到達。
- 参照は単方向（参照側 -> カタログ）。カタログは他 reference を参照しない（循環なし）。

## 既存構造との接続点

- 既存 reference 群（`handoff.md` / `gate-review.md` / `autonomous-loop.md`）と同階層に `stop-lines.md` を追加するため、既存 reference の相対リンク記法（`[name](name.md)` / `[name](references/name.md)`）に揃える。
- SKILL.md「分岐」表と「Triage 停止線」セクションが境界判定・停止線の既存入口。ここを変えずに参照行とサマリを差し込む。
- full.md / standard.md の「追加 reference」「停止線」セクションが既存の停止線記述位置。記述位置は維持し中身を参照化する。
- gate-review.md L53 / L76 が停止線語と意味的に連動する（`security-reviewer` 起動条件）。本変更は語集合を不変に保つため gate-review.md の編集は不要だが、語の正本がカタログへ移る点を考慮し、AC-003 等価維持で連動を保つ。

## Security / 権限 / Data / 外部 I/O

- 停止線文言そのものが security boundary（公開挙動 / auth / 権限 / secret / 外部送信 / injection / path traversal などの停止条件を定義する）。集約で 1 語でも欠落すると停止線網羅が縮小し security 後退になるため、AC-003 の語単位照合を設計上の必須ゲートとする（BD-004）。
- `secret` 統一（BD-004）は捕捉対象に `secret` を残すため security 範囲を縮小しない。`secret handling` -> `secret` は表記統一であり、handling を含む包含関係で網羅範囲は維持される（lead 確定）。
- progressive disclosure による「読むトリガー喪失」は、停止線という security boundary を見落とす経路になり得るため、BD-003 のカテゴリサマリ + 定型参照行で各セクションから必ずカタログへ到達させる（security 観点の設計上の担保）。
- 永続化 / 外部 I/O への新規影響なし。編集対象は chezmoi 配布対象の docs 構造（skill reference）で、runtime 実行経路の変更はない。ただし停止線・skill 定義・承認ルールに該当するため docs-only 扱いにしない（requirements 制約）。
- カタログは secret 値・認証情報・private data を含まない（停止線カテゴリ語のみ）。durable artifact への secret 残置なし。

## 主要判断と理由

- カタログを `references/stop-lines.md` に新設（既存 reference を間借りしない）理由: 停止線は独立した security boundary 正本であり、handoff / gate-review とは責務が異なる。単一 module に閉じることで locality（語の追加・修正が 1 箇所）と leverage（全 tier が 1 interface を参照）を得る。
- カテゴリサマリ 1 行を各セクションに残す折衷（BD-003）理由: best-practices が警告する「gotchas を別 reference へ切り出すと読むトリガーを失う」risk を、語の重複コピー（DRY 違反）を避けつつ緩和する。サマリは到達導線であり正本ではないため AC-001 の「同一語列挙の重複ブロック」には該当しない（語の列挙ではなくカテゴリ名のみ）。
- 遷移句テンプレをカタログ側に定義（BD-005）理由: 文脈差は 3 パターンに収束しており、テンプレ化で表現の drift を防ぎつつ、参照側は文脈名の選択だけで済む。文脈差自体は各セクションに残すため AC-005 を満たす。
- autonomous-loop.md L33 を集約対象外（BD-008）理由: 語順・粒度が triage/tier 停止線と別系統で、ループ中の自律実施可否という別責務。無理に集約すると意味が混線し等価性照合がかえって不安定になる。
- 境界判定をカタログへ展開しつつ入口を SKILL 分岐表近傍に置く（BD-007）理由: 振り分け判断は SKILL.md で行うため入口手掛かりは近傍が自然。詳細判定例は分量があるためカタログ（既に参照する reference）へ展開し SKILL.md の <500 行・入口判断中心を維持する。

## 未確認事項

- なし（`secret` 統一 / tier=full / 両 surface 同期 / autonomous-loop L33 除外は lead 確定または本設計で確定）。実装時の正確な語順・サマリ文言・境界判定例の本文は detailed-design.md に展開する。
