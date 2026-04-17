# Codex QUICKSTART

日常のバイブコーディングで毎回迷わないための、最小のチートシートです。
考え方や詳しい例は [HIGH_QUALITY_VIBE_CODING.md](./HIGH_QUALITY_VIBE_CODING.md)、全体ルールは [AGENTS.md](./AGENTS.md) を参照してください。

## 3つの依頼レーン

### 1. 小さな修正

- 対象: 単一ファイル中心の修正、軽微な設定変更、局所的な不具合修正
- 基本レーン: `task-intake → workspace-intake → coding-standards → test-runner`

```md
目的:
- 何を直したいか

背景・事実:
- いま確認できている事実

制約:
- 触ってよい範囲、避けたい変更

完了条件:
- どうなれば今回は十分か

非目的:
- 今回やらないこと
```

### 2. 探索多めの相談

- 対象: 背景が散らばっている相談、先に要件整理したい依頼
- 基本レーン: `request-shaping または task-intake → workspace-intake → 必要なら plan-product`

```md
目的:
- まず何を整理したいか

背景・事実:
- 分かっている事実
- 分かっていないこと

制約:
- 触れてほしくない範囲

完了条件:
- 今回どこまで整理できればよいか

非目的:
- 今回はまだ実装しないこと
```

### 3. 大きめ変更

- 対象: 複数ファイル変更、段階的に確認しながら進めたい作業
- 基本レーン: `request-shaping または task-intake → workspace-intake → plan-product → session-orchestrator または plan-architect → coding-standards → test-runner → change-review`

```md
目的:
- 何を前に進めたいか

背景・事実:
- 現状の実装、問題、制約

制約:
- 互換性、期限、触ってよい範囲

完了条件:
- 実装後に確認できる状態

非目的:
- 今回混ぜない整理や拡張
```

## 最初の頼み方

- 具体的なら、そのまま依頼してよい
- 情報が散らばっているなら、最初に `request-shaping` を使ってよい
- 既存挙動変更、公開インターフェース、永続化、認証認可、秘密情報、破壊的操作に触れそうなら、最初にその点を明示する

## レビュー依頼テンプレート

コードレビューだけを頼みたいときは、変更点と見てほしい観点を先に渡します。

```md
対象:
- どの変更を見てほしいか

確認してほしい観点:
- バグ
- 仕様逸脱
- テスト不足
- セキュリティ

制約:
- 今回は何を直さないか
```

## Checkpoint テンプレート

長い作業で文脈が膨らんだら、同一スレッド内で `session-orchestrator` に checkpoint を置かせます。

```md
目的:
- 今回の作業の目的

確認済み事実:
- 事実として確認できたこと

決定事項:
- ここまでに確定した方針

未決事項:
- まだ判断が必要な点

残タスク:
- 次に残っている作業

検証状況:
- 検証済み
- 未検証

次の最小ステップ:
- 次に着手する一歩
```

## セッション終了時の確認項目

- 依頼をどう理解して進めたかを短く説明できる
- 事実として確認したことと未確認事項が分かれている
- 実行した検証と未実行の検証が分かれている
- 高リスクな変更で必要な確認を飛ばしていない
- 次にユーザーが判断すべき点が残るなら短く明示されている

## 関連ドキュメント

- 全体ルール: [AGENTS.md](./AGENTS.md)
- 実務ガイド: [HIGH_QUALITY_VIBE_CODING.md](./HIGH_QUALITY_VIBE_CODING.md)
- 環境点検: [environment-audit](./skills/environment-audit/SKILL.md)
- 長い作業の進行整理: [session-orchestrator](./skills/session-orchestrator/SKILL.md)
