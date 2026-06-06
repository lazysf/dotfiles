# Lightweight Workflow

`dot_codex/` と `dot_claude/` の現在の姿。両 surface とも軽量 LLM-native へ再設計した結果を記録する。判断記録は ADR 0036（Codex 軽量化・両 surface 対称化）と ADR 0035（Claude 先行軽量化、0036 で superseded）。

## 現在の構成

| 要素 | Codex (`dot_codex/`) | Claude (`dot_claude/`) |
| --- | --- | --- |
| 全体契約 | `AGENTS.md`（進行ガイド・品質・doc・停止線・置き場 + prose 行動指針集約） | `CLAUDE.md`（同左、prose は `rules/` に分離） |
| skills | `scribe` / `git-commit` / `git-push` / `caveman`（output-style 非対応のため skill） | `scribe` / `git-commit` / `git-push` |
| output-style | なし | `caveman` |
| agents | `researcher`（low, read-only）/ `quality-reviewer`（high）/ `security-reviewer`（high）。toml + `sandbox_mode = "read-only"` | 同左。md frontmatter。researcher は `tools: Read, Glob, Grep`、reviewer 2 つは `tools: Read, Glob, Grep, Bash`（built-in read-only command の範囲で実質 read-only） |
| rules | command guard 専用（`.rules`、`allow` / `forbidden`） | path 条件付き短い prose rule（coding-standards / docs-artifacts / claude-surface-consistency / vba） |
| runtime config | `private_config.toml.tmpl`（model `gpt-5.5`、effort `medium`、approval / auto_review / sandbox / `.rules` guard 維持） | `settings.json.tmpl`（model `opus`、effort `medium`、permissions / sandbox） |

## 進行ガイド

進行ガイドの正本は各 surface の `dot_codex/AGENTS.md` / `dot_claude/CLAUDE.md`。発火条件・掘り下げ 4 条件 AND・ADR 3 条件 AND・doc 3 層 silent skip 禁止・review 明示時のみ・停止線などは正本側を参照する。本 note は両 surface の構成差分の記録に絞る。

## 両 surface の意図的差分

両 surface とも軽量 LLM-native だが、各 runtime 固有の差は残る。

| 観点 | Codex | Claude |
| --- | --- | --- |
| agent 間通信 | 直接通信なし、lead 仲介、handoff 出力 | direct subagent spawn（standing authorization 済み） |
| 方針工程 | 会話ベース承認 | `EnterPlanMode` 自己発動 + 承認 |
| `rules/` の責務 | command guard 専用（公式仕様） | 行動指針（path 条件付き）も可 |
| prose 行動指針の置き場 | `AGENTS.md` 集約 | `rules/` 分離 |
| 出力スタイル | `caveman` skill | `caveman` output-style |
| reviewer の read-only 強制 | `sandbox_mode = "read-only"` + `rules/*.rules` で read-only git allow | `tools: Read, Glob, Grep, Bash` + Claude Code built-in read-only command（read-only forms of git 等） + session 全体の既存 deny rule |
| reviewer の明示 diff fallback | `git status -sb` / `git diff` / `git diff --staged` / untracked content（`git status -sb` の `??` 行から特定）を sandbox 内 read-only git で取得（`rules/git-status.rules` / `git-diff.rules` の allow と整合） | 同左を built-in read-only git で取得（ADR 0038 で対称化） |

## 廃止したもの

両 surface で同じ集合を廃止した（Claude 側は ADR 0035 で先行、Codex 側は ADR 0036 で対称化）:

- skill: `orchestrate` / `grill` / `research` / `architecture` / `implement` / `inspect` / `doc-followup`
- agent: `inspector` / `requirements-reviewer` / `design-reviewer`
- 体系: request folder（`docs/requests/<slug>/`）の工程 doc、`REQ-*` / `AC-*` / `BD-*` / `DD-*` / `TASK-*` / `TC-*` traceability ID、tier / Phase / Gate、`orchestrate` 必須入口

## 共有 note との整合

`runtime-surface-guidance.md` / `harness-regression-checks.md` / `harness-design-principles.md` は ADR 0035 時点では Codex 重 SDLC を Codex 側でだけ有効な前提として保持していた。ADR 0036 で Codex も軽量化したため、これら共有 note の重 SDLC 前提は両 surface とも無効になった。本文は履歴として保持し（ADR 0022）、各 note の scope banner で「現行は両 surface 軽量、詳細は本 note を参照」と示す。共有 note 全面 bilateral 書き換えは churn 大のため deferred。

`claude-code-permission-policy.md` の `Agent(...)` allow 例外は維持（read-only subagent の standing authorization）。
