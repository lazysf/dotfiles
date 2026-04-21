# Classification-Driven Workflow Surface

この文書は、`dot_codex/AGENTS.md` で使う開発フロー surface の基準をまとめる。
現在の正式な公開 surface は `core-*` であり、`entry-classify` と `phase-*` は移行期間中の deprecated wrapper として残す。

## Surface の責務

- `core-*`: 主役となる実行手順。詳細手順、判断基準、停止条件、出力フォーマットを定義し、そのまま正式入口として使う
- `entry-classify`: 旧導線互換の整理 wrapper。新規の正式入口にはしない
- `phase-*`: 旧導線互換の wrapper。対応する `core-*` への橋渡しだけを担う
- `agents/`: 専門 reviewer などの補助役。read-only reviewer はここに残す

詳細なチェックリスト、テンプレート、例外規則は core とその `references/` に集約する。wrapper は互換性のためにのみ残し、新規の導線説明は `core-*` を基準にする。

## 要求分類

| 主分類        | 主目的                           | 主に含むもの                                               | ひとことで言うと         | 境界の扱い                                         |
| ------------- | -------------------------------- | ---------------------------------------------------------- | ------------------------ | -------------------------------------------------- |
| `research`    | 事実確認と判断材料の取得         | 原因調査、影響調査、PoC、方式比較、仕様確認                | まず調べる案件           | 実装方針や原因が未確定なら既定でここに倒す         |
| `bugfix`      | 既存の期待状態に戻す             | バグ修正、仕様逸脱修正、エラー是正、データ不整合修正       | 壊れているものを戻す案件 | 権限不備や脆弱性が主題なら `security`              |
| `feature`     | 新しい価値や振る舞いを追加する   | 新機能追加、機能拡張、UX改善、新規連携、新業務対応         | できることを増やす案件   | 主目的が追加なら内部整理を伴ってもここ             |
| `security`    | セキュリティリスクを下げる       | 脆弱性修正、認証/認可強化、入力検証強化、監査ログ強化      | 守りを強くする案件       | 外部追従が主なら `compat`、通常不具合なら `bugfix` |
| `quality`     | 品質特性を改善する               | 性能改善、安定性向上、可用性向上、可観測性改善、運用性改善 | より良く動かす案件       | 将来の変更容易性が主なら `maintenance`             |
| `maintenance` | 将来の保守性・変更容易性を上げる | リファクタ、技術的負債返済、テスト追加、命名整理、重複除去 | 将来の変更を楽にする案件 | 性能や安定性が主なら `quality`                     |
| `compat`      | 外部変化に追従する               | 外部 API 変更対応、依存更新、ランタイム更新、EOL 対応      | 外部変化に合わせる案件   | CVE 対応や権限強化が主なら `security`              |

## 代表的な core 導線

- `research`: `core-research`
- `bugfix`: `core-bug-diagnosis -> core-code-implementation-loop -> core-change-verification`
- `feature`: `core-request-shaping` / `core-task-intake` / `core-product-planning` / `core-implementation-planning -> core-code-implementation-loop -> core-change-testing -> core-code-review`
- `security`: `core-security-scan -> core-code-implementation-loop -> core-change-verification`
- `quality`: `core-quality-analysis -> core-code-implementation-loop -> core-change-verification`
- `maintenance`: `core-maintenance-analysis -> core-code-implementation-loop -> core-change-testing -> core-code-review`
- `compat`: `core-compat-assessment -> core-code-implementation-loop -> core-change-verification`
- `knowledge`: `core-capture-knowledge-triage -> core-write-knowledge-note` または `core-write-adr`
- `git`: `core-git-commit`, `core-git-push`
- `classification helper`: `core-task-classification`
- `review summary helper`: `core-review-findings-summary`

## 命名規約

- `core-*`: 工程内の詳細作業名を置く
- `entry-*` / `phase-*`: 旧導線互換の wrapper 名を置く

旧 `workflow-*` は削除済みとし、旧 `entry-*` / `phase-*` も互換用途に縮退させる。
