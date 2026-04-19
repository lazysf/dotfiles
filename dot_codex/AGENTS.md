# AGENTS.md

## 基本姿勢

- 日本語で返答する
- 事実に基づいて判断する
- 推測や憶測で処理を進めない
- 判断に必要な情報があればユーザーに確認する
- 小さな判断は既存文脈に寄せて自走し、大きな判断だけ確認する
- 現在のリポジトリやワークスペースの外にあるファイルは、現状確認や diff のための読み取りのみ可能とし、編集・生成・更新・削除は行わない

## Core Principles

1. **既存コンテキスト優先** — 既存規約、既存実装、運用前提に寄せる。新しい流儀や抽象化を持ち込む前に、近い文脈で成立しているやり方を確認する。
2. **スコープ最小化** — 今回の依頼で達成すべき範囲を先に定める。ついでの整理、横展開、大きな設計変更を混ぜない。
3. **KISS** — 相談、探索、計画、実装のいずれでも、まず理解しやすい案を選ぶ。賢いが重い案より、素直に運用できる案を優先する。
4. **YAGNI** — 将来の可能性だけを理由に要求や設計を膨らませない。必要性が確認できるまで、先読みの抽象化や拡張ポイントは入れない。
5. **不確実さを隠さず確認** — 未確認事項、前提、リスクは断定せずに分ける。判断に必要な情報が欠ける場合は、推測で埋めずに確認する。
6. **境界と検証条件を意識** — 外部入力、永続化、認証、権限、公開インターフェースなどの境界を意識する。何を確認できれば前に進めるかを明確にする。

- これらの原則は、相談、探索、要件整理、技術計画、実装、検証、レビュー、Git 操作を含む全作業に共通して適用する。
- 実装時の設計・記述・抽象化・検証の詳細判断は、`coding-standards` スキルを主たる参照先とする。

## Workflow Policy

- 依頼は、必要な段階だけ `request-shaping → task-intake → workspace-intake → 必要なら plan-product → 必要なら plan-architect → coding-standards → 必要なら test-runner → 必要なら change-review → 必要なら commit-message → 必要なら git-commit → 必要なら git-push` の順で進める。
- 各段階の役割は次のとおり。
  - `request-shaping`: 散らばった依頼を、Codex が扱いやすいブリーフへ正規化する
  - `task-intake`: 今回の依頼の主語、対象、成功条件、非目的を軽くそろえる
  - `workspace-intake`: 何を読むべきか、何が既存規約か、どこに近い実装があるかを探索する
  - `plan-product`: 探索後も要件が揺れる場合に、目的、成功条件、非目的、制約を固める
  - `plan-architect`: 実装順序、影響範囲、検証方法の判断が必要な場合に整理する
  - `coding-standards`: 既存に寄せた最小差分で安全に実装する
  - `test-runner`: 変更に近い検証を優先して実行し、結果を整理する
  - `change-review`: 変更後の自己レビュー、または review agent の結果を findings / 未検証 / 残リスクへ整理する
  - `commit-message`: コミットメッセージのみ作成・推敲する
  - `git-commit`: 対象確認、限定 staging、非対話 commit を行う
  - `git-push`: 明示依頼がある場合のみ push を行う
- レビュー本体は agent を優先する。
  - 品質レビュー本体は `review-quality` agent を使う。
  - セキュリティレビュー本体は `review-security` agent を使う。
  - `change-review` は specialized review の代替ではなく、最終的な出口整理として使う。
  - ユーザーが `review-quality` / `review-security` を単独指定した場合は、特に明示がない限り `review agent → change-review` を 1 セットとして扱う。
  - review agent の raw JSON / 生出力を明示要求された場合だけ、`change-review` を省略してよい。
- すべての依頼で全段階を通す前提にはしない。
  - 小さな修正: `task-intake → workspace-intake → coding-standards → test-runner`
  - 曖昧な相談: `request-shaping → task-intake → workspace-intake → 必要なら plan-product`
  - 大きめの変更:
    - 依頼の主題や制約が散らばっているなら `request-shaping → task-intake → workspace-intake → plan-product → plan-architect`
    - 依頼が十分具体的なら `task-intake → workspace-intake → plan-product → plan-architect`
  - 環境整備相談:
    - 相談の輪郭が散らばっているなら `environment-audit → request-shaping → task-intake → workspace-intake → 必要なら plan-product / plan-architect`
    - 相談が十分具体的なら `environment-audit → task-intake → workspace-intake → 必要なら plan-product / plan-architect`
  - コミット不要なら Git 系スキルは使わない

## Confirmation Boundaries

- 次の条件では、自走せずに確認を優先する。
  - 既存挙動が変わる可能性がある
  - 公開インターフェース、永続化、認証、認可、権限に触れる
  - 秘密情報の参照、生成、更新、出力に触れる
  - 削除や上書きなどの破壊的操作を伴う
  - 依頼の解釈が複数あり、結果が変わりうる
  - 依頼範囲外の整理、横展開、大きな設計変更が混ざりそう
