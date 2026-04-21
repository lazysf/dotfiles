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

- 標準導線は `依頼内容 -> 該当する core-* -> 必要時に隣接 core-* / reviewer / rules` とする
- まず依頼の主目的を見て、もっとも近い `core-*` へ入る
- 複数工程にまたがる依頼では、1 つの wrapper に戻すより `core-*` を順に切り替えて進める
- core は主役の実行手順として、詳細手順、判断基準、停止条件、出力フォーマットの正本を持つ
- `entry-classify` と `phase-*` は移行期間中の deprecated wrapper として残し、新規の正式入口にはしない
- 詳細な手順、判断基準、テンプレート、例外規則は core skill と配下の `references/` を参照する
- ユーザー向けの正式入口は `core-*` とする
- 補助的な整理や出口整形だけを担う skill は、正式入口ではなく補助 skill として扱う

### 1. Core Entry Guidance

- 依頼整理: `core-request-shaping`, `core-task-intake`, `core-product-planning`, `core-implementation-planning`
- 調査: `core-research`
- 診断: `core-bug-diagnosis`, `core-quality-analysis`, `core-security-scan`, `core-compat-assessment`, `core-maintenance-analysis`
- 実装: `core-code-implementation-loop`
- 確認: `core-change-testing`, `core-change-verification`, `core-code-review`
- 知識化: `core-capture-knowledge-triage`, `core-write-knowledge-note`, `core-write-adr`
- Git: `core-git-commit`, `core-git-push`
- 分類補助が必要な場合だけ `core-task-classification` を使う
- review 出口整形が必要な場合だけ `core-review-findings-summary` を使う

## Workflow Surface Policy

- 全体契約と導線は `AGENTS.md` に置く
- repo-level の参照知見は `root docs/` に置く
- repo-level の判断記録は `root docs/adr/` に置く
- 再利用する作業手順は `skills/` に置く
- `core-*` は self-contained な手順の正規置き場であり、正式入口としても使う
- `entry-classify` と `phase-*` は互換目的の wrapper として残す
- 詳細な判断基準、チェックリスト、テンプレート、例外規則は core skill 配下の `references/` に置く
- 専門化した補助役は `agents/` に置く
  - 現時点の reviewer は read-only 運用とする
  - 導線の入口や本体は `agents/` に置かない
- コマンド単位の安全制約や許可ルールは `rules/` に置く
  - 運用フロー本体は `rules/` に書かない
- `AGENTS.md` に phase / core の詳細手順や長いテンプレートを書かない
- 継続参照したい repo-level の知見は `AGENTS.md` に長文化せず、`root docs/` へ寄せる
- `references/` はトップレベルに置かず、原則として core skill ディレクトリ配下にのみ置く
- 置き場が曖昧でもトップレベルに新しい運用ファイルを増やさない
