# docs

この `docs/` は、この dotfiles repo を保守するときに参照する知見の置き場です。

- [../CONTEXT-MAP.md](../CONTEXT-MAP.md): multi-context repo としての context 一覧
- [CONTEXT.md](./CONTEXT.md): repo-level durable knowledge の用語
- `docs/notes/`: repo-level の通常知見を置く
  - [adr-ledger-model.md](./notes/adr-ledger-model.md): ADR を状態付き判断台帳として扱う運用
  - [adr-workflow-review-pitfalls.md](./notes/adr-workflow-review-pitfalls.md): ADR 台帳フロー拡張時の review 観点
  - [classification-driven-workflow-surface.md](./notes/classification-driven-workflow-surface.md): prefix なし skill surface の扱い
  - [coding-standards-skill-design.md](./notes/coding-standards-skill-design.md): 言語別コーディング標準 skill の設計・review 観点
  - [git-add-approval-friction-diagnosis.md](./notes/git-add-approval-friction-diagnosis.md): `git add` の approval friction を rule と sandbox で切り分けるメモ
  - [harness-design-principles.md](./notes/harness-design-principles.md): ハーネス設計の原則と採用方針
  - [harness-regression-checks.md](./notes/harness-regression-checks.md): ハーネス更新時の手動回帰チェック
  - [mise-tool-matrix.md](./notes/mise-tool-matrix.md): mise と nvim の formatter / linter 対応表
- `docs/adr/`: `Accepted` / `Superseded` を含む repo-level の状態付き判断台帳を置く
  - [0001-common-codex-harness-lives-in-dot_codex.md](./adr/0001-common-codex-harness-lives-in-dot_codex.md)
  - [0002-project-specific-knowledge-lives-in-project-docs.md](./adr/0002-project-specific-knowledge-lives-in-project-docs.md)
  - [0003-promote-harness-knowledge-by-runtime-surface.md](./adr/0003-promote-harness-knowledge-by-runtime-surface.md)
  - [0004-retire-legacy-workflow-prefixes.md](./adr/0004-retire-legacy-workflow-prefixes.md)
  - [0005-keep-harness-verification-focused-on-repo-contracts.md](./adr/0005-keep-harness-verification-focused-on-repo-contracts.md)
  - [0006-keep-agents-thin-and-surface-oriented.md](./adr/0006-keep-agents-thin-and-surface-oriented.md)
  - [0007-retire-harness-verifier-script.md](./adr/0007-retire-harness-verifier-script.md)
  - [0008-keep-git-operation-surface-minimal.md](./adr/0008-keep-git-operation-surface-minimal.md)
  - [0009-adopt-context-aware-upstream-planning.md](./adr/0009-adopt-context-aware-upstream-planning.md)
  - [0010-absorb-knowledge-capture-into-grill-with-docs.md](./adr/0010-absorb-knowledge-capture-into-grill-with-docs.md)
  - [0011-prune-codex-skill-and-reviewer-surface.md](./adr/0011-prune-codex-skill-and-reviewer-surface.md)
- `dot_codex/AGENTS.md`: 運用契約と薄い surface 案内を置く
- `dot_codex/skills/`: prefix なしの skill 手順と、その `references/` を置く
- `dot_codex/agents/`: review の正式入口になる reviewer agent を置く。review はここから明示的に呼び出す
- `dot_codex/rules/`: 機械的なガードを置く
