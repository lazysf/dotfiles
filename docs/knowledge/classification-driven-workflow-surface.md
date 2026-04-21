# Classification-Driven Workflow Surface

この文書は、`dot_codex/AGENTS.md` で使う開発フロー surface の基準をまとめる。

## 4層の責務

- `workflow-*`: 案件タイプごとの入口。どの phase をどの順で通すかを決める
- `phase-*`: 再利用可能な工程。目的、開始条件、完了条件、入出力、使用 core を定義する薄い orchestrator
- `core-*`: 主役となる実行手順。詳細手順、判断基準、停止条件、出力フォーマットを定義する
- `agents/`: 専門 reviewer などの補助役。read-only reviewer はここに残す

詳細なチェックリスト、テンプレート、例外規則は core とその `references/` に集約する。workflow は phase の並びに徹し、phase は core の束ねに徹する。

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

## workflow 一覧

- `workflow-research`: `phase-classify -> phase-research`
- `workflow-bugfix`: `phase-classify -> phase-diagnose -> phase-implement -> phase-verify`
- `workflow-feature`: `phase-classify -> phase-plan -> phase-implement -> phase-test -> phase-review`
- `workflow-security`: `phase-classify -> phase-security-scan -> phase-implement -> phase-verify`
- `workflow-quality`: `phase-classify -> phase-quality-analysis -> phase-implement -> phase-verify`
- `workflow-maintenance`: `phase-classify -> phase-maintenance-analysis -> phase-implement -> phase-test -> phase-review`
- `workflow-compat`: `phase-classify -> phase-compat-assessment -> phase-implement -> phase-verify`

必要時のみ次を共通 tail として差し込む。

- `phase-capture-knowledge`
- `phase-commit`
- `phase-publish`

## 命名規約

- `workflow-*`: 案件タイプ名を置く
- `phase-*`: 工程名を置く
- `core-*`: 工程内の詳細作業名を置く

旧 `*-workflow` や旧 detailed skill 名は移行期間を設けず新命名へ一本化する。
