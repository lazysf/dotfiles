# Lightweight Workflow

`dot_codex/` と `dot_claude/` の現在の姿。両 surface とも軽量 LLM-native へ再設計した結果を記録する。判断記録は ADR 0036（Codex 軽量化・両 surface 対称化）と ADR 0035（Claude 先行軽量化、0036 で superseded）。

## 現在の構成

| 要素 | Codex (`dot_codex/`) | Claude (`dot_claude/`) |
| --- | --- | --- |
| 全体契約 | `AGENTS.md`（進行ガイド・品質・doc・停止線・置き場 + prose 行動指針集約） | `CLAUDE.md`（同左、prose は `rules/` に分離） |
| skills | `scribe` / `git-commit` / `git-push` / `caveman`（output-style 非対応のため skill） | `scribe` / `git-commit` / `git-push` |
| output-style | なし | `caveman` |
| agents | `researcher`（high, read-only）/ `quality-reviewer`（high）/ `security-reviewer`（high）。toml + `sandbox_mode = "read-only"` | `researcher`（high）/ `quality-reviewer`（xhigh）/ `security-reviewer`（xhigh）。md frontmatter。researcher は `tools: Read, Glob, Grep`、reviewer 2 つは `tools: Read, Glob, Grep, Bash`（built-in read-only command の範囲で実質 read-only） |
| rules | command guard 専用（`.rules`、`allow` / `forbidden`） | path 条件付き短い prose rule（coding-standards / docs-artifacts / harness-surface-consistency / vba） |
| runtime config | `~/.codex/config.toml`（Codex app が書き換えるため source 管理しない。意図した設定値は下記「runtime config の扱い」に列挙） | `settings.json.tmpl`（model `claude-opus-5`、effortLevel `xhigh`、permissions / sandbox / env） |

## runtime config の扱い

- Date: 2026-07-30
- 出典: 実機 `~/.codex/config.toml` / [Codex Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents) / [Codex Config Reference](https://learn.chatgpt.com/docs/config-file/config-reference)

- Codex の `~/.codex/config.toml` は source 管理しない。Codex app 自身が `marketplaces.last_updated` / `projects` / `desktop` / `mcp_servers` を書き換えるため、chezmoi 側の template は追随できない。実際に source（`dot_codex/private_config.toml.tmpl`、model `gpt-5.5` / effort `medium`）と実機（model `gpt-5.6-sol` / effort `high`、plugin 構成も差異）が乖離し、「参照用 source」が誤情報になっていたため template を廃止した。値の正本は実機 config とする。
- 捨てた案: (1) 参照用 source として残し実機へ手動同期 — 同期漏れが再発する。(2) 配布対象へ戻す — app 側の書き込みと衝突する。
- ADR は書かない。複数案を実比較した判断だが、削除は git から復元でき影響も harness 内部に閉じるため「覆すコストが高い」を満たさない。判断と捨てた案はこの notes に残す。
- `[agents] max_depth` は公式の設定キーに存在しない。公式 `[agents]` は `enabled` / `max_concurrent_threads_per_session` / `default_subagent_model` / `default_subagent_reasoning_effort` / `interrupt_message` で、`max_threads` は `max_concurrent_threads_per_session` の legacy alias。ADR 0020 が「深さを制御する設定」として挙げた `max_depth` は効いていない前提で読む。nested spawn を抑える実効は `dot_codex/AGENTS.md` の「lead が仲介する」契約だけ。
- Claude の `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"` は experimental flag。lead が subagent を束ねる運用を有効にするために置いている。公式 docs に記載のない flag なので、廃止や改名で黙って挙動が変わり得る。subagent 周りの挙動が変わったらこの行を疑う。
- Claude の `env.CLAUDE_CODE_SUBPROCESS_ENV_SCRUB = "1"` は subprocess から Anthropic / cloud provider credential を除去する。狙いと限界は [claude-code-permission-policy.md](./claude-code-permission-policy.md)。

### 意図した設定値（再セットアップ時の復元用）

廃止した template が持っていた設定と、その意図。値の現状は実機 `~/.codex/config.toml` を見る。

- `model` / `model_reasoning_effort`: lead の意図値。`dot_codex/agents/*.toml` はこれに合わせる（乖離チェックは [harness-regression-checks.md](./harness-regression-checks.md)）。2026-07-30 時点の実機は `gpt-5.6-sol` / `high`。
- `approval_policy = "on-request"` + `approvals_reviewer = "auto_review"`: 承認は都度要求し、review は reviewer subagent に回す。
- `sandbox_mode = "workspace-write"`: workspace 外の書き込みを止める。
- `[sandbox_workspace_write] network_access = false`: workspace-write sandbox からの外向き通信を止める意図。**実機 config には該当 section が無く、app 内部 state（`~/.codex/.codex-global-state.json`）で `networkAccess: false` を確認しただけの状態。** 公式 docs でこの key の既定値を確認できていないため、実機 config へ明示する運用にする（下記手順）。
- `web_search = "live"`: 外部 web 検索を有効にする。未信頼コンテンツを取り込む経路なので、停止線と契約側で受ける。
- `[features] shell_snapshot` / `multi_agent`: どちらも公式に stable / 既定 on。明示して意図を残していた。
- `[features] default_mode_request_user_input = true`: UnderDevelopment flag。default mode でも `request_user_input` tool を有効化する目的（`openai/codex#12694`）。公式 docs に無いため、flag 廃止で黙って挙動が変わり得る。
- `[windows] sandbox = "elevated"`: **Windows での Codex sandbox 設定の唯一の記録。** Windows を再セットアップする時はこの値から始める。
- darwin 限定の `notify = [..., "turn-ended"]`: computer-use client への turn 終了通知。
- `[projects."<chezmoi sourceDir>"] trust_level = "trusted"`: この repo を trusted にして project 層の `.codex/` を読ませる。

`network_access` を実機へ明示する時は `~/.codex/config.toml` へ次を追記し、Codex を再起動する。

```toml
[sandbox_workspace_write]
network_access = false
```

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
| 行動指針の発火範囲 | `AGENTS.md` は常時 load | `rules/` は `paths` 条件付き。`coding-standards` は `**/src/**` 等に限定するため、この dotfiles repo のような layout では load されない（context 節約を取って許容する。常時 load したい場合は `paths` を外す） |
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
