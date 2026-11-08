# CLAUDE.md の設計

- Date: 2026-11-08
- 出典: [How Claude remembers your project](https://code.claude.com/docs/en/memory) / [Best practices for Claude Code](https://code.claude.com/docs/en/best-practices) / [Hooks reference](https://code.claude.com/docs/en/hooks) / [Tools reference](https://code.claude.com/docs/en/tools-reference) / `dot_claude/CLAUDE.md` / この環境での実測 / Codex での作業記録の要約（ユーザー提供）

`dot_claude/CLAUDE.md` が今の形になっている理由を残す。本体を読んでも分からない前提と判断に絞る。

## ここに置くものの基準

CLAUDE.md は全セッションの先頭で読まれる。残すのは、Claude が既定ではしないこと、または repo から読めないことを指示する行だけ。公式の [Best practices](https://code.claude.com/docs/en/best-practices) の "Claude already knows most of what you might be tempted to write down" に従う。起動後の手順は `skills/` にあり、ここでは重複させない。

この基準で、次の種類はここに置かない。

- 品質の優先順位、KISS / YAGNI / DRY、断定を根拠に結び付けることのような、一般的な開発の原則。
- 確認の質問をいつするか、plan mode をいつ始めるか、代替案を示すかのような、工程の進め方。Claude Code の既定の振る舞いと tool の説明が持つ。
- 規則の定義や置き場のような、規則についての説明。理由はこの notes に書く。

設定や防御が有効かを実測で確かめるまで数えない、という規律は置いていない。hook の試験（2026-11-08）では、試験の手順自体の誤りで、穴を見落としたり、試せていない場面を試したと数えたりした。実測を有効の条件にすると、誤った実測がそのまま有効の根拠になる。強制の仕組みは、作りを見れば正しさが分かる単純な形にする（[harness-design-principles.md](./harness-design-principles.md) の「削る基準」）。

外す側の「設定や防御を外す前に、使っているものが無いことを確かめる」は残している。`sandbox.network.allowUnixSockets` を「push に使えないので用途が無い」と判断して落とし、commit の署名を壊したことがある（[claude-code-settings-design.md](./claude-code-settings-design.md) の「署名 agent の socket を通す理由」）。同じ socket を署名も使うことは、Claude の既定の確認では見えなかった。

公式目安は 1 ファイル 200 行。常時 load されるのはこの 1 枚だけで 68 行（2026-11-08、`wc -l`）。目安に収まっている。`rules/` を持たず 1 枚へ集約している理由は [memory-surface-design.md](./memory-surface-design.md)。

## push を契約に書いている理由

push は sandbox の proxy が SSH を運ばないため agent が実行しても失敗する。この事実は `skills/git-commit` にも書いてあるが、**その skill は commit 依頼でしか発火しない**。「push して」とだけ言われた時、skill 側の記述はどこからも読まれず、agent は失敗する経路へ進む。

常時読まれる側に 1 文だけ置く必要がある。

## doc 要否の規律をここが持つ理由

doc 追従の要否を明示する規律が効くのは実装の区切りで、そこでは `scribe` を含めて何も起動していない。skill 側に書いても実効しないため、常時 load されるここが置き場になる。

条件を仕様 doc の対象（使い方、設定、公開挙動）に絞るのは、内部だけの変更でも「doc は不要」と毎回言わないため。commit 前は `skills/lapidary` の doc の観点が同じことを見るので、ここでは持たない。

要否を判断した後の書き方（3 条件、書式、既存 ADR の扱い）は `skills/scribe` が正本で、ここには持ち込まない。

## 停止線を判定可能な形にしてある理由

「公開インターフェースに影響する」と書くと、文字通り読めば新規関数 1 本でも停止する。「変更・削除する」に絞った。そのうえで「後から変えると外部を壊すもの（公開 API、永続化 schema、CLI 引数、設定キー）は新規でも含む」を添え、判定を 1 問へ集約してある。

「大きな設計変更」も主観語なので使わない。module 境界の移動、data flow の作り直し、framework / library の入れ替えという例示で閾値を示す。

## 手段の選び方を原則に置く理由

発端は、Codex での Excel 作業で起きた事故。依頼は、別ブックの様式シートを既存ブックへ移すことだった。agent はシートをコピーせず、フォント、列幅、色などを既存シートへ個別に移す自前の処理を選んだ。原資料との不一致と移植漏れが出て、指摘のたびに局所的な補修が足された。最終的な解は、標準のシートコピーでシート名と CodeName を維持し、指定された名前定義だけを削除する形だった。当時の判断理由は記録に残っていない。

置き場は skill でなく原則にしている。`skills/lapidary` の過剰さの観点も既存の仕組みで足りる自前実装を拾うが、作業の後にしか効かない。

比べる相手に「それらに小さな補正を足した形」を含めている。上の事故の最終的な解がこの形だった。標準機能そのものとだけ比べると、「コピーだけでは CodeName が変わるので満たせない」と判定され、自前の処理が通る。

**比べ直しのトリガは、語でなく出来事で決めている。** 「補正」と「補修」を語だけで区別すると、事後の直しを「小さな補正」と呼び替えて発火を避けられる。「2 回目以降」としているのは、1 回だけ比べて続行と結論すると、その後どれだけ食い違いが増えても比べ直す契機が無くなるため。事故では指摘のたびに補修が続いた。対象を「自分が選んだ手段」に限るのは、既存コードの bug fix で直す対象まで含めると、「既存の自前実装を標準機能へ置き換える」方向へ倒れるため。求めるのは比べ直すことだけで、作り直しは求めない。

報告や承認は求めていない。根拠の報告は「引き継ぎや完了報告では、変更内容、根拠、検証結果、未確認事項を分ける」がすでに持つ。通常の小さな変更に比較表や承認を一律に足すと、負担だけが増える。

## review を commit 前に置く理由

進行の review は、`quality-reviewer` などの起動条件だけでなく、commit 前の自己確認も含む。commit 前に毎回自分で変更を確認する運用が実際に機能していたので、契約に書いて実務と揃えてある。

観点はここに書かない。手順と観点は `skills/lapidary` が持ち、契約は「いつ通すか」だけを示す。CLAUDE.md は全 session で常時 load される。review の時にしか要らない詳細を置くと、review しない session でも context を占める。

commit の直前に置くのは、実装と doc をまとめて review するため。失敗は両者を跨ぐ形で出る。設定を消したのに notes が古い参照を持ったまま。skill の `description` を変えたのに notes の記述が対応していない。分けて review すると、実装だけを見る時点では doc がまだ無く、doc だけを見る時点では実装の差分を見ない。追従漏れを見つける場が消える。

commit は実装と doc で分けたままにする。review は変更セット全体を見る行為、commit は記録の粒度で、層が違う。

## スコープを 1 つに保つ規律をここに置く理由

作業の開始時点で決まる話なので、skill では拾えない。`skills/` は起動後の手順で、「今どのスコープにいるか」を持たない。

この環境では 2 つの形で逸脱した。1 つは、ある領域の作業中に別の領域へ着手して止められたこと。もう 1 つは、観点の点検を依頼されて答えを出した後、そのまま文言の推敲へ流れ、何度も推敲した末に案そのものが不要だと分かったこと。前者は範囲の逸脱、後者は目的の逸脱で、どちらも各ステップ単体では要求どおりに見える。全体を通してスコープが動いていることは、作業を俯瞰する側でしか気づけない。

## スキル名の列挙をここに置く理由

「使用したスキル名を列挙する」は応答の書式だが、`output-styles/` には置かない。style を切り替えると読まれなくなるため。どの output style でも効かせたいので、常時 load される側が置き場になる。

hook で機械化していない。hook が出せる `systemMessage` は harness がユーザーへ見せるメッセージで、assistant の返答本文ではない。求めているのは返答そのものに含まれることなので、hook では形が違う。

そのため遵守は LLM 依存になる。公式は CLAUDE.md を enforced configuration でなく context と位置付けている。矛盾する指示があると任意に選ぶ、としている。`output-styles/Caveman.md` の「前置きは書かない」とは、列挙を「最終返答の末尾」に限定することで区別してあるが、競合と読まれる余地は残る。2026-08-31 に、会話文脈のない新しい session で `skills/git-commit` を発火させたところ、`caveman` が有効なまま末尾へ列挙が出た。1 回の観測なので、競合しない担保にはならない。

## tool の使い分けを契約に置く理由

発端は 2026-11-08 のユーザーの相談。小さな編集でも python で書き換えるなど、作業が大げさになっていた。

読み取りを Read にするのは、作業対象 repo の subdirectory `CLAUDE.md` と `paths` 付き rule を確実に load させるため。Bash で読んだ時は、pipe や redirect を挟むと rule が黙って落ちる（条件と実測は [memory-surface-design.md](./memory-surface-design.md) の「`paths` を使わない」）。Read tool には読み方の条件が無い。shell での読み方の条件を守らせるより、Read に揃える方が単純。契約は作業対象 repo の `.claude/rules/` を置き場に挙げているので、落ちると、その repo の規約が効かないまま作業が進む。出力の量と形式は変わらない。2026-11-08 に同じ範囲を Read と `sed -n` で読み比べ、Read の出力が `cat -n` と同じ形式で、余分な付加が無いことを確かめた。呼び出し回数や待ち時間は比べていない。

編集を Edit にするのは、置換の失敗が見えるため。Edit は一致しない時と一意でない時にエラーで止まる。python の `str.replace` は、一致しなくても何も変えずに成功する。python で置換しても Edit と同じ old / new 文字列を送るので、量は減らない。

検索は Grep / Glob tool の有無で書き分けている。Windows では既定で使え、macOS、Linux、WSL では既定で外れている（[Tools reference](https://code.claude.com/docs/en/tools-reference)。2026-11-08 に macOS の session で ToolSearch しても該当なし）。外れた環境では、Claude の shell の `grep` / `find` が組み込み版の `ugrep` / `bfs` で動く。こちらが公式の想定する経路になる。OS 名でなく tool の有無で書くのは、既定が変わっても文面が古くならないため。tool がある時に優先するのは、出力の形（files / content / count）を選べるため。`.gitignore` の扱いには差が無い。組み込みの `grep` も `ugrep --ignore-files` で動く（2026-11-08、macOS の session の `declare -f grep`）。

macOS などで Grep / Glob を戻すことはしない。Tools reference によれば、戻すには、起動 flag の `--tools` / `--allowedTools` で名前を挙げるか、`Bash` を外すしかない。settings の allow rule では戻らず、env-vars の docs にも戻す変数は無い。`Bash` を外すと command を実行できなくなる。起動 flag は CLI の起動のたびに要る。CLI と desktop で使える tool が食い違う割に、得るものは出力の形を選べることだけ。

shell での書き換えを残す 2 つの場面には、それぞれ理由がある。多数ファイルへの同じ置換は、Edit で 1 件ずつ扱うと漏れやすい。formatter と generator の出力は、そもそも Edit では作れない。

auto mode は、shell での読み書きを認める指示を session へ入れる（文面は [memory-surface-design.md](./memory-surface-design.md)）。契約は harness の指示に勝つ（2026-09-02、apply 後の別 session で確認）。どちらを優先するかを契約の行に書いているのは、文面が変わっても判断を揺らさないため。

2026-09-02 に同じ規則を一度外している。理由は「auto mode では Bash の方が効率と正確さで優る」というユーザー判断で、二次情報に基づいていた。効率のうち出力の量と形式は、上の実測で差が無かった。正確さの根拠は記録に無く、2026-11-08 時点でユーザーも覚えていない。同じ理由で外す前に、根拠を一次情報で確かめる。

## 未確認

- 契約の tool の使い分けの行が、実際の session で python での書き換えを止めるか。
- desktop app で、Grep / Glob を戻す起動 flag を渡せるか。
