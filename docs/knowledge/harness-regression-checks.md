# Harness Regression Checks

`dot_codex/` の docs / rules / agents / config に相当する source を更新したときに、人手で回す代表的な回帰チェック集です。
自動 eval 基盤の代わりではなく、共通ハーネスの回帰を早く見つけるための軽量な確認セットとして使います。

## 使い方

- 変更内容に近いシナリオを優先して回す
- 期待から外れた場合は、`docs/knowledge/`, `docs/adr/`, `skills/`, `rules/`, `agents/`, `config` のどこへ反映すべきかを切り分ける
- 新しい繰り返し失敗が見つかったら、この文書へ追加する前に `skill` や `rule` へ昇格すべきでないかを確認する
- 汎用 lint で拾わない repo 固有契約や導線の観点は、この文書で手動確認する
- 全体契約と薄い surface 案内は `dot_codex/AGENTS.md`、surface 設計の背景は `classification-driven-workflow-surface.md` を参照する

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

### 3.5. `git add` friction を rule mismatch と誤診しない

- 例: 「`git add docs dot_codex scripts/verify_taplo_parser.lua` で承認が必要になった」
- 期待:
  - まず `.git/index.lock` と `Operation not permitted` の有無を確認し、sandbox 書き込み失敗かどうかを切り分ける
  - explicit-path の `git add` が一度止まっても、即座に `git-add.rules` の緩和案へ飛ばない
  - 詳細は [git-add-approval-friction-diagnosis.md](./git-add-approval-friction-diagnosis.md) を参照する

### 4. 知見の昇格先を切り分けられる

- 例: 「毎回同じ整理をしているので残したい」
- 期待:
  - 通常知見なら `docs/knowledge/`
  - 判断記録なら `docs/adr/`
  - 繰り返し手順なら `skills/`
  - 機械的ガードなら `rules/`
  - 専門化した補助役なら `agents/`

### 5. `AGENTS.md` が契約と薄い surface 案内として機能する

- 例: 「ハーネスの詳細知識はどこを読めばよいか」
- 期待:
  - `dot_codex/AGENTS.md` は契約と薄い surface 案内の入口として案内される
  - `skills / agents / rules / docs` の役割分担は `dot_codex/AGENTS.md` の説明と矛盾しない
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
- 観測ポイント:
  - 依頼内容に近い skill / reviewer が案内される
  - 旧導線向けの語彙や内部用語が再導入されていない
  - skill / reviewer の役割分担が自然文でも崩れていない
  - 具体的な導線、命名規約、frontmatter 説明ルールは [Classification-Driven Workflow Surface](./classification-driven-workflow-surface.md) を正本にする

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
- 観測ポイント:
  - 入口は知識の置き場判断 helper に残り、docs 更新専用入口と混同されない
  - 通常知見と判断記録の置き場が混ざらない
  - 詳細な routing や skill の役割分担は [Classification-Driven Workflow Surface](./classification-driven-workflow-surface.md) と各 `SKILL.md` を正本にする

### 11. ADR が状態付き台帳として扱われる

- 例: 「この判断を ADR として残したい」「この ADR はもう置き換えられた」
- 観測ポイント:
  - ADR が通常知見と混ざらず、状態付き台帳として扱われる
  - 新規作成と状態更新の責務が分離されたまま保たれている
  - 手順メモや運用メモが ADR に再流入していない
  - 状態モデルやメタデータ、運用フローの詳細は [ADR Ledger Model](./adr-ledger-model.md) を正本にする

### 12. 変更後知見化が `skip / knowledge / adr` で振り分けられる

- 例: 「このコミット後に何を残すべきか判断したい」
- 観測ポイント:
  - 一過性 change と durable な知見化対象が切り分けられる
  - 通常知見と判断記録の送り先が混ざらない
  - diff だけから判断を推測して ADR を作らない
  - triage の詳細は関連 skill と [ADR Ledger Model](./adr-ledger-model.md) を正本にする

### 13. ADR acceptance policy と direct ADR commit が一貫する

