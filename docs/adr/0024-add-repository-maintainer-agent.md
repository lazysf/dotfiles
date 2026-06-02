# 0024: repository maintenance agent を Gate 3 前に追加する

- Status: Superseded
- Superseded-By: 0034
- Amends: 0006, 0011, 0020, 0023

実装・検証後の docs 追従、repo hygiene、tooling 設定の仕上げを、完了前に同じ差分文脈で行いたい。これを lead が直接抱えると自己点検に寄り、developer / verifier に持たせると実装や検証の責務と混ざる。

Codex / Claude Code の両 surface に `repository-maintainer` agent を追加し、Phase 3 の `developer` / `verifier` 後、Gate 3 前に起動する。`repository-maintainer` は `doc-followup`、`scribe`、`verification` / `inspect` の手順を使い、変更内容、tooling の挙動差分、再検証要否、残リスクを handoff に残す。Gate 3 reviewer は repository maintenance 後の全変更セットと handoff を確認する。tooling の挙動差分がある場合、lead は Gate 3 前に `verifier` へ戻して影響する確認と `test.md` を更新させる。

`repository-maintainer` は、docs / references / prose の追従更新まで自走してよい。repo hygiene、lint / format / test / build まわりの設定、runtime guardrail、secret、deploy / publish、install、新依存、破壊的操作、stage / commit / push、scope 矛盾、品質ゲート弱体化には踏み込まず、必要なら `Blockers` と `review_focus` に返す。

この判断により、ADR 0023 の `doc-followup` は workflow 上の単独完了前チェックではなく、`repository-maintainer` が docs 追従更新に使う手順として残す。lead は agent 起動、handoff 統合、ユーザー確認、最終判断を担い、repository maintenance の実務は専門 agent へ分ける。
