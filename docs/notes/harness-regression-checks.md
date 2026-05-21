# Harness Regression Checks

`dot_codex/` の docs / rules / agents / config に相当する source を更新したときに、人手で回す代表的な回帰チェック集です。
自動 eval 基盤の代わりではなく、共通ハーネスの回帰を早く見つけるための軽量な確認セットとして使います。

## 使い方

- 変更内容に近いシナリオを優先して回す
- 期待から外れた場合は、`docs/notes/`, `docs/adr/`, `skills/`, `rules/`, `agents/`, `config` のどこへ反映すべきかを切り分ける
- 新しい繰り返し失敗が見つかったら、この文書へ追加する前に `skill` や `rule` へ昇格すべきでないかを確認する
- 汎用 lint で拾わない repo 固有契約や導線の観点は、この文書で手動確認する
- 全体契約と薄い surface 案内は `dot_codex/private_AGENTS.md.tmpl`、surface 設計の背景は [Runtime Surface Guidance](./runtime-surface-guidance.md) を参照する

## チェック項目

### 1. 知見の置き場が正しく案内される

- 例: 「ハーネスエンジニアリングの知見はどこに残すべきか」
- 期待:
  - repo-level の通常知見は `docs/notes/` に案内される
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

- 例: 「`git add docs dot_codex .tombi.toml mise.toml dot_config/mise/config.toml.tmpl` で承認が必要になった」
- 期待:
  - まず `.git/index.lock` と `Operation not permitted` の有無を確認し、sandbox 書き込み失敗かどうかを切り分ける
  - explicit-path の `git add` が一度止まっても、即座に `git-add.rules` の緩和案へ飛ばない
  - 詳細は [git-add-approval-friction-diagnosis.md](./git-add-approval-friction-diagnosis.md) を参照する

### 3.6. Git rules は最小 allow だけで整理される

- 例: 「Git rules を見直した」「read-only Git 操作を allow へ寄せた」
- 期待:
  - `decision = "prompt"` と `decision = "forbidden"` は置かない
  - allow 対象は `git status`、`git diff`、`git branch -vv`、`git remote -v`、`git log` だけにする
  - `git add` / `git commit` は allow せず、既定 prompt と `git-commit` skill の停止線に任せる
  - 通常 push は allow せず、既定 prompt に任せる
  - force push、hard reset、ignored file を含む clean も個別 rule を置かず、既定 prompt と skill 停止線に任せる
  - その他の Git 変更操作は rule を置かず、既定 prompt に任せる

### 4. 知見の昇格先を切り分けられる

- 例: 「毎回同じ整理をしているので残したい」
- 期待:
  - 通常知見なら `docs/notes/`
  - 判断記録なら `docs/adr/`
  - 繰り返し手順なら `skills/`
  - 機械的ガードなら `rules/`
  - 専門化した補助役なら `agents/`

### 5. `AGENTS.md` が契約と薄い surface 案内として機能する

- 例: 「ハーネスの詳細知識はどこを読めばよいか」
- 期待:
  - `dot_codex/private_AGENTS.md.tmpl` は契約と薄い surface 案内の入口として案内される
  - `skills / agents / rules / docs` の役割分担は `dot_codex/private_AGENTS.md.tmpl` の説明と矛盾しない
  - 補助 skill は主役 skill と混同せずに案内される
  - repo-level の詳細知識は `docs/notes/` に誘導される
  - 判断理由は `docs/adr/` に誘導される
  - project-specific knowledge は project 側 `docs/` に誘導される

### 6. 一時的な作業メモを repo-level knowledge と混同しない

- 例: 「今の作業メモを `docs/` に残しておきたい」
- 期待:
  - 恒久知識か短命な execution state かを切り分けて説明される
  - 短命な進捗や途中メモは `docs/` の正本にしない
  - 必要なら issue / PR / Git 履歴や一時ファイルなど、別の置き場を案内する

### 7. skill の発火条件と説明が一致する

- 例: 「要件を詰めたい」「変更後の参照漏れも見て」「コミットしたい」
- 観測ポイント:
  - `caveman`、`git-commit`、`git-push` 以外の skill は、明示的な skill 名指定がなくても文脈に応じて自動使用される
  - `caveman`、`git-commit`、`git-push` は、ユーザーの明示依頼で使う手動入口として保たれる
  - 依頼内容に近い skill / reviewer が案内される
  - 旧導線向けの語彙や内部用語が再導入されていない
  - skill / reviewer の役割分担が自然文でも崩れていない
  - 具体的な導線、命名規約、frontmatter 説明ルールは [Runtime Surface Guidance](./runtime-surface-guidance.md) を正本にする

