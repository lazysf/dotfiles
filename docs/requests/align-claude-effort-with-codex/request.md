# Request

## 元の要求・要望

Claude側のeffortをCodex側に合わせて

## 背景

- Codex 側は main `high`、researcher `medium`、inspector `medium`、reviewer 系 `high` に調整済み。
- Claude 側は main `high`、researcher `low`、inspector `medium`、requirements/design/quality reviewer `medium`、security reviewer `high` だった。
- Claude Code 公式 docs で、settings の `effortLevel` と subagent frontmatter の `effort` により effort を設定できることを確認した。

## 期待状態

- Claude main は `high` のまま。
- Claude researcher は `medium`。
- Claude inspector は `medium` のまま。
- Claude requirements/design/quality/security reviewer は `high`。
- Claude model は `claude-opus-4-6` のまま。

## 不明点

- なし。

## 再定義履歴

- なし。

## Scope / Acceptance

- `dot_claude/agents/researcher.md` の `effort` を `medium` に変更する。
- `dot_claude/agents/requirements-reviewer.md`、`dot_claude/agents/design-reviewer.md`、`dot_claude/agents/quality-reviewer.md` の `effort` を `high` に変更する。
- `dot_claude/settings.json` の `effortLevel`、`dot_claude/agents/inspector.md`、`dot_claude/agents/security-reviewer.md` は既に一致しているため変更しない。
- `model`、permissions、sandbox、tools、agent body は変更しない。

## 実装境界 / 省略理由 / 検証入口

- `requirements.md` / `basic-design.md` / `detailed-design.md` / `tasks.md` は省略する。理由: 合意済み effort mapping の小さな設定反映で、追加設計や task 分解が不要。
- 検証入口: `rg` による model / effort 設定確認、request artifact markdownlint、`git diff --check`、`mise run test`。
