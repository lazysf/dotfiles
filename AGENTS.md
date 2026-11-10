# AGENTS.md

この dotfiles repo を保守する時の、repo に固有の案内。Claude Code と Codex の両方が読む。chezmoi の配布対象にしない。

全 project に共通する進め方は、配布済みの `~/.claude/CLAUDE.md` と `~/.codex/AGENTS.md`（source は `dot_claude/` と `dot_codex/`）が持つ。ここには、この repo でだけ要ることを置く。

## 配布の前提

- 今の session を動かしているのは、配布済みの設定（Claude Code は `~/.claude`、Codex は `~/.codex`）。source の `dot_claude/` と `dot_codex/` を直しても、今の session には効かない。効くのはユーザーが `chezmoi apply` した後から。Claude Code の `CLAUDE.md` は次の session から効く（反映の違いは `docs/notes/harness-design-principles.md`）。Codex の `AGENTS.md` は、公式 docs によると起動時に 1 回読まれるので、次に起動した session から効く。
- `chezmoi apply` はユーザーが手元の terminal で行う。Claude Code の sandbox が書けるのは作業ディレクトリなどに限られ、apply の書き込み先の大半はその外にある。
- Claude Code の sandbox では、`chezmoi status` を repo 全体に打たず、`chezmoi status ~/.claude` のように path を絞る。全体に打つと `~/.config/gh` の読み取り拒否で止まる。

## surface を直す時

`dot_claude/**`、`dot_codex/**`、root の `AGENTS.md` / `CLAUDE.md` は、拡張子が `.md` でも agent の挙動を変える設定として扱い、この節の確認を通す。

- skill を作る時と、skill の設計（description、trigger、構成、references、scripts、評価）を変える時は、判断の前に `skill-creator` スキルを使い、Agent Skills の公式情報を確かめる。発火、配置、権限、frontmatter は runtime の公式情報も確かめる。
  - [Specification](https://agentskills.io/specification)、[Best practices](https://agentskills.io/skill-creation/best-practices)、[Optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)、[Evaluating skills](https://agentskills.io/skill-creation/evaluating-skills)、[Using scripts](https://agentskills.io/skill-creation/using-scripts)、[Documentation Index](https://agentskills.io/llms.txt)
- Claude Code の設定は、判断の対象ごとに次の公式ページを確かめる。一覧に無い対象は [Docs index](https://code.claude.com/docs/llms.txt) から探す。
  - 運用方針、作業設計: [Best practices for Claude Code](https://code.claude.com/docs/en/best-practices)
  - 拡張先の選び方: [Extend Claude Code](https://code.claude.com/docs/en/features-overview)
  - `CLAUDE.md`、memory、`@` import: [How Claude remembers your project](https://code.claude.com/docs/en/memory)
  - `.claude/` の置き場: [Explore the .claude directory](https://code.claude.com/docs/en/claude-directory)
  - `settings.json`、環境変数、優先順位: [Claude Code settings](https://code.claude.com/docs/en/settings)
  - permissions、sandbox、mode: [Configure permissions](https://code.claude.com/docs/en/permissions)
  - skills: [Extend Claude with skills](https://code.claude.com/docs/en/skills)
  - subagents: [Create custom subagents](https://code.claude.com/docs/en/sub-agents)
  - hooks: [Hooks reference](https://code.claude.com/docs/en/hooks)
  - MCP: [Connect Claude Code to tools via MCP](https://code.claude.com/docs/en/mcp)
  - plugins: [Create plugins](https://code.claude.com/docs/en/plugins)
  - mods: [Mods reference](https://code.claude.com/docs/en/plugins/mods/reference)
  - output styles: [Output styles](https://code.claude.com/docs/en/output-styles)
  - 設定が効かない時: [Debug your configuration](https://code.claude.com/docs/en/debug-your-config)
- Codex の設定は、Codex では `openai-docs` スキルで、Claude Code では次のページで確かめる: [Config basics](https://learn.chatgpt.com/docs/config-file/config-basic)、[Permissions](https://learn.chatgpt.com/docs/permissions)、[Skills](https://learn.chatgpt.com/docs/build-skills)、[Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)、[Rules](https://learn.chatgpt.com/docs/agent-configuration/rules)
- 確かめた公式ページは、最終返答で挙げる。確かめられなかった時は、その理由を書いて進め方を相談する。
- `dot_claude/` と `dot_codex/` の片方を変えたら、もう片方へ同じ意図を入れるかを確かめる。tool 名、配置、権限は機械的に揃えない。
- 誤字の修正、合意済みの文言の機械的な反映、path や現状の確認だけなら、`skill-creator` と公式情報の確認を省いてよい。scripts、references、trigger、権限、秘密情報、外部 I/O、実行の挙動に触れる変更は省かない。

## 変更後の確認

- 追加、rename、削除した path、名前（skill / rule / agent）、設定キーは、`rg --hidden -g '!.git'` で参照を探す。`--hidden` は `.github/` などの dot path を含めるため。ADR 本文は採用時点の記録なので直さない。
- Markdown を変えたら `npm run lint`、TOML を変えたら `npm run lint:toml` で lint する。`rumdl` と `tombi` は repo の devDependency なので、PATH 上の command を探さない。commit 時は prek の hook が同じ設定で走る（`docs/notes/lint-and-pre-commit-execution.md`）。
- `.gitignore` の追跡対象と `.chezmoiignore` の配布対象は、別々に確かめる。source から消したファイルは target に残るので、apply の後に `chezmoi managed` と target の実体を突き合わせる。
- surface（`dot_claude/`、`dot_codex/`、`.claude/`、root の `AGENTS.md` / `CLAUDE.md`）の変更と、その理由を書いた `docs/notes/` は別の commit にする（`docs/notes/git-commit-skill-design.md`）。後から見つけた追従漏れも別の commit にする。

## 置き場

- `dot_claude/`: 全 project へ配る Claude Code の契約（`CLAUDE.md`）、settings、hooks、skills、mods
- `dot_codex/`: 全 project へ配る Codex の契約（`AGENTS.md`）、skills、rules。`config.toml` はファイルごとには配布せず、`modify_private_config.toml` で決めたキーだけを上書きする（`docs/notes/codex-harness-operation.md`）
- root `TODO.md`: 着手を保留している残タスク。作業中に見つけた別スコープの問題を、今のスコープを閉じてから扱うために移す先
- `.claude/rules/`: 使わない。この repo に閉じる規則はこの `AGENTS.md` に置き、Claude と Codex の両方に読ませる（`docs/notes/memory-surface-design.md`）
- `docs/notes/`: repo の知見と、今の設計の理由。`docs/adr/`: repo の判断の記録
