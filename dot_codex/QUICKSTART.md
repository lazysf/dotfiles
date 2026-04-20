# Codex QUICKSTART

日常のバイブコーディングで毎回迷わないための、最小のチートシートです。
考え方や詳しい例は [HIGH_QUALITY_VIBE_CODING.md](./HIGH_QUALITY_VIBE_CODING.md)、全体ルールは [AGENTS.md](./AGENTS.md) を参照してください。
フローや停止線の正式な定義は `AGENTS.md` を優先します。

## 3つの依頼レーン

### 1. 小さな修正

- 対象: 単一ファイル中心の修正、軽微な設定変更、局所的な不具合修正
- 基本レーン: `task-intake → workspace-intake → coding-standards → test-runner`

### 2. 探索多めの相談

- 対象: 背景が散らばっている相談、先に要件整理したい依頼
- 基本レーン: `request-shaping → task-intake → workspace-intake → 必要なら plan-product`

### 3. 大きめ変更

- 対象: 複数ファイル変更、段階的に確認しながら進めたい作業
- 基本レーン: `request-shaping → task-intake → workspace-intake → plan-product → session-orchestrator または plan-architect → coding-standards → test-runner → change-review`
- 品質レビューが必要なら: `... → test-runner → review-quality agent → change-review`
- セキュリティレビューが必要なら: `... → test-runner → review-security agent → change-review`
- 両方必要なら: `... → test-runner → review-quality agent / review-security agent → change-review`

## 最初の頼み方

- 具体的なら、そのまま依頼してよい
- 情報が散らばっているなら、最初に `request-shaping` を使ってよい
- `目的 / 背景・事実 / 制約 / 完了条件 / 非目的` は推奨の整理軸であり、全部そろっていなくてもよい
- `request-shaping` は不足項目を会話から補い、重要な未確定事項だけを残す
- 既存挙動変更、公開インターフェース、永続化、認証認可、秘密情報、破壊的操作に触れそうなら、最初にその点を明示する

## Shorthand

- 短く頼むなら `review-quality でレビューして`
- この shorthand は既定で `review-quality agent → change-review` を意味し、`review-security` でも同様です
- review agent はレビュー本体、`change-review` は人間向けの出口整理を担当します
- raw JSON / 生出力が必要な場合だけ、`change-review` の省略を明示します

## 詳細を読む先

- 全体ルール: [AGENTS.md](./AGENTS.md)
- 実務ガイド: [HIGH_QUALITY_VIBE_CODING.md](./HIGH_QUALITY_VIBE_CODING.md)
- 依頼の整形: [request-shaping](./skills/request-shaping/SKILL.md)
- 入口整理: [task-intake](./skills/task-intake/SKILL.md)
- 探索の足場固め: [workspace-intake](./skills/workspace-intake/SKILL.md)
- 要件整理: [plan-product](./skills/plan-product/SKILL.md)
- 環境点検: [environment-audit](./skills/environment-audit/SKILL.md)
- 長い作業の進行整理: [session-orchestrator](./skills/session-orchestrator/SKILL.md)
- 実装の品質基準: [coding-standards](./skills/coding-standards/SKILL.md)
- 出口整理: [change-review](./skills/change-review/SKILL.md)