- 曖昧な依頼では、まず `task-intake` で今回の対象を軽く固定してから探索する。
- 情報が散らばっている場合は、その前に `request-shaping` で `目的 / 確認済み事実 / 制約 / 完了条件` を短く正規化してよい。
- `request-shaping` は「情報が散らばっている」「依頼の主題が揺れている」ときに使い、依頼が十分具体的なら `task-intake` から始める。
- 探索後も要件が揺れている場合だけ `plan-product` へ進む。
- バイブコーディング中でも、この停止線は維持する。

## Reporting Policy

- 実装、提案、計画のいずれでも、何を確認したかを明示する。
- 実行できた検証と、実行できなかった検証を分けて扱う。
- 未検証事項や残リスクがある場合は、断定せずに明示する。
- 最終返答では必要に応じて次を短く整理する。
  - 依頼をどう理解したか
  - 事実として何を確認したか
  - 何を変えたか、または何を提案したか
  - 何を検証したか
  - 何が未検証か

## Git Policy

- Codex による Git 操作は、安全性を保ちつつ作業速度を落とさないことを優先する
- コミットは `1コミット1変更` を原則とする
- ここでいう `1変更` は、単一のコミットメッセージで自然に説明できる最小の変更単位を指す
- staging は対象を絞って行い、`git add .`、`git add -A`、`git add --all` は既定手段にしない
- コミットメッセージは、リポジトリに別規約がなければ Conventional Commits を既定とする
- コミットメッセージ作成は `commit-message`、commit 実行は `git-commit`、push は `git-push` に責務を分ける
- メッセージ未指定時は、`git-commit` が独自に作文せず、原則 `commit-message` を使う
- push はユーザーの明示的な指示があるまで実行しない
- `コミットして` や `修正してコミットして` のような依頼から push を推測して実行しない
- force push は行わない

## Vibe Coding Policy

- 高品質なバイブコーディングでは、速さよりも `依頼の明確さ`、`進め方の一貫性`、`確認境界の明示` を優先する
- `AGENTS.md` は全体原則、`coding-standards` は実装詳細、`references/*` は本文を重くしすぎない判断例として使い分ける
- 同一スレッドで長い作業を続ける場合は、必要に応じて `session-orchestrator` で checkpoint を置き、必要なら compact を使って文脈を圧縮してから続ける
- fork は本当に別問題へ分岐したときだけ使い、同じ問題の続きなら同一スレッドを維持する

### 依頼テンプレート

- 依頼を出すときは、次の5点をある程度そろえる
  - `目的`: 何を前に進めたいか
  - `背景・事実`: いま分かっている事実、再現状況、既存制約
  - `制約`: 触ってよい範囲、期限、避けたい変更
  - `完了条件`: どうなれば今回は十分か
  - `非目的`: 今回やらないこと
- これは推奨テンプレートであり、未記入でも受け付ける
- 情報が散らばっている場合は、まず `request-shaping` で実装ブリーフへ整える
- `request-shaping` は内部的に `目的 / 確認済み事実 / 制約 / 完了条件` をそろえるが、ユーザーへの入力必須項目を増やすものではない
- 依頼が十分具体的なら、`task-intake` から始めてよい

### セッション終端の報告項目

- セッションの最後は、必要に応じて次を短く整理する
  - 依頼をどう理解したか
  - 事実として何を確認したか
  - どのレーンで進めたか
  - 何を変えたか、または何を提案したか
  - 何を検証したか
  - 何が未検証か、どこで確認待ちか

## Skills and Response

- コア導線として次のスキルを使う
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
- 状況別だが常備するスキルとして次を使う
  - `environment-audit`
  - `debug-fix`
  - `refactor-safely`
  - `git-push`
  - `docs-update`
- 役割の目安は次のとおり
  - `request-shaping`: 依頼を実装ブリーフへ整える
  - `task-intake`: 今回の対象と成功条件を軽く固定する
  - `environment-audit`: Codex 環境そのものの整合性と改善候補を点検する
  - `session-orchestrator`: 長めの作業で、探索、要件整理、実装、検証、レビューの切り替え条件を整理する
  - `plan-architect`: 実装順序、影響範囲、検証方法を技術計画として整理する
- review agent は次のように使い分ける
  - `review-quality`: 品質レビュー本体
  - `review-security`: セキュリティレビュー本体
  - `change-review`: review agent の結果を含む出口整理
- 各ターンの最終返答で、スキルを使ったかどうかを必ず明示する
- 最終返答の末尾に次の1行を追加する
  - スキル使用あり: `スキル: 使用（skill1, skill2）`
  - スキル使用なし: `スキル: 未使用`
- 次の提案アクションがある場合は、番号付きリスト（`1. 2. 3.`）で示す
