# git-commit skill の設計

- Date: 2026-11-10
- 出典: [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) の `skills/caveman-commit/SKILL.md` / [Best practices for skill creators](https://agentskills.io/skill-creation/best-practices) / [Extend Claude with skills](https://code.claude.com/docs/en/skills)（2026-11-08 と 2026-11-10 確認） / [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions) / この repo の commit 履歴の実測 / 使い捨て repo での prek の実測 / Claude Code の session の記録 / 使い捨て repo での skill の版の比較

`git-commit` skill が今の形になっている理由を残す。skill 本体を読んでも分からない前提と実測に絞る。

## 責務が message 生成に留まらない理由

参考にした `caveman-commit` は commit message の生成のみを担い、`git commit` も staging も行わない。この skill は状態の確認から commit の実行と報告までを担う。

message 生成だけに絞ると、止まる条件、staging の規定、staged diff の確認という安全側の規定が失われる。守備範囲が重なるのは message の書式だけなので、その範囲でだけ `caveman-commit` を参照している。

## title の規定

以下の数値は 2026-08-27 時点の commit 履歴の実測。

- scope を使わない。理由は title の可読性。scope が入ると title が長くなり `git log --oneline` で読み取りにくくなる。全 commit のうち scope 付きは 0 件。
- 英語で書く。全 commit が英語。応答言語が日本語（`settings.json` の `language`）なので、規定が無いと日本語 title を書きうる。「50 文字」の単位も、全角か半角かで実質の長さが倍近く変わって曖昧になる。
- 50 文字を目安、72 文字を上限。実測が既にこの範囲へ収まっており、現状追認になる。
- 命令形、末尾ピリオド禁止、emoji 禁止は `caveman-commit` から採った。

形式の検査は repo の commit-msg hook が持つ。この repo では prek の `check-commit-msg` が、type、scope の有無、description の先頭の小文字、末尾のピリオド、72 文字の上限を見る（[lint-and-pre-commit-execution.md](./lint-and-pre-commit-execution.md) の「commit message の title を検査する hook」）。skill の規定は、最初から hook を通る message を書くためのもの。repo が別の形式を決めていればそちらに従うのは、形式の正本が repo の hook の側にあるため。

## body の規定

body には原則 `Why:` を 1〜2 文書く。notes は今の設計しか書かないので（`skills/scribe` の「notes は今の設計を書く」）、変えた直接の理由は commit に残す。複数案を比べた判断は ADR にも残るが、ADR を作らない変更の理由は commit にしか残らない。理由が一般論しか書けない時と、title だけで理由が明らかな変更では省く。一般論の `Why:` は、読む人の判断を何も変えない。

`What:` と `Impact:` は、書く条件を `references/message-format.md` に置いている。2026-08-27 時点で body を持つ commit 66 件の実測は `Why:` 56 / `What:` 56 / `Impact:` 55。ほぼ機械的に 3 点セットで書かれていた。任意の規定が惰性化していたので、ラベルごとに条件を付けている。

`Impact:` の中身は 3 種類に分かれる。

1. 変更がもたらす状態。未完成状態の警告、復元手段、security 境界の変化。`What` では書けない。
2. 変わらないものの明示。「deny rule は依然有効」「sandbox の境界は無傷」など。permissions と sandbox を頻繁に触るこの repo では、「この変更が何を弱めていないか」の記録に実用価値がある。`Why` でも `What` でも書けない。
3. 空振り。`Docs only; no behavior change.` のような内容の無い行。

2 の用途が固有なのでラベルを残し、3 を禁じている。

代替案の枠は持たない。全 commit の body を検索しても、代替案を記録した実例は無い。捨てた案の置き場は doc の 3 層で ADR か notes と定義済みなので、commit body に枠を作ると二重管理になる。採らなかった案の理由が要る場合は `Why:` に含める。

AI 帰属の禁止は skill に書かない。制御点は settings 側にある（下の「Co-authored-by trailer は skill の外で決まる」）。

## footer と issue 参照

git trailer 形式（`Refs: #123` など）を規定する。ただしこの repo では、trailer も `#123` 形式の issue 参照も全 commit で 0 件。個人 dotfiles で issue を運用していないため。規定は残す。skill は user-global で、issue を使う repo でも読まれるため。ただし例には架空の trailer を置かない。

git trailer の仕様はコロンあり・なしの両方を許すが、コロンありに統一する。`Closes #42` は GitHub の自動クローズ構文で、trailer 仕様に寄せる理由がない。

## 止まる条件が手順のステップでない理由

止まる条件は手順全体にかかる制約として、別の節に書いている。手順 2 で確かめるが、後半の 2 つ（分け方が決まらない、1 つのファイルの中に入れる変更と入れない変更が混ざっている）は、範囲を決める段階まで分からない。

混在差分そのものは止まる理由にしない。分割して複数 commit にすれば済む場面が多い。止まるのは、分け方が決まらない時と、1 ファイル内に範囲に入れる変更と入れない変更が混ざりファイル単位で分けられない時。後者は hunk 単位の staging に `git add -p` が要る。`git add -p` は、答えを stdin から流し込めば agent でも動く（2026-11-08 に確認）。それでも使わないのは、答えの順番が hunk の並びとずれた時に、別の hunk が黙って stage されるため。止めてユーザーに委ねる方が安全。

1 ファイルを割る手は `git add -p` だけではない。2026-11-07 の session では、agent が今の版を scratchpad に控え、途中の版を作って順に stage し、1 つの note を 3 つの commit に割った。この手も、1 つのファイルの中に入れない変更が残るので、止まる条件に当たる。worktree のファイルを書き換える手なので、書き戻しを誤ると未 commit の編集を失う。

## 変更の単位

skill は分ける条件と並べて、分けない条件を持つ。2026-11-07 の履歴に、細かすぎる分割が出ていた。変更から機械的に決まる追従を別 commit にした型で、TODO の項目を閉じる commit と、残りの番号を振り直す commit が同じ分に並ぶ組が 4 つある（16:48〜16:59）。閉じる commit だけでは番号が飛ぶ。振り直す commit は 4 本とも、note 内の参照も直している（例: `TODO.md の 9` → `8`）。

分ける軸は目的と type の 2 つ。type を入れているのは、1 commit に 2 つの type が入ると、title の type がどちらかで嘘になるため。

repo の `AGENTS.md` や `CLAUDE.md` が分け方を決めていればそれに従う。skill は user-global で、分け方の運用は repo ごとに違う。

## surface の変更と doc を同じ commit にしない理由

この repo では、`dot_claude/` などの surface の変更と、その理由を書いた `docs/notes/` を別 commit にする。この規定は root `AGENTS.md` の「変更後の確認」が持ち、skill は repo の規定に従うとだけ書く。

同じ commit に入れる案も成立する。理由の記録は変更に従属するので、`git revert` した時に理由だけ残ると存在しない状態を説明する doc になる。それでも分けているのは、type を正確に保つ方を取ったため。1 commit にすると `feat` と `docs` のどちらを名乗っても片方が嘘になり、`git log --oneline` を type で追えなくなる。revert の齟齬は、戻す時に doc も直せば閉じる。

`docs/notes/` 側が実測の記録である場合は、そもそも変更に従属しない。単独で真なので分けるかどうかを判断するまでもない。

## 秘密情報の確認方法

目視ではなく staged diff に対する検索で確かめる。diff が長いと目視は漏れる。検索パターンは固定しない。言語や文脈に依存するため。

## 確認の報告に何を見たかを書かせる理由

報告は「staged diff で何を見たか」と「hook の結果」を持つ。「確認した」だけでは、次に読む人が確認の範囲を再現できない。2 種類の確認は性質が違い、単語 1 つの enum に収まらない。

報告は、`lapidary` が直したものと、提案した組み込みの review も持つ。`lapidary` は提案を自分の報告の最後に置くが、手順 4 から呼ばれた時は、最後の報告がこの skill の「出力」の形になる。そこに項目が無いと、提案が落ちる。2026-11-10 の session では、agent の設定（`dot_codex/AGENTS.md`）に触れる commit で、`lapidary` の条件に当たる `/security-review` の提案が報告に出なかった。

## pre-commit hook の実態

この repo の pre-commit hook のうちファイルを書き換えるのは `fix end of files`、`mixed line ending`、`rumdl-check --fix`、`tombi-format`。`trim trailing whitespace` も書き換えるが、`.md` を exclude しており、skill や docs のような主要ファイルには発火しない。commit-msg の段では `check-commit-msg` だけが走る。

自動修正型が発火すると commit が失敗し、修正後の内容が unstaged で残る。差分を確認せずに再 stage すると、hook が何を変えたか分からないまま commit することになる。

skill の Gotchas には一般則だけを置き、上の hook 名は置かない。skill は全 project へ配布されるので、この repo の hook 名は他の project では関係が無い。どの hook がファイルを書き換えたかは、commit が失敗した時の prek の出力に hook 名と `files were modified by this hook` として出るので、名前を事前に知らなくても見分けられる（2026-10-16 に使い捨て repo で `end-of-file-fixer` を発火させて確認）。

## ファイル分担

各ファイルの中身は、それぞれを正本とする。ここには分け方の理由だけを置く。

公式の best practices は 2 つを勧めている。reference は「いつ読むか」を条件で示す。環境固有で常識に反する事実（Gotchas）は `SKILL.md` 側へ置く。後者を reference に置くと、読むべき状況が来たことを認識できない。失敗した時の対応も、Gotchas として `SKILL.md` に置いている。

報告項目も `SKILL.md` に置く。報告は毎回書くもので、reference は必要な時だけ読むもの、という progressive disclosure の区分に従う。これで reference は、`Why:` 以外のラベル、footer、`BREAKING CHANGE` の書式（`message-format.md`）だけになる。

ファイル名に `commit-` prefix を付けないのは、パスが `skills/git-commit/references/` で skill 名が既に文脈を決めているため。`scribe` の reference（`adr-format.md` など）も prefix なし。

Gotchas に入れるのは、この環境で実際に踏んだか踏みかけたもの。ここでいう環境は skill の配布先に共通する実行環境で、この repo だけの事実は入れない（「pre-commit hook の実態」）。列挙は `SKILL.md` を正本とし、ここでは繰り返さない。

`diff <(...)` が sandbox で失敗する件は skill に置いていない。git 固有ではなく sandbox 全般の制約で、commit の手順にも該当する操作が無いため。sandbox 全般の制約を置く surface が無いので、記録をここに残す。`diff <(...)` は sandbox で `/dev/fd/N: Operation not permitted` になる（2026-11-09 にも再現）。比較は一時ファイルへ出力してから行う。

## push skill を持たない理由

Git 操作の skill は `git-commit` だけで、push 用の skill は持たない。sandbox 内から SSH push が通らないため、手順書を用意しても実行できない。通らない仕組みと、試して効かなかった設定は [claude-code-settings-design.md](./claude-code-settings-design.md) の「push は sandbox 内で SSH を通らない」にある。

push は人が手元の terminal で実行し、agent は commit までを担う。この分担は `dot_claude/CLAUDE.md` の「Git」が持つ。skill は push を扱わないと description に書くだけにしている。常時読まれる側に置く理由は [claude-md-design.md](./claude-md-design.md) の「push を契約に書いている理由」にある。

ADR は書かない。3 条件のうち「覆すコストが高い」を満たさない。sandbox の方針が変われば push が通るようになり、その時は再検討する。

## description の重心と境界

依頼語に絞らず、ユーザーが commit という語を出さなくても、作業を Git の履歴に残す流れなら拾う。明示依頼では通ったが、「進めて」「直して」の流れで commit する場面では通っていなかった（2026-08-31 に実測）。一般則は [harness-design-principles.md](./harness-design-principles.md) の「skill description の書き方」にある。

「作業が一段落した時」のような、commit を伴わない区切りは発火の場面に書かない。そこで load されると、commit しない区切りで `lapidary` まで走る。

「push、rebase、amend は扱わない」も description に書いている。description は skill を読む前に見える唯一の面なので、境界はここにも要る。commit の作業には履歴の組み直しが混ざりやすい。2026-08-31 の session では `amend` と `reset` を繰り返し使い、その都度この skill の範囲外だと明示する必要があった。

## 実行条件を skill 本体にも置く理由

description は作業を Git の履歴に残す流れなら skill を通すと広く取り、自動で発火させる。発火した先で commit まで走らないよう、手順の前に「指示された段までしか進まない」を置いている。

`dot_claude/CLAUDE.md` の「Git」も「commit はユーザーに指示された時だけ作る」を持つ。二重に見えるが、効く位置が違う。契約は skill を呼ぶかどうかの判断に効き、skill の条件は load された後に効く。skill 本体が持たないと、load された時点で手順 7 の commit まで止まるものが無い。

発火の側で止める形（description を絞る、`disable-model-invocation: true` を置く）は採らない。commit する流れで staging の規定と秘密情報の検索ごと飛ぶ。一般則は [harness-design-principles.md](./harness-design-principles.md) の「発火面と実行条件を分ける」にある。

## lapidary を手順で呼ぶ理由

手順 4 で、commit する変更の全体を `lapidary` で見直す。`lapidary` は description で commit の前に発火する設計だが、それだけでは発火しない場面が多かった。`lapidary` の description を当時の形にした `5b9b39d`（2026-11-07）の後の 4 session（2026-11-07〜08）で、commit を頼む発言を数えた。

- 「見直して commit」のように見直しの語を含む発言は 2 回で、2 回とも `lapidary` が発火した。
- 見直しの語を含まない発言は 6 回。直前に `lapidary` が発火したのは 1 回だった。1 回は、直前の発言で `lapidary` を通した後だった。残る 4 回は、commit する変更に `lapidary` を通さないまま commit した。
- この skill は、commit を実行した発言のすべてで、起動していたか load 済みだった。

確実に load されるこの skill の手順に置くと、`lapidary` の発火を description だけに頼らずに済む。上の 4 回は、どれも同じ session の前の段階で `lapidary` を通しており、その後に変更を足していた。公式の [Extend Claude with skills](https://code.claude.com/docs/en/skills) によると、skill の本文は一度 load されると会話に残り、後の turn で読み直されない。load 済みの skill は、変更が増えても通し直されにくいと見ている。そのため「通したか」を確かめるのでなく、commit を頼まれるたびに、その時 commit する変更の全体を通す形にしている。見直しの後に変更を足した時は、足した分を通し直す。

範囲が複数でも、範囲ごとには分けずに 1 回で通す。理由は 3 つある。

- 見直しは変更セット全体を見る行為で、commit の分け方とは層が違う（[lapidary-skill-design.md](./lapidary-skill-design.md) の「commit の前に通す理由」）。surface と notes を別の範囲として別々に見ると、追従漏れを見つける場が消える。
- 範囲ごとに回すと書いていた間に観測した 2 回は、どちらも 1 回だけ通していた。2026-11-09 の session は 5 つの範囲を、2026-11-10 の session は 2 つの範囲を、まとめて 1 回通した。
- 呼び直しても読み込まれるものが無い。公式の Extend Claude with skills によると、同じ内容の skill を呼び直した時は、本文ではなく読み込み済みを示す短い注記が足される。

`lapidary` の観点はここへ写さない。この skill が持つのは、変更の全体を渡して通す 1 段だけ。観点を取り込まない理由は [lapidary-skill-design.md](./lapidary-skill-design.md) の「`git-commit` に組み込まない理由」にある。

## Co-authored-by trailer は skill の外で決まる

skill は trailer を規定していない。付くかどうかは実行する harness の system prompt が決め、制御点は settings の `attribution` にある。この repo では `attribution` で止めている（理由と実測は [claude-code-settings-design.md](./claude-code-settings-design.md)）。

履歴に残る不揃いは skill の不備ではない。

## 作業範囲と実行権限を分ける理由

Codex の `workspace-write` は、書き込み可能な root 内でも `.git` を読取り専用として保護する。worktree の参照先も対象になる。コミットの作業指示だけでは、この境界を越える実行権限は得られない（[Protected paths in writable roots](https://learn.chatgpt.com/docs/agent-approvals-security#protected-paths-in-writable-roots)）。

同じ権限での再実行と、正式な承認を得た実行経路への切替を区別する必要がある。Auto-review は必要な申請を審査するもので、sandbox の権限を広げる設定ではない（[Auto-review](https://learn.chatgpt.com/docs/sandboxing/auto-review)）。Codex の skill は、`git add` と `git commit` をそのコマンドだけに限って申請することと、拒否されたら止まることを Gotchas に持つ。申請の一般的な規定は `dot_codex/AGENTS.md` の「権限」にある。

Claude 側の配布設定は `allowUnsandboxedCommands: false` を持つ。公式仕様では sandbox 外への再試行を禁止する設定であり、Codex の承認経路を機械的に移植しない（[Claude Code sandboxing](https://code.claude.com/docs/en/sandboxing)）。Claude 側の skill は、署名の失敗で迂回せず止まることと、再実行を 1 回に限ることを Gotchas に持つ。作業指示と実行権限を分け、deny を迂回しない意図は共通にする。

## 未確認

- description の trigger eval は未実施。公式の手順は 20 query × 3 run × 5 iteration の自動ループを想定しており、実行コストが大きい。現状は公式の記述指針（命令形、user intent への焦点、near-miss の明示、1024 文字以内）に照らした手動点検のみ。
- 「進めて」の流れで commit に向かう場面で skill が通るかは未測定。
- 手順 4 が毎回効くかは未測定。2026-11-09 と 2026-11-10 の session では、commit の依頼で手順 4 から `lapidary` が起動した。この skill が load 済みのまま次の commit を頼まれた時に、手順 4 が読み直されるかは確かめていない。
- 「出力」に足した `lapidary` の項目で、提案が報告に出るようになるか。落ちた観測は 2026-11-10 の 1 回だけ。
- Codex で、同じ内容の skill を呼び直した時に本文が読み直されるか。Codex の skill にも同じ手順を入れているが、呼び直しの挙動と 2 回の観測は Claude Code のもの。
- 2026-11-07 の 16:48〜16:59 にある close と renumber の組が、どの session でどう分けられたかは未確認。Claude Code と Codex の session の記録には、log を表示した出力しか残っていない。
