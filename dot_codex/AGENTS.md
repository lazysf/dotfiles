# AGENTS.md

## 基本姿勢

- 日本語で返答する
- 事実に基づいて判断する
- 推測や憶測で処理を進めない
- 小さな判断は既存文脈に寄せて自走し、大きな判断だけ確認する
- workspace 外のファイルは、現状確認や diff のための読み取りだけに留める
- 通常の最終返答では、スキルを使ったかどうかを末尾に必ず明示する
  - 使用あり: `スキル: skill1, skill2`
  - 使用なし: `スキル: 未使用`
- 次の提案アクションがある場合は、番号付きリストで示す

## 停止線

- 既存挙動が変わる可能性がある場合は、根拠と影響範囲を明示して確認する
- 公開インターフェース、永続化、認証認可、権限、秘密情報に触れる場合は確認を優先する
- 削除や上書きなどの破壊的操作を伴う場合は、ユーザーの明示的な意図なしに進めない

## 開発フロー

- 標準導線は `依頼内容 -> 主目的の主分類または直接入口 -> 該当 skill -> 必要時に隣接 skill / reviewer / rules` とする
- まず依頼の主目的にもっとも近い入口から入り、複数工程にまたがる場合だけ必要な skill へ順に切り替える
- `skills/` をユーザー向けの正式入口とし、詳細手順、判断基準、停止条件、出力フォーマットの正本は各 skill に置く
- `task-classification`、`review-findings-summary`、`reviewer`、`rules` は補助導線であり、入口整理、出口整形、機械的ガードに責務を絞る

### 1. 主分類から入る

- `research`: `research`
- `bugfix`: `bug-diagnosis -> code-implementation-loop -> change-verification`
- `feature`: `request-shaping` / `task-intake` / `product-planning` / `implementation-planning -> code-implementation-loop -> change-testing -> code-review`
- `security`: `security-scan -> code-implementation-loop -> change-verification`
- `quality`: `quality-analysis -> code-implementation-loop -> change-verification`
- `maintenance`: `maintenance-analysis -> code-implementation-loop -> change-testing -> code-review`
- `compat`: `compat-assessment -> code-implementation-loop -> change-verification`
- 実装方針や原因が未確定なら、まず `research` に倒す

### 2. 主分類の外にある直接入口

- `docs-only`: 成果物が既存ドキュメント更新に限られる場合は、主分類を増やさず `docs-update` へ直接入る
- `knowledge`: `capture-knowledge-triage -> write-knowledge-note` または `write-adr`
- `git`: `git-commit`, `git-push`

### 3. 補助導線

- 主分類に迷う場合だけ `task-classification` を使う
- review の出口整形が必要な場合だけ `review-findings-summary` を使う
- `reviewer` や `rules` は隣接して使う補助役であり、入口や本体導線にはしない

## 置き場の原則

- この節は、知見、手順、補助役をどこに置くかだけを短く案内する
- `AGENTS.md`: 全体契約と導線を置く。長い背景、詳細手順、テンプレートは置かない
- `docs/knowledge/`: repo-level の通常知見を置く
- `docs/adr/`: repo-level の判断記録を置く
- `skills/`: 再利用する作業手順を置く。詳細手順、判断基準、停止条件、出力フォーマットの正本もここに置く
- `references/`: チェックリスト、テンプレート、例外規則などの詳細を置く。トップレベルには置かず、skill 配下に限定する
- `rules/`: 機械的なガードを置く。運用フロー本体は置かない
- `agents/`: read-only の専門化した補助役を置く。入口や本体導線にはしない
- 置き場が曖昧でもトップレベルに新しい運用ファイルを増やさない
