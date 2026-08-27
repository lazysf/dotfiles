# Lightweight Workflow

`dot_codex/` と `dot_claude/` の現在の姿。両 surface とも軽量 LLM-native へ再設計した結果を記録する。判断記録は ADR 0036（Codex 軽量化・両 surface 対称化）と ADR 0035（Claude 先行軽量化、0036 で superseded）。

## 現在の構成

| 要素 | Codex (`dot_codex/`) | Claude (`dot_claude/`) |
| --- | --- | --- |
| 全体契約 | `AGENTS.md`（進行ガイド・品質・doc・停止線・置き場 + prose 行動指針集約） | `CLAUDE.md`（同左、prose は `rules/` に分離） |
| skills | `scribe` / `git-commit` / `git-push` / `caveman`（output-style 非対応のため skill） | `scribe` / `git-commit` / `git-push` |
| output-style | なし | `caveman` |
| agents | `researcher`（high, read-only）/ `quality-reviewer`（high）/ `security-reviewer`（high）。toml + `sandbox_mode = "read-only"` | `researcher`（high）/ `quality-reviewer`（xhigh）/ `security-reviewer`（xhigh）。md frontmatter。researcher は `tools: Read, Glob, Grep`、reviewer 2 つは `tools: Read, Glob, Grep, Bash`（built-in read-only command の範囲で実質 read-only） |
| rules | command guard 専用（`.rules`、`allow` / `forbidden`） | 短い prose rule。`coding-standards` は常時 load、`docs-artifacts` / `harness-surface-consistency` / `vba` は path 条件付き |
| runtime config | `~/.codex/config.toml`（Codex app が書き換えるため source 管理しない。意図した設定値は下記「runtime config の扱い」に列挙） | `settings.json.tmpl`（model `claude-opus-5`、effortLevel `high`、permissions / sandbox / env） |

## runtime config の扱い

