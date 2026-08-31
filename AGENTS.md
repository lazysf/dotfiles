# AGENTS.md

この root `AGENTS.md` は、この dotfiles repo を保守するときの repo-local な案内として扱い、chezmoi の展開対象にはしない。
root `CLAUDE.md` は Claude Code 向けの repo-local import shim として扱い、`AGENTS.md` を参照させるだけにする。

## Agent Skills に関する作業

- Claude Code のスキルを新規作成する、既存スキルの設計を変更する、または description / trigger / 構成 / references / scripts / 品質評価について判断する場合は、判断前に必ず `skill-creator` スキルを使用する
- スキル内容の検討・編集として、仕様、構造、description、progressive disclosure、best practice に関わる判断を行う場合は Agent Skills 公式情報を確認する。runtime 固有の発火、配置、権限、frontmatter は Claude Code の公式情報も確認する。既存スキルの内容を読み取るだけの場合は必須としない
  - [Overview](https://agentskills.io/home)
  - [Documentation Index](https://agentskills.io/llms.txt)
  - [Quickstart](https://agentskills.io/skill-creation/quickstart)
  - [Specification](https://agentskills.io/specification)
  - [Best practices](https://agentskills.io/skill-creation/best-practices)
  - [Optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)
  - [Evaluating skills](https://agentskills.io/skill-creation/evaluating-skills)
  - [Using scripts](https://agentskills.io/skill-creation/using-scripts)
  - [Claude Code skills](https://code.claude.com/docs/en/skills)
- Agent Skills 公式情報を確認した場合は、最終返答で参照した公式ページを簡潔に明示する。確認が必要だったが確認できない場合は、その事実と理由を明示し、進め方を相談する
- `SKILL.md` へ仕様や長い手順を転載せず、必要な詳細は `references/` などの progressive disclosure に分ける

### docs-only と扱わないもの

- 実行条件、権限、停止線、reviewer 起動、スキル定義、agent 定義、承認ルール、runtime 設定に触れるファイルは、拡張子に関係なく docs-only と扱わない
- `scribe` 単独で進めない代表例:
  - root `AGENTS.md` / `CLAUDE.md`、`dot_claude/CLAUDE.md`
  - `dot_claude/skills/**`（`SKILL.md` と、判断や実行に影響する `references/` / `scripts/` / `assets/`）
  - agent 定義（`dot_claude/agents/*.md`）
  - rules（`dot_claude/rules/*.md`）
  - `dot_claude/output-styles/*.md`
  - runtime 設定（`dot_claude/settings.json`）

### 軽量例外

- 誤字修正、単純な diff 確認、commit / push、合意済み文言の機械的反映、パスや現状確認だけの場合は、`skill-creator` や公式情報確認を必須とはしない。ただし、scripts / references / trigger / 権限 / secret / 外部 I/O / 実行挙動に触れる変更は除く

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

- `dot_claude/`: 全 project へ配る運用契約、rules、skills、output-styles、settings。内訳は `dot_claude/CLAUDE.md` の「置き場」を正本にする
- root `CLAUDE.md`: Claude Code 向けの repo-local import shim
- `.claude/rules/`: この repo に閉じる運用ルール。chezmoi は `.` 始まりを配布しない
- `docs/notes/`: repo-level の通常知見や背景
- `docs/adr/`: repo-level の判断記録
