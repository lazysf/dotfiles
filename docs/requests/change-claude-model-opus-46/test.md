# Test

## Summary

- Result: partial
- Scope: Claude Code settings JSON、Claude custom agent frontmatter、effort 設定維持、repo checks。

## Test Cases

### TC-001: Claude model pin と effort 維持を確認する

#### 対応

- `request.md` scope / acceptance

#### 種別

- automated / exploratory / lint

#### 手順

1. `jq . dot_claude/settings.json`
2. `rg -n '^(  "model"|  "effortLevel"|model:|effort:)' dot_claude/settings.json dot_claude/agents/*.md`
3. `rg -n 'model: opus|"model": "opus"' dot_claude`
4. `git diff --check`
5. `mise run test`
6. `mise run lint`

#### 結果

- partial
- `jq` は pass。JSON parse 成功。`model` は `claude-opus-4-6`、`effortLevel` は `high`。
- `rg` は pass。`dot_claude/settings.json` と 6 agent の `model` が `claude-opus-4-6`。
- `rg` は pass。`dot_claude` に `opus` alias の model 設定は残っていない。
- `git diff --check` は pass。whitespace error なし。
- `mise run test` は pass。`test:nvim-load` 成功。
- `mise run lint` は fail。`lint:lua`、`lint:toml`、`lint:yaml` は pass。`lint:markdown` は既存 docs の MD024 / MD038 / MD060 で fail。

#### 未実行理由 / 代替確認

- 実際の Claude Code 起動確認は未実行。理由: 設定 source の静的変更確認で今回 scope を満たせるため。

## Executed Checks

- `jq . dot_claude/settings.json`: pass
- `rg -n '^(  "model"|  "effortLevel"|model:|effort:)' dot_claude/settings.json dot_claude/agents/*.md`: pass
- `rg -n 'model: opus|"model": "opus"' dot_claude`: pass、match なし
- `git diff --check`: pass
- `mise run test`: pass
- `mise run lint`: partial、既存 Markdown lint error で fail

## Unverified Items

- 実際の Claude Code 起動確認は未実行。理由: 設定 source の静的変更確認で今回 scope を満たせるため。

## Remaining Risks

- `CLAUDE_CODE_SUBAGENT_MODEL` が展開後の外部環境で設定されている場合、Claude Code 公式 docs の優先順により subagent frontmatter より優先される。
