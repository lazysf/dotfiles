# Runtime Surface Guidance

> **Scope**: この文書は ADR 0036 以前の重 SDLC 対称モデル（Codex / Claude 両方が `orchestrate` / `grill` / `architecture` / `implement` / `inspect` / `doc-followup` skill、`inspector` / `requirements-reviewer` / `design-reviewer` agent、tier / Phase / Gate を持つ姿）と、ADR 0037 以前の `CONTEXT-MAP.md` / 近傍 `CONTEXT.md` 体系を記述する履歴文書。現行は ADR 0036 で両 surface とも軽量 LLM-native へ再設計され、これらの skill / agent / tier / Phase / Gate は持たず、ADR 0037 で CONTEXT.md 体系は撤去されている。現行構成は [lightweight-workflow.md](./lightweight-workflow.md) を正本にする。本文中で両 surface に依然有効なのは、置き場の原則、命名規約、frontmatter description 設計など surface 非依存の部分に限る。

この文書は、`dot_codex/AGENTS.md`、`dot_claude/CLAUDE.md`、各 `SKILL.md` / agent 定義で参照する runtime surface の基準をまとめる。
現行運用では要求分類を入口判断の軸にしない。
現在の managed surface は、`dot_codex/AGENTS.md`、`dot_codex/skills/`、`dot_codex/agents/`、`dot_codex/rules/`、`dot_claude/CLAUDE.md`、`dot_claude/skills/`、`dot_claude/agents/`、`dot_claude/rules/`、`dot_claude/output-styles/`、`dot_claude/settings.json` とする。skill 名の命名規約は kebab-case に統一する。
`caveman`、`git-commit`、`git-push` は明示依頼で使う手動入口とし、それ以外の skill は文脈上必要なら自動使用する入口として扱う。
root `CLAUDE.md` は repo-local import shim、`dot_codex/private_config.toml.tmpl` の target は repo 内の参照用 source として現在 `.chezmoiignore` で配布対象外にする（`dot_codex/CONTEXT.md` の記述は ADR 0037 で撤去済み）。managed surface の実効確認では `chezmoi managed` を正本にする。

## Surface の責務

- `skills/`: 実行手順の正本。詳細手順、判断基準、停止条件、出力フォーマットを定義し、そのまま正式入口として使う
- `orchestrate`: 全依頼の進行入口。Phase 0 で triage し、性質と規模に応じて inquiry / micro / standard / full の tier に振り分けて、Phase / Gate、Gate 3 前 docs 確認、request folder、agent routing、handoff、ユーザー確認つきで進める。tier により通す Phase / Gate を変え、inquiry は Phase 0 のみで完了する軽量経路、micro は最小工程に省く。Codex では main セッションが lead として agent 出力を次 agent の入力へ明示的に渡し、agent 間の直接通信を前提にしない。Claude Code では lead が specialist subagent と対応 skill を束ねる。workflow 上で必要な repo-local / managed agent / subagent 起動は standing authorization 済みとして扱い、tool 実行や停止線の判断とは分ける
- `research`: 事実確認、原因調査、影響調査、PoC、仕様確認の入口。bug / security / quality / compat / maintenance も、まず観測事実、制約、影響範囲、test entry point を集める段階ではここで扱う
- `grill`: 実装前の問い詰め、共有理解、inline knowledge capture の中核。目的、成功条件、非目的、制約、設計、実装順序、検証入口、対応関係を整理し、必要に応じて `CONTEXT.md`、docs、ADR、code と照合して確定した用語や判断を最小反映する
- `architecture`: architecture 改善候補の探索と候補選択後の grilling の入口。`zoom-out` 的な module / caller / 責務 / interface / data flow / security boundary の地図化を含み、実装順序確定は `grill`、差分作成は `implement` へ進める
- `implement`: 確認方法先行で、最小差分の実装、必要な整理、再確認を進める。対応 reference がある言語では保存形式や公開面のガードを足す
- `inspect`: 既存変更の受け入れ確認、bugfix / security / quality / compat の修正効果確認、rename / 削除 / surface 変更後の整合性確認を standalone で扱う
- `doc-followup`: 変更後の README、index、ADR、notes、CONTEXT、skill references などの追従更新を扱う。差分や変更根拠から影響する durable docs を特定し、確認できる参照ずれや古い導線を最小更新する。`orchestrate` では lead が Gate 3 前 docs 追従更新の手順として使う
- `caveman`: 出力を短く圧縮したい依頼で使う補助 skill。応答文体だけを変え、調査、計画、実装、レビュー、commit / push の責務は持たない
- `scribe`: README、既存 docs、運用手順、設計メモ、request folder、PRD、要件定義、設計、task、実装記録、検証結果、review、traceability、CONTEXT、ADR などの doc / artifact 作成・更新・整形の入口。変更後の参照ずれや docs 追従更新は `doc-followup`、置き場判断や共有理解の問い詰めが必要な場合は `grill` を使う
- `git-commit`, `git-push`: 通常 commit / push の正式入口。その他の Git 操作は skill を増やさず既定 prompt と停止線で扱う
- `agents/`: Codex と Claude Code の subagent 定義の入口。Codex では TOML、Claude Code では Markdown + YAML frontmatter で、調査・検証 specialist agent と reviewer agent を定義する。review 本体は対応する agent 定義で扱う
- `rules/`: 機械的な guard。Codex では安全に自走できる定番操作の `allow` と、root 削除、disk erase、filesystem format、package publish、auth logout、deploy / release など高リスク操作の `forbidden` を担う。Claude Code rules は対象 path 条件で読む短い運用ルールを担う

