# memory surface の設計

- Date: 2026-11-11
- 出典: [How Claude remembers your project](https://code.claude.com/docs/en/memory) / [Choose a permission mode](https://code.claude.com/docs/en/permission-modes) / [anthropics/claude-code#90450](https://github.com/anthropics/claude-code/issues/90450) / `dot_claude/CLAUDE.md` / [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) v4.9.0 / [Tools reference](https://code.claude.com/docs/en/tools-reference) / この環境での実測（`paths` の発火経路は 2026-09-02 の Claude Code v2.1.255 と、2026-11-08 の desktop app）

配布する memory surface を `dot_claude/CLAUDE.md` 1 枚にしている理由を残す。本体を読んでも分からない前提と判断に絞る。

## `rules/` を持たない

`~/.claude/rules/` を持たず、契約も品質規範も privacy も `CLAUDE.md` 1 枚に置く。根拠は 3 つ。

**機械的な差が無い。** 公式は "Rules without `paths` frontmatter are loaded at launch with the same priority as `.claude/CLAUDE.md`." と書く。下記のとおり `paths` を使わない方針なので、`rules/` に置いても launch 時に無条件 load される点は `CLAUDE.md` と同じになる。分ける機械的な利点が残らない。

**分離は重複を防げなかった。** 2026-09-02 まで `rules/quality.md` を分けていた理由は「統合すると 1 ファイル内で重複が再発する」だったが、分離した状態でも重複は起きていた。共通契約の「人が読み・誤解せず・安全に変えられるかで採否を決める」と、`quality` の「可読性: 未来の修正者が少ない文脈で誤解せず安全に変えられる形」。この 2 つが実質同じ主張のまま共存していた。分離は重複を防ぐのではなく、2 ファイルを突き合わせないと見えなくする。

**突き合わせ対象が減る。** 公式は "if two rules contradict each other, Claude may pick one arbitrarily. Review your CLAUDE.md files ... and `.claude/rules/` periodically to remove outdated or conflicting instructions." として定期点検を求めている。ファイルが少ない方が点検が軽い。

1 枚にまとめても、公式目安の 200 行に収まっている（行数は [claude-md-design.md](./claude-md-design.md) の「ここに置くものの基準」）。

## privacy を独立させない

分けても、コードを書かない作業（doc、設定、commit message）で品質規範を読ませずに済むわけではない。`paths` を使わない以上、どちらのファイルも毎 session 全文が load される。

`CLAUDE.md` の「確認してから進めること」とは重ならない。そちらが挙げる「秘密情報」は credential と token で、触る前に人へ確認するもの。`## Privacy` が扱うのは書き手と作業機の識別子で、確認ではなく置換で解決する。

**強制層はこの repo の commit にだけ持つ。** 公式は CLAUDE.md を context であって enforced configuration ではないと明示している。この repo の commit は、prek の local hook が staged の path と追加行を home の path、ユーザー名、ホスト名で検査する（[lint-and-pre-commit-execution.md](./lint-and-pre-commit-execution.md) の「作業機の識別子を検査する local hook」）。他の repo では、`git-commit` skill が手順 6 で同じ script を走らせる（[git-commit-skill-design.md](./git-commit-skill-design.md) の「識別子の検査を script で持つ理由」）。これは skill の手順で、強制ではない。pattern にできない識別子は、今も契約だけが担う。

## `paths` を使わない

path 条件付き rule が発火するのは、match するファイルを Read tool で読んだ時と、Bash で読んだ時の一部（Bash の条件は下記）。この dotfiles は `paths` 付き rule を持たない。外したのは 2026-09-02 で、当時の実測では `cat` で読んでも発火しなかった。auto mode の指示に従うと、構造的に発火しない状態だった。共通契約が読み取りを Read に定めた後（2026-11-08）も、`paths` を戻すかは判断していない。

2026-11-08 に、repo 内へ probe の directory と rule を一時的に作って確かめた。読み方ごとに別の directory と rule を用意し、各 directory は 1 回だけ読んだので、directory ごとに 1 回しか load しない sticky な挙動は結果に混ざらない。実測したのは次の 3 つの読み方だけ。`cat file` では、`paths` 付き rule と subdirectory の `CLAUDE.md` の両方が注入された。`cat -n file | head` では rule が注入されなかった。Read tool では両方が注入された。session の途中で作った rule でも発火した。

2026-09-02 には `src/probe.bas` を `cat` で読み、何も注入されなかった。Read tool の直後には当時の `rules/vba.md` の全文が注入された。

[Tools reference](https://code.claude.com/docs/en/tools-reference) は、Bash で読んで load される command として `cat`、`head`、`tail`、`sed -n 'X,Yp'`、`grep`、`rg` などを挙げる。1 ファイルを対象に、pipe も redirect も無いことを条件にしている。

公式も「Path-scoped rules trigger when Claude reads files matching the pattern, not on every tool use」と書く。compaction の節では「a path-scoped rule that hasn't matched a file since」と、ファイルに match していない状態を前提にしている。

**auto mode は shell での読み書きを認める指示を session へ入れる。** 2026-09-02 の文面は「read files with cat, head, or sed -n ... rather than using the dedicated Read, Edit, or Write tools」だった。2026-11-08 の文面は shell での読み取りを認め、厳密な置換と複数行の置換では Edit / Write を勧める。どちらの文面に従っても、pipe を挟んで shell で読めば `paths` 付き rule は発火しない。この指示は session へ入る文面にだけ現れる。2026-09-02 は system-reminder、2026-11-08 は system prompt に現れた。[Configure permissions](https://code.claude.com/docs/en/permissions)、[Choose a permission mode](https://code.claude.com/docs/en/permission-modes)、[Configure the sandboxed Bash tool](https://code.claude.com/docs/en/sandboxing) のいずれにも記載が無い。制御する設定キーがあるかは未確認で、文書化されていない以上いつ変わるかも分からない。

`CLAUDE.md` の共通契約は、読み取りを Read tool、編集を Edit / Write tool に定めている。そう定めた理由は [claude-md-design.md](./claude-md-design.md) の「tool の使い分けを契約に置く理由」にある。

### 外部からの裏付け

同じ衝突が [anthropics/claude-code#90450](https://github.com/anthropics/claude-code/issues/90450) に報告されている（2026-08-28 open、2026-09-03 時点で open、labels に `bug` / `has repro`）。上の実測より広く、この repo が測っていなかった 3 点を含む。

- 27 の access 手法を検証し、load したのは `Read` tool 系 4 つだけ。`cat` / `head` / `sed -n` / `grep` / `find` / `sed -i` / heredoc は全て無音
- **sticky**: load は directory ごとに session 1 回。早い段階の Bash read 1 回で、その directory の memory が session 中ずっと落ちる
- **compaction 後に復旧しない**: 再読み込みも Bash 呼び出しになるため

issue の、`cat` では何も load されないという結果は、2026-11-08 の実測と合わない。

**この dotfiles 自身は、`rules/` の廃止でこの issue の影響範囲から外れる。** `paths` 付き rule も nested `CLAUDE.md` も持たず、残るのは launch 時に無条件 load される user-scope の `CLAUDE.md` 1 枚だけになる。ただし、契約を配る先の作業対象 repo は `paths` 付き rule や nested `CLAUDE.md` を持ちうる。共通契約が読み取りを Read に定めているのは、その repo で issue の影響を避けるため（[claude-md-design.md](./claude-md-design.md) の「tool の使い分けを契約に置く理由」）。issue が解決した場合は `paths` を再検討する余地があるが、その時はこの note で判断し直す。

## rule でなく skill に置く基準

`paths` を捨てると、置き場は常時 load される `CLAUDE.md` か、description で発火する `skills/` の 2 択になる。判断は 2 段。

1. **どの依頼でも要るか。** 要るなら `CLAUDE.md`。
2. 要らないなら、**発火しなかった時の実害**を見る。security、privacy、データ損失に関わるなら確実性を取って `CLAUDE.md` に置く。skill の発火は description 依存で、外れると守られない。

両方に当たらないものだけ `skills/` へ置く。たとえば ADR と notes の書式は、doc を書く時にしか意味がない。発火しなくても実害は書式の崩れに留まる。そのため `skills/scribe/references/` にある。

## 短さと巧妙さを「優先しない側」にだけ書く

契約は「可読性と直しやすさを、短さ、巧妙さ、必要以上の性能より優先する」と書く。短さと巧妙さは、比べて負ける側にだけ現れる。優先順位の list に目標として並べると、「上位を損なわない範囲で巧妙さを追求してよい」と読める。巧妙さは可読性の敵なので、目標の側には置かない。

## doc / artifact の規定を契約に持たない

doc の書き方と、doc をいつ直すかは `skills/scribe` が正本にする。いつ直すかは description が「使い方・設定・公開挙動を変えた時」として持つ。契約へ足すと同じ規定が二重になり、scribe を直すたびに契約も直すことになる。

## repo 固有の rule を配らない

`~/.claude/` は全 project へ配布される。`dot_claude/**` のような、この repo の path を対象にする rule は他の project では一度も使われず、死んだ設定として残る。repo に閉じる rule は、その repo の `.claude/rules/` に置く。chezmoi は source 内の `.` 始まりを配布しないので `dot_claude/` と衝突しない。この repo では、変更後の確認を root `AGENTS.md` の同名の節に置く。`AGENTS.md` は root `CLAUDE.md` の import で Claude も常時読み、Codex も読むので、`.claude/rules/` にも置くと Claude には 2 回入る。

## ADR 本文を追従対象から外している

`AGENTS.md` の「変更後の確認」は変更した path を `rg` で検索して追従漏れを見ることを求めるが、ADR 本文はその対象から外している。ADR は採用時点の記録で、その後の rename や削除を反映しないため。

2026-08-31 に `docs/` 全体を検査した。Markdown のリンク形式で書かれた参照は、切れが 0 件。code span で書かれた path のうち、存在しない `docs/notes/` を指すものが 7 件あった。参照元は全て ADR 本文で、notes 側には 1 件も無い。参照している ADR は 11 件、うち 8 件が Superseded。参照先は退役したか、統合先はあってもそこが前提を書き換えており、当時の記述を指し直せない。

書く側の規定（`skills/scribe`、理由は [scribe-skill-design.md](./scribe-skill-design.md)）が ADR 本文を触らないと決めている。検査側で閉じないと、`rg` がヒットするたびに同じ判断を繰り返すことになる。

## 未確認

- compaction 後に user-scope の `CLAUDE.md` が再注入されるかは、公式に記載が無い。公式が compaction について書いているのは、project-root `CLAUDE.md` と `paths` 付き rule だけ。user-scope には触れていない。統合前後で条件は変わらないため、`rules/` 廃止の根拠には数えていない。
- 2026-09-02 と 2026-11-08 で `cat` の結果が違う理由。command の形か Claude Code の version の差かは、2026-09-02 の記録に無い。2026-11-08 の desktop app の version も、`claude` が PATH に無く取れていない。
