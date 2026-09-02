# harness の設計原則

- Date: 2026-09-02
- 出典: `dot_claude/` / [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions) / この環境での実測

この harness に何を置き、どう書くかの判断基準を残す。個別の設定や skill が今の形である理由は、それぞれの設計 note にある。

## surface へ昇格する基準

新しく得た調査結果や運用知見は、まず `docs/` に repo-level knowledge として残す。そこから `dot_claude/` へ上げるのは、展開後にも価値があり、workspace 横断で再利用するものだけ。配布する設定が増えると、全 project で常時 load とメンテの対象が増える。

## source から消しても配布先には残る

`chezmoi apply` は source から消えたファイルを target から削除しない。managed の対象外になるだけで実体は残り、skill / rule / agent を廃止しても `~/.claude/` を手で消すまで古い定義が有効なままになる。2026-08-29 の apply では、配布をやめた `researcher` agent と `git-push` skill、rule 2 本、rename 前の reference 2 本が残った。

廃止した時は `chezmoi managed` の一覧と target 側の実体を突き合わせ、差分を手で消す。

## apply の反映は設定の種類で違う

`chezmoi apply` で更新した設定のうち、sandbox は実行中の session に即反映される。`allowUnixSockets` を足して apply した直後、それまで拒否されていた agent socket へ接続できた。

`permissions.deny` も即反映される。`Bash(diskutil *)` を足して apply した直後、同じ session で `diskutil list` が実行前に拒否された（2026-09-02）。

session へ渡る skill 一覧も即反映される。`scribe` の description を書き換えて apply した直後、session を開き直さずに記述が新しいものへ変わった（2026-08-31）。新規 skill の追加も同じで、`self-review` を足すと apply の直後に一覧へ現れた（2026-09-01）。

`SKILL.md` の本文も、書き換えて apply した後に同じ session で invoke すると新しいものが届いた（2026-09-01、`self-review` の手順で確認）。

`outputStyle` の値も即反映される。`~/.claude/settings.json` を `caveman` → `Concise` → `caveman` と書き換えたところ、`/clear` も新しい session も挟まずに切り替わった（2026-09-02、同じ session 内で往復 2 回）。公式は「Changes take effect after `/clear` or a new session」と書くので、挙動が食い違う。ただし観測できたのは harness が注入する reminder の文言と、それに沿って応答が変わったことまでで、system prompt の style 本体が差し替わったかは切り分けていない。

`CLAUDE.md` と `rules/` は session 開始時に load されるため、apply しても動いている session は旧版のまま走り続ける。新版になるのは次に session を開いた時から。契約や rule を直した効果を確かめるには session を開き直す。

同じ output style でも、style ファイルの内容を編集した場合は session 開始時のままになる。2026-08-31 に `caveman.md` へ probe 文字列を足して apply し、同じ session で応答が変わらないことを確認した。公式の "reads once at session start" は `outputStyle` 設定について書かれていて内容の編集に触れていないが、実測では内容の側が公式の記述どおりに振る舞い、値の側が食い違う。

## skill description の書き方

`description` は skill の主な発火面で、ここに書いた語で呼ばれるかが決まる。

- どんな時に呼ぶかを先頭に置く。何をする skill かより先に読ませる。依頼語だけに絞らず、作業の流れで必要になる場面も書く。依頼語に絞ると、ユーザーがその語を出さない場面で発火しない。
- その skill が何を整理・実行・出力するかを示す。
- 近接 skill との差分、渡し先、対象外を明示する。
- 他の skill や agent を案内する時は「〜したい時は `skill-name` スキルを使う」のように surface 種別まで書く。skill 名の裸参照だけで意味を持たせない。
- 短さより境界語の明確さを優先する。

文数の上限は置かない。公式も "a few sentences to a short paragraph" を目安としている。

強めに書く方へ倒す。[Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions) は "Err on the side of being pushy. Explicitly list contexts where the skill applies, including cases where the user doesn't name the domain directly" と書く。`skill-creator` も、Claude が skill を undertrigger しがち（役に立つ場面で呼ばない）だとして、同じ対策を挙げている。

## AGENTS.md の URL 表を notes へ移さない理由

root `AGENTS.md` は公式ページへの URL 表を持つ。これを `docs/notes/` へ移し、契約には参照義務と index リンクだけ残す案を検討して見送った。

- root `AGENTS.md` は `.chezmoiignore` で配布対象外なので、他 project の常時 load はもともと増えていない。効果はこの repo のセッション限定。
- 一方この表は実際に機能した。in-process tool が sandbox の対象外であること、auto mode の allow drop 対象リスト — どちらも表から正しいページへ辿って確認できた。記憶で答えていれば誤っていた。
- 移すと indirection が 1 段増え、index を読まずに済ませる経路ができる。数十行の節約と引き換えに参照義務の実効を賭けることになる。

再検討の条件は、表が肥大して契約本文が読めなくなった時。その場合も「表は残して重複した導入文だけ削る」を先に試す。
