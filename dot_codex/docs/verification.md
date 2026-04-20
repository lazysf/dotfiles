# 共通ハーネスの検証

`~/.codex/` に相当する source を保守元 repo で変更したら、共通ハーネスとして deployable かを次の順で確認します。

## 必須確認

1. `python3 scripts/verify-codex-harness.py`
2. `pre-commit run --all-files`
3. 保守元 repo で `chezmoi execute-template < dot_codex/private_config.toml.tmpl`

## 補助確認

- `rg` による責務分離チェック
- [../../docs/harness-regression-scenarios.md](../../docs/harness-regression-scenarios.md) の代表シナリオ
  - docs / rules / agents / config を更新したときは、変更に近いシナリオを必ず手動で回す
- 必要に応じて `codex debug prompt-input`
  - この環境では `~/.codex/sessions` の権限状態に依存するため、必須ゲートにはしない

## 見るポイント

- `~/.codex/` に相当する source に repo-level 保守文書が混入していない
- `~/.codex/` に相当する source から repo-level の保守文書を参照していない
- `.codex/` を knowledge の標準置き場として推奨していない
- rules / agents / docs の導線が壊れていない
- 手動シナリオで、知見の置き場、approval 境界、一次情報優先のふるまいが崩れていない
