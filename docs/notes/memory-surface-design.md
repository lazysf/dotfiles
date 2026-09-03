# memory surface の設計

- Date: 2026-09-03
- 出典: [How Claude remembers your project](https://code.claude.com/docs/en/memory) / [Choose a permission mode](https://code.claude.com/docs/en/permission-modes) / [anthropics/claude-code#90450](https://github.com/anthropics/claude-code/issues/90450) / `dot_claude/CLAUDE.md` / [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) v4.9.0 / この環境での実測（`paths` の発火経路は 2026-09-02、Claude Code v2.1.255）

配布する memory surface を `dot_claude/CLAUDE.md` 1 枚にしている理由を残す。本体を読んでも分からない前提と判断に絞る。

## `rules/` を持たない

`~/.claude/rules/` を持たず、契約も品質規範も privacy も `CLAUDE.md` 1 枚に置く。根拠は 3 つ。

**機械的な差が無い。** 公式は "Rules without `paths` frontmatter are loaded at launch with the same priority as `.claude/CLAUDE.md`." と書く。下記のとおり `paths` を使わない方針なので、`rules/` に置いても launch 時に無条件 load される点は `CLAUDE.md` と同じになる。分ける機械的な利点が残らない。

**分離は重複を防げなかった。** 2026-09-02 まで `rules/quality.md` を分けていた理由は「統合すると 1 ファイル内で重複が再発する」だったが、分離した状態でも重複は起きていた。共通契約の「人が読み・誤解せず・安全に変えられるかで採否を決める」と、`quality` の「可読性: 未来の修正者が少ない文脈で誤解せず安全に変えられる形」。この 2 つが実質同じ主張のまま共存していた。分離は重複を防ぐのではなく、2 ファイルを突き合わせないと見えなくする。

**突き合わせ対象が減る。** 公式は "if two rules contradict each other, Claude may pick one arbitrarily. Review your CLAUDE.md files ... and `.claude/rules/` periodically to remove outdated or conflicting instructions." として定期点検を求めている。ファイルが少ない方が点検が軽い。

統合後の `CLAUDE.md` は 83 行（2026-09-03）で、公式目安の 200 行に収まっている。

## privacy を独立させない

分離していた時の理由は「混ぜると、コードを書かない作業（doc、設定、commit message）でも品質規範を全部読ませることになる」だった。`paths` を使わない以上どちらも毎 session 全文が load されるので、分離の有無に関わらず成立しない。

`CLAUDE.md` の停止線とは重ならない。停止線が挙げる「秘密情報」は credential と token で、触る前に人へ確認するもの。`## Privacy` が扱うのは書き手と作業機の識別子で、確認ではなく置換で解決する。

**強制層は持たない。** 公式は CLAUDE.md を context であって enforced configuration ではないと明示している。Claude の判断に関わらず止めたいなら PreToolUse hook を使え、としている。ここでは機械的検査を採らず、契約だけを置いている。skill と agent も同じく強制力を持たないので、層の性質を揃えてある。

## `paths` を使わない

path 条件付き rule は Read tool でしか発火せず、この harness は auto mode で Bash を主経路に指示する。結果として `paths` は構造的に発火しないため、使わない。

`paths` 付きの rule が context へ注入されるのは、Claude が **Read tool** で match するファイルを開いた時だけ。Bash の `cat` では注入されない。2026-09-02 に `src/probe.bas` を作り、`cat` と Read tool の両方で読んで確認した。`cat` では何も起きず、Read tool の直後に当時の `rules/vba.md` の全文が注入された。現在 VBA の規約は `skills/coding/references/` にある。

公式も「Path-scoped rules trigger when Claude reads files matching the pattern, not on every tool use」と書く。compaction の節では「a path-scoped rule that hasn't matched a file since」と、ファイルに match していない状態を前提にしている。

**この harness では auto mode が Bash を主経路に指示する。** 「read files with cat, head, or sed -n ... rather than using the dedicated Read, Edit, or Write tools」という指示が session へ入る。これに従う限り `paths` 付き rule は発火しない。この Bash 優先の指示は system-reminder にのみ現れる。[Configure permissions](https://code.claude.com/docs/en/permissions)、[Choose a permission mode](https://code.claude.com/docs/en/permission-modes)、[Configure the sandboxed Bash tool](https://code.claude.com/docs/en/sandboxing) のいずれにも記載が無い。制御する設定キーがあるかは未確認で、文書化されていない以上いつ変わるかも分からない。

`CLAUDE.md` の共通契約で Read / Edit / Write tool を使うよう定める案を試し、apply 後の別 session で契約が harness の指示に勝つことを確認した（2026-09-02）。それでも外したのは、auto mode では Bash の方が効率と正確さで優るため（[claude-md-design.md](./claude-md-design.md)）。`paths` の側を諦めている。

### 外部からの裏付け

同じ衝突が [anthropics/claude-code#90450](https://github.com/anthropics/claude-code/issues/90450) に報告されている（2026-08-28 open、2026-09-03 時点で open、labels に `bug` / `has repro`）。上の実測より広く、この repo が測っていなかった 3 点を含む。

- 27 の access 手法を検証し、load したのは `Read` tool 系 4 つだけ。`cat` / `head` / `sed -n` / `grep` / `find` / `sed -i` / heredoc は全て無音
- **sticky**: load は directory ごとに session 1 回。早い段階の Bash read 1 回で、その directory の memory が session 中ずっと落ちる
- **compaction 後に復旧しない**: 再読み込みも Bash 呼び出しになるため

**`rules/` の廃止により、この harness はこの issue の影響範囲から外れる。** `paths` 付き rule も nested `CLAUDE.md` も持たず、残るのは launch 時に無条件 load される user-scope の `CLAUDE.md` 1 枚だけになる。issue が解決した場合は `paths` を再検討する余地があるが、その時はこの note で判断し直す。

## rule でなく skill に置く基準

`paths` を捨てると、置き場は常時 load される `CLAUDE.md` か、description で発火する `skills/` の 2 択になる。判断は 2 段。

1. **どの依頼でも要るか。** 要るなら `CLAUDE.md`。
2. 要らないなら、**発火しなかった時の実害**を見る。security、privacy、データ損失に関わるなら確実性を取って `CLAUDE.md` に置く。skill の発火は description 依存で、外れると守られない。

両方に当たらないものだけ `skills/` へ置く。VBA の保存形式と識別子制約は `.bas` / `.cls` を触る時にしか意味がない。発火しなくても実害は形式の崩れに留まる。そのため `skills/coding/references/vba.md` にある（[coding-skill-design.md](./coding-skill-design.md)）。

## 優先順位に「短さ・巧妙さ」を置かない

priority list に載せると「上位を損なわない範囲で巧妙さを追求してよい」と読める。巧妙さは可読性の敵なので、「短さと巧妙さは目標にしない」と否定形で書く。`DRY` は「性能より下」という位置情報が有用なので list に残す。

## doc / artifact の規定を契約に持たない

doc の書き方は `skills/scribe` が正本で、「doc 追従の要否を黙って飛ばさない」は `CLAUDE.md` の `## doc` が常時側を担う。書き方まで契約へ足すと同じ規定が二重になり、scribe を直すたびに契約も直すことになる。

## repo 固有の rule を配らない

`~/.claude/` は全 project へ配布される。`dot_claude/**` のような、この repo の path を対象にする rule は他の project では一度も使われず、死んだ設定として残る。repo に閉じる rule は、その repo の `.claude/rules/` に置く。chezmoi は source 内の `.` 始まりを配布しないので `dot_claude/` と衝突しない。この repo では `harness-surface-consistency` がそれに当たる。

## ADR 本文を追従対象から外している

`harness-surface-consistency` は変更した path を `rg` で検索して追従漏れを見ることを求めるが、ADR 本文はその対象から外している。ADR は採用時点の記録で、その後の rename や削除を反映しないため。

2026-08-31 に `docs/` 全体を検査した。Markdown のリンク形式で書かれた参照は、切れが 0 件。code span で書かれた path のうち、存在しない `docs/notes/` を指すものが 7 件あった。参照元は全て ADR 本文で、notes 側には 1 件も無い。参照している ADR は 11 件、うち 8 件が Superseded。参照先は退役したか、統合先はあってもそこが前提を書き換えており、当時の記述を指し直せない。

書く側の規定（`skills/scribe`、理由は [scribe-skill-design.md](./scribe-skill-design.md)）が ADR 本文を触らないと決めている。検査側で閉じないと、`rg` がヒットするたびに同じ判断を繰り返すことになる。

## 未確認

- compaction 後に user-scope の `CLAUDE.md` が再注入されるかは、公式に記載が無い。公式が compaction について書いているのは、project-root `CLAUDE.md` と `paths` 付き rule だけ。user-scope には触れていない。統合前後で条件は変わらないため、`rules/` 廃止の根拠には数えていない。
