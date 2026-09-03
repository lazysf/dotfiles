# scribe skill の設計

- Date: 2026-09-03
- 出典: [ADR 0021](../adr/0021-allow-direct-adr-updates-from-user-agreement.md) / [ADR 0022](../adr/0022-preserve-adr-body-history.md) / `docs/adr/` 全件の実測 / [Best practices for skill creators](https://agentskills.io/skill-creation/best-practices) / [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions) / [ISO 24495-1:2023](https://www.iso.org/standard/78907.html)

`scribe` skill が今の形になっている理由を残す。skill 本体を読んでも分からない前提と判断に絞る。

## ADR 本文を書き換えない理由

ADR 0022 が「ADR は最新仕様への上書き先ではなく、採用時点の判断と理由を残す履歴台帳」と定めている。skill の「既存 ADR の扱い」はこれを実行手順にしたもので、新しい判断ではない。

直接編集を状態・関係メタデータと、判断内容を変えない修正（typo、リンク切れ、Markdown 破損）に限る境界も ADR 0022 が定めた通り。関係メタデータを推測で書かず、ユーザー依頼か会話上の合意だけを根拠にするのは ADR 0021。

## 並び順を実態でなく意味で決めた理由

関係メタデータのキーの綴りと並び順は `dot_claude/skills/scribe/references/adr-format.md` を正本とする。ここに残すのは、並び順を既存 ADR の書き方の多数決で決めなかった理由。

多数決で決めると、なぜその順なのかを読み手へ説明できない。意味で決めておけば、キーが増えた時も同じ規則で位置が決まる。綴りの方は git trailer の仕様が決めるので選択の余地がない。

## notes に変更履歴を書かない理由

notes が「旧規定は〜だった」を書き始めると、skill を直すたびに notes も直す必要が出る。実際にこの repo の notes は 2 回古くなった。過去の状態は git 履歴にあるので、notes は現在の設計とその理由だけを持つ。

## notes に実体を写さない理由

skill の内容を notes へ列挙すると、skill を直した時に notes だけが古い規定を持つ。この repo で実例が出た。ADR の状態モデル、メタデータ形式、運用フロー 7 ステップを列挙した notes が、古くなったまま残っていた。旧綴りの `Amended by`、廃止済み surface（`grill` / `git-push` / Codex）への参照、`dot_codex/` 配下へのリンク切れを抱えていた。

列挙は skill を正本とし、notes には「なぜその形か」だけを置く。

## Accepted 化を commit と切り離す規定

`Accepted` を commit や push に連動させない。この規定の理由はどこにも記録が残っておらず、再検討もしていない。変えたくなった時、根拠は見つからないものとして扱う。

## reference を 3 つに分けた理由

README / ADR / notes は同時に書かない。1 ファイルにまとめると、ADR を書く時に README の書式まで読むことになる。SKILL.md 側で「対象の reference を 1 つだけ読む」と指定し、書式の実体を 3 ファイルへ分けている。

SKILL.md が持つのはどの層を選ぶかの判断で、書式は選択後にしか要らないので reference にある。

## doc 要否の判断を持たない理由

この規律が効くべき 2 つの瞬間（実装の区切りと commit 前）に `scribe` は起動していない。skill に書いても実効しないため、常時 load される `CLAUDE.md` が持つ。理由は [claude-md-design.md](./claude-md-design.md)。

skill 側に残したのは起動後の責務だけ。doc が不要と判断した場合もその旨と理由を返す、という部分は「出力」が持つ。

## 用語の一貫を doc 側だけに持たせた理由

「共通の進め方」に「1 つの概念に 1 つの語を使い、doc の途中で言い換えない」を置いている。同じ節の「既存の章構成、用語、粒度、文体に寄せ」が既存 doc への追従を担い、この 1 文が同一 doc の中での一貫を担う。

根拠は ISO 24495-1 の Understandable にある「同じ語を一貫して使う」。対になる「修飾を浅く保つ」は `Caveman.md` の規則にあり、その理由は [claude-code-output-style-design.md](./claude-code-output-style-design.md) にある。

契約へ置く案は採らない。[memory-surface-design.md](./memory-surface-design.md) の「doc / artifact の規定を契約に持たない」が、doc の書き方は skill を正本とすると定めている。

## Caveman の規則を一部だけ doc へ移した理由

`Caveman.md` の「境界」節は README / docs / ADR / notes を chat の外として、通常の文体で書くと定めている。この境界は動かさない。圧縮の副作用（常体、断片文、前置きの除去）が成果物へ漏れるのを止める歯止め。その役割は [claude-code-output-style-design.md](./claude-code-output-style-design.md) の「成果物への影響」に書いてある。

一方で、Caveman の規則には**読み手が誰でも効くもの**が混ざっている。一文一事実、修飾を浅く保つ、略語を作らない、過剰な保留表現を削る、短くならないなら通常形を使う——この 5 つを `scribe` の「文体」へ移した。根拠は用語の一貫と同じ ISO 24495-1。そちらの Understandable が「同じ語を一貫して使う」なら、こちらは「主語と述語を近づける、曖昧さを避ける」に当たる。

移さなかったのは、常体、断片文、前置きの除去、求められた範囲だけ答える、結論の根拠を 1 文で添える。いずれも chat の応答形式で、doc には対応する場面が無い。

2026-09-03 まで、修飾の深さは output style だけが持っていた。doc 側は誰も持っておらず、地の文が名詞化した造語（「判定語」「受け皿」「有限性の担保」）と 1 文に 2〜3 主張を詰める形になっていた。

## 分量の判定を長さに置かない理由

「必要な情報を必要な分だけ」を skill へ足した時、判定を「短く書く」ではなく「これは誰のどの判断に効くか」に置いた。

長さを判定にすると、載っている記述を機械的に削る方向へ倒れる。2026-09-03 の surface 圧縮でこれが起きた。「理由の説明だから削れる」と分類した記述の多くが、実際には踏んだ失敗への対策だった（[harness-design-principles.md](./harness-design-principles.md) の「削る基準」）。doc 側で同じことをすると、後から読む人が今の形の理由を追えなくなる。

そのため「答えられるなら長くてよく、短くすること自体は目標にしない」を同じ節に置いてある。これが無いと、規定が削る側だけに働く。

`lapidary` の「過剰さ」観点と重ならない。あちらは書いた後に変更セットを見る観点で、こちらは書く前の基準。同じ判定（判断に効くか）を書く時と見直す時の両方に置いている。

## Gotchas に入れたものの基準

この環境で実際に訂正が入った失敗だけを入れている。「推測で書かない」のような一般規定では防げず、具体的な形で書かないと再発するものに絞った。列挙は `dot_claude/skills/scribe/SKILL.md` を正本とし、ここでは繰り返さない。

## description を依頼語でなく作業の流れに寄せた理由

`description` は「作業の流れで doc を更新する場面が主で、ユーザーが doc という語を出さないことの方が多い」と書いている。依頼語（「notes に残して」など）は例示に留め、重心を置いていない。全文は `dot_claude/skills/scribe/SKILL.md` を正本とする。

「点検する時」と「ずれが見つかった時」を分けて書いているのは、点検の入口で発火させるため。ずれ検出後だけを条件にすると、「合っているか確認して」という点検依頼では発火せず、ずれが無いという結論も skill の外で出ることになる。

依頼語を重心にすると発火しない。2026-08-30 の session では notes を更新する commit を 4 つ作ったが、この skill は一度も呼ばれなかった。ユーザーの指示は「未確認事項を潰したい」「進めて」で、doc を書けという語が無かった。doc の更新は依頼としてではなく、調査や実測が決着した副産物として起きる。

手動で 1 回ずつ確認した（2026-08-31）。「ある notes が今の `dot_claude/` の実態と合っているか確認して。ずれていたら直して」という形の依頼で、ずれ検出後だけを条件にしていた時は発火せず、点検の入口を足した後は同じ形の依頼で発火した。点検依頼で発火した 2 例とも、`Skill` の呼び出しは調査の後で prompt の直後ではない。

発火の測定には、skill 自身の path を含む依頼を使わない。`docs/notes/scribe-skill-design.md` と `dot_claude/skills/scribe/SKILL.md` の点検を題材にすると、依頼文に skill 名と path が入る。作業として `SKILL.md` 全文を読むので、description と無関係に発火する。

description を依頼語に絞らない一般則は `harness-design-principles.md` の「skill description の書き方」にある。

## 未確認

- 発火の確認は各条件 1 回ずつの手動観測にとどまる。trigger rate は測っていない。公式が model behavior は nondeterministic と明記しているため、1 回の発火と未発火では改善を断定できない。trigger eval（20 query × 3 run × 5 iteration）は未実施。失敗事例が 1 件では、eval query を実測から作れない。
- 関係メタデータの並び順は、書く側の規定としては決めたが、逸脱を検出する仕組みは持たせていない。
