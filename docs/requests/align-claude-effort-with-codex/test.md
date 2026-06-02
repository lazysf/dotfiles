# Test

## Summary

- Result: pass
- Scope: Claude agent frontmatter effort と Codex 側 effort mapping の一致。

## Test Cases

### TC-001: Claude effort が Codex 側 mapping と一致する

#### 対応

- `request.md` scope / acceptance

#### 種別

- automated / exploratory

#### 手順

1. `rg -n '^(  "model"|  "effortLevel"|model:|effort:|model_reasoning_effort\s*=)' dot_claude/settings.json dot_claude/agents/*.md dot_codex/private_config.toml.tmpl dot_codex/agents/*.toml`
2. `markdownlint-cli2 docs/requests/align-claude-effort-with-codex/*.md`
3. `git diff --check`
4. `mise run test`

#### 結果

- pass
- `rg` で Claude main `high`、researcher `medium`、inspector `medium`、requirements/design/quality/security reviewer `high` を確認した。
- `rg` で Codex main `high`、researcher `medium`、inspector `medium`、requirements/design/quality/security reviewer `high` を確認した。
- `markdownlint-cli2` は pass。request folder 3 files、0 errors。
- `git diff --check` は pass。whitespace error なし。
- `mise run test` は pass。`test:nvim-load` 成功。

#### 未実行理由 / 代替確認

- N/A

## Executed Checks

- `rg -n '^(  "model"|  "effortLevel"|model:|effort:|model_reasoning_effort\s*=)' dot_claude/settings.json dot_claude/agents/*.md dot_codex/private_config.toml.tmpl dot_codex/agents/*.toml`: pass
- `markdownlint-cli2 docs/requests/align-claude-effort-with-codex/*.md`: pass
- `git diff --check`: pass
- `mise run test`: pass

## Unverified Items

- 実際の `chezmoi apply` と Claude Code 再起動後の runtime 表示確認。

## Remaining Risks

- none
