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
- 品質レビューが必要なら: `... → test-runner → review-quality agent → change-review`
- セキュリティレビューが必要なら: `... → test-runner → review-security agent → change-review`
- 両方必要なら: `... → test-runner → review-quality agent / review-security agent → change-review`

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
- `目的 / 背景・事実 / 制約 / 完了条件 / 非目的` は推奨テンプレートであり、全部そろっていなくてもよい
- `request-shaping` は不足項目を会話から補い、重要な未確定事項だけを残す
- 既存挙動変更、公開インターフェース、永続化、認証認可、秘密情報、破壊的操作に触れそうなら、最初にその点を明示する

## レビュー依頼テンプレート

コードレビューだけを頼みたいときは、変更点と見てほしい観点を先に渡します。

- 品質レビュー本体は `review-quality` agent を使う。
- セキュリティレビュー本体は `review-security` agent を使う。
- `change-review` は specialized review の代替ではなく、最後の整理に使う。

```md
対象:
- どの変更を見てほしいか
- 差分境界や、今回見てほしいファイル

確認してほしい観点:
- 品質
- セキュリティ
- テスト/検証
- 境界/影響範囲

実施済み確認:
- 実行したテスト、lint、手動確認

未検証:
- まだ見られていない点

制約:
- 今回は何を直さないか
```

短く頼むなら、次の依頼でよいです。

```md
review-quality でレビューして
```

この shorthand は既定で `review-quality agent → change-review` を意味し、`review-security` でも同様です。review agent の raw JSON / 生出力を明示要求した場合だけ、出口整理を省略します。

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

- 会話が長くなりすぎたら、checkpoint で重要事項を固定してから compact を検討する
- fork は別問題へ分岐したときだけ使い、同じ問題なら同一スレッドを維持する

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
- 出口整理: [change-review](./skills/change-review/SKILL.md)
