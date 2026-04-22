# docs

この `docs/` は、この dotfiles repo を保守するときに参照する知見の置き場です。

- `docs/knowledge/`: repo-level の通常知見を置く
  - [adr-ledger-model.md](./knowledge/adr-ledger-model.md): ADR を状態付き判断台帳として扱う運用
  - [adr-workflow-review-pitfalls.md](./knowledge/adr-workflow-review-pitfalls.md): ADR 台帳フロー拡張時の review 観点
  - [classification-driven-workflow-surface.md](./knowledge/classification-driven-workflow-surface.md): prefix なし skill surface の扱い
  - [codex-harness-audit-findings.md](./knowledge/codex-harness-audit-findings.md): 2026-04 の監査 findings と是正内容
  - [harness-design-principles.md](./knowledge/harness-design-principles.md): ハーネス設計の原則と採用方針
  - [harness-regression-checks.md](./knowledge/harness-regression-checks.md): ハーネス更新時の手動回帰チェック
- `docs/adr/`: repo-level の判断記録を置く
  - [0001-common-codex-harness-lives-in-dot_codex.md](./adr/0001-common-codex-harness-lives-in-dot_codex.md)
  - [0002-project-specific-knowledge-lives-in-project-docs.md](./adr/0002-project-specific-knowledge-lives-in-project-docs.md)
  - [0003-promote-harness-knowledge-by-runtime-surface.md](./adr/0003-promote-harness-knowledge-by-runtime-surface.md)
  - [0004-retire-legacy-workflow-prefixes.md](./adr/0004-retire-legacy-workflow-prefixes.md)
  - [0005-keep-harness-verification-focused-on-repo-contracts.md](./adr/0005-keep-harness-verification-focused-on-repo-contracts.md)
- `dot_codex/AGENTS.md`: 運用契約と導線を置く
- `dot_codex/skills/`: prefix なしの skill 手順と、その `references/` を置く
- `dot_codex/agents/`: review の正式入口になる reviewer agent を置く。review はここから明示的に呼び出す
- `dot_codex/rules/`: 機械的なガードを置く
