# harness の設計原則

- Date: 2026-09-03
- 出典: `dot_claude/` / [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions) / この環境での実測

この harness に何を置き、どう書くかの判断基準を残す。個別の設定や skill が今の形である理由は、それぞれの設計 note にある。

## surface へ昇格する基準

新しく得た調査結果や運用知見は、まず `docs/` に repo-level knowledge として残す。そこから `dot_claude/` へ上げるのは、展開後にも価値があり、workspace 横断で再利用するものだけ。配布する設定が増えると、全 project で常時 load とメンテの対象が増える。

## 削る基準

surface を圧縮する時の基準は「その記述が無いと判断が変わるか」。変わらないものは、正しくても消す。

**ただし、この harness の記述の多くは踏んだ失敗への対策として足されている。** 2026-09-03 の全面圧縮では、「理由の説明だから削れる」と分類した記述が実際には対策だった例が繰り返し出た。`skills/coding` の段 4「client 側の機能は検証に数えない」は、`<input type="date">` で日付検証を済ませたと判定する穴を塞ぐ。`skills/self-review` の各観点の `確認` は、それが無かった間は収束しなかったという実測に基づく。

そのため**削る前に、対応する設計 note を読む。** note が「なぜこの記述がここにあるか」を持つ項目は、文言を縮めても規範としては残す。この順序を守らずに 3 回見落とした（`AGENTS.md` の URL 表、`rules/` の統合判断、`CLAUDE.md` の常時 load 側に置く理由 6 項目）。

分量そのものは指標にならない。判断に効くなら長くてよい。

## source から消しても配布先には残る

`chezmoi apply` は source から消えたファイルを target から削除しない。managed の対象外になるだけで実体は残り、skill / rule / agent を廃止しても `~/.claude/` を手で消すまで古い定義が有効なままになる。2026-08-29 の apply では、配布をやめたものが 6 つ残った。`researcher` agent、`git-push` skill、rule 2 本、rename 前の reference 2 本。

廃止した時は `chezmoi managed` の一覧と target 側の実体を突き合わせ、差分を手で消す。

## apply の反映は設定の種類で違う

`chezmoi apply` で更新した設定のうち、sandbox は実行中の session に即反映される。`allowUnixSockets` を足して apply した直後、それまで拒否されていた agent socket へ接続できた。

`permissions.deny` も即反映される。`Bash(diskutil *)` を足して apply した直後、同じ session で `diskutil list` が実行前に拒否された（2026-09-02）。

session へ渡る skill 一覧も即反映される。`scribe` の description を書き換えて apply した直後、session を開き直さずに記述が新しいものへ変わった（2026-08-31）。新規 skill の追加も同じで、`self-review` を足すと apply の直後に一覧へ現れた（2026-09-01）。

`SKILL.md` の本文も、書き換えて apply した後に同じ session で invoke すると新しいものが届いた（2026-09-01、`self-review` の手順で確認）。

`outputStyle` の値も即反映される。`~/.claude/settings.json` を `caveman` → `Concise` → `caveman` と書き換えたところ、`/clear` も新しい session も挟まずに切り替わった（2026-09-02、同じ session 内で往復 2 回）。公式は「Changes take effect after `/clear` or a new session」と書くので、挙動が食い違う。ただし観測できたのは、harness が注入する reminder の文言と、それに沿って応答が変わったことまで。system prompt の style 本体が差し替わったかは切り分けていない。

`CLAUDE.md` は session 開始時に load されるため、apply しても動いている session は旧版のまま走り続ける。新版になるのは次に session を開いた時から。契約を直した効果を確かめるには session を開き直す。

同じ output style でも、style ファイルの内容を編集した場合は session 開始時のままになる。2026-08-31 に `Caveman.md`（当時は `caveman.md`）へ probe 文字列を足して apply し、同じ session で応答が変わらないことを確認した。公式の "reads once at session start" は `outputStyle` 設定について書かれていて内容の編集に触れていないが、実測では内容の側が公式の記述どおりに振る舞い、値の側が食い違う。

## skill description の書き方

`description` は skill の主な発火面で、ここに書いた語で呼ばれるかが決まる。

- どんな時に呼ぶかを先頭に置く。何をする skill かより先に読ませる。依頼語だけに絞らず、作業の流れで必要になる場面も書く。依頼語に絞ると、ユーザーがその語を出さない場面で発火しない。
- その skill が何を整理・実行・出力するかを示す。
- 近接 skill との差分、渡し先、対象外を明示する。
- 他の skill や agent を案内する時は「〜したい時は `skill-name` スキルを使う」のように surface 種別まで書く。skill 名の裸参照だけで意味を持たせない。
- 短さより境界語の明確さを優先する。

文数の上限は置かない。公式も "a few sentences to a short paragraph" を目安としている。

強めに書く方へ倒す。[Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions) は "Err on the side of being pushy. Explicitly list contexts where the skill applies, including cases where the user doesn't name the domain directly" と書く。`skill-creator` も、Claude が skill を undertrigger しがち（役に立つ場面で呼ばない）だとして、同じ対策を挙げている。

## 絞れる description の条件

**description を絞れるのは、その skill を自動で起動しないと決めた時。** 発火の層が 2 つあり、片方が確実に効くならもう片方は要らない、という話。

- 自動で起動しない（`skills/self-review`）: 工程表も description も明示指定へ寄せる。
- 工程表が条件付き（`skills/git-commit` の「ユーザー指示時に」）: 条件を外した流れでは工程表が起動しないので、description が拾う。

`git-commit` の工程表を無条件へ変えて description を絞る形は採れない。「commit はユーザー指示時」は安全規定で、外すと指示なしに commit してよくなる。この skill は 2 層が別の役割を持つ。工程表が **commit してよいか**（実行条件）、description が **skill を通すか**（発火面）。description を絞ると、commit する流れで staging 規律と機密情報の検索が飛ぶ。実行条件は指示を要求したままなので、安全にはならず規律だけ失う。

誤発火のコストも非対称。`self-review` は commit を視野に入れていない場面で起動すると観点 6 つを空振りさせる。`git-commit` は手順 1 が `git status -sb` を読むだけなので、実害がほぼない。

各 skill での適用は [self-review-skill-design.md](./self-review-skill-design.md) と [git-commit-skill-design.md](./git-commit-skill-design.md) にある。

## AGENTS.md の URL 表を notes へ移さない理由

root `AGENTS.md` は公式ページへの URL 表を持つ。これを `docs/notes/` へ移し、契約には参照義務と index リンクだけ残す案を検討して見送った。

- root `AGENTS.md` は `.chezmoiignore` で配布対象外なので、他 project の常時 load はもともと増えていない。効果はこの repo のセッション限定。
- 一方この表は実際に機能した。in-process tool が sandbox の対象外であること、auto mode の allow drop 対象リスト。どちらも表から正しいページへ辿って確認できた。記憶で答えていれば誤っていた。
- 移すと indirection が 1 段増え、index を読まずに済ませる経路ができる。数十行の節約と引き換えに参照義務の実効を賭けることになる。

再検討の条件は、表が肥大して契約本文が読めなくなった時。その場合も「表は残して重複した導入文だけ削る」を先に試す。
