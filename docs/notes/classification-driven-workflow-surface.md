# Classification-Driven Workflow Surface

この文書は、`dot_codex/AGENTS.md` と各 `SKILL.md` / agent 定義で参照する runtime surface の基準をまとめる。
現在の正式な公開 surface は、`dot_codex/skills/` 配下の 14 個の prefix なし skill 名と、`dot_codex/agents/` 配下の 4 個の reviewer agent とする。skill 名の命名規約は kebab-case に統一する。

## Surface の責務

- `skills/`: 実行手順の正本。詳細手順、判断基準、停止条件、出力フォーマットを定義し、そのまま正式入口として使う
- `research`: 事実確認、原因調査、影響調査、PoC、仕様確認の入口。bug / security / quality / compat / maintenance も、まず観測事実を集める段階ではここで扱う
- `product-planning`: 要件定義の中核。散らばった依頼や軽い停止線整理も含め、目的、成功条件、非目的、制約、用語、未確定事項を整理する
- `to-prd`: 会話や整理済み要件を PRD draft に落とす入口。生成時点では draft として扱い、正式 docs への保存や issue 化は明示依頼がある時だけ扱う
- `implementation-planning`: 技術計画の中核。要件確定後の実装順序、変更境界、検証入口に加え、リファクタ境界、単純化、quality / compat / security の実装前 scope を整理する
- `improve-codebase-architecture`: architecture 改善候補の探索と候補選択後の grilling の入口。`zoom-out` 的な module / caller / 責務の地図化を含み、実装順序確定は `implementation-planning`、差分作成は `code-implementation-loop` へ進める
- `code-implementation-loop`: 確認方法先行で、最小差分の実装、必要な整理、再確認を進める
- `coding-standards`: コード作業に言語別の制約やベストプラクティスを足す補助 skill。実装、調査、計画、レビュー本体は担わず、対象言語の reference を必要時に読む
- `change-verification`: 既存変更の受け入れ確認や、bugfix / security / quality / compat の修正効果確認を standalone で扱う
- `docs-update`: 既存 docs のみを更新する docs-only 入口。知識の置き場判断や新しい note / ADR の作成を docs-aware な grilling と一緒に扱う場合は `grill-with-docs` を使う
- `grill-me`: plan / design の pressure test 入口。質問を 1 つずつ行い、推奨回答を添え、codebase で答えられることは先に探索する
- `grill-with-docs`: docs-aware な pressure test と inline knowledge capture の入口。`CONTEXT.md`、docs、ADR、code と照合し、確定した用語や判断をその場で反映する
- `consistency-audit`: 補助 skill。明示依頼時の整合性精査に責務を絞る
- `git-commit`, `git-push`: 通常 commit / push の正式入口。その他の Git 操作は skill を増やさず既定 prompt と停止線で扱う
- `agents/`: read-only reviewer と review の正式入口。review 本体はここで扱う
- `rules/`: 機械的なガード。操作制約や許可ルールを担う

詳細なチェックリスト、テンプレート、例外規則は各 skill とその `references/` に集約する。旧 prefix ベースの surface の履歴は ADR にのみ残し、現行導線の説明には持ち込まない。
docs-only の依頼で、成果物が既存ドキュメント更新に限られる場合は、主分類を増やさず `docs-update` を直接入口として使ってよい。
root `CONTEXT-MAP.md` は multi-context の入口、各 `CONTEXT.md` は glossary を担当する。
CONTEXT は spec、作業メモ、実装判断を扱わない。

## 要求分類の見方

この分類表は、依頼の主目的を読むための背景メモであり、分類ごとの専用 skill を増やす運用ではない。

| 主分類 | 主目的 | 主に含むもの | ひとことで言うと | 境界の扱い |
| --- | --- | --- | --- | --- |
| `research` | 事実確認と判断材料の取得 | 原因調査、影響調査、PoC、方式比較、仕様確認 | まず調べる案件 | 実装方針や原因が未確定なら既定でここに倒す |
| `bugfix` | 既存の期待状態に戻す | バグ修正、仕様逸脱修正、エラー是正、データ不整合修正 | 壊れているものを戻す案件 | 切り分けは `research`、実装は `code-implementation-loop`、修正効果確認は `change-verification` |
| `feature` | 新しい価値や振る舞いを追加する | 新機能追加、機能拡張、UX改善、新規連携、新業務対応 | できることを増やす案件 | 主目的が追加なら内部整理を伴ってもここ |
| `security` | セキュリティリスクを下げる | 脆弱性修正、認証/認可強化、入力検証強化、監査ログ強化 | 守りを強くする案件 | 事実確認は `research`、実装前 scope は `implementation-planning`、差分 review は `04-security-reviewer` |
| `quality` | 品質特性を改善する | 性能改善、安定性向上、可用性向上、可観測性改善、運用性改善 | より良く動かす案件 | 事実確認は `research`、実装前 scope は `implementation-planning`、差分 review は `03-quality-reviewer` |
| `maintenance` | 将来の保守性・変更容易性を上げる | リファクタ、技術的負債返済、テスト追加、命名整理、重複除去 | 将来の変更を楽にする案件 | architecture 改善候補の探索は `improve-codebase-architecture`、リファクタ境界や単純化の計画は `implementation-planning` |
| `compat` | 外部変化に追従する | 外部 API 変更対応、依存更新、ランタイム更新、EOL 対応 | 外部変化に合わせる案件 | 外部変化の確認は `research`、追従 scope は `implementation-planning` |

固定の代表導線は `dot_codex/AGENTS.md` に持たせず、この文書では分類語と surface 設計の背景だけを扱う。

## review 系 surface の役割分担

- 要件 draft review の正式入口は `01-product-planning-reviewer`
- 実装計画 draft review の正式入口は `02-implementation-planning-reviewer`
- 差分レビューの正式入口は `03-quality-reviewer`
- セキュリティレビューの正式入口は `04-security-reviewer`
- review は利用者が対象に応じて適切な reviewer agent を明示的に呼んで実施する
- generic review から `04-security-reviewer` への自動昇格は行わない
- `product-planning` と `implementation-planning` は整理専用であり、review 本体を担わない
- reviewer agent は、親がそのまま利用者へ渡しても読みやすい形で結果を返す
- `docs/README.md` は index、`dot_codex/AGENTS.md` は運用契約と薄い surface 案内、`docs/notes/harness-regression-checks.md` は手動回帰シナリオを担当する

## Frontmatter Description 設計ルール

- skill の発火面は `SKILL.md` frontmatter の `name` と `description` であり、特に `description` を主な自然文入口として扱う
- `description` は原則 3 文でそろえる
- 1 文目で、ユーザーが言いそうな依頼語を優先して「どんな依頼で使うか」を自然文で示す
- 2 文目で、その skill が何を整理 / 実行 / 出力するかを示す
- 3 文目で、近接 skill との差分、渡し先、または対象外を明示する
- 他 skill や agent を案内する時は、`〜したい時は \`skill-name\` スキルを使う`、`レビューしたい時は \`03-quality-reviewer\` reviewer agent を使う` のように surface 種別まで prose で書く
- `\`skill-name\` で扱う`、`\`skill-name\` に委ねる`、`\`skill-name\` へ handoff する`、`writer skill` のような抽象表現は避ける
- skill 名の裸参照だけで意味を持たせず、何をしたい時に使うのかを文の中で明示する
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
