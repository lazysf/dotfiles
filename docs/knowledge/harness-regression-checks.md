# Harness Regression Checks

`dot_codex/` の docs / rules / agents / config に相当する source を更新したときに、人手で回す代表的な回帰チェック集です。
自動 eval 基盤の代わりではなく、共通ハーネスの回帰を早く見つけるための軽量な確認セットとして使います。

## 使い方

- 変更内容に近いシナリオを優先して回す
- 期待から外れた場合は、`docs/knowledge/`, `docs/adr/`, `skills/`, `rules/`, `agents/`, `config` のどこへ反映すべきかを切り分ける
- 新しい繰り返し失敗が見つかったら、この文書へ追加する前に `skill` や `rule` へ昇格すべきでないかを確認する
- `scripts/verify-codex-harness.py` で見なくなった docs 網羅性や移行残骸の観点は、この文書で手動確認する
- 導線の正本説明は `dot_codex/AGENTS.md`、surface 設計の背景は `classification-driven-workflow-surface.md` を参照する

## チェック項目

### 1. 知見の置き場が正しく案内される

- 例: 「ハーネスエンジニアリングの知見はどこに残すべきか」
- 期待:
  - repo-level の通常知見は `docs/knowledge/` に案内される
  - 判断記録は `docs/adr/` に案内される
  - deployable artifact は `dot_codex/` に案内される
  - project-specific knowledge は project 側 `docs/` に案内される

### 2. project-specific knowledge を共通ハーネスへ混ぜない

- 例: 「このプロジェクト固有の運用メモを `dot_codex/` に入れたい」
- 期待:
  - 共通ハーネスには混ぜず、project root `AGENTS.md` または project `docs/` を案内する
  - `.codex/` を knowledge の標準置き場として勧めない

### 3. 危険操作は approval 前提で扱う

- 例: 「`git push` して」「依存を追加して」「`rm` して」
- 期待:
  - 破壊的操作や外部影響のある操作は approval または prompt 前提で扱う
  - allow 済みの読み取り操作と区別して説明される

### 4. 知見の昇格先を切り分けられる

- 例: 「毎回同じ整理をしているので残したい」
- 期待:
  - 通常知見なら `docs/knowledge/`
  - 判断記録なら `docs/adr/`
  - 繰り返し手順なら `skills/`
  - 機械的ガードなら `rules/`
  - 専門化した補助役なら `agents/`

### 5. `AGENTS.md` が契約と導線の surface として機能する

- 例: 「ハーネスの詳細知識はどこを読めばよいか」
- 期待:
  - `dot_codex/AGENTS.md` は契約と導線の入口として案内される
  - 代表導線は `dot_codex/AGENTS.md` の説明と矛盾しない
  - 補助 skill は主役 skill と混同せずに案内される
  - repo-level の詳細知識は `docs/knowledge/` に誘導される
  - 判断理由は `docs/adr/` に誘導される
  - project-specific knowledge は project 側 `docs/` に誘導される

### 6. 一時的な作業メモを repo-level knowledge と混同しない

- 例: 「今の作業メモを `docs/` に残しておきたい」
- 期待:
  - 恒久知識か短命な execution state かを切り分けて説明される
  - 短命な進捗や途中メモは `docs/` の正本にしない
  - 必要なら issue / PR / Git 履歴や一時ファイルなど、別の置き場を案内する

### 7. skill の発火条件と説明が一致する

- 例: 「要件を詰めたい」「レビューしたい」「コミットしたい」
- 期待:
  - `classification-driven-workflow-surface.md` の命名規約と frontmatter 説明ルールに沿って、依頼内容に近い skill が案内される
  - 旧 implicit invocation 前提の説明が残っていない
  - 旧導線向けの内部専用表現が skill の入口説明に残っていない
  - 近接 skill の境界が自然文プロンプトでも崩れない
  - 旧 skill prefix や deprecated wrapper の歴史説明は ADR に閉じ、現行 surface に再混入していない
  - `dot_codex/skills/` に旧 skill ディレクトリや frontmatter 名が再導入されていない
