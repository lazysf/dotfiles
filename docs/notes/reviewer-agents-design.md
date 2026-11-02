# reviewer agent の設計

- Date: 2026-11-02
- 出典: [Create custom subagents](https://code.claude.com/docs/en/sub-agents) / [Model configuration](https://code.claude.com/docs/en/model-config) の「Choose an effort level」（2026-11-02 確認） / `~/.claude/projects/` の全 42 session transcript（2026-08-29 時点） / `dot_claude/agents/`

reviewer agent 2 つが今の形になっている理由と、他の agent を置いていない理由を残す。agent 定義を読んでも分からない前提と判断に絞る。

## 起動実績

| subagent | 起動された session |
| --- | --- |
| `quality-reviewer` | 10（24%） |
| `security-reviewer` | 10（24%） |
| `researcher`（自前） | 0 |
| `Explore` / `general-purpose` / `Plan`（組み込み） | 0 |

## researcher を持たない理由

調査は読んだ結果から次に読む対象を決める往復で進むため、切り出すと往復ができない。分離や並列が要る場面は全 session で一度も起きていない。

将来その場面が来ても、組み込みの `Explore` と `general-purpose` がそのまま使える。自前定義の利点は役割を絞った prompt だが、それを評価する需要が観測されていない。

## reviewer に Bash を持たせる理由

reviewer 内部（sidechain）の tool 使用は Bash 196 / Read 50 / Grep 0 / Glob 0。Bash が主経路になっている。内訳は 2 種類に分かれる。

- `grep` / `sed` / `ls` / `cat`: 検索と読み取り。`Grep` / `Read` でも代替できる。
- **`git diff` / `git status` / `git show` / `git log`（計 48 回）**: 変更セットの取得。Bash なしでは代替できない。

呼び出し元が明示 diff を渡し忘れた時に reviewer が自力で取得する fallback が、実際に機能している。Bash を外すと、渡し忘れのたびに reviewer が停止して呼び出し元が再起動することになる。

## read-only は規範が担保している

Write / Edit tool は持たないが、Bash があるので cwd 内なら書ける。subagent 内で `git add` を試すと prompt なしで通り、classifier は関与しなかった。cwd 外への write だけは sandbox が EPERM で落とす（`Operation not permitted` であって permission denial ではない）。

つまり技術的な強制はなく、agent 定義の「write 系操作は責務外として実行しない」が担保している。規範は守られていて、上記の Bash のうち write 系は 0 件だった。reviewer が write を実行した時は hook による強制を検討する。

強制する場合の機構は subagent の frontmatter にある。公式は `hooks` を "Lifecycle hooks scoped to subagent" と定義しており、その agent だけに掛かる PreToolUse を書ける。今は足さない。write 系 0 件で発動条件を満たしていない。`disallowedTools` は代わりにならない。`tools:` が allowlist なので `Write` / `Edit` は既に不可で、穴は Bash の中にあるため tool 単位の deny では塞げない。

## 事実の確認を workspace 内に限る理由

`quality-reviewer` は事実の主張を workspace 内の根拠に当て、workspace で当て直せない出典しか根拠が無い主張は「呼び出し元への推奨」へ回す。外部の確認は `WebFetch` を持つ呼び出し元が行う。

`WebFetch` を足さないのは、外部 I/O を正規の経路にしないため。Bash からは外へ届く（[claude-code-settings-design.md](claude-code-settings-design.md) の「sandbox で効いている層と効いていない層」）。今それを止めているのは、外部 I/O を責務外とする役割の規範で、write と同じ構造になっている。`WebFetch` を足すとその規範を外すことになり、読んだ page が prompt injection の入口になる。2026-08-29 時点の reviewer 内の tool 使用（「reviewer に Bash を持たせる理由」）に、外部を取得したものは無い。

回す主張を出典で分けるのは、workspace に根拠が見つからない時、別の場所に根拠があるのかを reviewer が見分けられないため。

## 2 つに分けたままにする理由

session 単位では常に両方が起動され、単独起動は 0 件だった。ただし同一メッセージからの並列起動が 5 回あり、統合すると並列性を失う。

観点も構造的に違う。security は auth、secret、injection、path traversal と見る場所が別。1 つの agent に両方を負わせると、片方で早く「重大な指摘なし」に到達する。

## built-in の review skill と併存させる理由

`/code-review` と `/security-review` が built-in で使える。`--fix`、PR への inline comment、cloud の multi-agent review を持ち、機能はこちらが多い。

ただし対象が違う。built-in の instructions は correctness bug を探すよう指定する。反転した条件、off-by-one、null 参照、await 漏れ、外れた guard、壊れた caller、race。そのうえで "Prefer real failure modes over style" と、style 系の指摘を明示的に下げる。

自前 reviewer が見る scope 逸脱、実体の二重管理、責務分離、回帰リスクはこの範囲に入らない。実際に agent 定義と `CLAUDE.md` の diff を `/code-review` へ通したところ findings 0 件だった。

用途が重ならないので、契約の review 工程では両方を案内し、対象で選ぶ。

## standing authorization を契約側に 1 箇所だけ置く理由

reviewer をユーザー確認なしで起動してよいという規定は `CLAUDE.md` にだけ置く。同じ規定を root `AGENTS.md` にも置くと、AGENTS.md 側は「運用契約で認められている」と CLAUDE.md を参照する形になり、二重になる。

この許可は全 project で効くべきもので、repo-local な案内で繰り返す必要がない。二重に持つと片方だけ直した時にもう片方が古くなる。

## model と effort を固定する理由

`model` を書かないと親の設定を継ぐ。sonnet で作業している最中に review を頼めば sonnet が review することになる。effort も同じで、session が `low` なら reviewer も `low` になる。

reviewer は 1 度呼ばれて指摘を返すだけで、main のように往復して詰められない。session 側の設定に関係なく同じ深さで走らせるため、`model` と `effort` を frontmatter で固定する。`model` を alias でなく full ID にするのは、どの世代で review したかを確定させるため。

`effort` は `quality-reviewer` が `high`、`security-reviewer` が `xhigh`。公式は `high` を検証が重要で edge case が出やすい作業に、`xhigh` をより深い推論に充てる。品質 review は前者に当たる。security review は見落とした時の損失が大きいので 1 段上げる。

`max` は公式が security の脆弱性探しを例に挙げるが、頭打ちと考えすぎの傾向があり、広く使う前に試すよう書かれている。効果を測っていないので既定にしない。重い review では、呼び出し時の `effort` parameter で `max` を渡せる。

model を上げた時は effort も見直す。公式は、Opus 5.5 が同じ level でも Opus 5 より 1 turn に多く考えるとして、前の model の level を引き継がないよう勧めている。

## permissionMode を書かない理由

`settings.json` が `permissions.defaultMode: "auto"` である限り、subagent は auto mode を継承し、**frontmatter の `permissionMode` は無視される**。公式は "If the parent uses auto mode, the subagent inherits auto mode and any `permissionMode` in its frontmatter is ignored" と書く。効かない設定を書くと、read-only が permission 層で守られていると誤読される。実際の担保は「read-only は規範が担保している」のとおり。
