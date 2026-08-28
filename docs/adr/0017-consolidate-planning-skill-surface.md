# 0017: planning skill surface を統合する

- Status: Superseded
- Superseded-By: 0019
- Supersedes: 0010
- Amends: 0011, 0012, 0013

実装前の要件確認、計画作成、設計、docs-aware grilling、成果物 draft は、別々の user-facing skill に分けると発火条件と責務境界が重なりやすい。計画や設計を共有理解に到達するまで一問ずつ問い詰め、既存 docs、ADR、code、domain language と照合する入口を `planning` に統合する。

## Consequences

- 上流系の正式入口は `planning` とし、PRD、要件定義、基本設計、詳細設計、実装計画、テストケース、traceability matrix、CONTEXT、ADR の format は `references/` に置く。
- `grill-with-docs` の docs-aware grilling と durable knowledge 反映は `planning` に吸収する。
- 事実調査、バグ原因、再現条件、外部変化の切り分けは `research` に寄せる。
- 差分作成と確認方法先行の実装ループは `implementation` に寄せる。
- 変更後の受け入れ確認、修正効果確認、rename / 削除後の整合確認は `verification` に寄せる。
- 構造改善候補の探索は `architecture` に残し、実装前計画や durable knowledge 更新は `planning` に渡す。