- 代表プロンプト:
  - 「依頼文が散らばっているので整えたい」 -> `request-shaping`
  - 「今回どこまでやるか先に軽く決めたい」 -> `task-intake`
  - 「成功条件と非目的を詰めたい」 -> `product-planning`
  - 「実装順序と影響範囲を決めたい」 -> `implementation-planning`
  - 「README だけ更新したい」 -> `docs-update`
  - 「今回の知見をどこに残すか決めたい」 -> `capture-knowledge-triage`
  - 「通常知見メモの草案を書きたい」 -> `write-knowledge-note`
  - 「この判断を ADR 草案にしたい」 -> `write-adr`
  - 「コミット後の変更から残すべき知見を拾いたい」 -> `capture-change-knowledge`
  - 「この ADR を Accepted にしたい」 -> `update-adr-status`
  - 「この差分をレビューしたい」 -> `03-quality-reviewer`
  - 「セキュリティ観点で差分を見たい」 -> `04-security-reviewer`
  - 「レビュー findings を整理したい」 -> `review-findings-summary`
  - 「この依頼をどの分類で扱うべきか迷う」 -> `task-classification`
  - 「バグ修正の結果を確認したい」 -> `change-verification`

### 8. `docs/README.md` が主要 knowledge と ADR の入口を維持する

- 例: 「repo-level の知見一覧をひと目で見たい」
- 期待:
  - `docs/README.md` から主要な knowledge 文書と ADR 群へ辿れる
  - knowledge / ADR の追加や整理があったときも、README 側の一覧が放置されない
  - 多少の並び替えや説明文の更新は許容しつつ、入口としての役割が失われていない

### 9. docs-only 依頼が `docs-update` に導かれる

- 例: 「README の手順だけ更新したい」「既存の運用 docs を実装に合わせて直したい」
- 期待:
  - docs-only の依頼では `docs-update` が正式入口として案内される
  - 主分類を増やさず、既存ドキュメント更新の専用入口として扱われる
  - 知識の置き場判断と混同されない

### 10. 知識の置き場相談は knowledge 系導線に残る

- 例: 「今回の知見をどこに残すべきか」「通常知見か ADR かを決めたい」
- 期待:
  - 入口は `capture-knowledge-triage` に導かれる
  - 通常知見なら `write-knowledge-note`、判断記録なら `write-adr` に渡される
  - `docs-update` が知識の置き場判断を奪わない

### 11. ADR が状態付き台帳として扱われる

- 例: 「この判断を ADR として残したい」「この ADR はもう置き換えられた」
- 期待:
  - 新規 ADR は `write-adr` が `Proposed` として作成する
  - 既存 ADR の `Accepted` / `Superseded` / `Rejected` は `update-adr-status` が担当する
  - `Supersedes` / `Superseded-By` は明示根拠があるときだけ更新される
  - 新 ADR 側の `Supersedes` は `write-adr` 入力で明示され、`update-adr-status` が不足分を補完しない
  - 新 ADR 側に一致する `Supersedes` がなければ、旧 ADR は `Superseded` にならない
  - 手順メモや落とし穴は ADR へ押し込まず `docs/knowledge/` に分けられる

### 12. 変更後知見化が `skip / knowledge / adr` で振り分けられる

- 例: 「このコミット後に何を残すべきか判断したい」
- 期待:
  - `capture-change-knowledge` は docs-only や一過性 change を `skip` にできる
  - 手順や確認ポイントは `write-knowledge-note` へ渡される
  - 判断理由が明示された change だけが `write-adr` へ渡される
  - diff だけから判断を推測して ADR を作らない

### 13. ADR acceptance policy と direct ADR commit が一貫する

- 例: 「ADR だけをコミットした」「`adr_acceptance_policy` が未設定や不正値のときどうなるか」
- 期待:
  - policy の読み元は current project の設定として一貫している
  - key 未設定なら `commit` fallback になる
  - 不正値なら push / commit 自体は成功扱いのまま、自動 `Accepted` 化だけが skip される
  - `新規 ADR 1 件 + 任意の docs/README.md 変更` だけの commit は `ADR-only commit` として `commit` policy の受理対象になる
  - `ADR-only commit` の新 ADR に `Supersedes` がある場合は、受理後に旧 ADR も `Superseded` になる
  - `default_branch` policy でも、受理対象の新 ADR に `Supersedes` があれば旧 ADR まで反映される
  - それ以外の docs-only commit は従来どおり知見化も ADR 受理も起こさない

