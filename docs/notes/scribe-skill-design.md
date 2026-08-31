# scribe skill の設計

- Date: 2026-08-31
- 出典: [ADR 0021](../adr/0021-allow-direct-adr-updates-from-user-agreement.md) / [ADR 0022](../adr/0022-preserve-adr-body-history.md) / `docs/adr/` 全 42 件の実測 / [Best practices for skill creators](https://agentskills.io/skill-creation/best-practices) / [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)

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

skill の内容を notes へ列挙すると、skill を直した時に notes だけが古い規定を持つ。この repo では、ADR の状態モデル、メタデータ形式、運用フロー 7 ステップを列挙した notes が、旧綴りの `Amended by`、廃止済み surface（`grill` / `git-push` / Codex）への参照、`dot_codex/` 配下へのリンク切れを抱えたまま残っていた。

列挙は skill を正本とし、notes には「なぜその形か」だけを置く。

## Accepted 化を commit と切り離す規定

`Accepted` を commit や push に連動させない。この規定の理由はどこにも記録が残っておらず、再検討もしていない。変えたくなった時、根拠は見つからないものとして扱う。

## reference を 3 つに分けた理由

README / ADR / notes は同時に書かない。1 ファイルにまとめると、ADR を書く時に README の書式まで読むことになる。SKILL.md 側で「対象の reference を 1 つだけ読む」と指定し、書式の実体を 3 ファイルへ分けている。

SKILL.md が持つのはどの層を選ぶかの判断で、書式は選択後にしか要らないので reference にある。

## doc 要否の判断を持たない理由

この規律が効くべき 2 つの瞬間（実装の区切りと commit 前）に `scribe` は起動していない。skill に書いても実効しないため、常時 load される `CLAUDE.md` が持つ。理由は [claude-md-design.md](./claude-md-design.md)。

skill 側に残したのは起動後の責務だけ。doc が不要と判断した場合もその旨と理由を返す、という部分は「出力」が持つ。

## Gotchas に入れたものの基準

この環境で実際に訂正が入った失敗だけを入れている。「推測で書かない」のような一般規定では防げず、具体的な形で書かないと再発するものに絞った。列挙は `dot_claude/skills/scribe/SKILL.md` を正本とし、ここでは繰り返さない。

## description を依頼語でなく作業の流れに寄せた理由

`description` は「作業の流れで doc を更新する場面が主で、ユーザーが doc という語を出さないことの方が多い」と書いている。依頼語（「notes に残して」など）は例示に留め、重心を置いていない。全文は `dot_claude/skills/scribe/SKILL.md` を正本とする。

「点検する時」と「ずれが見つかった時」を分けて書いているのは、点検の入口で発火させるため。ずれ検出後だけを条件にすると、「合っているか確認して」という点検依頼では発火せず、ずれが無いという結論も skill の外で出ることになる。

依頼語を重心にすると発火しない。2026-08-30 の session では notes を更新する commit を 4 つ作ったが、この skill は一度も呼ばれなかった。ユーザーの指示は「未確認事項を潰したい」「進めて」で、doc を書けという語が無かった。doc の更新は依頼としてではなく、調査や実測が決着した副産物として起きる。

手動で 1 回ずつ確認した（2026-08-31）。「`docs/notes/rules-design.md` が今の `dot_claude/rules/` の実態と合っているか確認して。ずれていたら直して」という形の依頼で、ずれ検出後だけを条件にしていた時は発火せず、点検の入口を足した後は同じ形の依頼で発火した。点検依頼で発火した 2 例とも、`Skill` の呼び出しは調査の後で prompt の直後ではない。

発火の測定には、skill 自身の path を含む依頼を使わない。`docs/notes/scribe-skill-design.md` と `dot_claude/skills/scribe/SKILL.md` の点検を題材にすると、依頼文に skill 名と path が入り、作業として `SKILL.md` 全文を読むため、description と無関係に発火する。

description を依頼語に絞らない一般則は `harness-design-principles.md` の「skill description の書き方」にある。

## 未確認

- 発火の確認は各条件 1 回ずつの手動観測にとどまる。trigger rate は測っていない。公式が model behavior は nondeterministic と明記しているため、1 回の発火と未発火では改善を断定できない。trigger eval（20 query × 3 run × 5 iteration）は、失敗事例が 1 件では eval query を実測から作れないため未実施。
- 関係メタデータの並び順は、書く側の規定としては決めたが、逸脱を検出する仕組みは持たせていない。
