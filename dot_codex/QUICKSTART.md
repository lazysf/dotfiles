# Codex QUICKSTART

日常のバイブコーディングで毎回迷わないための、最小のチートシートです。
正式ルールは [AGENTS.md](./AGENTS.md)、詳しい実務ガイドは [docs/workflow-guide.md](./docs/workflow-guide.md)、共通運用 docs の入口は [docs/README.md](./docs/README.md) を参照してください。
この文書のレーンは入口選択の目安であり、正式な順序や shorthand の意味定義は `AGENTS.md` を優先します。

## 3つの依頼レーン

### 1. 小さな修正

- 対象: 単一ファイル中心の修正、軽微な設定変更、局所的な不具合修正
- 開始点: `task-intake`
- 追加判断: 近傍探索は `workspace-intake`、実装は `coding-standards`、検証は必要に応じて `test-runner`

### 2. 探索多めの相談

- 対象: 背景が散らばっている相談、先に要件整理したい依頼
- 開始点: `request-shaping`
- 追加判断: 入口整理は `task-intake`、探索は `workspace-intake`、要件が重ければ `plan-product`

### 3. 大きめ変更

- 対象: 複数ファイル変更、段階的に確認しながら進めたい作業
- 開始点: `task-intake`
- 追加判断: 依頼が散らばっている場合のみ `request-shaping` を先頭に置き、要件整理が必要なら `plan-product`、長めなら `session-orchestrator`、技術計画が必要なら `plan-architect`

## 最初の頼み方

- 具体的なら、そのまま依頼してよい
- 情報が散らばっているなら、最初に `request-shaping` を使ってよい
- `目的 / 背景・事実 / 制約 / 完了条件 / 非目的` は推奨の整理軸であり、全部そろっていなくてもよい
- 既存挙動変更、公開インターフェース、永続化、認証認可、秘密情報、破壊的操作に触れそうなら、最初にその点を明示する

## Shorthand

- 短く頼むなら `review-quality でレビューして`
- shorthand の正式な意味と省略規則は [AGENTS.md](./AGENTS.md) の `レビュー方針` を参照する

## 詳細を読む先

- 全体ルール: [AGENTS.md](./AGENTS.md)
- 実務ガイド: [docs/workflow-guide.md](./docs/workflow-guide.md)
- 共通 docs: [docs/README.md](./docs/README.md)
- 利用可能な skills: [skills/](./skills/)
