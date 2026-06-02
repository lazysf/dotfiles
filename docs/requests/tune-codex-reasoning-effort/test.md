# Test

## Summary

- Result: pass
- Scope: Codex config template、Codex researcher agent TOML、reasoning effort 設定。

## Test Cases

### TC-001: Codex model と reasoning effort が採用方針どおり

#### 対応

- `request.md` scope / acceptance

#### 種別

- automated / exploratory

#### 手順

1. `rg -n 'model(_reasoning_effort)?\s*=' dot_codex/private_config.toml.tmpl dot_codex/agents/*.toml`
2. `mise run lint:toml`
3. `git diff --check`
4. `mise run test`

#### 結果

- pass
- `rg` で main `model_reasoning_effort = "high"`、researcher `model_reasoning_effort = "medium"`、全 Codex model `gpt-5.5` を確認した。
- `mise run lint:toml` は pass。13 files linted successfully。
- `git diff --check` は pass。whitespace error なし。
- `mise run test` は pass。`test:nvim-load` 成功。

#### 未実行理由 / 代替確認

- N/A

## Executed Checks

- `rg -n 'model(_reasoning_effort)?\s*=' dot_codex/private_config.toml.tmpl dot_codex/agents/*.toml`: pass
- `mise run lint:toml`: pass
- `git diff --check`: pass
- `mise run test`: pass

## Unverified Items

- 実際の `chezmoi apply` と Codex 再起動後の runtime 表示確認。

## Remaining Risks

- none
