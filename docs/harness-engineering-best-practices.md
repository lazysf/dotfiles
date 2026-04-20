# ハーネスエンジニアリングのベストプラクティス

この文書は、この dotfiles repo で Codex ハーネスを保守するときの repo-level 知識をまとめたものです。
展開後にも日常参照する運用ガイドは `dot_codex/` 側に置き、この文書は保守元 repo の判断材料として扱います。

## 参考にした一次情報

- [OpenAI: Safety in building agents](https://developers.openai.com/api/docs/guides/agent-builder-safety)
- [OpenAI: Evaluate agent workflows](https://developers.openai.com/api/docs/guides/agent-evals)
- [OpenAI: Using GPT-5.4](https://developers.openai.com/api/docs/guides/latest-model)
- [OpenAI: Codex agent internet access](https://developers.openai.com/codex/cloud/internet-access)
- [Anthropic: Building effective agents](https://www.anthropic.com/engineering/building-effective-agents)
- [Anthropic: Writing effective tools for agents](https://www.anthropic.com/engineering/writing-tools-for-agents)
- [Anthropic: Subagents](https://code.claude.com/docs/en/sub-agents)
- [affaan-m/everything-claude-code: README](https://raw.githubusercontent.com/affaan-m/everything-claude-code/main/README.md)
- [affaan-m/everything-claude-code: AGENTS.md](https://raw.githubusercontent.com/affaan-m/everything-claude-code/main/AGENTS.md)
- [affaan-m/everything-claude-code: WORKING-CONTEXT.md](https://raw.githubusercontent.com/affaan-m/everything-claude-code/main/WORKING-CONTEXT.md)
- [逆瀬川ちゃん: Claude Code / Codex ユーザーのための誰でもわかるHarness Engineeringベストプラクティス](https://nyosegawa.com/posts/harness-engineering-best-practices-2026/)

## 要点

| 原則 | この repo への解釈 | 反映先 |
| --- | --- | --- |
| 安全なツール運用を既定にする | 破壊的操作や外部接続は allow ではなく prompt/forbidden を基本にし、`approval_policy = "on-request"` を維持する。 | `dot_codex/rules/`, `dot_codex/private_config.toml.tmpl`, `dot_codex/docs/rules.md` |
| untrusted input を強い指示層へ直接混ぜない | 外部調査や repo 外知識は、まず事実として切り出し、運用規約や設定変更へ直接流し込まない。 | `dot_codex/AGENTS.md`, `dot_codex/agents/`, `docs/harness-regression-scenarios.md` |
| eval 駆動で改善する | 初回は重い自動評価基盤を作らず、代表シナリオを手動回帰セットとして維持する。 | `docs/harness-regression-scenarios.md`, `dot_codex/docs/verification.md` |
| tool / agent の説明は明示的にする | agent 定義や docs は「何をするか」「何をしないか」「どう返すか」を短く固定する。 | `dot_codex/agents/`, `dot_codex/docs/knowledge-promotion.md` |
| focused な再利用単位を優先する | 汎用の巨大 agent や長文 runbook ではなく、繰り返す判断だけを skill / agent / rule に昇格する。 | `dot_codex/skills/`, `dot_codex/agents/`, `docs/adr/0005-promote-harness-knowledge-by-runtime-surface.md` |
| knowledge は責務ごとに分離する | repo-level の保守知識は root `docs/`、deployable な共通運用 docs は `dot_codex/docs/`、project-specific knowledge は project 側 `docs/` に分ける。 | `README.md`, `AGENTS.md`, `dot_codex/docs/project-integration.md`, `docs/adr/` |
| サブエージェントは狭い責務で使う | review のような定型探索や一次情報調査は read-only agent に閉じ込め、メイン文脈を汚さない。 | `dot_codex/agents/` |
| tool surface は狭く保つ | 初回では `max_depth = 1`、既定 model、approval policy を変えず、docs と検証導線を先に整える。 | `dot_codex/private_config.toml.tmpl`, `docs/adr/0003-keep-gpt-5-4-as-default.md`, `docs/adr/0004-do-not-adopt-codex-hooks-yet.md` |

## この repo で優先すること

- まず repo-level の知見として調査結果を残し、その後で `dot_codex/` に入れるべきものだけを昇格する。
- `dot_codex/` には deployable で、展開後にも価値があるものだけを置く。
- 初回の改善では defaults を大きく動かさず、docs・agent・検証導線の明確化を優先する。

## 外部調査から今回採用する repo-level 原則

### 1. `AGENTS.md` は長文知識の正本ではなくポインタとして使う

- 外部ソースの示唆:
  - `everything-claude-code` は knowledge capture を project docs に寄せ、逆瀬川ちゃんの記事も `AGENTS.md` / `CLAUDE.md` をポインタとして設計する方針を示している。
- この repo での解釈:
  - `<project>/AGENTS.md` は短い project-local ポインタとして使い、詳細な知識は project 側 `docs/` に寄せる。
  - この repo の root `AGENTS.md` は、この dotfiles repo における Codex 設定の目的と、repo-level の知識置き場を案内する文書として扱う。
  - `dot_codex/AGENTS.md` は、共通ハーネスの運用契約と正式フローの正本として扱い、長い背景説明や調査メモは持ち込まない。
- 現時点の反映先:
  - `AGENTS.md`
  - `dot_codex/AGENTS.md`
  - `README.md`
  - `dot_codex/docs/project-integration.md`
- 今回は採用しないもの:
  - `AGENTS.md` を大きく書き換えて短文化すること自体は今回のスコープに含めない。
  - 外部 repo の command catalog や workflow surface をそのまま移植しない。

### 2. repo-level の恒久知識と短命な execution state を分離する

- 外部ソースの示唆:
  - `everything-claude-code` の `WORKING-CONTEXT.md` は current sprint 用の短期コンテキストを扱い、完了済みの内容は archive や repo docs へ要約する運用を取っている。
  - 逆瀬川ちゃんの記事も、セッション間の引き継ぎでは Git 履歴や進捗ファイルを使い、恒久知識と区別する前提を置いている。
- この repo での解釈:
  - root `docs/` に残すのは、この repo を保守する判断材料、回帰シナリオ、ADR のような恒久知識だけに絞る。
  - セッション進捗、実験途中のメモ、短命なタスクリストは root `docs/` の正本にせず、必要なら issue / PR / Git 履歴や一時ファイルで扱う。
- 現時点の反映先:
  - `docs/harness-engineering-best-practices.md`
  - `docs/harness-regression-scenarios.md`
  - `docs/adr/0005-promote-harness-knowledge-by-runtime-surface.md`
  - `dot_codex/docs/knowledge-promotion.md`
- 今回は採用しないもの:
  - `WORKING-CONTEXT.md` 相当の新しい top-level 進捗ファイルは追加しない。
  - セッション状態を自動保存する hooks や state store の導入は行わない。

### 3. 大規模ハーネスを丸ごと模倣せず、責務分離に効く原則だけ採る

- 外部ソースの示唆:
  - `everything-claude-code` は agent、skill、rule、hook、state 管理を広く持つ大規模ハーネスで、参考になるのは表面積の大きさよりも knowledge capture の停止線と責務分離である。
  - 逆瀬川ちゃんの記事も、platform 固有機能を理解しつつ、無条件に最大構成へ寄せるのではなく、計画と実行の分離や docs の腐敗耐性を重視している。
- この repo での解釈:
  - この repo では root `docs/`、`dot_codex/docs/`、`skills`、`rules`、`agents` の責務を維持し、必要な原則だけを拾う。
  - 改善は docs と回帰導線を先に整え、表面積を増やす変更は別判断に分ける。
- 現時点の反映先:
  - `README.md`
  - `docs/adr/0005-promote-harness-knowledge-by-runtime-surface.md`
  - `dot_codex/docs/knowledge-promotion.md`
  - `dot_codex/docs/README.md`
- 今回は採用しないもの:
  - 外部 repo の hooks、commands、state infrastructure、catalog 数を追従目標にしない。
  - `dot_codex/` の runtime surface を一括拡張しない。

### 4. prose だけで腐敗しやすいルールは、将来の昇格候補として扱う

- 外部ソースの示唆:
  - 逆瀬川ちゃんの記事は、ドキュメントだけでは守られにくいルールを lint / hook / executable check に寄せること、ADR と実行可能ルールを対応づけることを勧めている。
  - `everything-claude-code` も knowledge capture を docs と workflow surface に分け、繰り返し守らせたいことを rules や skills に持たせている。
- この repo での解釈:
  - まず root `docs/` と `docs/adr/` に repo-level の判断理由を残し、反復して破られるルールだけを `dot_codex/docs/`、`skills/`、`rules/`、`agents/` のどこへ昇格するか判断する。
  - docs に書いただけで十分なものと、機械的ガードへ昇格すべきものを混同しない。
- 現時点の反映先:
  - `docs/adr/0005-promote-harness-knowledge-by-runtime-surface.md`
  - `dot_codex/docs/knowledge-promotion.md`
  - `docs/harness-regression-scenarios.md`
  - `dot_codex/rules/`
- 今回は採用しないもの:
  - `docs/adr/0004-do-not-adopt-codex-hooks-yet.md` は上書きしない。
  - hooks や追加ルールの導入は、必要な失敗パターンが溜まるまで再判断候補として扱う。
