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

- 標準導線は `entry-classify -> workflow-* -> workflow が選ぶ phase-* -> core-* -> 必要時に phase-capture-knowledge -> 必要時に phase-commit -> 必要時に phase-publish` とする
- まず `entry-classify` で要求を単一の主分類へ倒し、対応する `workflow-*` へ入る
- 依頼が単一工程に明確に閉じる場合だけ、対応する `phase-*` を直接入口として使ってよい
- `phase-*` の直呼びは、依頼目的が 1 つの工程に閉じており、他 phase への自動接続を前提にしない場合に限る
- 複数工程にまたがる依頼や、途中で別工程への接続が必要になった依頼は標準導線へ戻す
- workflow は分類後に使う工程の並びと入出力の受け渡しだけを扱う
- phase は工程の目的、開始条件、完了条件、I/O schema、使う core を扱う薄い orchestrator とする
- core は主役の実行手順として、詳細手順、判断基準、停止条件、出力フォーマットの正本を持つ
- 詳細な手順、判断基準、テンプレート、例外規則は core skill と配下の `references/` を参照する
- ユーザー向けの公開入口は `entry-classify` と `phase-*` とし、`workflow-*` は分類結果として入る導線、`core-*` は phase の内部詳細として扱う
- `phase-*` を直接入口にする場合も、phase 単位で入力、出力、完了条件を説明できる状態を保つ
- 代表的な単独依頼の入口は次とする
  - 「レビューだけ」 -> `phase-review`
  - 「要件定義だけ」「計画作成だけ」 -> `phase-plan`
  - 「コミットだけ」 -> `phase-commit`
- `phase-test` と `phase-verify` の直呼び運用は今回は標準導線へ含め、単独入口としては明文化しない

### 1. Entry Classify

- 目的: チャット入力された要求を単一の主分類へ整理し、次に入る `workflow-*` を決める
- 進む条件: `primary_category`、`reason`、`boundary_note`、`selected_workflow`、`stop_conditions` を説明できる
- 詳細: `entry-classify` を起点に、分類判断の詳細は `core-task-classification` を使う

### 2. Typed Workflow

- 目的: 要求分類の結果として選ばれた案件タイプに応じて必要な phase だけを並べ、工程間の受け渡しをそろえる
- workflow の種類:
  - `workflow-research`
  - `workflow-bugfix`
  - `workflow-feature`
  - `workflow-security`
  - `workflow-quality`
  - `workflow-maintenance`
  - `workflow-compat`
- 代表フロー:
  - `workflow-research`: `phase-research`
  - `workflow-bugfix`: `phase-diagnose -> phase-implement -> phase-verify`
  - `workflow-feature`: `phase-plan -> phase-implement -> phase-test -> phase-review`
  - `workflow-security`: `phase-security-scan -> phase-implement -> phase-verify`
  - `workflow-quality`: `phase-quality-analysis -> phase-implement -> phase-verify`
  - `workflow-maintenance`: `phase-maintenance-analysis -> phase-implement -> phase-test -> phase-review`
  - `workflow-compat`: `phase-compat-assessment -> phase-implement -> phase-verify`

### 3. Phase Tail

- `phase-capture-knowledge`
  - 目的: 残すべき知識の要否と置き場を整理し、必要なら docs へ落とす
  - 詳細: `core-capture-knowledge-triage`、`core-write-adr`、`core-write-knowledge-note`
- `phase-commit`
  - 目的: 差分を意味のある最小単位へまとめ、規約に沿ったコミットへ整理する
  - 詳細: `core-git-commit`
- `phase-publish`
  - 目的: 明示依頼がある場合だけ共有先へ push し、共有結果を整える
  - 詳細: `core-git-push`

## Workflow Surface Policy

- 全体契約と導線は `AGENTS.md` に置く
- repo-level の参照知見は `root docs/` に置く
- repo-level の判断記録は `root docs/adr/` に置く
- 再利用する作業手順は `skills/` に置く
- `entry-classify` は全導線の共通入口、`workflow-*` は分類後の案件タイプ別導線、`phase-*` は再利用可能な工程、`core-*` は主役の実行手順の正規置き場にする
- 詳細な判断基準、チェックリスト、テンプレート、例外規則は core skill 配下の `references/` に置く
- 専門化した補助役は `agents/` に置く
  - 現時点の reviewer は read-only 運用とする
  - workflow の入口や本体は `agents/` に置かない
- コマンド単位の安全制約や許可ルールは `rules/` に置く
  - 運用フロー本体は `rules/` に書かない
- `AGENTS.md` に workflow / phase / core の詳細手順や長いテンプレートを書かない
- 継続参照したい repo-level の知見は `AGENTS.md` に長文化せず、`root docs/` へ寄せる
- `references/` はトップレベルに置かず、原則として core skill ディレクトリ配下にのみ置く
- 置き場が曖昧でもトップレベルに新しい運用ファイルを増やさない
