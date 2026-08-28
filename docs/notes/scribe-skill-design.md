# scribe skill の設計

- Date: 2026-08-28
- 出典: [ADR 0021](../adr/0021-allow-direct-adr-updates-from-user-agreement.md) / [ADR 0022](../adr/0022-preserve-adr-body-history.md) / `docs/adr/` 全 42 件の実測 / [Best practices for skill creators](https://agentskills.io/skill-creation/best-practices)

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

「実装が一段落した時と commit 前に doc 追従の要否を明示する」という規律は、その 2 つの瞬間に `scribe` が起動していないため、skill に書いても実効しない。commit 前に起動しているのは `git-commit` で、実装の区切りでは何も起動していない。全 session で読まれる `CLAUDE.md` か `rules/` が置き場になる。

skill 側に残したのは起動後の責務だけ。doc が不要と判断した場合もその旨と理由を返す、という部分は「出力」が持つ。

## Gotchas に入れたものの基準

この環境で実際に訂正が入った失敗だけを入れている。「推測で書かない」のような一般規定では防げず、具体的な形で書かないと再発するものに絞った。列挙は `dot_claude/skills/scribe/SKILL.md` を正本とし、ここでは繰り返さない。

## 未確認

- skill をまだ `chezmoi apply` していないため、`~/.claude/skills/scribe/` は旧版のまま。description による発火は未検証。
- 関係メタデータの並び順は、書く側の規定としては決めたが、逸脱を検出する仕組みは持たせていない。
- doc 要否の規律をどこに置くかは未決。現状は旧 `~/.claude/CLAUDE.md` と旧 `~/.claude/rules/docs-artifacts.md` が deploy されたまま効いている。両者の再構築時に置き場を決める必要がある。
