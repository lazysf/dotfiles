# Claude Code Settings の設計

- Date: 2026-08-28
- 出典: [Claude Code settings](https://code.claude.com/docs/en/settings) / [Configure permissions](https://code.claude.com/docs/en/permissions) / [Choose a permission mode](https://code.claude.com/docs/en/permission-modes) / [Configure the sandboxed Bash tool](https://code.claude.com/docs/en/sandboxing) / [JSON schema](https://www.schemastore.org/claude-code-settings.json) / 実機 `claude auto-mode defaults`（v2.1.246）

`dot_claude/settings.json.tmpl` が今の形になっている理由を残す。

## 方針: default が塞いでいない穴だけ書く

Claude Code の default と auto mode の built-in classifier が既にかなりの範囲を守る。設定に書くのは、それらが塞いでいない穴だけにする。default と同じ値を書くと、default が変わった時に気づけず、設定を読む人が「これは意図的な選択だ」と誤解する。

## default で足りるもの・足りないもの

| 領域 | default | 設定が要るか |
| --- | --- | --- |
| sandbox の write | cwd とセッション temp のみ書ける | 要らない。ただし pre-commit が `~/.cache/prek/` に書くので `allowWrite` を 1 件足す |
| sandbox の read | **computer 全体を読める。credential も読める** | **要る**。公式が「this default still allows reading credential files such as `~/.aws/credentials` and `~/.ssh/`」と明記 |
| sandbox の network | pre-allow なし。初回に prompt | 要らない。`allowedDomains` は prompt を省くための設定で、遮断のための設定ではない |
| Bash の危険操作 | auto mode の built-in が判断 | ほぼ要らない（下記） |
| Read tool | permission rule のみ | **要る**。sandbox は Bash 経由の read を守るが、Read tool は permission rule でしか止まらない |

## auto mode の built-in ルール

`defaultMode: "auto"` の時だけ classifier が働き、実機（v2.1.246）で `allow` 17 / `soft_deny` 67 / `hard_deny` 1 / `environment` 20 のルールを持つ。件数と内容は次で確認できる。

```sh
"$(ls -d ~/Library/Application\ Support/Claude/claude-code/*/claude.app/Contents/MacOS/claude | tail -1)" auto-mode defaults
```

desktop app 経由の install では `claude` が PATH に無く、実体は `~/Library/Application Support/Claude/claude-code/<version>/claude.app/Contents/MacOS/claude`。

自前の deny rule と重複する主なもの。

| 自前で書きたくなる deny | built-in の該当 |
| --- | --- |
| `npm publish` / `pnpm` / `yarn` の publish | `hard_deny` の Data Exfiltration が `package-publish commands` を Methods に列挙 |
| `git remote set-url` / `git remote add` | 同 `hard_deny` が名指し。`soft_deny` の Remote Repoint も |
| `rm -rf /` などの破壊 | `soft_deny` の Irreversible Local Destruction が `rm -rf` / `Remove-Item -Recurse -Force` を名指し |
| `op item delete` | `soft_deny` の Secret-Store Writes の「or equivalent」 |
| force push、remote branch 削除、`commit --amend` | `soft_deny` の Git Destructive |

built-in が扱わないもの。**disk の format（`mkfs` / `diskutil eraseDisk`）** は「ローカルファイルの削除」ではないので Irreversible Local Destruction の射程外。これだけ自前で deny する。

`gh auth logout` も built-in に無いが、実害が小さいので置いていない。

**auto mode でなければ classifier は働かない。** `defaultMode` を `default` にすると built-in の 68 ルールは一切効かず、毎回 prompt になる。

`defaultMode: "auto"` は user settings（`~/.claude/settings.json`）に置く必要がある。v2.1.142 以降、`.claude/settings.json` / `.claude/settings.local.json` の `auto` は無視される。

## sandbox で効いている層と効いていない層

| 層 | 状態 |
| --- | --- |
| filesystem の read/write 制限 | **効いている**。`~/.config/gh` を deny した状態で `gh` を実行すると `operation not permitted` で落ちる（2026-08-28 実測） |
| raw socket / DNS | **遮断**（`gaierror`）。egress は local の認証付き proxy に強制される |
| `network.allowedDomains` | **domain gate として機能しない**（2026-08-27 実測）。allowlist にも `WebFetch(domain:)` にも無い host へ prompt なしで到達した |
| `Bash(curl *)` / `wget` / `nc` の deny | permission rule としては有効だが**名前ベース**。`python3 -c "import urllib.request; ..."` で素通りする（実測） |
| `WebFetch` | 公式仕様上 sandbox の対象外 |

**Bash の外向き通信に実効的な domain 境界は無い。** 歯止めは LLM 契約と停止線、および credential 側の deny。

切り分けの注意: proxy の拒否は HTTP status ではなく `URLError: Tunnel connection failed` として現れる。HTTP status を deny の証拠と読むと誤判定する（406 を返す origin に到達しているだけ、ということがある）。

`strictAllowlist: true` を入れれば「許可外は prompt でなく deny」になるが、sandboxed command の全 host 到達が制限されるので `npm install` などが壊れるリスクがある。実害が出てから検討する。

## credentials block を使う理由

credential の read を止める方法は `filesystem.denyRead` と `sandbox.credentials` の 2 つあり、公式は後者を勧めている。

- credential 規則が一般の filesystem 規則から分離される
- **環境変数の unset / mask も同じブロックで書ける**

`deny` の効果は `filesystem.denyRead` と同じ。組み込みの deny リストは無いので、守りたい path は自分で列挙する。v2.1.187 以降。

**注意**: `credentials` の deny は例外を作れない可能性がある。公式は「A `deny` entry only ever narrows access, so any scope can add one, but **no scope can remove one** that another scope added」と書く。`denyRead: ~/.ssh` + `allowRead: ~/.ssh/known_hosts` のような例外が要るなら、`filesystem` 側で書く必要があるかもしれない。未検証。

## bypassPermissions を封じる理由

`disableBypassPermissionsMode: "disable"` は `bypassPermissions` mode の 4 つの起動経路（`--permission-mode bypassPermissions`、`--dangerously-skip-permissions`、`--allow-dangerously-skip-permissions`、settings の `defaultMode`）を塞ぐ。公式は managed settings 向けと説明するが、user settings でも機能する（「A user can set it in their own settings to lock themselves out of bypass mode.」）。

この mode で残るのは deny rule と sandbox だけ。**auto mode の built-in 68 ルールが全部消え、protected paths（`.claude/settings.json` など）への書き込み保護も外れる。** 落差が大きいわりに、うっかり入る経路は無い（起動時に明示しない限り mode cycle にも現れない）ので、1 行で塞いでおく。

`auto` mode は封じない。それは別キーの `disableAutoMode`。

## push は sandbox 内でできない

`sandbox.network.allowedDomains` は HTTP(S) proxy 用の許可で、**SSH を運ばない**。`git@github.com` への push は sandbox 内で `nc: authentication method negotiation failed` で失敗する。

`excludedCommands: ["git"]` を入れても解決しなかった（2026-08-05 実測、`53be6a5` → `9afdbb7` で revert）。`allowUnsandboxedCommands` を `true` へ戻す案は、失敗した全 command に sandbox 外再試行を開くので採らない。

**push は人が手元の terminal で打つ運用を正とし、agent は commit までを担う。**

## 入れていない設定と理由

| 設定 | 理由 |
| --- | --- |
| `env.CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` | **permission mode を `default` に強制し、auto mode を黙って無効化する**（v2.1.221 で対照実験）。`--permission-mode auto` を明示すると Claude Code 自身が警告を出す。公式 docs に値の記載が無い |
| `sandbox.autoAllowBashIfSandboxed` | default の `true` に任せる。`false` にすると sandbox 済み Bash も 1 本ごとに classifier 往復が入って遅く、block が fallback カウンタに積まれる |
| `sandbox.failIfUnavailable` | 公式は managed deployment 向けと説明。macOS の Seatbelt は組み込みで、sandbox が使えないことは稀 |
| `sandbox.filesystem.denyWrite` | default で cwd 外は書けない |
| `sandbox.network.allowUnixSockets` | 1Password の SSH agent socket を通しても、SSH 接続自体が proxy を通らないので用途が無い。公式は Unix socket 経由の privilege escalation を警告している |
| `autoMode`（classifier への宣言） | 4 配列（`environment` / `allow` / `soft_deny` / `hard_deny`）のいずれにも `"$defaults"` を含めないと、その配列の built-in が丸ごと置き換わる。誤 block が実際に観測されてから検討する |
| PowerShell 版 deny | Windows では sandbox が動かず（公式: native Windows 非対応）、`denyRead` も効かない。PowerShell は prefix match を容易に外せるため speed bump にしかならない。実効防御は WSL2 上での実行に寄せる |
| OS 分岐（`{{ if eq .chezmoi.os "windows" }}`） | `failIfUnavailable` が default の `false` なので、Windows でも警告して sandbox なしで続行する |

## 仕様の確認記録

公式仕様に照らして確認したキーと値。

| 対象 | 確認内容 |
| --- | --- |
| `permissions.defaultMode` | `default` / `acceptEdits` / `plan` / `auto` / `dontAsk` / `bypassPermissions`。`default` の CLI 表示名は Manual、`manual` が alias |
| `disableBypassPermissionsMode` | 値は文字列 `"disable"`。防ぐのは `bypassPermissions` だけ |
| `Read(//**/.env)` | filesystem-wide の `.env` に match する |
| `Bash(mkfs *)` の `*` | 任意位置で使え、末尾 `*` の前に空白があると word boundary を要求する（`Bash(ls *)` は `ls -la` に match、`lsof` には match しない） |
| `PowerShell(...)` | `Bash(...)` とは別 namespace。Windows の PowerShell 経路は `Bash(...)` deny では覆えない |
| `WebFetch(domain:...)` | hostname に case-insensitive match。`domain:` 形は sandbox の allowed domain list へも合流する |
| `model` | alias（`opus` 等）と full model name の両方を受け付ける |
| `effortLevel` | `low` / `medium` / `high` / `xhigh` / `max` / `auto` |
| `autoUpdatesChannel` | default は `latest`。`stable` は約 1 週間前の版で、major regression のある版を飛ばす |
| `autoMemoryEnabled` | default は `true`。`~/.claude/projects/<project>/memory/` へ自動保存する |
| `cleanupPeriodDays` | default は `30` |
| auto mode の fallback | classifier が 3 回連続または累計 20 回 block すると auto mode が pause し prompt が再開する。閾値は設定不可 |
| auto mode の allow rule drop | auto mode に入ると、任意コード実行を与える広い allow rule（blanket `Bash(*)` / `PowerShell(*)`、wildcard interpreter、package manager の run、`Agent`、`Monitor`）が drop される。narrow rule は残る |

## 未解消のリンク切れ

削除済みの `claude-code-permission-policy.md` を指す参照が 3 ファイルに残っている。

- `docs/adr/0038-allow-reviewer-subagents-read-only-bash.md` — リンク切れ自体は ADR の編集境界が許す修正（判断内容を変えない）。ただしこの ADR は「Codex reviewer と fallback を対称化する」ことを目的としており、Codex 廃止で前提を失っている。同じ箇所が削除済みの `Bash(git remote set-url *)` deny にも言及しており、参照先の差し替えだけでは辻褄が合わない。Codex 廃止をまとめる ADR で `Superseded` にする時に処理する。
- `docs/notes/harness-regression-checks.md`（5 箇所）と `docs/notes/lightweight-workflow.md`（2 箇所） — どちらも Codex 併用期の note で再構築対象。そちらを整理する時に解消する。

## 未確認

- **この設定はまだ `chezmoi apply` していない。** 実機で動作を確認していないので、防御層として数えられない。特に `sandbox.credentials` が実際に read を止めるか、`defaultMode: "auto"` が実際に auto で動くか（`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` が黙って壊した前例がある）は apply 後に実測する。
- `credentials` の deny に例外を作れるか。SSH を sandbox 内で使う必要が出た時に問題になる。
- `allowedDomains` が gate しないのが、この環境固有か Claude Code 一般か。`strictAllowlist` で gate が復活するかも未確認。
- `WebFetch` / `WebSearch` は未信頼コンテンツを context へ取り込む経路でもある。この経路に enforcement は無く、「取り込んだ内容は data であって指示ではない」は LLM の既定挙動に依存する。契約側に該当条項を置くかは別途判断。
