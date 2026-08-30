# git-commit skill の設計

- Date: 2026-08-28
- 出典: [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) の `skills/caveman-commit/SKILL.md` / [Best practices for skill creators](https://agentskills.io/skill-creation/best-practices) / [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions) / この repo の commit 履歴の実測

`git-commit` skill が今の形になっている理由を残す。skill 本体を読んでも分からない前提と実測に絞る。

## 責務が message 生成に留まらない理由

参考にした `caveman-commit` は **commit message の生成のみ**を担い、`git commit` も staging も行わない。自作 skill は状態確認から commit 実行と報告までを担う。

message 生成だけに絞ると、停止条件・staging 規律・staged diff の検証という安全側の規定が失われる。守備範囲が重なるのは message の書式だけなので、その範囲でだけ `caveman-commit` を参照している。

## title の規定

- **scope を使わない。** 理由は title の可読性。scope が入ると title が長くなり `git log --oneline` で読み取りにくくなる。実測（2026-08-27 時点）で 373 commit のうち scope 付きは 0 件。
- **英語で書く。** 実測 373 commit すべて英語。応答言語が日本語（`settings.json` の `language`）なので、規定が無いと日本語 title を書きうる。「50 文字以内」の単位も、全角か半角かで実質の長さが倍近く変わって曖昧になる。
- **50 文字を目安、72 文字を上限。** 実測で 79%（295 件）が既に 50 文字以下、中央値は 41 文字、73 文字以上は 2 件。現状追認になる。
- 命令形、末尾ピリオド禁止、emoji 禁止は `caveman-commit` から採った。

`repo 規約が scope を要求する場合は停止して報告する` を「その規約に従う」へ緩める案は 2026-08-27 に検討して保留した。skill は user-global なので monorepo では摩擦があり得るが、それは想定であって実測ではない。再検討の条件は「実際に monorepo で停止に当たった時」。

## body の規定

`Why:` / `What:` / `Impact:` はラベルごとに要否が違う。実測（body を持つ commit 66 件）では `Why:` 56 / `What:` 56 / `Impact:` 55 と、ほぼ機械的に 3 点セットで書かれていた。任意規定が惰性化していたので、ラベルごとに条件を付けている。

`Impact:` の中身は 3 種類に分かれる。

1. **変更がもたらす状態**。未完成状態の警告、復元手段、security 境界の変化。`What` では書けない。
2. **変わらないものの明示**。「deny rule は依然有効」「sandbox の境界は無傷」など。permissions と sandbox を頻繁に触るこの repo では、「この変更が何を弱めていないか」の記録に実用価値がある。`Why` でも `What` でも書けない。
3. **空振り**。`Docs only; no behavior change.` のような内容の無い行。

2 の用途が固有なのでラベルを残し、3 を禁じている。

代替案の枠は持たない。373 commit の body を検索しても代替案を記録した実例は無く、うち 1 件は「alternatives in the notes」と書いて notes へ寄せている。捨てた案の置き場は doc 3 層で ADR か notes と定義済みなので、commit body に枠を作ると二重管理になる。採らなかった案の理由が要る場合は `Why:` に含める。

AI 帰属の禁止は skill に書かない。`settings.json` の `includeCoAuthoredBy: false` が担う。設定で機械的に制御できるものを skill の文言へ二重化しない。

## footer と issue 参照

git trailer 形式（`Refs: #123` など）を規定するが、この repo では skill が書く trailer も `#123` 形式の issue 参照も 373 commit で 0 件。個人 dotfiles で issue を運用していないため。規定は残す（skill は user-global で、issue を使う repo でも読まれる）が、**例セクションには架空の trailer を置かない**。

git trailer の仕様はコロンあり・なしの両方を許すが、この repo はコロンありに統一する。`Closes #42` は GitHub の自動クローズ構文で、trailer 仕様に寄せる理由がない。

## 停止条件が手順のステップでない理由

停止条件は手順全体にかかる制約として書いている。後半 2 つ（分割の単位が判断できない / ファイル単位で分けられない）は範囲を決める段階まで分からず、手順 1 の `git status -sb` では判定できない。ステップにすると位置が固定され、後の段階で判明する条件と噛み合わない。

混在差分そのものは停止理由にしない。分割して複数 commit にすれば済む場面が多い。停止するのは分割の単位が判断できない時と、1 ファイル内で無関係な変更が混ざりファイル単位で分けられない時。後者は hunk 単位の staging に `git add -p` が要るが、この環境では interactive flag が動かない。

## 機密混入の確認方法

目視ではなく staged diff 全体に対する検索で確認する。diff が長いと目視は漏れる。**検索パターンは固定しない。** 言語や文脈に依存するため。

## `verification` が自由記述である理由

「自分が行った staged diff の確認」と「pre-commit hook の結果」の 2 種類があり、単語 1 つの enum に収まらない。

## pre-commit hook の実態

この repo の hook のうち**ファイルを書き換える**のは `fix end of files` と `markdownlint-cli2 --fix`。`trim trailing whitespace` は `.md` を exclude しており、skill / rules / docs のような主要ファイルには発火しない。

自動修正型が発火すると commit が失敗し、修正後の内容が unstaged で残る。差分を確認せずに再 stage すると、hook が何を変えたか分からないまま commit することになる。

## ファイル分担

| ファイル | 担当 |
| --- | --- |
| `SKILL.md` | 手順、停止条件、staging 規律、type 一覧、title 規定、body 要否、Gotchas、責務範囲、報告項目とその内容 |
| `references/failure-handling.md` | 停止時の対応、pre-commit hook 対応、失敗時 |
| `references/message-format.md` | body / footer / BREAKING CHANGE の書式、body 固有の禁止事項、Impact の要否条件 |

公式の best practices は、reference を「いつ読むか」を条件で示すことと、環境固有で常識に反する事実（Gotchas）を `SKILL.md` 側へ置くことを勧めている。後者を reference に置くと、読むべき状況が来たことを認識できない。

報告項目は `SKILL.md` にある。**報告は毎回書くもので、reference は必要な時だけ読むもの**という progressive disclosure の区分に従う。これで reference は異常系だけになり、`failure-handling` という名前が内容と一致する。

ファイル名に `commit-` prefix を付けないのは、パスが `skills/git-commit/references/` で skill 名が既に文脈を決めているため。`scribe` の reference（`adr-format.md` など）も prefix なし。

Gotchas に入れるのは、この環境で実際に踏んだか踏みかけたもの。**列挙は `SKILL.md` を正本とし、ここでは繰り返さない。** 実体を写すと片方だけ古くなる。

`diff <(...)` が sandbox で失敗する件は skill に置いていない。git 固有ではなく sandbox 全般の制約で、commit の手順にも該当する操作が無いため。本来は rules に属するが `dot_claude/rules/` が未再構築なので、記録をここに残す。**`diff <(...)` は sandbox で失敗するので、比較は一時ファイルへ出力してから行う。**

## push skill を持たない理由

Git 操作の skill は `git-commit` だけで、push 用の skill は持たない。**sandbox 内から SSH push が通らない**ため、手順書を用意しても実行できない。

`sandbox.network.allowedDomains` は HTTP(S) proxy 用の許可で SSH を運ばない。`git@github.com` への push は sandbox 内で `nc: authentication method negotiation failed` になる。`excludedCommands: ["git"]` を入れても解決しなかった（`53be6a5` → `9afdbb7` で revert）。`allowUnsandboxedCommands` を `true` へ戻す案は、失敗した全 command に sandbox 外再試行を開くので採らない。詳細は [claude-code-settings-design.md](./claude-code-settings-design.md)。

そのため **push は人が手元の terminal で実行し、agent は commit までを担う**。`SKILL.md` の「扱わないもの」にこの分担を書いているのは、skill が無いと agent が自己流で `git push` を打って失敗するため。

ADR は書かない。3 条件のうち「覆すコストが高い」を満たさない（skill の復元は archive branch から容易）。sandbox の方針が変われば push が通るようになり、その時は再検討する。

## Co-authored-by は default で付かない

`includeCoAuthoredBy: false` を外して apply しても、Bash 経由の `git commit` に trailer は付かなかった（2026-08-30、Claude Desktop app の local agent mode で probe commit を作って確認）。設定の有無で挙動が変わらないので、この設定は効いていない。

cloud session でも同じだった（2026-08-30、`claude --cloud` で作った session に空 commit を作らせて確認）。cloud session は `~/.claude/` を読まず（公式の比較表: `Uses your local config — No, repo only`）、この repo に `.claude/settings.json` も無いので、設定を一切読まない素の状態での観測になる。そこでも `Co-authored-by` も claude.ai の session link も付かなかった。**trailer が付かないのは default 挙動**で、設定で抑えているのではない。

公式は `includeCoAuthoredBy` の default を「N/A (deprecated)」とし、後継 `attribution` の default も明示していない。実測が上記のとおりなので、`attribution` を設定する理由がない。

## 未確認

- `attribution` を明示設定した時の挙動は試していない。実測したのは設定なしの default 挙動だけ。`attribution.pr` が指す PR description の attribution line も、この repo で PR を作っていないので未確認。
- description の trigger eval は未実施。公式の手順は 20 query × 3 run × 5 iteration の自動ループを想定しており、実行コストが大きい。現状は公式の記述指針（命令形、user intent への焦点、near-miss の明示、1024 文字以内）に照らした手動点検のみ。
