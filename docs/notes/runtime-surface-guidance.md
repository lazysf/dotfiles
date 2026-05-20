# Runtime Surface Guidance

この文書は、`dot_codex/private_AGENTS.md.tmpl` と各 `SKILL.md` / agent 定義で参照する runtime surface の基準をまとめる。
現行運用では要求分類を入口判断の軸にしない。
現在の正式な公開 surface は、`dot_codex/skills/` 配下の prefix なし skill 名と、`dot_codex/agents/` 配下の 2 個の reviewer agent とする。skill 名の命名規約は kebab-case に統一する。
`caveman`、`git-commit`、`git-push` は明示依頼で使う手動入口とし、それ以外の skill は文脈上必要なら自動使用する入口として扱う。

## Surface の責務

- `skills/`: 実行手順の正本。詳細手順、判断基準、停止条件、出力フォーマットを定義し、そのまま正式入口として使う
- `research`: 事実確認、原因調査、影響調査、PoC、仕様確認の入口。bug / security / quality / compat / maintenance も、まず観測事実を集める段階ではここで扱う
- `planning`: 実装前の問い詰め、計画作成、inline knowledge capture の中核。目的、成功条件、非目的、制約、設計、実装順序、検証入口、対応関係を整理し、必要に応じて `CONTEXT.md`、docs、ADR、code と照合して確定した用語や判断をその場で反映する
- `architecture`: architecture 改善候補の探索と候補選択後の grilling の入口。`zoom-out` 的な module / caller / 責務の地図化を含み、実装順序確定は `planning`、差分作成は `implementation` へ進める
- `implementation`: 確認方法先行で、最小差分の実装、必要な整理、再確認を進める。対応 reference がある言語では保存形式や公開面のガードを足す
- `verification`: 既存変更の受け入れ確認、bugfix / security / quality / compat の修正効果確認、rename / 削除 / surface 変更後の整合性確認を standalone で扱う
- `caveman`: 出力を短く圧縮したい依頼で使う補助 skill。応答文体だけを変え、調査、計画、実装、レビュー、commit / push の責務は持たない
- `docs-update`: 既存 docs のみを更新する docs-only 入口。知識の置き場判断や新しい note / ADR の作成を planning と一緒に扱う場合は `planning` を使う
- `git-commit`, `git-push`: 通常 commit / push の正式入口。その他の Git 操作は skill を増やさず既定 prompt と停止線で扱う
- `agents/`: read-only reviewer と review の正式入口。review 本体はここで扱う
- `rules/`: 機械的なガード。操作制約や許可ルールを担う

詳細なチェックリスト、テンプレート、例外規則は各 skill とその `references/` に集約する。旧 prefix ベースの surface の履歴は ADR にのみ残し、現行導線の説明には持ち込まない。
要求分類は user-facing workflow として案内せず、依頼を固定分類へ当てはめるための正本も置かない。
docs-only の依頼で、成果物が既存ドキュメント更新に限られる場合は、新しい user-facing workflow を増やさず `docs-update` を直接入口として使ってよい。
root `CONTEXT-MAP.md` は multi-context の入口、各 `CONTEXT.md` は glossary を担当する。
CONTEXT は spec、作業メモ、実装判断を扱わない。

## 導線の考え方

固定の代表導線は `dot_codex/private_AGENTS.md.tmpl` に持たせない。
実行時の入口判断は、要求分類表ではなく、各 `SKILL.md` の description、reviewer agent 定義、ユーザーが明示した依頼語、既存 docs / ADR / code で確認できる事実に基づいて行う。
迷う場合は、観測事実の取得を `research`、要件整理や実装前の変更境界、検証入口の整理を `planning`、最小差分の実装を `implementation`、変更後確認を `verification` に寄せる。

## review 系 surface の役割分担

- 要件 draft と実装計画 draft の review は、専用 reviewer agent を持たず親 Codex が扱う
- 差分レビューの正式入口は `quality-reviewer`
- セキュリティレビューの正式入口は `security-reviewer`
- review は利用者が対象に応じて適切な reviewer agent を明示的に呼んで実施する
- generic review から `security-reviewer` への自動昇格は行わない
- `planning` は整理専用であり、review 本体を担わない
- reviewer agent は、親がそのまま利用者へ渡しても読みやすい形で結果を返す
- `docs/README.md` は index、`dot_codex/private_AGENTS.md.tmpl` は運用契約と薄い surface 案内、`docs/notes/harness-regression-checks.md` は手動回帰シナリオを担当する

## Frontmatter Description 設計ルール

- skill の発火面は `SKILL.md` frontmatter の `name` と `description` であり、特に `description` を主な自然文入口として扱う
- `description` は原則 3 文でそろえる
- 自動使用する skill の 1 文目は、明示的な skill 名指定がなくても文脈から使えるように「文脈上、...必要な時に自動使用する」と書く
- `caveman`、`git-commit`、`git-push` の 1 文目は、明示依頼で使う手動入口として読める形にする
- 1 文目で、ユーザーが言いそうな依頼語を優先して「どんな依頼で使うか」を自然文で示す
- 2 文目で、その skill が何を整理 / 実行 / 出力するかを示す
- 3 文目で、近接 skill との差分、渡し先、または対象外を明示する
- 言語、ファイル形式、provider、成果物 format など限定的な処理の詳細は、発火語として必要な場合を除き本文の reference 選択や `references/` に置く
- 他 skill や agent を案内する時は、`〜したい時は \`skill-name\` スキルを使う`、`レビューしたい時は \`quality-reviewer\` reviewer agent を使う` のように surface 種別まで prose で書く
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
