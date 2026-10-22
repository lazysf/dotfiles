# Claude Code の mod の検証

- Date: 2026-10-16
- 出典: [Mods reference](https://code.claude.com/docs/en/plugins/mods/reference) / 一時 home へ展開した mod での `claude plugin test`（v2.1.292）

[`dot_claude/mods/`](../../dot_claude/mods/) は chezmoi で `~/.claude/mods/` へ配布する Claude Code の mod。[`dot_claude/settings.json`](../../dot_claude/settings.json) の `env.CLAUDE_CODE_PLUGIN_DIRS` に列挙した folder を、起動する session で読み込む。帯を描くのは terminal と desktop app で、VS Code 拡張は描かない。この配布方法を選んだ理由は [ADR 0045](../adr/0045-distribute-claude-mods-via-plugin-dirs.md) にある。

source の folder では `.claude-plugin/` を `dot_claude-plugin/` と書く。そのため、`claude plugin validate` と `claude plugin test` は展開先の folder に対して実行する。test の `*.test.ts` は mod と一緒に配布する。engine は test を読み込まない。
