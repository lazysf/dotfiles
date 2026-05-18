# 0009: context-aware upstream planning を採用する

- Status: Superseded
- Superseded-By: 0011

上流系 skill は、要件と実装計画を問いで鍛え、既存 context / docs / code / ADR と照合してから次へ進む形に寄せる。この repo は `dot_codex/` と `docs/` の責務が分かれているため、single root `CONTEXT.md` ではなく root `CONTEXT-MAP.md` と context 近傍の `CONTEXT.md` を採用する。

## Consequences

- `product-planning` と `implementation-planning` は上流の中核 skill として再設計する。
- `task-intake`、`research`、analysis 系 skill は v1 では削除せず、段階統合に留める。
- ADR は `Status` を維持しつつ、本文は軽量に書ける。