- 例: 「ADR だけをコミットした」「project policy が未設定や不正値のときどうなるか」
- 観測ポイント:
  - ADR の受理タイミングが current project の policy と矛盾しない
  - direct ADR commit を含む例外導線が他の知見化フローと競合していない
  - 受理や supersede の扱いが状態付き台帳モデルと整合している
  - policy や例外導線の詳細は [ADR Ledger Model](./adr-ledger-model.md) と関連 skill を正本にする

### 14. `git-push` の返答が最小契約を保つ

- 例: 「このブランチを push して」「upstream を設定して push して」「push 対象がない」
- 観測ポイント:
  - `git-push` の結果報告で、push 先と実行結果が利用者に分かる
  - upstream の既存利用、設定、未設定停止などの違いが埋もれない
  - behind / diverged / 認証失敗のような停止理由が必要十分に伝わる
  - 結果フォーマットの詳細は `git-push` skill を正本にする

### 15. `update-adr-status` direct entry が policy 契約に従う

- 例: 「この ADR を Accepted にしたい」「project policy が未設定や不正値のときの direct entry」
- 観測ポイント:
  - direct entry の状態更新が current project の policy と矛盾しない
  - supersede 更新が明示根拠のある場合だけ行われる
  - 詳細な更新条件は [ADR Ledger Model](./adr-ledger-model.md) と `update-adr-status` skill を正本にする

### 16. 既存の主要入口が壊れていない

- 例: 「バグを直したい」「リファクタしたい」「新機能を追加したい」
- 観測ポイント:
  - docs 更新後も、主要な依頼が適切な skill / reviewer agent の入口へ案内される
  - `dot_codex/AGENTS.md`、surface 文書、各 `SKILL.md` / agent 定義の役割分担が矛盾しない

### 17. planning skill が整理専用のまま保たれる

- 例: 「成功条件と非目的を詰めたい」「実装順序と検証方法を詰めたい」
- 観測ポイント:
  - planning skill が整理専用のまま保たれ、review 本体を抱え込んでいない
  - 要件 review と実装計画 review の責務が分離されたまま維持されている
  - 導線の詳細は [Classification-Driven Workflow Surface](./classification-driven-workflow-surface.md) と各 `SKILL.md` / agent 定義を正本にする

### 18. review summary helper が reviewer 起動元へ昇格しない

- 例: 「レビュー findings を整理したい」「この差分をレビューして結果までまとめたい」
- 観測ポイント:
  - review summary helper が reviewer 結果の整形に責務を絞ったまま保たれている
  - review 本体や reviewer 選択を代行しない
  - 導線と役割分担の詳細は [Classification-Driven Workflow Surface](./classification-driven-workflow-surface.md) と関連 skill / agent 定義を正本にする

### 19. repo 固有契約の軽い確認を手動回帰で補う

- 例: 「agent metadata や rule metadata の欠落、リンク切れ、`.codex` 推奨文言を見落としていないか」
- 観測ポイント:
  - `dot_codex/agents/*.toml` の必須 metadata が欠けていない
  - `dot_codex/rules/*.rules` の説明責務が崩れていない
  - `dot_codex/` と `docs/` 配下の参照先が実在する
  - knowledge の置き場として project-local `.codex` を勧める文面が再流入していない
  - これらの観点は自動失敗ではなく、変更時の手動 review で確認する

### 20. reviewer 設定 tier が役割分担に沿って保たれる

- 例: 「reviewer agent の model や `model_reasoning_effort` を見直した」「品質重視や速度重視で tier を変えたい」
- 観測ポイント:
  - reviewer 設定が役割分担と矛盾せず、不要な一律変更になっていない
  - planning 系 reviewer と差分 review 系 reviewer の責務差が保たれている
  - 具体的な tier や既定値は agent 定義と runtime config を正本にする

## 関連文書

- [ADR Ledger Model](./adr-ledger-model.md)
- [Harness Design Principles](./harness-design-principles.md)
- [Classification-Driven Workflow Surface](./classification-driven-workflow-surface.md)
- [ADR 0005](../adr/0005-keep-harness-verification-focused-on-repo-contracts.md)
- [ADR 0007](../adr/0007-retire-harness-verifier-script.md)
