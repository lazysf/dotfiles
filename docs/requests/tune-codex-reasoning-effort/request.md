# Request

## 元の要求・要望

Codex 側は推奨案 2 を採用する。

## 背景

- Codex 側の model と reasoning effort を Claude 側と比較した。
- ユーザーは `medium` / `high` / `low` の使い分けを望んでいる。
- 採用された案は、Codex main を品質寄せにし、researcher は事実調査中心として少し軽くする方針。
- Codex manual で、`gpt-5.5` が多くの Codex tasks の推奨 model、`model_reasoning_effort` は `minimal` / `low` / `medium` / `high` / `xhigh` を設定できることを確認した。

## 期待状態

- Codex main は `gpt-5.5` / `high`。
- Codex researcher agent は `gpt-5.5` / `medium`。
- 他の Codex agents は既存の `gpt-5.5` / `high` または `medium` のまま。

## 不明点

- なし。

## 再定義履歴

- なし。

## Scope / Acceptance

- `dot_codex/private_config.toml.tmpl` の `model_reasoning_effort` を `high` に変更する。
- `dot_codex/agents/researcher.toml` の `model_reasoning_effort` を `medium` に変更する。
- `model = "gpt-5.5"` は維持する。
- permissions、sandbox、agent body、plugins、features は変更しない。

## 実装境界 / 省略理由 / 検証入口

- `requirements.md` / `basic-design.md` / `detailed-design.md` / `tasks.md` は省略する。理由: 合意済み model/effort 方針の小さな設定反映で、追加設計や task 分解が不要。
- 検証入口: `rg` による model / effort 設定確認、`mise run lint:toml`、`git diff --check`、必要に応じた `mise run test`。
