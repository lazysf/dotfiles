# Context Map

## Contexts

- [Codex ハーネス](./dot_codex/CONTEXT.md) - Codex runtime surface の source を定義する。managed surface は AGENTS、skills、agents、rules を中心に扱う。
- [Knowledge Ledger](./docs/CONTEXT.md) - repo-level の durable knowledge を定義する。notes、ADRs、context docs、decision status、documentation responsibilities を含む。

## Relationships

- **Codex ハーネス -> Knowledge Ledger**: Runtime surface の変更は、durable knowledge、notes、ADRs を生むことがある。
- **Knowledge Ledger -> Codex ハーネス**: Accepted decisions と repo-level guidance は、managed harness surface の形を決める。
