# self-review skill の設計

- Date: 2026-09-01
- 出典: [Extend Claude Code](https://code.claude.com/docs/en/features-overview) / [Best practices for skill creators](https://agentskills.io/skill-creation/best-practices) / この repo の review 運用の実測

`self-review` skill が今の形になっている理由を残す。skill 本体を読んでも分からない前提と判断に絞る。

## skill に置く理由

commit 前の自己確認は、同じ観点の並びを毎回 chat へ書き下す形で運用していた。公式は「同じ playbook や多段手順を 3 回目に貼ったら skill にする」を目安に挙げている。CLAUDE.md 側の用途は「Project conventions, "always do X" rules」と説明され、例も `Use pnpm, not npm` の粒度。

CLAUDE.md へ観点を書かない理由は容量ではなく適用範囲にある。CLAUDE.md は全 session で常時 load されるため、review の巡ごとにしか要らない詳細を置くと、review しない session でも context を占める。工程表は「いつ通すか」だけを持ち、手順と観点は skill 側にある。

ADR は書かない。3 条件のうち「覆すコストが高い」を満たさない（skill の追加は戻しやすく、公開 IF も永続化も持たない）。review の分担そのものを変える時は再検討する。

## `git-commit` に組み込まない理由

commit しない review がある。作業の区切り、方針の確認、書いたものが仕上がったかの点検は、commit と独立して起きる。組み込むと review だけを呼べない。

`git-commit` の責務も膨らむ。あちらは停止条件、staging 規律、staged diff の検証を持つ。review の観点と混ざると、commit したいだけの時に観点表まで読むことになる。

## agent との使い分け

`self-review` が入口で、`quality-reviewer` / `security-reviewer` は skill の中の選択肢として提案する。既定は自己確認で、独立 context は条件に当たった時だけ。

分ける根拠は、両者が拾う指摘の性質が違うこと。自己確認は自分が書いた文を見るのは得意で、指示語の空振り、掛かり先のずれ、誇張、表現のゆれ、参照の空振りを拾う。一方で**自分が調べた範囲の外は見えない**。実際に agent 側が拾ったのは、`git log` の committer date が示す履歴書き換え、schema の実 default、観測を超えた一般化、スコープ外の混入で、いずれも一次情報を取り直さないと出ない。

条件を skill に持たせたのは、ユーザーが毎回どちらかを指定しなくて済むようにするため。ユーザーが「じっくり」「独立で」と言った時と agent 名を出した時は、提案を挟まず起動する。

`CLAUDE.md` の standing authorization はこの分担と二重にならない。あちらが持つのは起動の許可で、skill が持つのはいつ起動するかの条件。

## 観点を 5 つに絞った理由

公式は「網羅しすぎた skill は、関係ない指示に引きずられて不要な経路を辿る」ため、簡潔で段階的な手順を勧めている。観点を増やすほど 1 巡が重くなり、巡を重ねられなくなる。

5 つ（スコープ / 事実 / 整合性 / 過剰さ / doc）は、この repo で実際に指摘として出たものから採った。各 3 項目に留め、細かい判断まで指定していない。公式も code review を「観点を挙げて手順は縛らない」側の例に置いている。

## 「1 巡で終わらせない」を書いた理由

直すと別の問題が生まれる。数値を消せば指示語が指す先を失い、記述を強めれば根拠を超え、短くすれば参照が空振りする。いずれも最初の巡には存在せず、直した後に現れる。

繰り返しの指示だけでは従う理由が伝わらないので、なぜ 2 巡目に新しい問題が出るかを skill 本体に書いている。
