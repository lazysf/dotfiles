# CLAUDE.md の設計

- Date: 2026-11-13
- 出典: [How Claude remembers your project](https://code.claude.com/docs/en/memory) / [Best practices for Claude Code](https://code.claude.com/docs/en/best-practices) / [Hooks reference](https://code.claude.com/docs/en/hooks) / [Checkpointing](https://code.claude.com/docs/en/checkpointing) / [Configure permissions](https://code.claude.com/docs/en/permissions) の「What `Read` and `Edit` rules cover」（2026-11-09 確認） / [Claude Code settings](https://code.claude.com/docs/en/settings) / `dot_claude/CLAUDE.md` / この環境での実測 / Codex での作業記録の要約（ユーザー提供）

`dot_claude/CLAUDE.md` が今の形になっている理由を残す。本体を読んでも分からない前提と判断に絞る。

## ここに置くものの基準

CLAUDE.md は全セッションの先頭で読まれる。残すのは、Claude が既定ではしないこと、または repo から読めないことを指示する行だけ。公式の [Best practices](https://code.claude.com/docs/en/best-practices) の "Claude already knows most of what you might be tempted to write down" に従う。起動後の手順は `skills/` にあり、ここでは重複させない。

この基準で、次の種類はここに置かない。

- KISS / YAGNI / DRY、断定を根拠に結び付けることのような、一般的な開発の原則。
- 確認の質問をいつするか、plan mode をいつ始めるかのような、工程の進め方。Claude Code の既定の振る舞いと tool の説明が持つ。
- review をいつ通すか、doc をいつ直すか。前者は `skills/git-commit` の手順が `skills/lapidary` を呼び、後者は `skills/scribe` の description が持つ（[lapidary-skill-design.md](./lapidary-skill-design.md)、[scribe-skill-design.md](./scribe-skill-design.md)）。
- 規則の定義や置き場のような、規則についての説明。理由はこの notes に書く。

設定や防御が有効かを実測で確かめるまで数えない、という規律は置いていない。hook の試験（2026-11-08）では、試験の手順自体の誤りで、穴を見落としたり、試せていない場面を試したと数えたりした。実測を有効の条件にすると、誤った実測がそのまま有効の根拠になる。強制の仕組みは、作りを見れば正しさが分かる単純な形にする（[harness-design-principles.md](./harness-design-principles.md) の「削る基準」）。

外す側の「設定や防御を外す前に、それに依存しているものが無いことを確かめる」は残している。`sandbox.network.allowUnixSockets` を「push に使えないので用途が無い」と判断して落とし、commit の署名を壊したことがある（[claude-code-settings-design.md](./claude-code-settings-design.md) の「署名 agent の socket を通す理由」）。同じ socket を署名も使うことは、Claude の既定の確認では見えなかった。

公式目安は 1 ファイル 200 行。常時 load されるのはこの 1 枚だけで 46 行（2026-11-09、`wc -l`）。目安に収まっている。`rules/` を持たず 1 枚へ集約している理由は [memory-surface-design.md](./memory-surface-design.md)。

## Git の節を持つ理由

組み込みの git 指示は `settings.json` の `includeGitInstructions: false` で止めている（[claude-code-settings-design.md](./claude-code-settings-design.md) の「組み込みの git 指示を止める理由」）。止めると、組み込みの指示が持っていた安全側の規定も消える。そのうち履歴と署名を守る規定（git config を変えない、hook と署名を迂回しない、未 commit の変更や履歴を壊す操作をしない）を、この節と `skills/git-commit` に置いている。

branch と PR の運用は、repo ごとの `AGENTS.md` / `CLAUDE.md` に任せ、書かれていなければ今の branch へ commit する。この形を選んだ理由は記録に無い。user-global の契約で branch を決めた場合は、repo の運用と食い違った時にどちらに従うかが決まらない。CLAUDE.md は上書きでなく連結で読まれ、矛盾があると Claude はどちらかを任意に選ぶ（[How Claude remembers your project](https://code.claude.com/docs/en/memory)）。

### push を契約に書いている理由

push を agent が実行した時の結果は、OS で違う。mac の sandbox では、SSH の remote への push は、proxy が SSH を運ばないので失敗する。native Windows の HTTPS の `origin` では、止める設定が無いと、保存済みの資格情報で通る。どちらの理由も、止める設定も、[claude-code-settings-design.md](./claude-code-settings-design.md) の「push は sandbox 内で SSH を通らない」にある。契約には、OS で変わらない「agent は実行しない」だけを書く。`skills/git-commit` は push を扱わないと書くだけで、理由は持たない。その skill も commit 依頼でしか発火しない。「push して」とだけ言われた時、agent は push を試みる経路へ進む。

常時読まれる側に 1 文だけ置く必要がある。

## 「確認してから進めること」を判定できる形にしてある理由

「公開インターフェースに影響する」と書くと、文字通り読めば新規関数 1 本でも確認が要る。「変える、または消す」に絞った。そのうえで「後から変えると外部を壊すもの（公開 API、永続化 schema、CLI 引数、設定キー）は、新しく定義する時も含む」を添え、判定を 1 問へ集約してある。

「大きな設計変更」も主観語なので使わない。module 境界の移動、data flow の作り直し、framework や library の入れ替えという例示で閾値を示す。

## 手段の選び方を原則に置く理由

発端は、Codex での Excel 作業で起きた事故。依頼は、別ブックの様式シートを既存ブックへ移すことだった。agent はシートをコピーせず、フォント、列幅、色などを既存シートへ個別に移す自前の処理を選んだ。原資料との不一致と移植漏れが出て、指摘のたびに局所的な補修が足された。最終的な解は、標準のシートコピーでシート名と CodeName を維持し、指定された名前定義だけを削除する形だった。当時の判断理由は記録に残っていない。

置き場は skill でなく原則にしている。`skills/lapidary` の過剰さの観点も既存の仕組みで足りる自前実装を拾うが、作業の後にしか効かない。

比べ直しのトリガは、語でなく出来事で決めている。「補正」と「補修」を語だけで区別すると、事後の直しを「小さな補正」と呼び替えて発火を避けられる。「2 回目」としているのは、1 回だけ比べて続行と結論すると、その後どれだけ食い違いが増えても比べ直す契機が無くなるため。事故では指摘のたびに補修が続いた。対象を「同じ手段への手直し」に限るのは、既存コードの bug fix まで含めると、「既存の自前実装を標準機能へ置き換える」方向へ倒れるため。求めるのは比べ直すことだけで、作り直しは求めない。

報告や承認は求めていない。根拠の報告は「報告」の節がすでに持つ。通常の小さな変更に比較表や承認を一律に足すと、負担だけが増える。

## 報告を 4 つに分ける条件

「変更内容、根拠、検証結果、未確認の事項を分けて書く」の対象は、ファイルを変えた作業の完了報告と、別の session や人への引き継ぎに限っている。条件が無いと、質問への答えや読むだけの作業にも同じ形を求める。どちらの条件も、ファイルを変えたか、作業を相手へ渡すかという出来事で判定でき、主観語に頼らない。

この行の由来は記録に無い。同じ趣旨の行は最初の版（`fa9386d`、2026-05-31）からあり、どの失敗への対策かは notes にも commit にも残っていない。

検証結果と未確認の事項の報告は、Claude Code の system prompt の "Report outcomes faithfully" が既定で持つ（2026-11-08、この環境の session で確認）。それでも行を残すのは、根拠を分けて書くことが既定に無いため。手段の選び方の行は、根拠の報告をこの行に任せている（上の「手段の選び方を原則に置く理由」）。

## スコープを 1 つに保つ規律をここに置く理由

作業の開始時点で決まる話なので、skill では拾えない。`skills/` は起動後の手順で、「今どのスコープにいるか」を持たない。

この環境では 2 つの形で逸脱した。1 つは、ある領域の作業中に別の領域へ着手して止められたこと。もう 1 つは、観点の点検を依頼されて答えを出した後、そのまま文言の推敲へ流れ、何度も推敲した末に案そのものが不要だと分かったこと。前者は範囲の逸脱、後者は目的の逸脱で、どちらも各ステップ単体では要求どおりに見える。全体を通してスコープが動いていることは、作業を俯瞰する側でしか気づけない。

見つけた無関係の問題の行き先は、この repo では root `TODO.md`（root `AGENTS.md` の「置き場」）。契約は「ユーザーへ伝える」までを持ち、行き先は repo に任せる。

## スキル名の列挙をここに置く理由

「使ったスキル名を挙げる」は応答の書式だが、output style には置かない。style を切り替えると読まれなくなるため。どの output style でも効かせたいので、常時 load される側が置き場になる。

hook で機械化していない。hook が出せる `systemMessage` は harness がユーザーへ見せるメッセージで、assistant の返答本文ではない。求めているのは返答そのものに含まれることなので、hook では形が違う。

そのため遵守は LLM 依存になる。公式は CLAUDE.md を enforced configuration でなく context と位置付けている。矛盾する指示があると任意に選ぶ、としている。組み込みの Concise は "no closing recap of what you already said" を求めるが、スキル名の列挙は既に言ったことの要約ではないので、競合しない書き方にしてある。2026-11-09 の session では、Concise が有効なまま、スキルを使ったターンの最後に列挙が出た。1 回の観測なので、競合しない担保にはならない。

## tool の使い分けを契約に置く理由

発端は 2026-11-08 のユーザーの相談。小さな編集でも python で書き換えるなど、作業が大げさになっていた。

読み取りを Read にするのは、作業対象 repo の subdirectory `CLAUDE.md` と `paths` 付き rule を確実に load させるため。Bash で読んだ時は、pipe や redirect を挟むと rule が黙って落ちる（条件と実測は [memory-surface-design.md](./memory-surface-design.md) の「`paths` を使わない」）。Read tool には読み方の条件が無い。shell での読み方の条件を守らせるより、Read に揃える方が単純。出力の量と形式は変わらない。2026-11-08 に同じ範囲を Read と `sed -n` で読み比べ、Read の出力が `cat -n` と同じ形式で、余分な付加が無いことを確かめた。呼び出し回数や待ち時間は比べていない。

編集を Edit / Write にする理由は 3 つある。

- 置換の失敗が見える。Edit は一致しない時と一意でない時にエラーで止まる。python の `str.replace` は、一致しなくても何も変えずに成功する。python で置換しても Edit と同じ old / new 文字列を送るので、量は減らない。
- `/rewind` で戻せる。公式の [Checkpointing](https://code.claude.com/docs/en/checkpointing) は "A file that only Bash commands changed isn't tracked and stays as it is" と書く。
- `Edit` の deny rule が掛かる。公式の [Configure permissions](https://code.claude.com/docs/en/permissions) によると、deny rule は built-in の file tool と、Claude Code が認識する Bash の file command（`cat`、`sed`、`tee` など）と redirect の先に効く。自分でファイルを開く Python や Node の script には効かない。

shell での書き換えを残す 2 つの場面には、それぞれ理由がある。多数ファイルへの同じ置換は、Edit で 1 件ずつ扱うと漏れやすい。formatter と generator の出力は、そもそも Edit では作れない。

auto mode は、shell での読み書きを認める指示を session へ入れる（文面は [memory-surface-design.md](./memory-surface-design.md)）。2026-11-13 の session では、その指示が「The choice is yours」で終わり、どちらの手段を使うかを model に任せていた。同じ session には契約も読み込まれていたが、model（Opus 5.5）は `cat` と heredoc でファイルを読み書きした。そのため契約は、harness が shell を勧めても自分を優先すると明記している。2026-09-02 には、この明記が無い契約でも、apply 後の別 session で harness の指示に勝った。ただし、その時とは指示の文面が違い、その時の model は記録に無い。

2026-09-02 に同じ規則を一度外している。理由は「auto mode では Bash の方が効率と正確さで優る」というユーザー判断で、二次情報に基づいていた。効率のうち出力の量と形式は、上の実測で差が無かった。正確さの根拠は記録に無く、2026-11-08 時点でユーザーも覚えていない。同じ理由で外す前に、根拠を一次情報で確かめる。

## git の author を差し替えない規律を Privacy に置く理由

Privacy の節は、git の author と committer を repo の git 設定のまま使い、環境変数や option で差し替えないと定めている。公開用のアドレスを入れる役目は、人が持つ git の設定（`dot_config/git/config.tmpl` が GitHub の noreply を入れる）に任せる。

以前は「git の author には公開用のアドレス（GitHub なら noreply）を使う」と書いていた。これは設定を作る人に向けた書き方で、commit するだけの agent には「author をそう差し替えろ」と読める。2026-11-09 に、Codex が `$TMPDIR` の使い捨ての repo で commit を頼まれ、`GIT_AUTHOR_*` と `GIT_COMMITTER_*` を合成の名前とアドレスに差し替えた。理由を聞くと、この行を根拠に挙げた。git の設定は既に noreply を返していて、差し替える必要は無かった。本物の repo で同じことをすると、commit の名義が変わる。

設定のアドレスが公開してよいと確かめられない時に agent が直さず、ユーザーに伝えて判断を待つのは、git の設定を変えない規律（「Git」の節）と揃えるため。個人のアドレスに見える時だけに絞ると、社内のドメインのように判定のつかないアドレスで、そのまま commit する読み方が残る。止まるのは commit に進む時だけで、stage だけを頼まれた時は止まらない。名義が履歴に入るのは commit の時だけだから。

## 未確認

- 契約の tool の使い分けの行が、実際の session で python での書き換えを止めるか。
- harness より契約を優先するという明記が、auto mode の session で shell での読み書きを止めるか。
- 組み込みの git 指示を止めた後、branch の運用が書かれていない repo で、今の branch へ commit するか。2026-11-09 に、この repo の session で組み込みの git の節が system prompt に無いことは確かめた。
