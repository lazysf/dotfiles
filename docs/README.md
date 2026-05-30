# docs

この `docs/` は、この dotfiles repo を保守するときに参照する知見の置き場です。

- [../CONTEXT-MAP.md](../CONTEXT-MAP.md): multi-context repo としての context 一覧
- [CONTEXT.md](./CONTEXT.md): repo-level durable knowledge の用語
- `docs/notes/`: repo-level の通常知見を置く
  - [adr-ledger-model.md](./notes/adr-ledger-model.md): ADR を状態付き判断台帳として扱う運用
  - [adr-workflow-review-pitfalls.md](./notes/adr-workflow-review-pitfalls.md): ADR 台帳フロー拡張時の review 観点
  - [Runtime Surface Guidance](./notes/runtime-surface-guidance.md): runtime surface guidance と prefix なし skill surface の扱い
  - [git-add-approval-friction-diagnosis.md](./notes/git-add-approval-friction-diagnosis.md): `git add` の approval friction を rule と sandbox で切り分けるメモ
  - [harness-design-principles.md](./notes/harness-design-principles.md): ハーネス設計の原則と採用方針
  - [harness-regression-checks.md](./notes/harness-regression-checks.md): ハーネス更新時の手動回帰チェック
  - [mise-tool-matrix.md](./notes/mise-tool-matrix.md): mise と nvim の formatter / linter 対応表
  - [vba-implementation-reference-design.md](./notes/vba-implementation-reference-design.md): VBA 実装 reference の設計・review 観点
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
  - [0012-retire-review-findings-summary-skill.md](./adr/0012-retire-review-findings-summary-skill.md)
  - [0013-add-prd-and-architecture-skill-surfaces.md](./adr/0013-add-prd-and-architecture-skill-surfaces.md)
  - [0014-adopt-rtk-as-codex-shell-proxy.md](./adr/0014-adopt-rtk-as-codex-shell-proxy.md)
  - [0015-retire-rtk-as-codex-shell-proxy.md](./adr/0015-retire-rtk-as-codex-shell-proxy.md)
  - [0016-reduce-reviewer-agent-surface.md](./adr/0016-reduce-reviewer-agent-surface.md)
  - [0017-consolidate-planning-skill-surface.md](./adr/0017-consolidate-planning-skill-surface.md)
  - [0018-keep-git-mutation-rules-prompted.md](./adr/0018-keep-git-mutation-rules-prompted.md)
  - [0019-split-planning-and-docs-surface.md](./adr/0019-split-planning-and-docs-surface.md)
- `dot_codex/private_AGENTS.md.tmpl`: `~/.codex/AGENTS.md` へ展開する運用契約と薄い surface 案内を置く
- `dot_codex/skills/`: `~/.codex/skills/` へ展開する prefix なしの skill 手順と、その `references/` を置く
- `dot_codex/agents/`: `~/.codex/agents/` へ展開する read-only reviewer agent を置く
- `dot_codex/rules/`: `~/.codex/rules/` へ展開する allow / forbidden の機械的 guard を置く
- `dot_codex/CONTEXT.md`, `dot_codex/private_config.toml.tmpl`: repo 内の参照用 source。展開先の `.codex/CONTEXT.md` / `.codex/config.toml` は `.chezmoiignore` で配布対象外
