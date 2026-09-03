# CLAUDE.md の設計

- Date: 2026-09-03
- 出典: [How Claude remembers your project](https://code.claude.com/docs/en/memory) / [Hooks reference](https://code.claude.com/docs/en/hooks) / `dot_claude/CLAUDE.md` / この環境での実測

`dot_claude/CLAUDE.md` が今の形になっている理由を残す。本体を読んでも分からない前提と判断に絞る。

## ここに置くものの基準

CLAUDE.md は全セッションの先頭で読まれる。入れるのは、どの依頼でも要る契約と判断基準、工程の発火条件。起動後の手順は `skills/` にあり、ここでは重複させない。

公式目安は 1 ファイル 200 行。常時 load されるのはこの 1 枚だけで 83 行（2026-09-03）。目安に収まっている。`rules/` を持たず 1 枚へ集約している理由は [memory-surface-design.md](./memory-surface-design.md)。

## push を工程表に書いている理由

push は sandbox の proxy が SSH を運ばないため agent が実行しても失敗する。この事実は `skills/git-commit` にも書いてあるが、**その skill は commit 依頼でしか発火しない**。「push して」とだけ言われた時、skill 側の記述はどこからも読まれず、agent は失敗する経路へ進む。

常時読まれる側に 1 文だけ置く必要がある。

## doc 要否の規律をここが持つ理由

「実装が一段落した時と commit 前に doc 追従の要否を明示する」という規律は、その 2 つの瞬間に `scribe` が起動していない。commit 前に起動しているのは `git-commit` で、実装の区切りでは何も起動していない。skill 側に書いても実効しないため、常時 load されるここが置き場になる。

要否を判断した後の書き方（3 条件、書式、既存 ADR の扱い）は `skills/scribe` が正本で、ここには持ち込まない。

## 停止線を判定可能な形にしてある理由

「公開インターフェースに影響する」と書くと、文字通り読めば新規関数 1 本でも停止する。「変更・削除する」に絞った。そのうえで「後から変えると外部を壊すもの（公開 API、永続化 schema、CLI 引数、設定キー）は新規でも含む」を添え、判定を 1 問へ集約してある。

「大きな設計変更」も主観語なので使わない。module 境界の移動、data flow の作り直し、framework / library の入れ替えという例示で閾値を示す。

## 「実測で確認するまで有効な層と数えない」を共通契約に置く理由

この環境で 3 つの失敗を踏んだ。allowlist を防御層として数えていた。`Agent` allow が既定 mode で死んでいた。path 条件付き rule の発火を推測で断じた。すべてこの 1 行で防げた。公式 docs の記述を確認の代わりにしたことが共通の原因だったため、契約側で一度だけ言う。

同じ項目に「外す時も、その設定を使っているものが無いことを確認する」を持たせているのは、入れる時と外す時で確認の向きが逆になるため。`sandbox.network.allowUnixSockets` を「push に使えないので用途が無い」と判断して落とした。結果、commit 署名を壊した（詳細は [claude-code-settings-design.md](./claude-code-settings-design.md)）。入れる側だけを規範にすると、削除の判断が実測なしで通る。

## review を doc の後に置く理由

工程表の review は commit 前の自己確認を含む。もともと `quality-reviewer` などの起動条件しか書いていなかったが、実際には commit 前に毎回自分で変更を確認していて、その運用が機能していた。契約に無い行為が実務を支えている状態だったので、契約側へ移した。

観点はここに書かない。手順と観点は `skills/self-review` が持ち、工程表は「いつ通すか」だけを示す。CLAUDE.md は全 session で常時 load される。review の時にしか要らない詳細を置くと、review しない session でも context を占める。

図を `doc → review` の順にしてあるのは、実装と doc をまとめて review するため。失敗は両者を跨ぐ形で出る。設定を消したのに notes が古い参照を持ったまま。skill の `description` を変えたのに notes の記述が対応していない。分けて review すると、実装だけを見る時点では doc がまだ無く、doc だけを見る時点では実装の差分を見ない。追従漏れを見つける場が消える。`.claude/rules/harness-surface-consistency.md` も両方を並べて見ることを前提にしている。

commit は実装と doc で分けたままにする。review は変更セット全体を見る行為、commit は記録の粒度で、層が違う。

## スコープを 1 つに保つ規律をここに置く理由

作業の開始時点で決まる話なので、skill では拾えない。`skills/` は起動後の手順で、「今どのスコープにいるか」を持たない。

この環境では 2 つの形で逸脱した。1 つは、ある領域の作業中に別の領域へ着手して止められたこと。もう 1 つは、観点の点検を依頼されて答えを出した後、そのまま文言の推敲へ流れ、何度も推敲した末に案そのものが不要だと分かったこと。前者は範囲の逸脱、後者は目的の逸脱で、どちらも各ステップ単体では要求どおりに見える。全体を通してスコープが動いていることは、作業を俯瞰する側でしか気づけない。

## スキル名の列挙をここに置く理由

「使用したスキル名を列挙する」は応答の書式だが、`output-styles/` には置かない。style を切り替えると読まれなくなるため。どの output style でも効かせたいので、常時 load される側が置き場になる。

hook で機械化していない。hook が出せる `systemMessage` は harness がユーザーへ見せるメッセージで、assistant の返答本文ではない。求めているのは返答そのものに含まれることなので、hook では形が違う。

そのため遵守は LLM 依存になる。公式は CLAUDE.md を enforced configuration でなく context と位置付けている。矛盾する指示があると任意に選ぶ、としている。`output-styles/Caveman.md` の「前置き、tool 実行の予告、進捗、実況を書かない」とは、列挙を「最終返答の末尾」に限定することで実況と区別してあるが、競合と読まれる余地は残る。2026-08-31 に、会話文脈のない新しい session で `skills/git-commit` を発火させたところ、`caveman` が有効なまま末尾へ列挙が出た。1 回の観測なので、競合しない担保にはならない。

## 閾値の見直し方を工程表に書かない理由

掘り下げの 4 条件と ADR の 3 条件は、どちらも AND で結んだ発火閾値を持つ。閾値が運用に合わなくなった時にどうするかは、工程表に書かない。

「運用して過少／過剰なら見直す」は session 中に完結しない。見直すのは人が `CLAUDE.md` を触る時で、その時の置き場がこの notes になる。閾値が合っていないと agent が気づいた場合の経路は、スコープを 1 つに保つ規律が既に持っている。工程表へ置くと、全 session で読まれるのにどの依頼でも使われない行が残る。閾値を固定と扱っているわけではなく、置き場の話。

## tool の使い分けを契約に書かない理由

auto mode は「read files with cat, head, or sed -n ... rather than using the dedicated Read, Edit, or Write tools」という指示を session へ入れる。これに従うと `paths` 付き rule が一度も発火しない（[memory-surface-design.md](./memory-surface-design.md)）。

対抗して「読み書き編集は Read / Edit / Write tool で行う」を共通契約へ置く案を試し、外した。契約は harness の指示に勝つ（2026-09-02、apply 後の別 session で確認）。外したのは効かないからではなく、auto mode では Bash の方が効率と正確さで優るため（2026-09-02 のユーザー判断。二次情報に基づくもので、一次情報での裏付けは取っていない）。

`paths` 側を諦める形になった。置き場の基準は [memory-surface-design.md](./memory-surface-design.md) にある。
