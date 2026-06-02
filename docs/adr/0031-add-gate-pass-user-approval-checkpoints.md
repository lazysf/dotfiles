# ADR 0031: Gate pass 後のユーザー承認 checkpoint を明示する

- Status: Superseded
- Superseded-By: 0032

## Context

ADR 0029 は、停止線接触、Gate fail の同じ blocking 繰り返し、ユーザー入力必須の決定を除き、`orchestrate` が tier に応じた最終 Gate pass まで自走する方針を採用した。

一方で、ここでの「自走」は無人完走ではない。各 Phase 内の調査、artifact 作成、agent 起動、handoff 統合、差戻し準備は lead が進めるが、Gate reviewer の pass はユーザー承認を代替しない。要所では、ユーザーが次フェーズへ進むか、リスクを受け入れるか、完了扱いにするかを判断する必要がある。

## Decision

- `orchestrate` の自走は「次の checkpoint まで進む」ことを意味する。
- 追加情報が必要な質問、停止線接触、scope / risk 受容判断、Gate fail の同じ blocking 繰り返し、ユーザー指示待ちは checkpoint として扱う。
- Gate がある tier では、Gate pass 後に lead が成果物、review 結果、残リスク、次工程または完了判断をまとめ、ユーザー承認を得てから進む。
  - `standard`: Gate 3 pass 後にユーザー承認を得て完了する。
  - `full`: Gate 1 / Gate 2 / Gate 3 pass 後にユーザー承認を得てから次フェーズまたは完了へ進む。
- 停止線由来で `full` に倒した場合、read-only 調査と artifact 作成は進めてよいが、Phase 3 着手前に設計、task、Security-Relevant Actions、残リスクを提示してユーザー承認を得る。
- Phase / Gate 進行中の中途報告は引き続き最小化する。承認 checkpoint と完了報告は中途報告とは別に扱う。
- commit / push は ADR 0029 と同じく自走対象外で、ユーザー指示がある場合だけ該当 skill で扱う。

## Consequences

- ADR 0029 の「最終 Gate pass まで自走」は、「ユーザー確認不要な範囲では次 checkpoint まで自走する」と解釈する。
- Gate reviewer pass、lead 判断、ユーザー承認の責務が分かれる。
- full flow では Gate 1 / Gate 2 / Gate 3 のたびに承認 checkpoint が発生するため、無人の連続実行ではなく、判断材料を lead が揃える運用になる。
