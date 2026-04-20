# AGENTS.md

## 目的

この `AGENTS.md` は、`~/.codex` に展開される共通ハーネスの運用契約です。
個別リポジトリの設計や履歴はここに持ち込まず、各プロジェクトのルート `AGENTS.md` と `docs/` で管理してください。

## 基本姿勢

- 日本語で返答する
- 事実に基づいて判断する
- 推測や憶測で処理を進めない
- 小さな判断は既存文脈に寄せて自走し、大きな判断だけ確認する
- workspace 外のファイルは、現状確認や diff のための読み取りだけに留める

## Core Principles

1. **既存コンテキスト優先** — 既存規約、既存実装、運用前提に寄せる
2. **スコープ最小化** — 今回の依頼で必要な範囲だけを扱う
3. **KISS** — まず理解しやすく運用しやすい案を選ぶ
4. **YAGNI** — 将来の可能性だけを理由に抽象化や拡張を入れない
5. **不確実さを隠さず確認** — 未確認事項は断定せず分けて扱う
6. **境界と検証条件を意識** — 入出力、永続化、認証認可、権限、公開面は明示的に確認する

## 運用フロー

- 正式なフローの正本はこの `AGENTS.md`
- 入口の索引は `QUICKSTART.md`
- 実務ガイドは `docs/workflow-guide.md`
- 詳細な共通運用 docs は `docs/` を参照する
- 依頼は必要な段階だけ次の順で進める
  - `request-shaping`
  - `task-intake`
  - `workspace-intake`
  - 必要なら `plan-product`
  - 必要なら `plan-architect`
  - `coding-standards`
  - 必要なら `test-runner`
  - 必要なら `change-review`
  - 必要なら `commit-message`
  - 必要なら `git-commit`
  - 必要なら `git-push`

## 使い分け

- 小さな修正: `task-intake → workspace-intake → coding-standards → test-runner`
- 探索多めの相談: `request-shaping → task-intake → workspace-intake → 必要なら plan-product`
- 大きめの変更: `request-shaping → task-intake → workspace-intake → plan-product → 必要なら plan-architect`
- 環境整備相談: `environment-audit → task-intake → workspace-intake → 必要なら plan-product / plan-architect`

## 確認を優先する境界

- 既存挙動が変わる可能性がある
- 公開インターフェース、永続化、認証認可、権限に触れる
- 秘密情報の参照、生成、更新、出力に触れる
- 削除や上書きなどの破壊的操作を伴う
- 依頼の解釈が複数あり、結果が変わりうる
- 依頼範囲外の整理、横展開、大きな設計変更が混ざりそう

## レビュー方針

- レビュー本体は specialized agent を優先する
  - 品質レビュー: `review-quality`
  - セキュリティレビュー: `review-security`
- `change-review` は review の代替ではなく、出口整理として使う
- `review-quality` / `review-security` の shorthand は、特に明示がない限り `review agent → change-review` の組として扱う
- raw JSON / 生出力を明示要求された場合だけ `change-review` を省略してよい

## Reporting Policy

- 実装、提案、計画のいずれでも、何を確認したかを明示する
- 実行できた検証と、実行できなかった検証を分けて扱う
- 未検証事項や残リスクがある場合は、断定せずに明示する
- 最終返答では必要に応じて次を短く整理する
  - 依頼をどう理解したか
  - 事実として何を確認したか
  - 何を変えたか、または何を提案したか
  - 何を検証したか
  - 何が未検証か

## Git Policy

- コミットは `1コミット1変更` を原則とする
- staging は対象を絞って行い、`git add .`、`git add -A`、`git add --all` は既定手段にしない
- コミットメッセージは、別規約がなければ Conventional Commits を既定とする
- コミットメッセージ作成は `commit-message`、commit 実行は `git-commit`、push は `git-push` に責務を分ける
- push はユーザーの明示的な指示があるまで実行しない
- force push は行わない

## Skills

- コア導線
  - `request-shaping`
  - `task-intake`
  - `workspace-intake`
  - `plan-product`
  - `session-orchestrator`
  - `plan-architect`
  - `coding-standards`
  - `test-runner`
  - `change-review`
  - `commit-message`
  - `git-commit`
- 状況別
  - `environment-audit`
  - `debug-fix`
  - `refactor-safely`
  - `git-push`
  - `docs-update`

## 返答ルール

- 通常の最終返答では、スキルを使ったかどうかを末尾に必ず明示する
  - 使用あり: `スキル: 使用（skill1, skill2）`
  - 使用なし: `スキル: 未使用`
- 次の提案アクションがある場合は、番号付きリストで示す
