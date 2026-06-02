# implementation: orchestrate-auto-gate-approval

## 対応タスク / 対応範囲

- `AC-001`: Gate pass 後の自動継続方針を Codex / Claude の skill と reference に反映。
- `AC-002`: 確認必須事項と commit / push の自走対象外を維持。
- `AC-003`: Codex / Claude 両 surface を同じ方針へ更新。
- `AC-004`: ADR 0031 / 0032 と docs index を追従。

## 変更内容

- Codex / Claude の `orchestrate/SKILL.md` で、Gate pass 後にユーザー確認が必要な事項がなければ承認待ちを挟まず次フェーズまたは完了へ進む、と明記した。
- `references/gate-review.md`、`references/standard.md`、`references/full.md` の Gate pass 後の進め方を同じ方針へ更新した。
- 確認対象は、停止線接触、scope / risk 受容、change request 採否、追加情報なしでは次工程を判断できない事項、ユーザー指示待ちに限定した。
- ADR 0031 を superseded にし、ADR 0032 で今回の判断を記録した。
- `docs/notes/runtime-surface-guidance.md` の関連 ADR に 0031 / 0032 を追加した。

## 変更しなかったこと

- 停止線の条件。
- `autonomous-loop.md` の fail / 差戻し制御。
- commit / push のユーザー指示待ち。
- agent / subagent 定義。

## 実行した確認

- 文言検索と `git diff --check`。最終結果は `test.md` に記録。

## 未確認事項

- none
