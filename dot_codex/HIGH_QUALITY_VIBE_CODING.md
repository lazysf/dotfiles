# 高品質なバイブコーディング手引き

この文書は、Codex Desktop を前提に、高品質なバイブコーディングを安定して進めるための実務ガイドです。
目的は「勢いで雑に作る」ことではなく、「頼み方と進め方を整えて、良い差分を再現しやすくする」ことです。
毎回の短い手順は [QUICKSTART.md](./QUICKSTART.md) を参照してください。

## まず意識すること

- 依頼は、解決策より先に `目的` と `完了条件` を置く
- 背景説明は `確認済みの事実` を優先し、推測は分ける
- スコープを広げすぎず、今回やらないことを明示する
- 高リスクな変更は、バイブコーディング中でも確認を挟む

## 良い依頼例

```markdown
目的:
- Codex の既定フローを崩さずに、依頼テンプレートを AGENTS に追加したい

背景・事実:
- 既存の AGENTS には品質原則と既定フローはある
- 依頼の出し方や長いセッションの進め方は明文化されていない

制約:
- rules は触らない
- 既存スキルは置き換えず、追加だけにしたい

完了条件:
- AGENTS、README、専用スキルで導線が一致している

非目的:
- review agent 設定の見直し
- 大規模な README 全面改稿
```

## 避けたい依頼例

- 「いい感じに改善して」
- 「全部整理して最強にして」
- 事実確認なしで「たぶんこれが原因だから直して」
- 今回やらないことがないまま、広い改善をまとめて依頼する

## レーン別の進め方

### 小さな修正

- まず `task-intake` で今回の対象と完了条件を軽く固定する
- 次に `workspace-intake` で近傍実装と確認手段を掴む
- その後は `coding-standards → test-runner` で短く閉じる

### 探索多めの相談

- 依頼が散らばっているなら `request-shaping` で実装ブリーフへ整える
- その後に `workspace-intake` で事実ベースの探索を行う
- 要件が揺れる場合だけ `plan-product` へ進む

### 大きめ変更

- 入口で `request-shaping` または `task-intake` を使い、今回の芯を揃える
- `workspace-intake` と `plan-product` で前提を固める
- 長めの進行管理が必要なら `session-orchestrator`、技術計画が必要なら `plan-architect` を使う
- 文脈が膨らんだら、同一スレッド内で `session-orchestrator` の checkpoint を置く
- 実装後は `test-runner → change-review` で閉じる

## Multi-agent の扱い

- `multi_agent=true` は有効だが、sub-agent を常用する前提ではない
- delegation や parallel work をユーザーが明示的に求めた時だけ使う
- 深く考えたい、丁寧に調べたい、詳細にレビューしたい、という理由だけでは自動で sub-agent に振らない

## おすすめスキルの組み合わせ

- 依頼が散らばっている: `request-shaping → task-intake → workspace-intake`
- 相談を要件化したい: `request-shaping → workspace-intake → plan-product`
- 段階的に安全に進めたい: `request-shaping → workspace-intake → plan-product → session-orchestrator`
- 実装順序まで明確にしたい: `task-intake → workspace-intake → plan-product → plan-architect`
- 実装を締めたい: `coding-standards → test-runner → change-review`

## セッション終了時のチェック項目

- 依頼をどう理解して進めたかを短く説明できる
- 確認した事実と未確認事項が分かれている
- 実行した検証と未実行の検証が分かれている
- 高リスクな変更で、必要な確認を飛ばしていない
- 次にユーザーが判断すべき点が残るなら、短く明示されている

## どこを読むべきか

- 運用全体の基準: [AGENTS.md](./AGENTS.md)
- 毎回の実務手順: [QUICKSTART.md](./QUICKSTART.md)
- 依頼を整える: [request-shaping](./skills/request-shaping/SKILL.md)
- 環境点検: [environment-audit](./skills/environment-audit/SKILL.md)
- 長めの進行を整える: [session-orchestrator](./skills/session-orchestrator/SKILL.md)
- 実装の品質基準: [coding-standards](./skills/coding-standards/SKILL.md)
- 出口の確認: [change-review](./skills/change-review/SKILL.md)