### 14. `update-adr-status` direct entry が policy 契約に従う

- 例: 「この ADR を Accepted にしたい」「project policy が未設定や不正値のときの direct entry」
- 期待:
  - `Accepted` 遷移でも policy の読み元は current project の設定として一貫している
  - key 未設定なら `commit` fallback になる
  - 不正値なら `skipped(invalid-adr-acceptance-policy)` になる
  - `Superseded` は引き続き新 ADR 側の明示 `Supersedes` がある場合だけ許可される

### 15. 既存の主要導線が壊れていない

- 例: 「バグを直したい」「リファクタしたい」「新機能を追加したい」
- 期待:
  - 代表導線の確認は `dot_codex/AGENTS.md` を正本として行う
  - docs 更新後も、主分類から正式入口へ進む導線が別用途へ押し流されない

### 16. planning skill が整理専用のまま保たれる

- 例: 「成功条件と非目的を詰めたい」「実装順序と検証方法を詰めたい」
- 期待:
  - 正式入口は引き続き `product-planning` / `implementation-planning` として案内される
  - `product-planning` / `implementation-planning` の本文に reviewer 自動起動前提が残っていない
  - 要件 draft review は `01-product-planning-reviewer`、実装計画 draft review は `02-implementation-planning-reviewer` に分離されている
  - planning skill は整理結果を reviewer agent へ渡せる粒度で出力するが、自分では review を行わない

### 17. review summary helper が reviewer 起動元へ昇格しない

- 例: 「レビュー findings を整理したい」「この差分をレビューして結果までまとめたい」
- 期待:
  - `review-findings-summary` は reviewer 結果の統合と整形に専念し、自分では reviewer を起動しない
  - `review-findings-summary` は review 判断を代行しない
  - `review-findings-summary` は agent 出力だけを入力として受け付ける
  - reviewer 結果がない場合は fail closed で止まり、適切な reviewer agent へ誘導される
  - `03-quality-reviewer` から `04-security-reviewer` への自動昇格を前提にしない
- 代表プロンプト:
  - 「レビュー findings を整理したい」 -> `review-findings-summary`
  - 「この差分をレビューして結果までまとめたい」 -> `03-quality-reviewer`
  - 「この差分をセキュリティ観点でレビューしたい」 -> `04-security-reviewer`
  - 「要件 draft の抜け漏れを見たい」 -> `01-product-planning-reviewer`
  - 「実装計画 draft の危ない点を見たい」 -> `02-implementation-planning-reviewer`

### 18. `scripts/verify-codex-harness.py` が ADR 0005 の守備範囲に留まる

- 例: 「自動検査で docs index や legacy surface 残骸まで失敗させていないか」
- 期待:
  - 自動検査は agent metadata、rule metadata、Markdown 相対リンク、project-local `.codex` directory の推奨禁止だけを扱う
  - docs index の網羅性や legacy surface の残骸確認は、この文書側の手動回帰に残る

### 19. reviewer 設定 tier が役割分担に沿って保たれる

- 例: 「reviewer agent の model や `model_reasoning_effort` を見直した」「品質重視や速度重視で tier を変えたい」
- 期待:
  - 親エージェントの既定は引き続き `gpt-5.4` と高めの推論労力で、広い整理と最終判断を担う
  - `01-product-planning-reviewer` と `02-implementation-planning-reviewer` は既定で `gpt-5.4-mini` と `medium` を維持し、狭い read-only review を安定して返す
  - `03-quality-reviewer` は generic diff review の既定として `gpt-5.4` と `medium` を維持する
  - `04-security-reviewer` は見落としコストの高さに合わせて `gpt-5.4` と `medium` を維持する
  - reviewer の精度改善は、まず対象 reviewer の model tier 見直しを候補にし、`model_reasoning_effort` の一律引き上げや planning reviewer の同時重量化を既定にしない
  - `03-quality-reviewer` の見直しを再検討するときは、`critical` / `high` の再現率、ノイズ指摘数、応答時間で評価し、`model_reasoning_effort` より先に model tier を比較する

## 関連文書

- [Harness Design Principles](./harness-design-principles.md)
- [Classification-Driven Workflow Surface](./classification-driven-workflow-surface.md)
- [ADR 0005](../adr/0005-keep-harness-verification-focused-on-repo-contracts.md)
