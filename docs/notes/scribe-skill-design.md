# scribe skill の設計

- Date: 2026-11-09
- 出典: [How Claude remembers your project](https://code.claude.com/docs/en/memory) / [ADR 0021](../adr/0021-allow-direct-adr-updates-from-user-agreement.md) / [ADR 0022](../adr/0022-preserve-adr-body-history.md) / `docs/adr/` 全件の実測 / [Best practices for skill creators](https://agentskills.io/skill-creation/best-practices) / [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions) / [ISO 24495-1:2023](https://www.iso.org/standard/78907.html)

`scribe` skill が今の形になっている理由を残す。skill 本体を読んでも分からない前提と判断に絞る。

## ADR 本文を書き換えない理由

ADR 0022 が「ADR は最新仕様への上書き先ではなく、採用時点の判断と理由を残す履歴台帳」と定めている。skill の「既存 ADR の扱い」はこれを実行手順にしたもので、新しい判断ではない。

直接編集を状態・関係メタデータと、判断内容を変えない修正（typo、リンク切れ、Markdown 破損）に限る境界も ADR 0022 が定めた通り。関係メタデータを推測で書かず、ユーザー依頼か会話上の合意だけを根拠にするのは ADR 0021。

## 並び順を実態でなく意味で決めた理由

関係メタデータのキーの綴りと並び順は `dot_claude/skills/scribe/references/adr-format.md` を正本とする。ここに残すのは、並び順を既存 ADR の書き方の多数決で決めなかった理由。

多数決で決めると、なぜその順なのかを読み手へ説明できない。意味で決めておけば、キーが増えた時も同じ規則で位置が決まる。綴りの方は git trailer の仕様が決めるので選択の余地がない。

## notes に変更履歴を書かない理由

notes が「旧規定は〜だった」を書き始めると、skill を直すたびに notes も直す必要が出る。実際にこの repo の notes は 2 回古くなった。過去の状態は git 履歴にあり、なぜ変えたかは commit の `Why:` が持つ（[git-commit-skill-design.md](./git-commit-skill-design.md) の「body の規定」）。notes は今の設計とその理由だけを持つ。

## notes に実体を写さない理由

skill の内容を notes へ列挙すると、skill を直した時に notes だけが古い規定を持つ。この repo で実例が出た。ADR の状態モデル、メタデータ形式、運用フロー 7 ステップを列挙した notes が、古くなったまま残っていた。旧綴りの `Amended by`、廃止済み surface（`grill` / `git-push` / Codex）への参照、`dot_codex/` 配下へのリンク切れを抱えていた。

列挙は skill を正本とし、notes には「なぜその形か」だけを置く。

## Accepted 化を commit と切り離す規定

`Accepted` を commit や push に連動させない。この規定の理由はどこにも記録が残っておらず、再検討もしていない。変えたくなった時、根拠は見つからないものとして扱う。

## reference を 3 つに分けた理由

README / ADR / notes は同時に書かない。1 ファイルにまとめると、ADR を書く時に README の書式まで読むことになる。SKILL.md 側で「対象の reference を 1 つだけ読む」と指定し、書式の実体を 3 ファイルへ分けている。

SKILL.md が持つのはどの層を選ぶかの判断で、書式は選択後にしか要らないので reference にある。

## doc をいつ直すかを description に持たせる理由

doc を直すべき場面は、実装の区切りで訪れる。そこでは `scribe` を含めて何も起動していない。そのため、いつ直すかは skill の本文ではなく description に置いている。description は常時 context にあるので、「使い方・設定・公開挙動を変えた時」という場面で発火の手がかりになる。commit の前には `lapidary` も、doc の追従が要りそうな変更なら scribe を通すよう一言添える。

いつ直すかの全部は決めていない。仕様（README / docs）をいつ更新するかと、事前の doc を作るかは、repo の運用に従う。仕様を先に書いて開発する repo もあり、全層へ一律に時期を決めると、その repo の CLAUDE.md と矛盾する。CLAUDE.md は上書きでなく連結で読まれ、矛盾があると Claude はどちらかを任意に選ぶ（[How Claude remembers your project](https://code.claude.com/docs/en/memory)）。skill の冒頭に「repo が独自の doc 規約を持っていれば、そちらに従う」を置いているのも同じ理由。

doc が不要と判断した時もその旨と理由を返す、という部分は skill の末尾が持つ。

## 用語の一貫を doc 側に持たせた理由

「進め方」に「1 つの概念に 1 つの語を使い、途中で言い換えない」を置いている。同じ項目の「既存の章構成、用語、粒度、文体に寄せる」が既存 doc への追従を担い、この 1 文が同一 doc の中での一貫を担う。

根拠は ISO 24495-1 の Understandable にある「同じ語を一貫して使う」。

契約へ置く案は採らない。[memory-surface-design.md](./memory-surface-design.md) の「doc / artifact の規定を契約に持たない」が、doc の書き方は skill を正本とすると定めている。

## 文体の規則を doc の側に持つ理由

「文体と分量」の規則（1 文に 1 つの主張、修飾を浅く保つ、造語の名詞化を避ける、略語を作らない、断定できることは断定する）は、読み手が誰でも効く。根拠は ISO 24495-1 の「主語と述語を近づける、曖昧さを避ける」。ISO 24495-1 は有料規格で、本文は未取得。

output style は組み込みの Concise で、chat の応答の圧縮だけを扱う（[claude-code-settings-design.md](./claude-code-settings-design.md) の「output style に組み込みの Concise を使う理由」）。doc の文体の規定は、この skill だけが持つ。

doc 側に修飾の規定が無いと、地の文が名詞化した造語（「判定語」「受け皿」「有限性の担保」）と、1 文に 2〜3 主張を詰める形になる。修飾の深さを output style だけが持っていた 2026-09-03 までの notes が、そうなっていた。

## 分量の判定を長さに置かない理由

「必要な情報を必要な分だけ」を skill へ足した時、判定を「短く書く」ではなく「これは誰のどの判断に効くか」に置いた。

長さを判定にすると、載っている記述を機械的に削る方向へ倒れる。2026-09-03 の surface 圧縮でこれが起きた。「理由の説明だから削れる」と分類した記述の多くが、実際には踏んだ失敗への対策だった（[harness-design-principles.md](./harness-design-principles.md) の「削る基準」）。doc 側で同じことをすると、後から読む人が今の形の理由を追えなくなる。

そのため「答えられるなら長くてよい」を同じ項目に置いてある。これが無いと、規定が削る側だけに働く。

`lapidary` の「過剰さ」観点と重ならない。あちらは書いた後に変更セットを見る観点で、こちらは書く前の基準。同じ判定（判断に効くか）を書く時と見直す時の両方に置いている。

## Gotchas に入れたものの基準

この環境で実際に訂正が入った失敗だけを入れている。「推測で書かない」のような一般規定では防げず、具体的な形で書かないと再発するものに絞った。列挙は `dot_claude/skills/scribe/SKILL.md` を正本とし、ここでは繰り返さない。

## description を依頼語でなく作業の流れに寄せた理由

`description` は「作業の流れで doc を直す場面が主で、ユーザーが doc という語を出さないことの方が多い」と書いている。依頼語（「notes に残して」など）は例示に留め、重心を置いていない。全文は `dot_claude/skills/scribe/SKILL.md` を正本とする。

「既存の doc が実態と合っているかを点検する時」を書いているのは、点検の入口で発火させるため。ずれが見つかった後だけを条件にすると、「合っているか確認して」という点検依頼では発火せず、ずれが無いという結論も skill の外で出ることになる。

依頼語を重心にすると発火しない。2026-08-30 の session では notes を更新する commit を 4 つ作ったが、この skill は一度も呼ばれなかった。ユーザーの指示は「未確認事項を潰したい」「進めて」で、doc を書けという語が無かった。doc の更新は依頼としてではなく、調査や実測が決着した副産物として起きる。

手動で 1 回ずつ確認した（2026-08-31）。「ある notes が今の `dot_claude/` の実態と合っているか確認して。ずれていたら直して」という形の依頼で、ずれ検出後だけを条件にしていた時は発火せず、点検の入口を足した後は同じ形の依頼で発火した。点検依頼で発火した 2 例とも、`Skill` の呼び出しは調査の後で prompt の直後ではない。

発火の測定には、skill 自身の path を含む依頼を使わない。`docs/notes/scribe-skill-design.md` と `dot_claude/skills/scribe/SKILL.md` の点検を題材にすると、依頼文に skill 名と path が入る。作業として `SKILL.md` 全文を読むので、description と無関係に発火する。

description を依頼語に絞らない一般則は `harness-design-principles.md` の「skill description の書き方」にある。

## 未確認

- 発火の確認は各条件 1 回ずつの手動観測にとどまる。trigger rate は測っていない。公式が model behavior は nondeterministic と明記しているため、1 回の発火と未発火では改善を断定できない。trigger eval（20 query × 3 run × 5 iteration）は未実施。失敗事例が 1 件では、eval query を実測から作れない。
- 関係メタデータの並び順は、書く側の規定としては決めたが、逸脱を検出する仕組みは持たせていない。
