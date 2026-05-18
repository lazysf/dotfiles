# Context Map

## Contexts

- [Codex ハーネス](./dot_codex/CONTEXT.md) - deployable な Codex runtime surface を定義する。skills、agents、rules、plugins、config、operational boundaries を含む。
- [Knowledge Ledger](./docs/CONTEXT.md) - repo-level の durable knowledge を定義する。notes、ADRs、context docs、decision status、documentation responsibilities を含む。

## Relationships

- **Codex ハーネス -> Knowledge Ledger**: Runtime surface の変更は、durable knowledge、notes、ADRs を生むことがある。
- **Knowledge Ledger -> Codex ハーネス**: Accepted decisions と repo-level guidance は、deployable harness surface の形を決める。
