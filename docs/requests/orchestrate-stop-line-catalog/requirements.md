# Requirements

## 目的

- `orchestrate` skill の停止線定義を「カタログ集約」方式で DRY 化し、停止線が捕捉する網羅範囲を変更前と等価に保つ。
- `standard` / `full` の tier 境界判定の曖昧さを減らす。
- 上記を Claude（`dot_claude`）/ Codex（`dot_codex`）両 surface に同期して反映し、実差分を surface 固有語のみに保つ。

## 背景 / 課題

- 停止線リストが SKILL.md / full.md / standard.md / micro.md / inquiry.md に分散コピーされており、語の追加・修正時に複数箇所の手修正が必要で drift 源になっている。
- 「2 大ブロック」（ブロックA: 公開挙動系、ブロックB: command 系）が語彙ほぼ完全一致で各所にコピーされている。唯一の語彙ゆれは full.md の `secret handling`（他は `secret`）。
- `standard`↔`full` の振り分け条件（「軽い設計判断」「複数 file」など）が主観的で、判定例が無い。
- Claude / Codex 両 surface が同一構造で存在し、実差分は `subagent` / `agent`・Claude / Codex 語のみ。両 surface を同期して変更する必要がある。
- 本 repo は chezmoi 管理で、`dot_claude` / `dot_codex` 配下が配布対象。停止線・skill 定義・承認ルールに触れるため docs-only として扱わない。

## Scope

- 停止線の共通部分（ブロックA・ブロックB相当の列挙語集合）を 1 つの共通カタログに集約する。
- SKILL.md および各 tier reference（full / standard / micro / inquiry）が、共通カタログを参照しつつ tier 固有差分のみを保持する構造にする。
- 末尾遷移句（Triage / 各 tier / full の文脈依存表現）の文脈差を維持する。
- `standard` / `full` の境界判定基準を、判定例または明示基準として曖昧さが減る形で示す。
- Claude / Codex 両 surface へ同期反映する。
- 既存の参照 path / 相対リンクの drift を防ぐ。

## Non-Scope

- 停止線の網羅範囲（捕捉対象語集合）の意味的な拡張・縮小。等価維持が前提。
- lead 集約による並列化制約、inquiry tier の triage overhead の見直し（意図的トレードオフとして現状維持）。
- agent の model / effort 配分の見直し。
- 検証自動化の追加。
- 共通カタログ reference の具体的なファイル名・章立て・配置 path・相対リンク方式の決定（設計の責務）。
- 境界明確化を SKILL 分岐表近傍に置くか別 reference に置くかの最終決定（設計の責務）。
- `autonomous-loop.md` L33 のブロックB相当文言を集約対象に含めるかの決定（設計判断に委ねる。本要件は等価維持の制約のみ課す）。

## 要求事項

- `REQ-001`: 停止線の共通列挙語集合（ブロックA・ブロックB相当）を、複数箇所への重複コピーなく単一の共通カタログとして保持する。
- `REQ-002`: SKILL.md / full.md / standard.md / micro.md / inquiry.md が、共通カタログを参照する形で停止線を表現し、tier 固有差分のみを各自に残す。
- `REQ-003`: 集約後の停止線網羅範囲（捕捉対象語の集合）が、集約前と等価である。
- `REQ-004`: 末尾遷移句の文脈差（Triage は「full に倒す」、各 tier は「`full` に移し実行/受容/Phase 3 着手前にユーザー確認」、full は「実行/受容/Phase 3 着手判断はユーザー確認」）を維持する。
- `REQ-005`: tier 固有の停止線差分が集約で失われず、各 tier に保全される。
- `REQ-006`: `standard` / `full` 境界の判定が、判定例または明示基準により曖昧さが減る。
- `REQ-007`: Claude（`dot_claude`）/ Codex（`dot_codex`）両 surface が同期し、両 surface 間の実差分が surface 固有語（`subagent` / `agent`・Claude / Codex 語など）のみに保たれる。
- `REQ-008`: 集約に伴う参照 path / 相対リンクの drift が無い。

## 受入条件

