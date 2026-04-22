# Codex Harness Audit Findings

2026-04 の Codex ハーネス監査で確認した findings と、その是正内容をまとめる。

## Must-Fix

- `scripts/verify-codex-harness.py` が、[ADR 0005](../adr/0005-keep-harness-verification-focused-on-repo-contracts.md) で手動回帰へ移した docs index 網羅性、legacy surface 文言、legacy directory 残骸まで自動失敗対象にしていた。
  - Evidence: 修正前の `scripts/verify-codex-harness.py` では `check_docs_readme_index()`、`check_skill_surface()`、`check_review_surface()` が自動 fail 条件だった。
  - Impact: repo 固有契約の自動検知と、移行残骸や docs 保守の確認が混ざり、ADR 0005 の責務分離に反していた。
  - Recommendation: 自動検査は agent metadata、rule metadata、Markdown 相対リンク、project-local `.codex` directory の推奨禁止に限定する。
- `dot_codex/skills/code-review/` が空ディレクトリのまま残っていた。
  - Evidence: `find dot_codex -type d -empty` で `dot_codex/skills/code-review` が検出されていた。
  - Impact: review の正式入口が `dot_codex/agents/` である契約に対して、不要な surface 候補に見える stale artifact になっていた。
  - Recommendation: 空ディレクトリは削除し、review 導線は `dot_codex/agents/` の説明へ寄せる。

## Should-Fix

- `dot_codex/AGENTS.md` と `docs/knowledge/classification-driven-workflow-surface.md` の両方に代表導線の列挙があり、どちらが正本か迷いやすかった。
  - Impact: flow 名や補助導線の更新時に二重管理が発生しやすい。
  - Recommendation: `dot_codex/AGENTS.md` を契約と導線の正本、`classification-driven-workflow-surface.md` を背景知識と命名規約の説明に寄せる。
- `docs/knowledge/harness-regression-checks.md` に surface の正本説明が混ざっていた。
  - Impact: 手動回帰シナリオ集と運用契約の本文が競合しやすい。
  - Recommendation: 手動回帰では「何を確認するか」だけを残し、導線の正本は `dot_codex/AGENTS.md` と `classification-driven-workflow-surface.md` へ参照で寄せる。

## Nice-to-Have

- docs 間の役割差を、短い相互参照でより明示してもよい。
  - 例: `dot_codex/AGENTS.md` から surface 背景説明へのリンク、`harness-regression-checks.md` から正本説明へのリンク。
