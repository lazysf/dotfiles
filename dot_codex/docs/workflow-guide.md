# 共通ワークフローガイド

この文書は、Codex Desktop を前提に、高品質なバイブコーディングを安定して進めるための実務ガイドです。
正式なフローや停止線は [AGENTS.md](../AGENTS.md) を正本とし、日常の入口は [QUICKSTART.md](../QUICKSTART.md) を参照してください。
このガイドでは、直下 2 ファイルだけでは書き切らない具体例、補足、長めセッションの進め方を扱います。

## まず意識すること

- 依頼は、解決策より先に `目的` と `完了条件` を置く
- 背景説明は `確認済みの事実` を優先し、推測は分ける
- スコープを広げすぎず、今回やらないことを明示する
- 高リスクな変更は、バイブコーディング中でも確認を挟む
- `目的 / 確認済み事実 / 制約 / 完了条件` は良い整理軸だが、毎回の入力必須項目として扱わない
- `request-shaping` は入口で `目的 / 確認済み事実 / 制約` と未確定事項を整え、完了条件は `task-intake` や `plan-product` で固めてよい

## 良い依頼例

```markdown
目的:
- Codex の既定フローを崩さずに、依頼テンプレートを AGENTS に追加したい

背景・事実:
- 既存の AGENTS には品質原則と既定フローはある
- 依頼の出し方や長いセッションの進め方は明文化されていない

制約:
- 既存フローを崩さない
- repo-level の設計理由は root docs に分けたい

完了条件:
- AGENTS、QUICKSTART、docs の導線が一致している

非目的:
- 既存の agent 定義そのものの見直し
- 不要な横展開
```

## 避けたい依頼例

- 「いい感じに改善して」
- 「全部整理して最強にして」
- 事実確認なしで「たぶんこれが原因だから直して」
- 今回やらないことがないまま、広い改善をまとめて依頼する

## レーン別の補足

### 小さな修正

- 入口は [QUICKSTART.md](../QUICKSTART.md) の小さな修正レーンを使う
- `task-intake` では対象と完了条件を軽く固定し、`workspace-intake` では近傍実装と確認手段だけを掴む
- 深い要件整理や計画へ広げず、`coding-standards → test-runner` で短く閉じる

### 探索多めの相談

- 情報が散らばっているときは、まず `request-shaping` で実装ブリーフへ整える
- その後に `task-intake` で今回の停止線を置き、`workspace-intake` で事実ベースの探索へ進む
- 要件が揺れるときだけ `plan-product` を追加し、入口整理と要件整理を混ぜない

### 大きめ変更

- 依頼が十分具体的なら `task-intake`、散らばっているなら `request-shaping` から入る
- `request-shaping` を使った場合も、通常は `task-intake` を経てから探索へ進む
- 長めの進行管理が必要なら `session-orchestrator`、技術計画が必要なら `plan-architect` を使う
- 文脈が膨らんだら、同一スレッド内で `session-orchestrator` の checkpoint を置き、必要なら compact を使う
- 実装後は `test-runner → 必要なら review-quality agent / review-security agent → change-review` で閉じる

## おすすめスキルの組み合わせ

- 依頼が散らばっている: `request-shaping → task-intake → workspace-intake`
- 相談を要件化したい: `request-shaping → task-intake → workspace-intake → plan-product`
- 段階的に安全に進めたい: `request-shaping → task-intake → workspace-intake → plan-product → session-orchestrator`
- 実装順序まで明確にしたい: `task-intake → workspace-intake → plan-product → plan-architect`
- 実装を締めたい: `coding-standards → test-runner → 必要なら review-quality agent / review-security agent → change-review`

## セッション終了時のチェック項目

- 依頼をどう理解して進めたかを短く説明できる
- 確認した事実と未確認事項が分かれている
- 実行した検証と未実行の検証が分かれている
- 高リスクな変更で、必要な確認を飛ばしていない
- 次にユーザーが判断すべき点が残るなら、短く明示されている

## どこを読むべきか

- 運用全体の基準: [AGENTS.md](../AGENTS.md)
- 毎回の実務入口: [QUICKSTART.md](../QUICKSTART.md)
- 共通 docs の入口: [README.md](./README.md)
- 依頼を整える: [request-shaping](../skills/request-shaping/SKILL.md)
- 環境点検: [environment-audit](../skills/environment-audit/SKILL.md)
- 長めの進行を整える: [session-orchestrator](../skills/session-orchestrator/SKILL.md)
- 実装の品質基準: [coding-standards](../skills/coding-standards/SKILL.md)
- レビュー本体: `review-quality` / `review-security` agent
- 出口の確認: [change-review](../skills/change-review/SKILL.md)