- `AC-001`（REQ-001）: 共通列挙語集合が単一箇所で定義され、grep / 目視で同一語列挙の重複ブロックが他ファイルに残っていないことを確認できる。
- `AC-002`（REQ-002）: SKILL.md / full.md / standard.md / micro.md / inquiry.md の停止線記述が、共通カタログへの参照と tier 固有差分のみで構成されていることを目視で確認できる。
- `AC-003`（REQ-003）: 集約前後で停止線の捕捉対象語の集合が一致する。具体的には、集約前の全列挙語（ブロックA: `公開挙動` / `公開 API` / `data format` / `永続化` / `auth` / `権限` / `secret` / `新依存` / `破壊的操作` / `本番設定` / `runtime guardrail` / `CI permission` / `外部送信` / `deploy` / `publish`、ブロックB: `command` / `script` / `hook` / `workflow の実行入口` / `権限` / `失敗条件` / `外部 I/O` / `security boundary` / `validation 境界` / `injection` / `path traversal` / `security-sensitive data flow`）が、集約後の共通カタログにすべて存在し、欠落・新規追加が無いことを語単位で照合できる。
- `AC-004`（REQ-003）: `secret` / `secret handling` の語彙ゆれが、等価維持を損なわない形で扱われている（統一する場合はカタログ側で 1 語に集約し、捕捉対象に `secret` を含む状態を保つ。統一可否の判断は未確認事項に従う）。
- `AC-005`（REQ-004）: Triage / 各 tier / full の末尾遷移句が、集約後も各文脈に対応した表現で残っていることを目視で確認できる。
- `AC-006`（REQ-005）: 次の tier 固有差分が集約後も各 tier に残っていることを確認できる。
  - micro: 「複数 file / 設計判断 / 影響調査が必要なら standard 以上へ」「自己確認で意図外差分 / 未確認リスク / scope ずれなら完了扱いにしない」
  - inquiry: 「コード変更 / 差分作成 / 既存機能変更が必要になったら tier 再判定」「根拠が取れない場合は不明点として返す」
  - standard: 「scope/non-scope 変更 / change request 採否 / 未解消リスク受容ならユーザー確認」「repository-maintainer が blocked なら Gate 3 へ進めない」「自律差戻し禁止リスト」「同じ Gate blocking 繰り返しならユーザー確認」
  - full: Triage 相当（要求再定義 / secret 読取等）、blocked、Gate blocking 繰り返し
- `AC-007`（REQ-006）: `standard` と `full` のどちらに振り分けるかを、判定例または明示基準を参照して判断できる（少なくとも、現状曖昧な「軽い設計判断」「複数 file」に対応する境界の手掛かりが、判定例または基準の形で示されている）。
- `AC-008`（REQ-007）: `dot_claude` 配下と `dot_codex` 配下の対応ファイルを比較したとき、差分が surface 固有語（`subagent` / `agent`・Claude / Codex 語など）のみで、停止線の構造・列挙語・境界判定の内容は一致していることを確認できる。
- `AC-009`（REQ-008）: 集約で追加・rename・移動した reference があれば、それを参照する全箇所（SKILL.md / 各 tier reference / 関連 doc）の相対リンクが解決し、`rg` で旧参照が残っていないことを確認できる。
- `AC-010`（REQ-001..008）: `chezmoi diff` および `chezmoi apply --dry-run` が想定外のエラーなく完了し、変更が `dot_claude` / `dot_codex` 両 surface に対応して現れることを確認できる。

## 制約

- `requirements.md` のみ本工程で編集する。SKILL.md / reference / agent / config / tests は本工程では編集しない。
- 編集対象は `dot_claude` / `dot_codex` 配下の chezmoi 管理ファイル。両 surface を同期する。
- skill の設計変更に該当するため、設計・実装工程では skill-creator 使用 + Agent Skills 公式情報確認が前提（AGENTS.md）。停止線 / skill 定義 / 承認ルールに触れるため docs-only 扱いにしない。
- 停止線・承認ルール・runtime guardrail に触れる変更であり、本 repo CLAUDE.md / AGENTS.md の停止線対象。意味的な網羅範囲を変える判断は本要件の Non-Scope。
- 検証は自動テスト無し。`chezmoi diff` / `chezmoi apply --dry-run`、`rg` での参照追従、リンク目視で確認する。
- MD013（line length）は off、markdownlint / chezmoi ignore に該当しないため、新 reference 追加自体への機械的制約は無い。

## 前提

- 停止線リストは SKILL.md / full.md / standard.md / micro.md / inquiry.md に分散している（researcher 確認済み）。
- ブロックA / ブロックB は語彙ほぼ完全一致でコピーされ、唯一の語彙ゆれは full.md の `secret handling`（researcher 確認済み）。
- 末尾遷移句は文脈で変わる（Triage / 各 tier / full）（researcher 確認済み）。
- tier 固有差分（AC-006 に列挙）はカタログに溶かせず保全必須（researcher 確認済み）。
- 外部からの reference path 参照は無く、新 reference を `orchestrate/references/` に追加する機械的制約も無い（researcher 確認済み）。
- 両 surface の実差分は `subagent` / `agent`・Claude / Codex 語のみ（request / researcher 確認済み）。

## 未確認事項

- `secret` / `secret handling` を 1 語に統一してよいか（捕捉対象としては等価だが、表記統一が full.md の文意に影響しないか）。設計でカタログ語彙を確定する前に統一可否を判断する必要がある。設計をブロックし得る。
- `autonomous-loop.md` L33 のブロックB相当文言を共通カタログに集約対象として含めるか。語集合は近いが順序 / 粒度が別系統のため、等価維持の観点で集約するか現状維持するかは設計判断。設計判断であり本要件はブロックしないが、AC-003 の等価照合範囲に含めるかは設計時に確定が要る。
- 共通カタログ reference の置き場・ファイル名・相対リンク方式、および境界明確化の置き場（SKILL 分岐表近傍 / 別 reference）。設計の責務であり本要件では決めない。
