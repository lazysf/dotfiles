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

- 標準導線は `依頼内容 -> 該当する skill -> 必要時に隣接 skill / reviewer / rules` とする
- まず依頼の主目的を見て、もっとも近い skill へ入る
- 複数工程にまたがる依頼では、必要な skill を順に切り替えて進める
- skill は主役の実行手順として、詳細手順、判断基準、停止条件、出力フォーマットの正本を持つ
- 詳細な手順、判断基準、テンプレート、例外規則は skill と配下の `references/` を参照する
- ユーザー向けの正式入口は skill 群とする
- 補助的な整理や出口整形だけを担う skill は、正式入口ではなく補助 skill として扱う

### 1. Skill Entry Guidance

- 依頼整理: `request-shaping`, `task-intake`, `product-planning`, `implementation-planning`
- 調査: `research`
- 診断: `bug-diagnosis`, `quality-analysis`, `security-scan`, `compat-assessment`, `maintenance-analysis`
- 実装: `code-implementation-loop`
- 確認: `change-testing`, `change-verification`, `code-review`
- 知識化: `capture-knowledge-triage`, `write-knowledge-note`, `write-adr`
- Git: `git-commit`, `git-push`
- 分類補助が必要な場合だけ `task-classification` を使う
- review 出口整形が必要な場合だけ `review-findings-summary` を使う

## Workflow Surface Policy

- 全体契約と導線は `AGENTS.md` に置く
- repo-level の参照知見は `root docs/` に置く
- repo-level の判断記録は `root docs/adr/` に置く
- 再利用する作業手順は `skills/` に置く
- skill は self-contained な手順の正規置き場であり、正式入口としても使う
- 詳細な判断基準、チェックリスト、テンプレート、例外規則は skill 配下の `references/` に置く
- 専門化した補助役は `agents/` に置く
  - 現時点の reviewer は read-only 運用とする
  - 導線の入口や本体は `agents/` に置かない
- コマンド単位の安全制約や許可ルールは `rules/` に置く
  - 運用フロー本体は `rules/` に書かない
- `AGENTS.md` に skill の詳細手順や長いテンプレートを書かない
- 継続参照したい repo-level の知見は `AGENTS.md` に長文化せず、`root docs/` へ寄せる
- `references/` はトップレベルに置かず、原則として skill ディレクトリ配下にのみ置く
- 置き場が曖昧でもトップレベルに新しい運用ファイルを増やさない
