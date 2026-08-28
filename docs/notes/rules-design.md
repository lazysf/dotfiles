# rules の設計

- Date: 2026-08-28
- 出典: [How Claude remembers your project](https://code.claude.com/docs/en/memory) / `dot_claude/rules/` / この環境での実測

`dot_claude/rules/` が今の形になっている理由を残す。rule 本体を読んでも分からない前提と判断に絞る。

## CLAUDE.md へ統合しない理由

常時 load される総量は公式目安（1 ファイル 200 行）に収まっている。統合しても容量では困らない。

分けているのは、統合すると 1 ファイル内で重複が再発するため。共通契約と品質規範は「最小差分で始める」「予防的抽象化を避ける」のように内容が近く、同じファイルに置くと両方に書かれて片方が古くなる。分離した状態で、共通契約側を「実装・編集は最小差分で始める。」の 1 行へ短縮し、判断基準は `coding-standards.md` へ一本化してある。

**この一本化により、共通契約から削った規範の受け皿は `coding-standards.md` だけになっている。** この rule に `paths` を付けるなら、共通契約側の記述も同時に戻す。片方だけ戻すと規範が全セッションから黙って消える。

## coding-standards を常時 load にする理由

`paths` を付けない。理由は 3 つ。

- **中身の大半がコード限定でない。** 品質の優先順位、適用の参照順、基本原則、最小差分（計 22 行）は `settings.json`、`CLAUDE.md`、`docs/` の編集にも効く。コード限定は可読性の具体とコメントの約 10 行だけ。`paths` を付けるとこの 22 行が巻き添えで無効化される。
- **path 条件には穴がある。** `**/src/**` 系の glob を並べても `cmd/` / `internal/` / `pkg/` / `apps/` / repo 直下のコードが漏れる。`paths` を持たなければこの穴は構造的に消える。
- **節約量が誤差。** 常時 load の総量は公式目安を大きく下回る（実測は [claude-md-design.md](./claude-md-design.md)）。

捨てた案: 常時適用部（22 行）とコード限定部（10 行）へ 2 ファイル分割。10 行の節約のために path 条件の穴を再生産することになる。コード限定部が大きく育った時に再検討する。

`vba.md` は逆に `paths` を持つ。VBA の保存形式と識別子制約は `.bas` / `.cls` を触る時にしか意味がなく、他の作業では読む価値がない。

## path 条件付き rule は正常に発火する

`paths` 付きの rule は auto mode でも発火する。2026-08-27 の実測で、Read tool を一度も使わないセッションでも context へ注入されることを確認した。`InstructionsLoaded` hook でも `session_start` での load を確認している。

`cat` / `sed` を主経路にすると Read tool を通らないため発火しない、という推測は成り立たない。`paths` を避ける理由にはならない。

## 品質規範を名前ベースでなく判断基準ベースにする理由

- **優先順位に「短さ・巧妙さ」を置かない。** priority list に載せると「上位を損なわない範囲で巧妙さを追求してよい」と読める。巧妙さは可読性の敵なので、「短さと巧妙さは目標にしない」と否定形で書く。`DRY` は「性能より下」という位置情報が有用なので list に残す。
- **命名の汎用語リストに `handler` / `process` を入れない。** HTTP handler / event handler は framework が定義する確立した語で、`data` / `tmp` と同列に禁じると誤爆する。例外の根拠は「近傍実装で使われている」ではなく「framework が定義する語である」に絞る。前者だと「この repo は既に `helpers/` を使っている」でリスト全体を無効化できてしまう。
- **予防的抽象化の禁止列挙に `Provider` / `Manager` を入れず、例示に留める。** React の Provider や Nest / Spring の DI container は framework 規約が要求する構造で、自作の間接層とは別物。素の Node / Python で自作する DI container はこの規範が止めたい典型なので、例示は framework 名まで具体化する。
- `manager` が命名リストに残り `Manager` が抽象化リストから外れているのは整合する。命名 rule は識別子の曖昧さ、抽象化 rule は間接層の早期導入と、対象軸が違う。

## doc / artifact の rule を持たない理由

doc の書き方は `skills/scribe` が正本で、「doc 追従の要否を黙って飛ばさない」は `CLAUDE.md` の `## doc` が常時側を担う。rule を足すと同じ規定が三重になり、scribe を直すたびに rule も直すことになる。

## repo 固有の rule を配らない理由

`~/.claude/rules/` は全 project へ配布される。`dot_claude/**` のような、この repo の path を `paths` に持つ rule は、他の project では一度も match せず、死んだ設定として残る。repo に閉じる rule は、その repo の `.claude/rules/` に置く。

## 未確認

- rules をまだ `chezmoi apply` していないため、`~/.claude/rules/` は旧版 4 本のまま。配布していない `docs-artifacts` と `harness-surface-consistency` は削除されずに残る。
- `harness-surface-consistency` を repo の `.claude/rules/` へ置き直すかは未決。