### 7.5. 入口整理と変更後確認が統合後 surface に乗る

- 例: 「依頼文が散らばっているので今回どこまでやるか整理したい」「新機能の受け入れ確認をしたい」「バグ修正が効いたか確認したい」
- 観測ポイント:
  - 散らばった依頼や軽い停止線整理は `grill`、PRD draft 作成や整形は `scribe` が正式入口として案内される
  - `scribe` で生成した PRD は draft として扱われ、正式 docs への保存や issue 化は明示依頼がある時だけ扱われる
  - feature / maintenance の受け入れ確認は `verification` の `acceptance` mode として扱われる
  - bugfix / security / quality / compat の修正効果確認は `verification` の `verification` mode として扱われる
  - 要求分類そのものを user-facing workflow として案内しない

### 8. `docs/README.md` が主要 note と ADR の入口を維持する

- 例: 「repo-level の知見一覧をひと目で見たい」
- 期待:
  - `docs/README.md` から主要な note と ADR 群へ辿れる
  - note / ADR の追加や整理があったときも、README 側の一覧が放置されない
  - 多少の並び替えや説明文の更新は許容しつつ、入口としての役割が失われていない

### 9. docs-only 依頼が `scribe` に乗る

- 例: 「README の手順だけ更新したい」「既存の運用 docs を実装に合わせて直したい」
- 期待:
  - docs-only の依頼では `scribe` が文脈に応じて自動使用される
  - 新しい user-facing workflow を増やさず、既存ドキュメント更新と artifact 整形の入口として扱われる
  - 知識の置き場判断や共有理解の問い詰めが必要な場合は `grill` と切り分けられる

### 10. 知見蓄積は `grill` / `scribe` に分担される

- 例: 「docs と照らして計画を問い詰めて」「今回の用語を CONTEXT に残して」「この判断を ADR として残したい」
- 観測ポイント:
  - user-facing 入口は、問い詰めと置き場判断を `grill`、doc / artifact の作成・更新・整形を `scribe` に分けて案内される
  - docs-aware な grilling の中で evidence 収集、置き場判断、必要な CONTEXT / existing docs / note / ADR 更新候補が扱われる
  - docs / note / ADR / ADR metadata は、会話中に確定した durable knowledge として扱われる
  - 通常知見と判断記録の置き場が混ざらない
  - 詳細な workflow は `grill` / `scribe` skill と [ADR Ledger Model](./adr-ledger-model.md) を正本にする

### 11. ADR が状態付き台帳として扱われる

- 例: 「この判断を ADR として残したい」「この ADR はもう置き換えられた」
- 観測ポイント:
  - ADR が通常知見と混ざらず、状態付き台帳として扱われる
  - 新規作成、採用、旧 ADR の退役が順序付き action として扱われる
  - 手順メモや運用メモが ADR に再流入していない
  - 状態モデルやメタデータ、運用フローの詳細は [ADR Ledger Model](./adr-ledger-model.md) を正本にする

### 12. `grill` が durable knowledge を inline 最小反映する

- 例: 「docs と照らしてこの設計を grill して」「この用語が固まったので CONTEXT に残して」
- 観測ポイント:
  - 一過性 change と durable な知見化対象が切り分けられる
  - 用語が確定したら対象 context の `CONTEXT.md` が inline 更新される
  - 対象 context が曖昧な場合は推測で root `CONTEXT.md` を作らない
  - ADR 作成と状態更新の順序が崩れない
  - note と ADR の送り先が混ざらない
  - diff だけから判断を推測して ADR を作らない
  - 詳細は `grill` / `scribe` skill と [ADR Ledger Model](./adr-ledger-model.md) を正本にする

### 13. ADR 採用判断と状態更新が一貫する

- 例: 「この ADR を採用済みにしたい」「ADR 作成後に Accepted へ進めたい」
- 観測ポイント:
  - ADR の `Accepted` 化が commit 作成と切り離されている
  - 採用判断が明示された場合だけ `scribe` で状態更新される
  - `Superseded` は、新 ADR 側に対象 ADR を指す `Supersedes` が明示されている場合だけ更新される
  - 受理や supersede の扱いが状態付き台帳モデルと整合している
  - ADR lifecycle の詳細は [ADR Ledger Model](./adr-ledger-model.md) と `scribe` skill を正本にする

