# AGENTS.md

この root `AGENTS.md` は、この dotfiles repo を保守するときの repo-local な案内として扱い、chezmoi の展開対象にはしない。
root `CLAUDE.md` は Claude Code 向けの repo-local import shim として扱い、`AGENTS.md` を参照させるだけにする。

## 基本姿勢

- 日本語で返答する
- 事実に基づいて判断する
- 推測や憶測で処理を進めない

## Agent Skills に関する作業

- Codex または Claude Code のスキルを新規作成する、既存スキルの設計を変更する、または description / trigger / 構成 / references / scripts / 品質評価について判断する場合は、判断前に必ず `skill-creator` スキルを使用する
- スキル内容の検討・編集として、仕様、構造、description、progressive disclosure、best practice に関わる判断を行う場合は Agent Skills 公式情報を確認する。runtime 固有の発火、配置、権限、frontmatter は Codex / Claude Code の公式情報も確認する。既存スキルの内容を読み取るだけの場合は必須としない
  - [Overview](https://agentskills.io/home)
  - [Documentation Index](https://agentskills.io/llms.txt)
  - [Quickstart](https://agentskills.io/skill-creation/quickstart)
  - [Specification](https://agentskills.io/specification)
  - [Best practices](https://agentskills.io/skill-creation/best-practices)
  - [Optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)
  - [Evaluating skills](https://agentskills.io/skill-creation/evaluating-skills)
  - [Using scripts](https://agentskills.io/skill-creation/using-scripts)
  - [Codex Agent Skills](https://developers.openai.com/codex/skills)
  - [Claude Code skills](https://code.claude.com/docs/en/skills)
- Agent Skills 公式情報を確認した場合は、最終返答で参照した公式ページを簡潔に明示する。確認が必要だったが確認できない場合は、その事実と理由を明示し、進め方を相談する
- `SKILL.md` へ仕様や長い手順を転載せず、必要な詳細は `references/` などの progressive disclosure に分ける

### docs-only と扱わないもの

- 実行条件、権限、停止線、reviewer 起動、スキル定義、agent 定義、承認ルール、runtime 設定に触れるファイルは、拡張子に関係なく docs-only と扱わない
- `scribe` 単独で進めない代表例:
  - root `AGENTS.md` / `CLAUDE.md` と `dot_codex/AGENTS.md`
  - `dot_claude/CLAUDE.md`
  - `dot_codex/skills/**/SKILL.md`
  - `dot_codex/skills/**/references/`、`scripts/`、`assets/` のうち skill の判断や実行に影響するもの
  - `dot_claude/skills/**/SKILL.md`
  - `dot_claude/skills/**/references/`、`scripts/`、`assets/` のうち skill の判断や実行に影響するもの
  - `dot_codex/agents/*.toml`
  - `dot_claude/agents/*.md`
  - `dot_codex/rules/*.rules`
  - `dot_claude/rules/*.md`
  - `dot_claude/output-styles/*.md`
  - `dot_codex/private_config.toml.tmpl` など Codex runtime 設定
  - `dot_claude/settings.json` など Claude Code runtime 設定

### 軽量例外

- 誤字修正、単純な diff 確認、commit / push、合意済み文言の機械的反映、パスや現状確認だけの場合は、`skill-creator` や公式情報確認を必須とはしない。ただし、scripts / references / trigger / 権限 / secret / 外部 I/O / 実行挙動に触れる変更は除く

## Agent / Subagent 起動

- `orchestrate` workflow 上で必要と定義された repo-local / managed agent / subagent は、ユーザーの standing authorization があるものとして lead が追加確認なしで起動してよい
- この許可は agent / subagent 起動だけを対象にする。各 agent 内の tool 実行、sandbox escalation、secret / auth / 外部 I/O / 破壊的操作の停止線は維持する

## Codex 本体に関する作業

- Codex の設定、権限、実行環境、AGENTS.md、MCP、hooks、rules、skills、subagents、plugins、CLI / app / IDE extension、運用方針に関わる判断を行う場合は、事前に [Codex Docs](https://developers.openai.com/codex) と [Docs MCP](https://developers.openai.com/learn/docs-mcp) を参照する
- Codex の運用方針や作業設計を判断する場合は、[Best practices](https://developers.openai.com/codex/learn/best-practices) を参照する
- 判断対象ごとに該当する公式ページを参照する:
  - 初期導入 / 概要: [Quickstart](https://developers.openai.com/codex/quickstart)
  - ユースケース: [Codex use cases](https://developers.openai.com/codex/use-cases)
  - `AGENTS.md`: [Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md)
  - `~/.codex/config.toml` 基本: [Config basics](https://developers.openai.com/codex/config-basic)
  - config 応用: [Advanced Configuration](https://developers.openai.com/codex/config-advanced)
  - config 詳細: [Configuration Reference](https://developers.openai.com/codex/config-reference)
  - environment variables: [Environment variables](https://developers.openai.com/codex/environment-variables)
  - config 例: [Sample Configuration](https://developers.openai.com/codex/config-sample)
  - permissions / sandbox / approvals: [Permissions](https://developers.openai.com/codex/permissions)
  - rules: [Rules](https://developers.openai.com/codex/rules)
  - hooks: [Hooks](https://developers.openai.com/codex/hooks)
  - MCP: [Model Context Protocol](https://developers.openai.com/codex/mcp)
  - plugins: [Plugins](https://developers.openai.com/codex/plugins)
  - skills: [Agent Skills](https://developers.openai.com/codex/skills)
  - subagents: [Subagents](https://developers.openai.com/codex/subagents)
  - CLI: [CLI](https://developers.openai.com/codex/cli)
  - app: [App](https://developers.openai.com/codex/app)
  - IDE extension: [IDE extension](https://developers.openai.com/codex/ide)
  - app troubleshooting: [Troubleshooting](https://developers.openai.com/codex/app/troubleshooting)
  - changelog / release 確認: [Changelog](https://developers.openai.com/codex/changelog)

## Claude Code に関する作業

- Claude Code の設定や編集に関わる判断を行う場合は、事前に [Claude Code Docs](https://code.claude.com/docs) と [Docs index](https://code.claude.com/docs/llms.txt) を参照する
- Claude Code の運用方針や作業設計を判断する場合は、[Best practices for Claude Code](https://code.claude.com/docs/en/best-practices) を参照する
- Claude Code の拡張先を選ぶ場合は、[Extend Claude Code](https://code.claude.com/docs/en/features-overview) の使い分けに従う
- 判断対象ごとに該当する公式ページを参照する:
  - `CLAUDE.md` / memory / rules / `@` import: [How Claude remembers your project](https://code.claude.com/docs/en/memory)
  - `.claude/` 配下の置き場: [Explore the .claude directory](https://code.claude.com/docs/en/claude-directory)
  - `settings.json` / environment variables / precedence: [Claude Code settings](https://code.claude.com/docs/en/settings)
  - permissions / sandbox / modes: [Configure permissions](https://code.claude.com/docs/en/permissions)
  - skills / commands: [Extend Claude with skills](https://code.claude.com/docs/en/skills)
  - subagents: [Create custom subagents](https://code.claude.com/docs/en/sub-agents)
  - hooks: [Hooks reference](https://code.claude.com/docs/en/hooks)
  - MCP: [Connect Claude Code to tools via MCP](https://code.claude.com/docs/en/mcp)
  - plugins: [Create plugins](https://code.claude.com/docs/en/plugins)
  - output styles: [Output styles](https://code.claude.com/docs/en/output-styles)
  - 設定が効かない時: [Debug your configuration](https://code.claude.com/docs/en/debug-your-config)

## 置き場の原則

- `dot_codex/skills/`: Codex 用の再利用する作業手順と通常作業の正式入口を置く
- `dot_claude/skills/`: Claude Code 用の再利用する作業手順と通常作業の正式入口を置く
- `docs/notes/`: repo-level の通常知見や背景を置く
- `docs/adr/`: repo-level の判断記録を置く
- root `CLAUDE.md`: Claude Code 向けの repo-local import shim を置く
- `dot_codex/AGENTS.md`: managed Codex surface 側の運用契約を置く
- `dot_claude/CLAUDE.md`: managed Claude Code surface 側の運用契約を置く
