# Harness Design Principles

> **Scope**: 「6. workflow と review」「7. agent の model 設定」の `orchestrate` / `doc-followup` 前提は Codex surface の記述。Claude surface は ADR 0035 で軽量 workflow へ再設計され、これらの skill を持たない。Claude surface の現行構成は [claude-lightweight-workflow.md](./claude-lightweight-workflow.md) を正本にする。

この文書は、この dotfiles repo で Codex / Claude Code ハーネスを保守するときの repo-level knowledge をまとめたものです。
`dot_codex/` や `dot_claude/` に置く runtime surface source そのものではなく、保守元 repo で参照する設計原則と採用方針を扱います。

## 基本原則

- runtime surface source は `dot_codex/` と `dot_claude/` に置き、repo-level knowledge は `docs/` に置く
- project-specific knowledge は各 project の `docs/` を正本にする
- multi-context repo では root `CONTEXT-MAP.md` を入口にし、各 `CONTEXT.md` は対象 context の近くに置く
- 知見は `CONTEXT.md`, `docs/notes/`, `docs/adr/`, `skills/`, `rules/`, `agents/` のどこへ置くかを分ける
- defaults は明確な効果と回帰検証なしに大きく動かさない
- preview / unstable feature は安易に既定採用しない
- 破壊的操作や外部影響のある操作は allow しない。高リスク操作は `forbidden` rule、その他の mutation は既定 prompt と skill 停止線に任せる

## この repo で優先すること

- まず repo-level knowledge として調査結果や運用知見を `docs/` に残し、その後で `dot_codex/` / `dot_claude/` に昇格すべきものだけを選ぶ
- `dot_codex/` / `dot_claude/` の managed surface には、展開後にも価値があり、workspace 横断で再利用するものだけを置く
- 大きな runtime surface の追加よりも、docs、inspect、rules、skills の整合を優先する
- prefix 付きの workflow 名を増やすより、各 skill の発火条件と説明を揃えることを優先する

## 採用している考え方

### 1. `AGENTS.md` は長文知識の正本ではなく契約と薄い surface 案内を置く

- `dot_codex/AGENTS.md` と `dot_claude/CLAUDE.md` は、共通ハーネスの運用契約と薄い runtime surface 案内を扱う
- repo-level の詳しい背景や判断理由は `docs/notes/` や `docs/adr/` に分ける
- `AGENTS.md` の責務境界や導線設計の詳細は、関連 ADR や surface 文書を正本にする

### 2. knowledge は runtime surface ごとに昇格先を分ける

- 通常知見は `docs/notes/`
- 判断記録は `docs/adr/` の状態付き ADR 台帳として置く
- context 固有の用語は `CONTEXT.md` に置く
- 繰り返し使う手順は `dot_codex/skills/` または `dot_claude/skills/`
- 機械的に守らせたい制約は `dot_codex/rules/`、Claude Code の path 条件付き運用ルールは `dot_claude/rules/`
- 調査・検証 specialist、reviewer などの専門 role は `dot_codex/agents/` または `dot_claude/agents/`

### 2.5. ADR は状態付き台帳として扱う

- ADR は通常知見ではなく、採用された判断とその履歴関係の正本として扱う
- ADR 本文は軽量でよいが、状態は必ず持つ
- 方針変更や既存判断の補正は既存 ADR 本文を上書きせず、新規 ADR と状態・関係メタデータで履歴として残す
- ADR は、あとから変えにくく、文脈なしでは驚きがあり、実際の trade-off がある判断だけに使う
- 新規 ADR の作成と、既存 ADR の状態更新は同じ知見蓄積 workflow 内でも別 action / 別判断境界として扱う
- `Accepted` のタイミングや知見蓄積の具体契約は ADR 台帳の運用文書を正本にする

### 3. defaults は大きく動かさない

- 既定 model、approval、sandbox などは、整理や見直しのたびに動かす対象にしない
- 主目的が構造整理や運用導線の整備である場合は、まず docs と inspect を固める
- 既定値を変えるときは、変更理由と回帰確認の観点をセットで残す

### 4. unstable feature は既定採用しない

- preview や開発中の機能は、将来性だけで既定採用しない
- docs、rules、inspect で安定してカバーできる範囲を優先する
- 新機能の採用は、安定性と運用効果が確認できた時点で別判断にする

### 5. prose だけで腐敗しやすいルールは将来の昇格候補として扱う

- 単発の説明で十分なものは `docs/` に残す
- 何度も繰り返す手順は `skills/` への昇格を検討する
- 機械的に止めたい操作は `rules/` を優先する
- 調査・検証 specialist、reviewer などの定型的な専門 role は `agents/` に分ける

### 6. workflow と review は agent-first の明示選択で扱う

- multi-agent workflow や review 種別の選択責務を prose の暗黙挙動へ逃がさず、surface で明示する
- workflow の進行は `orchestrate` skill と specialist agent 定義を正本にする
- 実装後の repo hygiene / docs / tooling 設定の仕上げは lead が `doc-followup` skill を使って行い、ユーザー確認を含めて lead が一貫して担う
- review 本体は reviewer agent が担い、結果の見せ方も agent 定義内で人間向けに調整する
- 具体的な reviewer 名や review 導線は surface 文書と agent 定義を正本にする

### 7. agent の model 設定は agent 定義を正本にする

- specialist agent の model tier や reasoning effort は、agent 定義で明示する
- agent の調整は、対象 role の責務と実行コストに照らして行う
- 具体的な model 設定や agent ごとの既定値は agent 定義を正本にし、全体既定は現行 runtime config または config template で確認する

## 関連文書

- [dot_codex/AGENTS.md](../../dot_codex/AGENTS.md)
- [dot_claude/CLAUDE.md](../../dot_claude/CLAUDE.md)
- [ADR Ledger Model](./adr-ledger-model.md)
- [Runtime Surface Guidance](./runtime-surface-guidance.md)
- [Harness Regression Checks](./harness-regression-checks.md)
- [ADR 0001](../adr/0001-common-codex-harness-lives-in-dot_codex.md)
- [ADR 0002](../adr/0002-project-specific-knowledge-lives-in-project-docs.md)
- [ADR 0003](../adr/0003-promote-harness-knowledge-by-runtime-surface.md)
- [ADR 0004](../adr/0004-retire-legacy-workflow-prefixes.md)
- [ADR 0005](../adr/0005-keep-harness-verification-focused-on-repo-contracts.md)
- [ADR 0006](../adr/0006-keep-agents-thin-and-surface-oriented.md)
- [ADR 0007](../adr/0007-retire-harness-verifier-script.md)
- [ADR 0008](../adr/0008-keep-git-operation-surface-minimal.md)
- [ADR 0009](../adr/0009-adopt-context-aware-upstream-planning.md)
- [ADR 0011](../adr/0011-prune-codex-skill-and-reviewer-surface.md)
- [ADR 0023](../adr/0023-add-doc-followup-skill.md)
- [ADR 0024](../adr/0024-add-repository-maintainer-agent.md)
- [ADR 0034](../adr/0034-reduce-non-reviewer-agents.md)
