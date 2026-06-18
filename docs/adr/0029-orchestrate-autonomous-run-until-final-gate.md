# 0029: orchestrate を最終 Gate pass まで自走させる

- Status: Superseded
- Superseded-By: 0036
- Amends: 0025, 0026
- Amended by: 0032, 0033

ADR 0025 で全依頼を `orchestrate` Phase 0 + Triage 入口に統一し、ADR 0026 で `inquiry` tier を加えて 4 tier 構成を確立した。tier 別フローと停止線は整ったが、実運用では Phase / Gate ごとに lead がユーザーへ完了報告を返すため、ユーザー入力で進行が区切られ、停止線に触れない場面でも逐次介入が要る流れになっていた。停止線・Gate fail の同じ blocking 繰り返し・ユーザー入力必須の決定 以外は自走可能なはずだが、運用契約として明文化されていなかった。

`orchestrate` の挙動仕様として、triage 後から tier に応じた最終 Gate pass まで自走するモードを既定にする。Phase / Gate 進行中の都度報告は最小化し、最終 Gate pass 時に lead がまとめて 1 回ユーザーへ返す。停止線と autonomous-loop の取り扱いは変更しない。commit / push の trigger も従来どおりユーザー指示で実行する。

## Decision

- 停止線接触、Gate fail の同じ blocking 繰り返し、ユーザー入力必須の決定 を除き、`orchestrate` は triage 後から tier に応じた最終 Gate の pass まで自走する。終端は次のとおり。
  - `inquiry`: Phase 0 (lead が直接回答) で完了。
  - `micro`: 実装と lead 自己確認まで。
  - `standard`: 統合 Gate (`quality-reviewer` 必須、security 兆候があれば `security-reviewer` 追加) の pass まで。
  - `full`: Gate 3 の pass まで。
- 自走中の Phase / Gate 進行は進捗ステータス (短い 1 行) で十分とし、Phase / Gate ごとの完了報告は都度ユーザーに送らない。
- 最終 Gate pass 時に、lead が変更内容・検証結果・未確認事項・次アクション (commit / push / 追加依頼) を 1 回でまとめて報告する。
- commit / push は本 ADR の対象外で、引き続きユーザー指示で実行する。`git-commit` / `git-push` skill の trigger は変更しない。
- 停止線リスト (SKILL.md `## 停止線` 節) と `autonomous-loop` references は変更しない。自走モードはこれらの上に成り立つ。
- 「進捗ステータス」と「中途報告」は別概念とする。前者は statusMessage 相当の短い 1 行で許容、後者は最小化する。

## Consequences

- 停止線に触れない案件で Phase / Gate が一気に通り、軽い依頼ほど体感速度が上がる。Gate pass 時の単一の総括報告で全体を把握できる。
- Phase / Gate ごとの handoff schema (`references/handoff.md`) と Gate 判定基準 (`references/gate-review.md`) は無変更。agent 間 handoff の中身は変わらない。
- ユーザーが途中で介入したい場合は、stop / interrupt で割り込み、orchestrate は次の停止線あるいは指示まで自走を続ける。
- ADR 0025 / 0026 本文は「lead がユーザー確認の窓口になる」原則を保持したまま、確認のタイミングを「停止線・最終 Gate 後」に集約した形になる。ADR 履歴は保持する (ADR 0022)。
- `caveman` output-style など応答文体の指針は本 ADR の対象外。中途報告そのものを送らないため、caveman モードでも非該当 (出さないものを短縮するだけ)。