### 13.5. `verification` が整合性を確認する

- 例: 「この変更の整合性を確認したい」「ファイルを rename したので参照漏れを確認したい」「`.chezmoiignore` 変更の影響を見たい」
- 観測ポイント:
  - `git-commit` は commit 作成に責務を絞り、条件付き整合性 preflight を自動実行しない
  - README、docs、index、一覧、参照リンクの追従漏れ確認は `verification` の `consistency` mode で扱われる
  - ファイル追加、rename、削除、ignore 変更の参照追従確認は `verification` の対象になる
  - `.gitignore` は Git 追跡対象、`.chezmoiignore` は chezmoi 配布対象として独立に確認される
  - `verification` が判断を要する事項を見つけた場合、確認すべき点が返る
  - `verification` が修正を加えた場合、次の commit 導線で差分と 1 コミット 1 変更のまとまりが確認される

### 14. `git-push` が知見蓄積を行わない

- 例: 「このブランチを push して」「upstream を設定して push して」
- 観測ポイント:
  - `git-push` は push 実行と upstream 判定だけを扱う
  - 知見蓄積、ADR 作成、ADR 状態更新を開始しない
  - 知見整理が必要な場合でも push 結果と混ぜず、必要なら別 action として `grill` / `scribe` を案内する

### 15. `git-push` の返答が最小契約を保つ

- 例: 「このブランチを push して」「upstream を設定して push して」「push 対象がない」
- 観測ポイント:
  - `git-push` の結果報告で、push 先と実行結果が利用者に分かる
  - upstream の既存利用、設定、未設定停止などの違いが埋もれない
  - behind / diverged / 認証失敗のような停止理由が必要十分に伝わる
  - 知見蓄積の結果が push 結果に混ざらない
  - 結果フォーマットの詳細は `git-push` skill を正本にする

### 16. ADR 状態更新が明示根拠に従う

- 例: 「この ADR を Accepted にしたい」「Supersedes に合わせて旧 ADR を Superseded にしたい」
- 観測ポイント:
  - `scribe` の状態更新が `grill` で確認した採用判断や supersede 根拠に沿っている
  - supersede 更新が明示根拠のある場合だけ行われる
  - 詳細な更新条件は [ADR Ledger Model](./adr-ledger-model.md) と `scribe` skill を正本にする

### 17. 既存の主要入口が壊れていない

- 例: 「バグを直したい」「リファクタしたい」「新機能を追加したい」
- 観測ポイント:
  - docs 更新後も、主要な依頼が適切な skill / reviewer agent の入口へ案内される
  - `dot_codex/private_AGENTS.md.tmpl`、surface 文書、各 `SKILL.md` / agent 定義の役割分担が矛盾しない

### 17.5. リファクタや品質改善の入口が統合後 surface に乗る

- 例: 「過剰な分岐を減らして既存挙動を守りたい」「どこまで整理するか決めたい」「性能を改善したい」「実装に入りたい」
- 観測ポイント:
  - architecture 改善候補を見つけたい依頼は `architecture` に案内される
  - `zoom-out` 的な codebase 地図化は独立 skill ではなく `architecture` の探索ステップとして扱われる
  - `architecture` は候補出しと候補選択後の grilling までを扱い、実装順序確定は `grill` に進める
  - 過剰実装、不要な抽象化、複雑な分岐を既存挙動維持で減らす計画は `grill` に案内される
  - リファクタ境界そのものを決める依頼は `grill` に案内される
  - 性能や安定性など品質特性の事実確認は `research`、実装前 scope は `grill` に案内される
  - 実装開始や確認方法先行の最小差分は `implementation` に案内される

### 18. `grill` skill が問い詰め専用のまま保たれる

- 例: 「成功条件と非目的を詰めたい」「実装順序と検証方法を詰めたい」
- 観測ポイント:
  - `grill` skill が問い詰めと共有理解の整理専用のまま保たれ、review 本体を抱え込んでいない
  - 要件 review と実装計画 review の責務が分離されたまま維持されている
  - 導線の詳細は [Runtime Surface Guidance](./runtime-surface-guidance.md) と各 `SKILL.md` / agent 定義を正本にする

### 19. context-aware upstream grilling が機能する

