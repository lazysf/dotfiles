# reviewer agent の設計

- Date: 2026-08-29
- 出典: [Create custom subagents](https://code.claude.com/docs/en/sub-agents) / `~/.claude/projects/` の全 42 session transcript / `dot_claude/agents/`

reviewer agent 2 つが今の形になっている理由と、他の agent を置いていない理由を残す。agent 定義を読んでも分からない前提と判断に絞る。

## 起動実績

| subagent | 起動された session |
| --- | --- |
| `quality-reviewer` | 10（24%） |
| `security-reviewer` | 10（24%） |
| `researcher`（自前） | 0 |
| `Explore` / `general-purpose` / `Plan`（組み込み） | 0 |

## researcher を持たない理由

調査は読んだ結果から次に読む対象を決める往復で進むため、切り出すと往復ができない。分離や並列が要る場面は 42 session で一度も起きていない。

将来その場面が来ても、組み込みの `Explore` と `general-purpose` がそのまま使える。自前定義の利点は役割を絞った prompt だが、それを評価する需要が観測されていない。

## reviewer に Bash を持たせる理由

reviewer 内部（sidechain）の tool 使用は Bash 196 / Read 50 / Grep 0 / Glob 0 で、Bash が主経路になっている。内訳は 2 種類に分かれる。

- `grep` / `sed` / `ls` / `cat`: 検索と読み取り。`Grep` / `Read` でも代替できる。
- **`git diff` / `git status` / `git show` / `git log`（計 48 回）**: 変更セットの取得。Bash なしでは代替できない。

呼び出し元が明示 diff を渡し忘れた時に reviewer が自力で取得する fallback が、実際に機能している。Bash を外すと、渡し忘れのたびに reviewer が停止して呼び出し元が再起動することになる。

## 2 つに分けたままにする理由

session 単位では常に両方が起動され、単独起動は 0 件だった。ただし同一メッセージからの並列起動が 5 回あり、統合すると並列性を失う。

観点も構造的に違う。security は auth、secret、injection、path traversal と見る場所が別で、1 つの agent に両方を負わせると片方で早く「重大な指摘なし」に到達する。

## built-in の review skill と併存させる理由

`/code-review` と `/security-review` が built-in で使える。`--fix`、PR への inline comment、cloud の multi-agent review を持ち、機能はこちらが多い。

ただし対象が違う。built-in の instructions は correctness bug（反転した条件、off-by-one、null 参照、await 漏れ、外れた guard、壊れた caller、race）を探すよう指定し、"Prefer real failure modes over style" と style 系の指摘を明示的に下げる。

自前 reviewer が見る scope 逸脱、実体の二重管理、責務分離、回帰リスクはこの範囲に入らない。実際に agent 定義と `CLAUDE.md` の diff を `/code-review` へ通したところ findings 0 件だった。

用途が重ならないので、契約の review 工程では両方を案内し、対象で選ぶ。

## standing authorization を契約側に 1 箇所だけ置く理由

reviewer をユーザー確認なしで起動してよいという規定は `CLAUDE.md` にだけ置く。同じ規定を root `AGENTS.md` にも置くと、AGENTS.md 側は「運用契約で認められている」と CLAUDE.md を参照する形になり、二重になる。

この許可は全 project で効くべきもので、repo-local な案内で繰り返す必要がない。二重に持つと片方だけ直した時にもう片方が古くなる。

## model と effort を固定する理由

`model` を書かないと親の設定を継ぐ。sonnet で作業している最中に review を頼めば sonnet が review することになる。effort も同じで、session が `low` なら reviewer も `low` になる。

reviewer は 1 度呼ばれて指摘を返すだけで、main のように往復して詰められない。session 側の設定に関係なく最高品質で走らせるため、`model` は full ID、`effort` は `xhigh` で固定する。`model` を alias でなく full ID にするのは、どの世代で review したかを確定させるため。

## permissionMode を書かない理由

`settings.json` が `permissions.defaultMode: "auto"` である限り、subagent は auto mode を継承し、**frontmatter の `permissionMode` は無視される**（公式仕様）。効かない設定を書くと「read-only が permissionMode で守られている」と誤読される。実際に守っているのは `tools` の allowlist。

## 未確認

- auto mode の classifier が subagent の write 系 Bash をどう扱うかは未検証。`tools` の allowlist とは別の層として数えていない。
