# rules の設計

- Date: 2026-09-02
- 出典: [How Claude remembers your project](https://code.claude.com/docs/en/memory) / [Choose a permission mode](https://code.claude.com/docs/en/permission-modes) / `dot_claude/rules/` / [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) v4.9.0 / この環境での実測（`paths` の発火経路は 2026-09-02、Claude Code v2.1.255）

`dot_claude/rules/` が今の形になっている理由を残す。rule 本体を読んでも分からない前提と判断に絞る。

## CLAUDE.md へ統合しない理由

常時 load される総量は公式目安（1 ファイル 200 行）に収まっている。統合しても容量では困らない。

分けているのは、統合すると 1 ファイル内で重複が再発するため。共通契約と品質規範は「最小差分で始める」「予防的抽象化を避ける」のように内容が近く、同じファイルに置くと両方に書かれて片方が古くなる。分離した状態で、共通契約側を「実装・編集は最小差分で始める。」の 1 行へ短縮し、判断基準は `rules/quality.md` へ一本化してある。

**この一本化により、共通契約から削った規範の受け皿は `rules/quality.md` だけになっている。** この rule に `paths` を付けるなら、共通契約側の記述も同時に戻す。片方だけ戻すと規範が全セッションから黙って消える。

## `paths` を使わない

path 条件付き rule は Read tool でしか発火せず（下記）、この harness は auto mode で Bash を主経路に指示する。`CLAUDE.md` で対抗する案は実際に効いたが、auto mode では Bash の方が効率と正確さで優るため外した（[claude-md-design.md](./claude-md-design.md)）。結果として `paths` は構造的に発火しないので、rule には付けない。

## rule と skill の使い分け

`paths` を捨てると、置き場は常時 load される `rules/` か、description で発火する `skills/` の 2 択になる。判断は 2 段。

1. **どの依頼でも要るか。** 要るなら `rules/`。
2. 要らないなら、**発火しなかった時の実害**を見る。security、privacy、データ損失に関わるなら確実性を取って `rules/` に置く。skill の発火は description 依存で、外れると守られない。

両方に当たらないものだけ `skills/` へ移す。2026-09-02 時点の判定は次のとおり。

| rule | どの依頼でも要るか | 実害 | 置き場 |
| --- | --- | --- | --- |
| `quality` | はい | 中 | `rules/` |
| `privacy` | はい | 大 | `rules/` |
| `vba` | いいえ | 小 | `skills/` |

## quality を常時 load にする理由

残した 4 節（品質の優先順位、適用の参照順、基本原則、最小差分）は、コードに限らず `settings.json` や `docs/` の編集にも効く。「rule と skill の使い分け」の 1 段目に当たるので `rules/` に置く。

2026-09-02 まではコード限定部（打ち切り順、可読性の具体、コメント）も同じファイルにあり、名前も `coding-standards.md` だった。分割したのは、`paths` を使わない方針が決まった時に中身を数え直し、実質 31 行（見出しと空行を除く）のうち 20 行がコードを書く時だけ要ると分かったため。移した先と経緯は [coding-skill-design.md](./coding-skill-design.md)。

分割前は 2 ファイル分割案を「コード限定部は小さく、分割で減る量に対して path 条件の穴を再生産する」として捨てていた。`paths` を使わない今は穴が生じず、減る量も 20 行あるので、捨てた根拠が両方とも消えている。

rename したのは、残った 4 節がコーディング限定でないため。`standards` が指す具体的な規約（命名、直線化、コメント）は skill へ移り、判断基準だけが残った。skill 名 `coding` との混同も避けている。

## vba を rules に置かない理由

VBA の保存形式と識別子制約は `.bas` / `.cls` を触る時にしか意味がなく、他の作業では読む価値がない。「rule と skill の使い分け」の 2 段を通すと、どの依頼でも要るわけではなく、発火しなくても実害は形式の崩れに留まるので `skills/` に当たる。実体は `dot_claude/skills/coding/references/vba.md` で、拡張子の衝突をどう扱っているかは [coding-skill-design.md](./coding-skill-design.md)。

`paths` で絞る形は 2026-09-02 まで採っていたが、一度も発火していなかった。glob（`src/**/*.{bas,cls}`）の書き方は正しく、発火しない原因は経路の側にある（下記）。

## path 条件付き rule は Read tool でしか発火しない

`paths` 付きの rule が context へ注入されるのは、Claude が **Read tool** で match するファイルを開いた時だけ。Bash の `cat` では注入されない。2026-09-02 に `src/probe.bas` を作り、`cat` と Read tool の両方で読んで確認した（`cat` では何も起きず、Read tool の直後に `vba.md` の全文が注入された。当時 VBA の規約は `rules/vba.md` にあり、現在は skill）。

公式も「Path-scoped rules trigger when Claude reads files matching the pattern, not on every tool use」と書き、compaction の節では「a path-scoped rule that hasn't matched a file since」と、ファイルに match していない状態を前提にしている。

**この harness では auto mode が Bash を主経路に指示する。** 「read files with cat, head, or sed -n ... rather than using the dedicated Read, Edit, or Write tools」という指示が session へ入る。これに従う限り `paths` 付き rule は発火しない。2026-09-02 時点で発火した実績は無く、macOS はこの環境での実測、Windows はユーザーの確認による。

この Bash 優先の指示は system-reminder にのみ現れ、[Configure permissions](https://code.claude.com/docs/en/permissions) / [Choose a permission mode](https://code.claude.com/docs/en/permission-modes) / [Configure the sandboxed Bash tool](https://code.claude.com/docs/en/sandboxing) のいずれにも記載が無い。制御する設定キーがあるかは未確認で、文書化されていない以上いつ変わるかも分からない。

`CLAUDE.md` の共通契約で Read / Edit / Write tool を使うよう定める案を試し、apply 後の別 session で契約が harness の指示に勝つことを確認した（2026-09-02）。それでも外したのは、auto mode では Bash の方が効率と正確さで優るため（[claude-md-design.md](./claude-md-design.md)）。`paths` の側を諦めている。

## 優先順位に「短さ・巧妙さ」を置かない理由

priority list に載せると「上位を損なわない範囲で巧妙さを追求してよい」と読める。巧妙さは可読性の敵なので、「短さと巧妙さは目標にしない」と否定形で書く。`DRY` は「性能より下」という位置情報が有用なので list に残す。

命名と予防的抽象化について同じ型の判断があるが、そちらは `skills/coding` へ移った（[coding-skill-design.md](./coding-skill-design.md)）。

## privacy を独立した rule にしている理由

`rules/quality.md` へ足さず別ファイルにしてある。対象が違うため。`quality` は変更の質を扱い、`privacy` は成果物に残る値を扱う。混ぜると、コードを書かない作業（doc、設定、commit message）でも品質規範を全部読ませることになる。

`paths` を付けない。混入はコードに限らず、doc、設定、commit message のいずれでも起きる。path で絞ると、そのうち glob に載らない経路が外れる。

`CLAUDE.md` の停止線と重ならない。停止線が挙げる「秘密情報」は credential と token で、触る前に人へ確認するもの。`privacy` が扱うのは書き手と作業機の識別子で、確認ではなく置換で解決する。2026-09-01 時点で、識別子の方を扱う記述は `CLAUDE.md`、`rules/quality.md`、`skills/git-commit`、`skills/self-review` のどこにも無かった。

**強制層は持たない。** 公式 docs は rule を context であって enforced configuration ではないと明示しており、Claude の判断に関わらず止めたいなら PreToolUse hook を使えとしている。ここでは機械的検査を採らず、rule だけを置いている。既存の rule と skill も同じく強制力を持たないので、層の性質を揃えてある。

## doc / artifact の rule を持たない理由

doc の書き方は `skills/scribe` が正本で、「doc 追従の要否を黙って飛ばさない」は `CLAUDE.md` の `## doc` が常時側を担う。rule を足すと同じ規定が三重になり、scribe を直すたびに rule も直すことになる。

## repo 固有の rule を配らない理由

`~/.claude/rules/` は全 project へ配布される。`dot_claude/**` のような、この repo の path を `paths` に持つ rule は、他の project では一度も match せず、死んだ設定として残る。repo に閉じる rule は、その repo の `.claude/rules/` に置く。chezmoi は source 内の `.` 始まりを配布しないので、`dot_claude/` と衝突しない。この repo では `harness-surface-consistency` がそれに当たる。

## ADR 本文を追従対象から外している理由

`harness-surface-consistency` は変更した path を `rg` で検索して追従漏れを見ることを求めるが、ADR 本文はその対象から外している。ADR は採用時点の記録で、その後の rename や削除を反映しないため。

2026-08-31 に `docs/` 全体を検査した。Markdown のリンク形式で書かれた参照は切れが 0 件で、code span で書かれた path のうち存在しない `docs/notes/` を指すものが 7 件あった。参照元は全て ADR 本文で、notes 側には 1 件も無い。参照している ADR は 11 件、うち 8 件が Superseded。参照先は退役したか、統合先はあってもそこが前提を書き換えており、当時の記述を指し直せない。

書く側の規定（`skills/scribe`、理由は [scribe-skill-design.md](./scribe-skill-design.md)）が ADR 本文を触らないと決めている以上、検査側で閉じないと、`rg` がヒットするたびに同じ判断を繰り返すことになる。