詳細なチェックリスト、テンプレート、例外規則は各 skill とその `references/` に集約する。旧 prefix ベースの surface の履歴は ADR にのみ残し、現行導線の説明には持ち込まない。
要求分類は user-facing workflow として案内せず、依頼を固定分類へ当てはめるための正本も置かない。
追従更新ではない docs / artifact 作成・整形は、multi-agent workflow が不要なら `scribe` を直接入口として使ってよい。変更後の参照ずれや docs 追従更新は `doc-followup` を使う。
root `CONTEXT-MAP.md` は multi-context の入口、各 `CONTEXT.md` は glossary を担当する。
CONTEXT は spec、作業メモ、実装判断を扱わない。

## 導線の考え方

固定の細かい代表導線は `dot_codex/AGENTS.md` や `dot_claude/CLAUDE.md` に持たせない。multi-agent workflow は `orchestrate` skill を正本にする。Phase 0、Triage 判定、Triage 停止線、星取表は `SKILL.md`、tier 決定後の flow と tier 固有の停止線差分は `references/inquiry.md` / `references/micro.md` / `references/standard.md` / `references/full.md` を正本にする。停止線で列挙する語・遷移句・standard / full 境界判定は `references/stop-lines.md` を正本にし、各 tier reference はそこを参照して tier 固有差分だけを持つ。`references/stop-lines.md` のカタログ語を改訂する際は、`references/gate-review.md` の `security-reviewer` 起動条件（停止線語と意味連動するが語彙系統は別管理）の追従も確認する。
実行時の入口判断は、要求分類表ではなく、各 `SKILL.md` の description、agent 定義、ユーザーが明示した依頼語、既存 docs / ADR / code で確認できる事実に基づいて行う。
迷う場合は、観測事実の取得を `research`、要件整理や実装前の変更境界、検証入口の問い詰めを `grill`、doc / artifact の作成・更新・整形を `scribe`、変更後の docs 追従更新を `doc-followup` に寄せる。実装は `implement`、変更後確認は `inspect` を使う。workflow 内の実装後 repo hygiene / docs / tooling 設定の仕上げは lead が `doc-followup` skill を使う。

## review 系 surface の役割分担

- Gate 1 の要件 review は `requirements-reviewer` を使う
- Gate 2 の設計 review は `design-reviewer` と `security-reviewer` を使う
- Gate 3 の品質 review は `quality-reviewer` と `security-reviewer` を使う
- Gate 3 前の docs / references / prose の追従更新と repo hygiene / tooling 設定の影響確認は lead が `doc-followup` skill で行い、Gate 3 reviewer は全変更セットと品質ゲート影響、security / CI 影響を確認する
- workflow 外の差分 review では、対象に応じて `quality-reviewer` / `security-reviewer` を明示的に呼んでよい
- generic review から `security-reviewer` への自動昇格は行わない
- `grill` は問い詰めと共有理解の整理専用であり、review 本体を担わない
- reviewer agent は、親がそのまま利用者へ渡しても読みやすい形で結果を返す
- `docs/README.md` は index、`dot_codex/AGENTS.md` と `dot_claude/CLAUDE.md` は運用契約と薄い surface 案内、`docs/notes/harness-regression-checks.md` は手動回帰シナリオを担当する

## Frontmatter Description 設計ルール

- skill の発火面は `SKILL.md` frontmatter の `name` と `description` であり、特に `description` を主な自然文入口として扱う
- `description` は 1-3 文程度に保ち、短くても入口と境界が分かる形にする
- 自動使用する skill の 1 文目は、明示的な skill 名指定がなくても文脈から選べる依頼語で書く
- `caveman`、`git-commit`、`git-push` の 1 文目は、ユーザーの明示依頼で使う手動入口として読める形にする
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
- [ADR 0019](../adr/0019-split-planning-and-docs-surface.md)
- [ADR 0020](../adr/0020-import-claude-sdlc-workflow-to-codex.md)
- [ADR 0023](../adr/0023-add-doc-followup-skill.md)
- [ADR 0024](../adr/0024-add-repository-maintainer-agent.md)
- [ADR 0034](../adr/0034-reduce-non-reviewer-agents.md)
- [ADR 0025](../adr/0025-orchestrate-triage-tier-routing.md)
- [ADR 0026](../adr/0026-add-inquiry-tier-to-orchestrate.md)
- [ADR 0027](../adr/0027-align-codex-skill-names-with-claude.md)
- [ADR 0028](../adr/0028-align-agent-names-with-skill-pairs.md)
- [ADR 0029](../adr/0029-orchestrate-autonomous-run-until-final-gate.md)
- [ADR 0030](../adr/0030-split-orchestrate-tier-flow-references.md)
- [ADR 0031](../adr/0031-add-gate-pass-user-approval-checkpoints.md)
- [ADR 0032](../adr/0032-auto-skip-gate-pass-approval-when-no-user-decision.md)
- [ADR 0033](../adr/0033-preauthorize-orchestrate-workflow-agent-spawn.md)
