# Harness Design Principles

この文書は、この dotfiles repo で Codex ハーネスを保守するときの repo-level knowledge をまとめたものです。
`dot_codex/` に置く deployable artifact そのものではなく、保守元 repo で参照する設計原則と採用方針を扱います。

## 基本原則

- deployable artifact は `dot_codex/` に置き、repo-level knowledge は `docs/` に置く
- project-specific knowledge は各 project の `docs/` を正本にする
- 知見は `docs/knowledge/`, `docs/adr/`, `skills/`, `rules/`, `agents/` のどこへ置くかを分ける
- defaults は明確な効果と回帰検証なしに大きく動かさない
- preview / unstable feature は安易に既定採用しない
- 破壊的操作や外部影響のある操作は allow ではなく prompt / forbidden を基本にする

## この repo で優先すること

- まず repo-level knowledge として調査結果や運用知見を `docs/` に残し、その後で `dot_codex/` に昇格すべきものだけを選ぶ
- `dot_codex/` には、展開後にも価値があり、workspace 横断で再利用するものだけを置く
- 大きな runtime surface の追加よりも、docs、verification、rules、skills の整合を優先する
- 旧導線 wrapper を増やすより、`core-*` の発火条件と説明を揃えることを優先する

## 採用している考え方

### 1. `AGENTS.md` は長文知識の正本ではなく契約と導線を置く

- `dot_codex/AGENTS.md` は、共通ハーネスの運用契約と開発フローの surface を扱う
- repo-level の詳しい背景や判断理由は `docs/knowledge/` や `docs/adr/` に分ける
- project 側では、root `AGENTS.md` を短いポインタとして使い、詳細は project の `docs/` に寄せる

### 2. knowledge は runtime surface ごとに昇格先を分ける

- 通常知見は `docs/knowledge/`
- 判断記録は `docs/adr/`
- 繰り返し使う手順は `dot_codex/skills/`
- 機械的に守らせたい制約は `dot_codex/rules/`
- read-only の専門化した補助役は `dot_codex/agents/`

### 3. defaults は大きく動かさない

- 既定 model、approval、sandbox などは、整理や見直しのたびに動かす対象にしない
- 主目的が構造整理や運用導線の整備である場合は、まず docs と verification を固める
- 既定値を変えるときは、変更理由と回帰確認の観点をセットで残す

### 4. unstable feature は既定採用しない

- preview や開発中の機能は、将来性だけで既定採用しない
- docs、rules、verification で安定してカバーできる範囲を優先する
- 新機能の採用は、安定性と運用効果が確認できた時点で別判断にする

### 5. prose だけで腐敗しやすいルールは将来の昇格候補として扱う

- 単発の説明で十分なものは `docs/` に残す
- 何度も繰り返す手順は `skills/` への昇格を検討する
- 機械的に止めたい操作は `rules/` を優先する
- reviewer などの定型的な read-only の見立ては `agents/` に分ける

## 関連文書

- [Classification-Driven Workflow Surface](./classification-driven-workflow-surface.md)
- [Harness Regression Checks](./harness-regression-checks.md)
- [ADR 0001](../adr/0001-common-codex-harness-lives-in-dot_codex.md)
- [ADR 0002](../adr/0002-project-specific-knowledge-lives-in-project-docs.md)
- [ADR 0003](../adr/0003-promote-harness-knowledge-by-runtime-surface.md)
