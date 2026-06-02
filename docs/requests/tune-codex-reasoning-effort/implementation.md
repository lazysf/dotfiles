# Implementation

## 対応タスク / 対応範囲

- `request.md` scope / acceptance: Codex main を `gpt-5.5` / `high`、Codex researcher を `gpt-5.5` / `medium` に調整した。

## 変更内容

- `dot_codex/private_config.toml.tmpl` の `model_reasoning_effort` を `medium` から `high` に変更した。
- `dot_codex/agents/researcher.toml` の `model_reasoning_effort` を `high` から `medium` に変更した。

## 変更ファイル

- `dot_codex/private_config.toml.tmpl`: Codex main default reasoning effort を `high` に変更。
- `dot_codex/agents/researcher.toml`: researcher agent reasoning effort を `medium` に変更。
- `docs/requests/tune-codex-reasoning-effort/request.md`: request scope と検証入口を記録。

## Scope 外

- `model = "gpt-5.5"` の変更。
- reviewer / inspector agents の reasoning effort 変更。
- permissions、sandbox、agent body、plugins、features の変更。

## 実装中に判明した事項

- Codex 側の main と agents は既に `gpt-5.5` に固定済みだった。
- 現在の Codex agents は、inspector が `medium`、researcher が今回 `medium`、reviewer 系が `high` になった。

## 実行した確認

- `rg -n 'model(_reasoning_effort)?\s*=' dot_codex/private_config.toml.tmpl dot_codex/agents/*.toml`
- `mise run lint:toml`
- `git diff --check`
- `mise run test`

## 未確認事項

- 実際の `chezmoi apply` と Codex 再起動後の runtime 表示確認は未実行。
