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
