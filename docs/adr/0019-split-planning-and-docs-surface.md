# 0019: planning と docs surface を grill / scribe に分割する

- Status: Superseded
- Superseded-By: 0042
- Supersedes: 0017
- Amended by: 0020, 0023

`planning` に問い詰め、durable knowledge 反映、成果物 format、既存 docs 更新を統合した結果、共有理解を詰める責務と文書を整える責務が再び重なった。共有理解へ到達するまで一問ずつ問い詰める入口を `grill`、README、既存 docs、PRD、要件定義、設計、実装計画、CONTEXT、ADR などの doc / artifact 作成・更新・整形を `scribe` として分ける。

## Consequences

- `planning` と `docs-update` は廃止する。
- `grill` は実装前の問い詰め、確定事項の最小反映、scope、成功条件、制約、検証入口、実装 readiness を扱う。
- `scribe` は既存 docs 更新、成果物 format、ID / section / traceability 整理、CONTEXT、ADR の作成・更新・整形を扱う。
- ADR 作成や状態更新は、`grill` で根拠や採用判断を確認し、`scribe` で明示根拠に沿って反映する。