- 例: 「計画を深掘りして」「既存 context と docs に照らして要件を固めたい」「実装順序と検証方法を詰めたい」
- 観測ポイント:
  - 要件定義の深掘りは `grill` に案内される
  - 実装計画の深掘りは `grill` に案内される
  - root `CONTEXT-MAP.md` から `dot_codex/CONTEXT.md` と `docs/CONTEXT.md` へ辿れる
  - root `CONTEXT.md` は作らない
  - `CONTEXT.md` は glossary と関係性に限定され、spec、作業メモ、実装判断を混ぜない
  - `CONTEXT-MAP.md` と deploy 先の `.codex/CONTEXT.md` は `.chezmoiignore` で配布対象外になる
  - `grill me` は `grill` の発火語として扱われ、docs 反映が不要な場合は質問だけを 1 つずつ進める

### 20. ADR が状態付き軽量 ADR として扱われる

- 例: 「この判断を残したい」「この用語を残したい」
- 観測ポイント:
  - 用語は該当 context の `CONTEXT.md` に送られる
  - 判断は hard to reverse、surprising without context、real trade-off の 3 条件を満たす場合だけ ADR 候補になる
  - ADR は `Status` を持つ
  - 短い判断は 1-3 文の本文で残せる
  - `Context` / `Decision` / `Consequences` は必要な場合だけ使われる

### 21. reviewer agent の返答が JSON 固定へ戻らない

- 例: 「レビュー findings を整理したい」「この差分をレビューして結果までまとめたい」
- 観測ポイント:
  - 差分 review 本体は `quality-reviewer` / `security-reviewer` が担う
  - reviewer agent が固定の JSON 形式だけを返す指定へ戻っていない
  - reviewer agent の結果が、親がそのまま利用者へ渡しても読みやすい findings-first の形になっている
  - 導線と役割分担の詳細は [Runtime Surface Guidance](./runtime-surface-guidance.md) と関連 agent 定義を正本にする

### 22. reviewer agent 起動契約が AGENTS に残る

- 例: 「計画レビューを親 Codex で扱いたい」「quality-reviewer に差分レビューを依頼したい」
- 観測ポイント:
  - `dot_codex/private_AGENTS.md.tmpl` に、reviewer agent を `agent_type` で明示起動する場合は `fork_context=true` を併用しない契約がある
  - reviewer 定義側の `model` / `sandbox_mode` / instructions を有効にする目的が崩れていない
  - `quality-reviewer` / `security-reviewer` には `cwd`、対象差分、対象ファイル、観点、除外範囲、検証状況を `message` に明示して渡す契約がある
  - docs / skills に、reviewer role と `fork_context=true` の併用を推奨する記述が再流入していない

### 23. repo 固有契約の軽い確認を手動回帰で補う

- 例: 「agent metadata や rule metadata の欠落、リンク切れ、`.codex` 推奨文言を見落としていないか」
- 観測ポイント:
  - `dot_codex/agents/*.toml` の必須 metadata が欠けていない
  - `dot_codex/rules/*.rules` の説明責務が崩れていない
  - `dot_codex/` と `docs/` 配下の参照先が実在する
  - `dot_codex/private_config.toml.tmpl` の macOS 向け `notify` 設定が残っている
  - knowledge の置き場として project-local `.codex` を勧める文面が再流入していない
  - これらの観点は自動失敗ではなく、変更時の手動 review で確認する

### 24. reviewer 設定 tier が役割分担に沿って保たれる

- 例: 「reviewer agent の model や `model_reasoning_effort` を見直した」「品質重視や速度重視で tier を変えたい」
- 観測ポイント:
  - reviewer 設定が役割分担と矛盾せず、不要な一律変更になっていない
  - 要件 review / 実装計画 review と差分 review 系 reviewer の責務差が保たれている
  - 具体的な tier や既定値は agent 定義と runtime config を正本にする

## 関連文書

- [ADR Ledger Model](./adr-ledger-model.md)
- [Harness Design Principles](./harness-design-principles.md)
- [Runtime Surface Guidance](./runtime-surface-guidance.md)
- [ADR 0006](../adr/0006-keep-agents-thin-and-surface-oriented.md)
- [ADR 0005](../adr/0005-keep-harness-verification-focused-on-repo-contracts.md)
- [ADR 0007](../adr/0007-retire-harness-verifier-script.md)
- [ADR 0008](../adr/0008-keep-git-operation-surface-minimal.md)
- [ADR 0018](../adr/0018-keep-git-mutation-rules-prompted.md)
