# 共通ハーネスの検証

`dot_codex/` を変更したら、共通ハーネスとして deployable かを次の順で確認します。

## 必須確認

1. `python3 scripts/verify-codex-harness.py`
2. `pre-commit run --all-files`
3. `chezmoi execute-template < dot_codex/private_config.toml.tmpl`

## 補助確認

- `rg` による責務分離チェック
- 必要に応じて `codex debug prompt-input`
  - この環境では `~/.codex/sessions` の権限状態に依存するため、必須ゲートにはしない

## 見るポイント

- `dot_codex/` に repo-level 保守文書が混入していない
- `dot_codex/` から repo-level の保守文書を参照していない
- `.codex/` を knowledge の標準置き場として推奨していない
- rules / agents / docs の導線が壊れていない
