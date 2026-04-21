# Classification-Driven Workflow Surface

この文書は、`dot_codex/AGENTS.md` で使う開発フロー surface の基準をまとめる。
現在の正式な公開 surface は `dot_codex/skills/` 配下の prefix なし skill 名であり、命名規約は kebab-case に統一する。

## Surface の責務

- `skills/`: 実行手順の正本。詳細手順、判断基準、停止条件、出力フォーマットを定義し、そのまま正式入口として使う
- `task-classification`, `review-findings-summary`: 補助 skill。入口整理や出口整形に責務を絞る
- `agents/`: 専門 reviewer などの補助役。read-only reviewer はここに残す
- `rules/`: 機械的なガード。操作制約や許可ルールを担う

詳細なチェックリスト、テンプレート、例外規則は各 skill とその `references/` に集約する。旧 prefix ベースの surface の履歴は ADR にのみ残し、現行導線の説明には持ち込まない。
docs-only の依頼で、成果物が既存ドキュメント更新に限られる場合は、主分類を増やさず `docs-update` を直接入口として使ってよい。

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

## 代表的な skill 導線

- `research`: `research`
- `bugfix`: `bug-diagnosis -> code-implementation-loop -> change-verification`
- `feature`: `request-shaping` / `task-intake` / `product-planning` / `implementation-planning -> code-implementation-loop -> change-testing -> code-review`
- `security`: `security-scan -> code-implementation-loop -> change-verification`
- `quality`: `quality-analysis -> code-implementation-loop -> change-verification`
- `maintenance`: `maintenance-analysis -> code-implementation-loop -> change-testing -> code-review`
- `compat`: `compat-assessment -> code-implementation-loop -> change-verification`
- `docs-only artifact`: `docs-update`
- `knowledge`: `capture-knowledge-triage -> write-knowledge-note` または `write-adr`
- `git`: `git-commit`, `git-push`
- `classification helper`: `task-classification`
- `review summary helper`: `review-findings-summary`

## review 系 skill の役割分担

- 差分レビュー用 reviewer の起動元は `code-review`
- 要件 draft reviewer の起動元は `product-planning`
- 実装計画 draft reviewer の起動元は `implementation-planning`
- `review-findings-summary` は reviewer 非起動の出口整理 helper として使う

## Frontmatter Description 設計ルール

- skill の発火面は `SKILL.md` frontmatter の `name` と `description` であり、特に `description` を主な自然文入口として扱う
- `description` は原則 3 文でそろえる
- 1 文目で、ユーザーが言いそうな依頼語を優先して「どんな依頼で使うか」を自然文で示す
- 2 文目で、その skill が何を整理 / 実行 / 出力するかを示す
- 3 文目で、近接 skill との差分、渡し先、または対象外を明示する
- 主役 skill と補助 skill の違いは prefix や内部用語ではなく prose で表現する
- `metadata.short-description` は UI 向けの短い説明であり、trigger surface の正本としては扱わない
- 旧 implicit invocation、wrapper、legacy surface を前提にした言い回しは `description` に持ち込まない
- 文量は必要最小限に保ちつつ、短さより境界語の明確さを優先する

## 命名規約

- skill 名は prefix なしの kebab-case とする
- 補助 skill も同じ規約に従い、命名で役割を区別しない
- 役割の違いは `AGENTS.md` や各 `SKILL.md` の prose で説明する

## 関連文書

- [ADR 0004](../adr/0004-retire-legacy-workflow-prefixes.md)
