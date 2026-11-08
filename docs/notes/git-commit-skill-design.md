# git-commit skill の設計

- Date: 2026-11-08
- 出典: [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) の `skills/caveman-commit/SKILL.md` / [Best practices for skill creators](https://agentskills.io/skill-creation/best-practices) / [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions) / この repo の commit 履歴の実測 / 使い捨て repo での prek の実測

`git-commit` skill が今の形になっている理由を残す。skill 本体を読んでも分からない前提と実測に絞る。

## 責務が message 生成に留まらない理由

参考にした `caveman-commit` は **commit message の生成のみ**を担い、`git commit` も staging も行わない。自作 skill は状態確認から commit 実行と報告までを担う。

message 生成だけに絞ると、停止条件・staging 規律・staged diff の検証という安全側の規定が失われる。守備範囲が重なるのは message の書式だけなので、その範囲でだけ `caveman-commit` を参照している。

## title の規定

以下の数値は 2026-08-27 時点の commit 履歴の実測。

- **scope を使わない。** 理由は title の可読性。scope が入ると title が長くなり `git log --oneline` で読み取りにくくなる。全 commit のうち scope 付きは 0 件。
- **英語で書く。** 全 commit が英語。応答言語が日本語（`settings.json` の `language`）なので、規定が無いと日本語 title を書きうる。「50 文字以内」の単位も、全角か半角かで実質の長さが倍近く変わって曖昧になる。
- **50 文字を目安、72 文字を上限。** 実測が既にこの範囲へ収まっており、現状追認になる。
- 命令形、末尾ピリオド禁止、emoji 禁止は `caveman-commit` から採った。

`repo 規約が scope を要求する場合は停止して報告する` を「その規約に従う」へ緩める案は 2026-08-27 に検討して保留した。skill は user-global なので monorepo では摩擦があり得るが、それは想定であって実測ではない。再検討の条件は「実際に monorepo で停止に当たった時」。

## body の規定

`Why:` / `What:` / `Impact:` はラベルごとに要否が違う。実測（2026-08-27 時点、body を持つ commit 66 件）は `Why:` 56 / `What:` 56 / `Impact:` 55。ほぼ機械的に 3 点セットで書かれていた。任意規定が惰性化していたので、ラベルごとに条件を付けている。

`Impact:` の中身は 3 種類に分かれる。

1. **変更がもたらす状態**。未完成状態の警告、復元手段、security 境界の変化。`What` では書けない。
2. **変わらないものの明示**。「deny rule は依然有効」「sandbox の境界は無傷」など。permissions と sandbox を頻繁に触るこの repo では、「この変更が何を弱めていないか」の記録に実用価値がある。`Why` でも `What` でも書けない。
3. **空振り**。`Docs only; no behavior change.` のような内容の無い行。

2 の用途が固有なのでラベルを残し、3 を禁じている。

代替案の枠は持たない。全 commit の body を検索しても、代替案を記録した実例は無い。うち 1 件は「alternatives in the notes」と書いて notes へ寄せている。捨てた案の置き場は doc 3 層で ADR か notes と定義済みなので、commit body に枠を作ると二重管理になる。採らなかった案の理由が要る場合は `Why:` に含める。

AI 帰属の禁止は skill に書かない。制御点は settings 側にある（後述の「Co-authored-by trailer は skill の外で決まる」）。skill が書く層ではない。

## footer と issue 参照

git trailer 形式（`Refs: #123` など）を規定する。ただしこの repo では、skill が書く trailer も `#123` 形式の issue 参照も全 commit で 0 件。個人 dotfiles で issue を運用していないため。規定は残す。skill は user-global で、issue を使う repo でも読まれるため。ただし**例セクションには架空の trailer を置かない**。

git trailer の仕様はコロンあり・なしの両方を許すが、この repo はコロンありに統一する。`Closes #42` は GitHub の自動クローズ構文で、trailer 仕様に寄せる理由がない。

## 停止条件が手順のステップでない理由

停止条件は手順全体にかかる制約として書いている。後半 2 つ（分割の単位が判断できない / ファイル単位で分けられない）は範囲を決める段階まで分からず、手順 1 の `git status -sb` では判定できない。ステップにすると位置が固定され、後の段階で判明する条件と噛み合わない。

混在差分そのものは停止理由にしない。分割して複数 commit にすれば済む場面が多い。停止するのは分割の単位が判断できない時と、1 ファイル内で無関係な変更が混ざりファイル単位で分けられない時。後者は hunk 単位の staging に `git add -p` が要る。`git add -p` は、答えを stdin から流し込めば agent でも動く（2026-11-08 に確認）。それでも使わないのは、答えの順番が hunk の並びとずれた時に、別の hunk が黙って stage されるため。止めてユーザーに委ねる方が安全。

## surface の変更と doc を同じ commit にしない理由

`dot_claude/` などの surface を変えた時、その理由を書いた `docs/notes/` は別 commit にする。skill 側の「性質の違う変更が混ざっていれば分割」をこの組み合わせへ当てた結果で、skill 本文は判断の材料を持たない。

同じ commit に入れる案も成立する。理由の記録は変更に従属するので、`git revert` した時に理由だけ残ると存在しない状態を説明する doc になる。それでも分けているのは、type を正確に保つ方を取ったため。1 commit にすると `feat` と `docs` のどちらを名乗っても片方が嘘になり、`git log --oneline` を type で追えなくなる。revert の齟齬は、戻す時に doc も直せば閉じる。

`docs/notes/` 側が実測の記録である場合は、そもそも変更に従属しない。単独で真なので分けるかどうかを判断するまでもない。

2026-09-01 時点の履歴で、`dot_claude/` と `docs/notes/` を同じ commit で触ったものは 30 件ある。ただしその大半は surface を作り替える `refactor` / `chore` で、単一の rule や skill を足す変更では分かれている。

## 機密混入の確認方法

目視ではなく staged diff 全体に対する検索で確認する。diff が長いと目視は漏れる。**検索パターンは固定しない。** 言語や文脈に依存するため。

## 確認の報告を自由記述にしている理由

「自分が行った staged diff の確認」と「pre-commit hook の結果」の 2 種類があり、単語 1 つの enum に収まらない。

## pre-commit hook の実態

この repo の hook のうち**ファイルを書き換える**のは `fix end of files`、`mixed line ending`、`markdownlint-cli2 --fix`、`tombi-format`。`trim trailing whitespace` も書き換えるが、`.md` を exclude しており、skill / rules / docs のような主要ファイルには発火しない。

自動修正型が発火すると commit が失敗し、修正後の内容が unstaged で残る。差分を確認せずに再 stage すると、hook が何を変えたか分からないまま commit することになる。

skill の Gotchas には一般則だけを置き、上の hook 名は置かない。skill は全 project へ配布されるので、この repo の hook 名は他の project では関係が無い。どの hook がファイルを書き換えたかは、commit が失敗した時の prek の出力に hook 名と `files were modified by this hook` として出るので、名前を事前に知らなくても見分けられる（2026-10-16 に使い捨て repo で `end-of-file-fixer` を発火させて確認）。

## ファイル分担

各ファイルの中身は、それぞれを正本とする。ここには分け方の理由だけを置く。

公式の best practices は 2 つを勧めている。reference は「いつ読むか」を条件で示す。環境固有で常識に反する事実（Gotchas）は `SKILL.md` 側へ置く。後者を reference に置くと、読むべき状況が来たことを認識できない。

報告項目も `SKILL.md` に置く。**報告は毎回書くもので、reference は必要な時だけ読むもの**という progressive disclosure の区分に従う。これで reference は、失敗時の対応（`failure-handling.md`）と message の書式の詳細（`message-format.md`）だけになる。`failure-handling` という名前も内容と一致する。

ファイル名に `commit-` prefix を付けないのは、パスが `skills/git-commit/references/` で skill 名が既に文脈を決めているため。`scribe` の reference（`adr-format.md` など）も prefix なし。

Gotchas に入れるのは、この環境で実際に踏んだか踏みかけたもの。ここでいう環境は skill の配布先に共通する実行環境で、この repo だけの事実は入れない（「pre-commit hook の実態」）。**列挙は `SKILL.md` を正本とし、ここでは繰り返さない。** 実体を写すと片方だけ古くなる。

`diff <(...)` が sandbox で失敗する件は skill に置いていない。git 固有ではなく sandbox 全般の制約で、commit の手順にも該当する操作が無いため。sandbox 全般の制約を置く surface が無いので、記録をここに残す。**`diff <(...)` は sandbox で失敗するので、比較は一時ファイルへ出力してから行う。**

## push skill を持たない理由

Git 操作の skill は `git-commit` だけで、push 用の skill は持たない。**sandbox 内から SSH push が通らない**ため、手順書を用意しても実行できない。通らない仕組みと、試して効かなかった設定は [claude-code-settings-design.md](./claude-code-settings-design.md) の「push は sandbox 内で SSH を通らない」にある。

そのため **push は人が手元の terminal で実行し、agent は commit までを担う**。`SKILL.md` の「扱わないもの」にこの分担を書いているのは、skill が無いと agent が自己流で `git push` を打って失敗するため。

ADR は書かない。3 条件のうち「覆すコストが高い」を満たさない（skill の復元は archive branch から容易）。sandbox の方針が変われば push が通るようになり、その時は再検討する。

## description の重心と境界

依頼語に絞らず、ユーザーが commit という語を出さなくても、変更を Git 履歴へ残す流れなら拾う。明示依頼では通ったが、「進めて」「直して」の流れで commit する場面では通っていなかった（2026-08-31 に実測）。一般則は `harness-design-principles.md` の「skill description の書き方」にある。

「作業が一段落した時」のような、commit を伴わない区切りは発火の場面に書かない。そこで load されると `lapidary` の「commit する流れ」に当たると読め、`lapidary` の自動発火を commit の前に限った判断（[lapidary-skill-design.md](./lapidary-skill-design.md)）と食い違う。「進めて」の流れを拾うために description が持つのは、先頭の「commit する時に使う」と、「commit という語を出さなくても」の文の 2 つ。

「push と履歴の書き換え（rebase / amend / squash）は扱わない」も description に書いている。body の「扱わないもの」と重なるが、description は skill を読む前に見える唯一の面なので、境界はここにも要る。commit の作業には履歴の組み直しが混ざりやすい。2026-08-31 の session では `amend` と `reset` を繰り返し使い、その都度この skill の範囲外だと明示する必要があった。

## 実行条件を skill 本体にも置く理由

description は「変更を Git 履歴へ残す流れなら skill を通す」と広く取り、自動で発火させる。発火した先で commit まで走らないよう、手順の入口に実行条件を置いている。

`dot_claude/CLAUDE.md` の工程表も「commit: ユーザー指示時に `skills/git-commit`」を持つ。二重に見えるが、効く位置が違う。工程表は skill を呼ぶかどうかの判断に効き、入口の条件は skill が load された後に効く。**skill 本体が持たないと、load された時点で手順 5 の commit まで止まるものが無い。**

発火の側で止める形（description を絞る、`disable-model-invocation: true` を置く）は採らない。commit する流れで staging 規律と機密情報の検索ごと飛ぶ。一般則は `harness-design-principles.md` の「発火面と実行条件を分ける」にある。

## Co-authored-by trailer は skill の外で決まる

skill は trailer を規定していない。付くかどうかは実行する harness の system prompt が決め、制御点は settings の `attribution` にある。この repo では `attribution` で止めている（理由と実測は [claude-code-settings-design.md](./claude-code-settings-design.md)）。

**履歴に残る不揃いは skill の不備ではない。**

## 作業範囲と実行権限を分ける理由

Codex の `workspace-write` は、書き込み可能な root 内でも `.git` を読取り専用として保護する。worktree の参照先も対象になる。コミットの作業指示だけでは、この境界を越える実行権限は得られない（[Protected paths in writable roots](https://learn.chatgpt.com/docs/agent-approvals-security#protected-paths-in-writable-roots)）。

同じ権限での再実行と、正式な承認を得た実行経路への切替を区別する必要がある。Auto-review は必要な申請を審査するもので、sandbox の権限を広げる設定ではない（[Auto-review](https://learn.chatgpt.com/docs/sandboxing/auto-review)）。判断手順の正本は `dot_codex/skills/git-commit/references/failure-handling.md` に置く。

Claude 側の配布設定は `allowUnsandboxedCommands: false` を持つ。公式仕様では sandbox 外への再試行を禁止する設定であり、Codex の承認経路を機械的に移植しない（[Claude Code sandboxing](https://code.claude.com/docs/en/sandboxing)）。作業指示と実行権限を分け、deny を迂回しない意図は共通にする。

## 未確認

- 承認・拒否の実機検証と、Claude 側の上記設定の実効性確認は未実施。2026-10-31 の確認は、指示を辿るシナリオ評価と静的検証に限る。
- description の trigger eval は未実施。公式の手順は 20 query × 3 run × 5 iteration の自動ループを想定しており、実行コストが大きい。現状は公式の記述指針（命令形、user intent への焦点、near-miss の明示、1024 文字以内）に照らした手動点検のみ。
- 「進めて」の流れで commit に向かう場面で skill が通るかは未測定。
