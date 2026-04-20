# 0003: 既定モデルは `gpt-5.4` を維持する

- Status: Accepted

## Context

Codex 向けモデルの選択肢は増えているが、この環境では既に `gpt-5.4` を既定で運用している。
今回の見直しの主目的はモデル変更ではなく、共通ハーネスの責務整理と検証強化である。

## Decision

`dot_codex/private_config.toml.tmpl` の既定モデルは `gpt-5.4` のまま維持する。

## Consequences

- モデル切替は今回のスコープ外とする
- 今回はハーネス改善の効果を設定再編に集中して確認する