- Date: 2026-07-30
- 出典: 実機 `~/.codex/config.toml` / [Codex Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents) / [Codex Config Reference](https://learn.chatgpt.com/docs/config-file/config-reference)

- Codex の `~/.codex/config.toml` は source 管理しない。Codex app 自身が `marketplaces.last_updated` / `projects` / `desktop` / `mcp_servers` を書き換えるため、chezmoi 側の template は追随できない。実際に source（`dot_codex/private_config.toml.tmpl`、model `gpt-5.5` / effort `medium`）と実機（model `gpt-5.6-sol` / effort `high`、plugin 構成も差異）が乖離し、「参照用 source」が誤情報になっていたため template を廃止した。値の正本は実機 config とする。
- 捨てた案: (1) 参照用 source として残し実機へ手動同期 — 同期漏れが再発する。(2) 配布対象へ戻す — app 側の書き込みと衝突する。
- ADR は書かない。複数案を実比較した判断だが、削除は git から復元でき影響も harness 内部に閉じるため「覆すコストが高い」を満たさない。判断と捨てた案はこの notes に残す。
- `[agents] max_depth` は公式の設定キーに存在しない。公式 `[agents]` は `enabled` / `max_concurrent_threads_per_session` / `default_subagent_model` / `default_subagent_reasoning_effort` / `interrupt_message` で、`max_threads` は `max_concurrent_threads_per_session` の legacy alias。ADR 0020 が「深さを制御する設定」として挙げた `max_depth` は効いていない前提で読む。nested spawn を抑える実効は `dot_codex/AGENTS.md` の「lead が仲介する」契約だけ。
- Claude の `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"` は experimental flag。lead が subagent を束ねる運用を有効にするために置いている。公式 docs に記載のない flag なので、廃止や改名で黙って挙動が変わり得る。subagent 周りの挙動が変わったらこの行を疑う。
- Claude の `env.CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` は 2026-08-05 に削除した。permission mode を `default` に強制して auto mode を無効化するため。経緯と代替の防御層は [claude-code-permission-policy.md](./claude-code-permission-policy.md)。

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

進行ガイドの正本は各 surface の `dot_codex/AGENTS.md` / `dot_claude/CLAUDE.md`。発火条件・掘り下げ 4 条件 AND・ADR 3 条件 AND・doc 3 層 silent skip 禁止・review 明示時のみ・停止線などは正本側を参照する。本 note は両 surface の構成差分と、ADR 3 条件を満たさない harness 判断の記録を扱う。

## 両 surface の意図的差分

両 surface とも軽量 LLM-native だが、各 runtime 固有の差は残る。

| 観点 | Codex | Claude |
| --- | --- | --- |
| agent 間通信 | 直接通信なし、lead 仲介、handoff 出力 | direct subagent spawn（standing authorization 済み） |
| 方針工程 | 会話ベース承認 | `EnterPlanMode` 自己発動 + 承認 |
| `rules/` の責務 | command guard 専用（公式仕様） | 行動指針も可。常時 load と path 条件付きを rule ごとに選べる |
| prose 行動指針の置き場 | `AGENTS.md` 集約 | `rules/` 分離 |
| 行動指針の発火範囲 | `AGENTS.md` は常時 load | `coding-standards` は `paths` を外して常時 load（下記「coding-standards を常時 load にした判断」）。他の rule は path 条件付き |
| 出力スタイル | `caveman` skill | `caveman` output-style |
| reviewer の read-only 強制 | `sandbox_mode = "read-only"` + `rules/*.rules` で read-only git allow | `tools: Read, Glob, Grep, Bash` + Claude Code built-in read-only command（read-only forms of git 等） + session 全体の既存 deny rule |
| reviewer の明示 diff fallback | `git status -sb` / `git diff` / `git diff --staged` / untracked content（`git status -sb` の `??` 行から特定）を sandbox 内 read-only git で取得（`rules/git-status.rules` / `git-diff.rules` の allow と整合） | 同左を built-in read-only git で取得（ADR 0038 で対称化） |

## coding-standards を常時 load にした判断

- Date: 2026-08-27
- 出典: [Claude Code / How Claude remembers your project](https://code.claude.com/docs/en/memory) / [Codex / Custom instructions with AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)

`dot_claude/rules/coding-standards.md` の `paths`（`**/src/**` / `**/app/**` / `**/lib/**` / `**/packages/**` / `**/test/**` / `**/tests/**` / `**/spec/**` / `**/scripts/**` / `**/tools/**`）を削除し、常時 load へ変更した。

- **Codex 側は絞れない。** 公式仕様上 `AGENTS.md` に glob / path scoping は無く、`~/.codex/AGENTS.md` は常時 load。Codex の常時適用は設計選択ではなく唯一の選択肢。対称化の方向は「Claude を常時へ寄せる」しかない。
- **中身の大半がコード限定でない。** 品質の優先順位 / 適用の参照順 / 基本原則 / 最小差分（計 22 行）は `settings.json`、`AGENTS.md`、`docs/` の編集にも効く。コード限定は可読性の具体とコメントの約 10 行だけ。従来の path 条件はこの 22 行を巻き添えで無効化していた。
- **path 条件の穴。** `cmd/` / `internal/` / `pkg/` / `apps/` / repo 直下のコードが漏れる。`paths` を外せばこの穴は構造的に消える。
- ~~発火条件の不確実性~~（**2026-08-27 に否定**）。当初「auto mode で `cat` / `sed` を主経路にすると Read tool を通らず path 条件付き rule が発火しない可能性がある」を論拠の 1 つに挙げたが、実測で誤りと判明した。Read tool を一度も使わないセッションでも `docs-artifacts` / `harness-surface-consistency` は context へ注入された。`InstructionsLoaded` hook でも `coding-standards` が `session_start` で load されることを確認済み。**path 条件付き rule は正常に発火する**ため、残る 3 本は path 条件付きのまま維持する。この論拠は失効したが、上記の他の論拠で判断は変わらない。
- **実測。** 2026-08-27 に read-only subagent をこの repo で起動した際、配布済みの旧 `coding-standards`（`paths` 付き）は context へ注入されず、`docs-artifacts` / `harness-surface-consistency`（同じく `paths` 付きだが、subagent が読んだファイルに match する）は注入された。「この repo の layout では load されない」という主張の実地確認になる。ただし Read tool 経由の観測で、`cat` / `sed` 経路の不確実性は解消していない。
- **節約量が誤差。** 変更後に常時 load されるのは `CLAUDE.md` 68 行と `coding-standards.md` 35 行の 2 ファイル（他 3 rule は path 条件付きのまま）。公式目安は 1 ファイル 200 行未満で、どちらも大きく下回る。

捨てた案:

- **常時適用部（22 行）と コード限定部（10 行）へ 2 ファイル分割**: 10 行の節約のために、path 条件の穴の再生産、Codex（品質節 1 枚）との構造非対称、共有 note 1 箇所（本 note の構成表）の追従、上記の発火条件不確実性への依存を買うことになる。コード限定部が大きく育った時に再検討する。
- **現状維持（path 条件付き）**: 上記のとおり、この repo を含む多くの layout で最小差分規範ごと沈黙する。

ADR は書かない。3 条件のうち「覆すコストが高い」を満たさない（frontmatter の削除で、git から復元でき影響は harness 内部に閉じる）。

常時 load 化で、共通契約（`CLAUDE.md` / `AGENTS.md` の「実装・編集は最小直線で始める。共通化、抽象化、helper、設定層、新依存は実害が出てから入れる。」）と品質規範（YAGNI / 予防的抽象化を避ける）の重複が全セッションで顕在化した。共通契約側を「実装・編集は最小直線で始める。」へ短縮し、判断基準は品質規範へ一本化した。`helper` / `設定層` は予防的抽象化の例示へ移し、`新依存` は停止線（新しい依存は確認して止まる）が上位互換で受けるため移さない。

この一本化により、Claude 側で削った共通契約の受け皿は `coding-standards.md` **のみ**になった。将来この rule に `paths` を戻すなら、共通契約側の記述も同時に復元する。片方だけ戻すと規範が全セッションから黙って消える。

## 品質規範を名前ベースから判断基準ベースへ変えた

- Date: 2026-08-27

上記と同じ変更単位で入れたが、常時 load 化とは独立した変更。両 surface 対称に適用した。

- **優先順位から「短さ・巧妙さ」を外した。** priority list に載せると「上位を損なわない範囲で巧妙さを追求してよい」と読める。巧妙さは可読性の敵で品質目標ではないため、「短さと巧妙さは目標にしない」と否定形へ改めた。`DRY` は「性能より下」という位置情報が有用なため list に残した。
- **命名の汎用語リストから `handler` / `process` を外した。** HTTP handler / event handler は framework が定義する確立した語で、`data` / `tmp` と同列に禁じると誤爆する。例外の根拠は「近傍実装で使われている」ではなく「framework が定義する語である」に絞った。前者だと「この repo は既に `helpers/` を使っている」でリスト全体を無効化でき、かつ近傍実装との一貫性は「適用の参照順」の第 2 位で既に受けているため二重の緩和になる。
- **予防的抽象化の禁止列挙から `Provider` / `Manager` を外し、例示化した。** React の Provider や Nest / Spring の DI container は framework 規約が要求する構造で、自作の間接層とは別物。逆に素の Node / Python で自作する DI container はこの規範が止めたい典型なので、例示は framework 名まで具体化した。
- `manager` が命名リストに残り `Manager` が抽象化リストから外れたのは整合する。命名 rule は識別子の曖昧さ、抽象化 rule は間接層の早期導入と、対象軸が違う。

[ADR 0035](../adr/0035-make-claude-surface-lightweight-llm-native.md) が本文に記録した優先順位「…→ DRY → 短さ」の末尾「短さ」は、本変更で外した。ADR 本文は履歴として書き換えない（ADR 0022）。

## 契約と skill の摩擦を減らした判断

- Date: 2026-08-27
- 出典: [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) / [Agent Skills best practices](https://agentskills.io/skill-creation/best-practices) / この repo の commit 実績

実測で欠陥が確定していた分（別記の常時 load 化と記録の是正）とは別に、運用して摩擦になる箇所を 3 件だけ直した。検討したが**見送った 2 件**も、同じ検討を繰り返さないために残す。

### 実施

- **commit の `<type>` 集合を `SKILL.md` へ明記。** Conventional Commits は `feat` / `fix` 以外の type を自由にしており（規格 clause 14）、skill 側も集合を決めていなかったため、commit ごとに語が揺れていた。この repo の実績 9 種（`docs` / `chore` / `feat` / `fix` / `refactor` / `style` / `revert` / `perf` / `build`）に `test` / `ci` を足した 11 種に固定。配置は `references/` でなく `SKILL.md` 本体で、公式の「毎回必要な内容は本体に置く」に従う。集合を絞るのは repo 側の選択で、規格違反ではない。
- **停止線を判定可能な形へ。** 「公開インターフェースに影響する」は文字通り読むと新規関数 1 本でも停止するため、「変更・削除する」+「後から変えると外部を壊すもの（公開 API、永続化 schema、CLI 引数、設定キー）は新規でも含む」に置き換え、判定を 1 問へ集約した。「大きな設計変更」も主観語だったため、例示（module 境界の移動、data flow の作り直し、framework / library の入れ替え）で閾値を示す形にした。
- **共通契約へ 1 行。** 「設定や防御は、実測で効いていることを確認するまで有効な層として数えない。」 本 note の他の項目で記録した失敗（allowlist を防御層として数えていた、`Agent` allow が既定 mode で死んでいた、path rule の発火を推測で断じた）は、すべてこの 1 行で防げた。

### 見送り: root `AGENTS.md` の URL 表を notes へ移す

契約側 45 行（うち URL 37 行）を `docs/notes/` へ移し、契約には参照義務と index リンクだけ残す案。**見送った。**

- 効果は**この repo のセッション限定**で約 40 行。root `AGENTS.md` は `.chezmoiignore` で配布対象外のため、他 project の常時 load はもともと増えていない。
- 一方この表は 2026-08-27 の作業で実際に機能した。Codex に path scoping が無いこと、in-process tool が sandbox の対象外であること、auto mode の allow drop 対象リスト — いずれも表から正しいページへ辿って確認できた。記憶で答えていれば誤っていた。
- 移すと indirection が 1 段増え、index を読まずに済ませる経路ができる。**40 行の節約と引き換えに参照義務の実効を賭けることになる**ため、割に合わないと判断した。
- 再検討の条件: 表が肥大して契約本文が読めなくなった時。その場合も「表は残して重複した導入文だけ削る」を先に試す。

### 見送り: commit の `scope` 禁止を緩める

「repo 規約が scope を要求する場合は停止して報告する」を「その規約に従う」へ緩める案。**保留。**

- この repo の 368 commit で scope 付きは **0 件**。実害が観測されていない。
- skill は user-global なので monorepo では摩擦があり得るが、それは想定であって実測ではない。今日の作業方針（実測で裏が取れた分だけ直す）に照らして先送りする。
- 再検討の条件: 実際に monorepo で「停止して報告」に当たった時。

## 廃止したもの

両 surface で同じ集合を廃止した（Claude 側は ADR 0035 で先行、Codex 側は ADR 0036 で対称化）:

- skill: `orchestrate` / `grill` / `research` / `architecture` / `implement` / `inspect` / `doc-followup`
- agent: `inspector` / `requirements-reviewer` / `design-reviewer`
- 体系: request folder（`docs/requests/<slug>/`）の工程 doc、`REQ-*` / `AC-*` / `BD-*` / `DD-*` / `TASK-*` / `TC-*` traceability ID、tier / Phase / Gate、`orchestrate` 必須入口

## 共有 note との整合

`runtime-surface-guidance.md` / `harness-regression-checks.md` / `harness-design-principles.md` は ADR 0035 時点では Codex 重 SDLC を Codex 側でだけ有効な前提として保持していた。ADR 0036 で Codex も軽量化したため、これら共有 note の重 SDLC 前提は両 surface とも無効になった。本文は履歴として保持し（ADR 0022）、各 note の scope banner で「現行は両 surface 軽量、詳細は本 note を参照」と示す。共有 note 全面 bilateral 書き換えは churn 大のため deferred。

`claude-code-permission-policy.md` の `Agent(...)` allow 例外は維持（read-only subagent の standing authorization）。
