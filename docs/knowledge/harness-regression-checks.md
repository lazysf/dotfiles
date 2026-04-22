# Harness Regression Checks

`dot_codex/` の docs / rules / agents / config に相当する source を更新したときに、人手で回す代表的な回帰チェック集です。
自動 eval 基盤の代わりではなく、共通ハーネスの回帰を早く見つけるための軽量な確認セットとして使います。

## 使い方

- 変更内容に近いシナリオを優先して回す
- 期待から外れた場合は、`docs/knowledge/`, `docs/adr/`, `skills/`, `rules/`, `agents/`, `config` のどこへ反映すべきかを切り分ける
- 新しい繰り返し失敗が見つかったら、この文書へ追加する前に `skill` や `rule` へ昇格すべきでないかを確認する

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
  - 正式入口は skill 群として案内される
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
  - `product-planning`, `code-review`, `git-commit` など、依頼内容に近い skill がそのまま案内される
  - 旧 implicit invocation 前提の説明が残っていない
  - 旧導線向けの内部専用表現が skill の入口説明に残っていない
  - 近接 skill の境界が自然文プロンプトでも崩れない
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
  - 「この差分をレビューしたい」 -> `code-review`
  - 「レビュー findings を整理したい」 -> `review-findings-summary`
  - 「この依頼をどの分類で扱うべきか迷う」 -> `task-classification`
  - 「バグ修正の結果を確認したい」 -> `change-verification`

### 8. docs-only 依頼が `docs-update` に導かれる

- 例: 「README の手順だけ更新したい」「既存の運用 docs を実装に合わせて直したい」
- 期待:
  - docs-only の依頼では `docs-update` が正式入口として案内される
  - 主分類を増やさず、既存ドキュメント更新の専用入口として扱われる
  - 知識の置き場判断と混同されない

### 9. 知識の置き場相談は knowledge 系導線に残る

- 例: 「今回の知見をどこに残すべきか」「通常知見か ADR かを決めたい」
- 期待:
  - 入口は `capture-knowledge-triage` に導かれる
  - 通常知見なら `write-knowledge-note`、判断記録なら `write-adr` に渡される
  - `docs-update` が知識の置き場判断を奪わない

### 10. ADR が状態付き台帳として扱われる

- 例: 「この判断を ADR として残したい」「この ADR はもう置き換えられた」
- 期待:
  - 新規 ADR は `write-adr` が `Proposed` として作成する
  - 既存 ADR の `Accepted` / `Superseded` / `Rejected` は `update-adr-status` が担当する
  - `Supersedes` / `Superseded-By` は明示根拠があるときだけ更新される
  - 新 ADR 側の `Supersedes` は `write-adr` 入力で明示され、`update-adr-status` が不足分を補完しない
  - 新 ADR 側に一致する `Supersedes` がなければ、旧 ADR は `Superseded` にならない
  - 手順メモや落とし穴は ADR へ押し込まず `docs/knowledge/` に分けられる

### 11. 変更後知見化が `skip / knowledge / adr` で振り分けられる

- 例: 「このコミット後に何を残すべきか判断したい」
- 期待:
  - `capture-change-knowledge` は docs-only や一過性 change を `skip` にできる
  - 手順や確認ポイントは `write-knowledge-note` へ渡される
  - 判断理由が明示された change だけが `write-adr` へ渡される
  - diff だけから判断を推測して ADR を作らない

### 12. ADR acceptance policy と direct ADR commit が一貫する

- 例: 「ADR だけをコミットした」「`adr_acceptance_policy` が未設定や不正値のときどうなるか」
- 期待:
  - policy の読み元は current project の設定として一貫している
  - key 未設定なら `commit` fallback になる
  - 不正値なら push / commit 自体は成功扱いのまま、自動 `Accepted` 化だけが skip される
  - `新規 ADR 1 件 + 任意の docs/README.md 変更` だけの commit は `ADR-only commit` として `commit` policy の受理対象になる
  - `ADR-only commit` の新 ADR に `Supersedes` がある場合は、受理後に旧 ADR も `Superseded` になる
  - `default_branch` policy でも、受理対象の新 ADR に `Supersedes` があれば旧 ADR まで反映される
  - それ以外の docs-only commit は従来どおり知見化も ADR 受理も起こさない

### 13. `update-adr-status` direct entry が policy 契約に従う

- 例: 「この ADR を Accepted にしたい」「project policy が未設定や不正値のときの direct entry」
- 期待:
  - `Accepted` 遷移でも policy の読み元は current project の設定として一貫している
  - key 未設定なら `commit` fallback になる
  - 不正値なら `skipped(invalid-adr-acceptance-policy)` になる
  - `Superseded` は引き続き新 ADR 側の明示 `Supersedes` がある場合だけ許可される

### 14. 既存の主要導線が壊れていない

- 例: 「バグを直したい」「リファクタしたい」「新機能を追加したい」
- 期待:
  - bugfix は `bug-diagnosis -> code-implementation-loop -> change-verification`
  - maintenance は `maintenance-analysis -> code-implementation-loop -> change-testing -> code-review`
  - feature は `request-shaping` / `task-intake` / `product-planning` / `implementation-planning -> code-implementation-loop -> change-testing -> code-review`
  - `docs-update` 追加後も、既存の skill 導線が別用途へ押し流されない

### 15. planning reviewer が skill-first 導線を壊さない

- 例: 「成功条件と非目的を詰めたい」「実装順序と検証方法を詰めたい」
- 期待:
  - 正式入口は引き続き `product-planning` / `implementation-planning` として案内される
  - `product-planning-reviewer` / `implementation-planning-reviewer` は内部補助 reviewer として扱われる
  - reviewer の raw JSON をそのままユーザー向けの最終返答に流さない
  - planning reviewer の追加後も、`code-review` は `quality-reviewer` / `security-reviewer` 中心のままで説明と起動条件が崩れない

### 16. review summary helper が reviewer 起動元へ昇格しない

- 例: 「レビュー findings を整理したい」「この差分をレビューして結果までまとめたい」
- 期待:
  - `review-findings-summary` は reviewer 結果の統合と整形に専念し、自分では reviewer を起動しない
  - 差分レビューの reviewer 起動は `code-review` が担う
  - 要件 draft reviewer の起動は `product-planning` が担う
  - 実装計画 draft reviewer の起動は `implementation-planning` が担う
- 代表プロンプト:
  - 「レビュー findings を整理したい」 -> `review-findings-summary`
  - 「この差分をレビューして結果までまとめたい」 -> `code-review`
  - 「要件 draft の抜け漏れを見たい」 -> `product-planning`
  - 「実装計画 draft の危ない点を見たい」 -> `implementation-planning`

## 関連文書

- [Harness Design Principles](./harness-design-principles.md)
- [Classification-Driven Workflow Surface](./classification-driven-workflow-surface.md)
