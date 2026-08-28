# 0032: ユーザー判断が不要な Gate pass 後承認を自動 skip する

- Status: Superseded
- Superseded-By: 0036
- Supersedes: 0031
- Amended-By: 0033
- Amends: 0029

## Context

ADR 0029 は `orchestrate` を最終 Gate pass まで自走させる方針を採用した。ADR 0031 は Gate reviewer pass とユーザー承認を分け、各 Gate pass 後に承認 checkpoint を置いた。

しかし、Gate reviewer が pass し、停止線、scope / risk 受容、change request 採否、追加情報なしでは判断できない事項が残っていない場合まで承認待ちにすると、ADR 0029 の自走性が弱くなる。ユーザーの意図は、判断が本当に必要な場面だけ止まり、それ以外は lead が次工程または完了まで進めることにある。

## Decision

- Gate reviewer の pass はユーザー承認ではない、という責務分離は維持する。
- Gate pass 後、lead は成果物、review 結果、残リスク、次工程または完了判断を確認する。
- ユーザー確認が必要な事項がなければ、承認待ちを挟まず次フェーズまたは完了へ進む。
- ユーザー確認するのは、停止線接触、scope / risk 受容、change request 採否、追加情報がないと次工程を判断できない事項、ユーザー指示待ちが残る場合だけ。
- 停止線由来で `full` に倒した場合の Phase 3 着手可否確認、commit / push のユーザー指示待ちは維持する。

## Consequences

- ADR 0031 の「Gate pass 後は必ずユーザー承認」は superseded とする。
- `standard` は Gate 3 pass 後、確認必須事項がなければ完了できる。
- `full` は Gate 1 / Gate 2 / Gate 3 pass 後、確認必須事項がなければ次工程または完了へ進める。
- Gate reviewer pass、lead 判断、ユーザー確認の責務は分かれたまま、確認必須事項の有無で承認待ちを省ける。
- 停止線、autonomous-loop、commit / push trigger は変更しない。
