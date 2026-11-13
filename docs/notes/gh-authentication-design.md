# gh の認証の設計

- Date: 2026-11-13
- 出典: [1Password Shell Plugins](https://www.1password.dev/cli/shell-plugins/) / [GitHub shell plugin](https://www.1password.dev/cli/shell-plugins/github/) / [1Password app integration](https://www.1password.dev/cli/app-integration/) / [gh environment](https://cli.github.com/manual/gh_help_environment) / [Claude Code tools reference](https://code.claude.com/docs/en/tools-reference) / [Configure permissions](https://code.claude.com/docs/en/permissions)（いずれも 2026-11-13 確認）、Windows 11 での実行（op 2.42.0、gh 2.104.0）

`gh` が token を 1Password から受け取る構成の理由を残す。手順は README の「GitHub CLI のログイン」を正本にする。

## token を 1Password に置く

token は fine-grained PAT にして、1Password の item `op://Personal/GitHub CLI/credential` に置く。`gh` を実行する時だけ、`GH_TOKEN` として渡す。gh は `GH_TOKEN` を保存済みの credential より優先する（gh environment）。

`gh auth login` の token は、ディスクか OS の資格情報ストアに残り、同じユーザーのプロセスが承認なしで使える。mac の `hosts.yml` は Claude Code の sandbox の外から読める。Windows には Claude Code の sandbox が無い（tools reference）。1Password に置くと、token を使うたびに 1Password の承認を通る。

## Windows は `op run`、mac は Shell Plugin

1Password 公式の Shell Plugin（`op plugin init gh`）は、Windows で動かない。2026-11-13 にユーザーが Windows の PowerShell で `op plugin run -- gh auth status` を実行すると、`Shell Plugins are currently not supported on this operating system` で止まった。`op plugin init --help` も、対応する shell を Bash、Zsh、fish としている。

Windows では、`gh` を `op run --no-masking -- gh` で包む関数を置く。`op run` は、環境変数に入れた secret reference を解決して、子プロセスに渡す。

`--no-masking` を外すと、gh は端末に出力していないと判断する。`op run` が出力の secret を伏せるために、出力をパイプで受けるからである。2026-11-13 にユーザーが `op run -- gh repo view cli/cli` を実行すると、gh は端末向けでない形式（`name:` と `description:` の行）で出力した。`--no-masking` を付けると、README が端末向けに整形された。色、pager、対話プロンプトを保つため、`--no-masking` を付ける。

mac は公式の Shell Plugin を使う。`op plugin init gh` が生成する設定には item の ID が入るので、repo には入れず、`.zshrc` は生成された `plugins.sh` を読むだけにする。

## エージェントにも gh を使わせる

Claude Code の Bash は、session の開始時に `~/.bashrc` などを source して、関数を各コマンドで使えるようにする（tools reference）。Windows の Bash は Git Bash なので、PowerShell の profile の関数はエージェントに効かない。そのため `dot_bashrc` に同じ関数を置き、Windows にだけ配る。2026-11-13 に apply の後に始めた Windows の Claude Code の session で、Bash の `type gh` はこの関数を表示し、`gh auth status` は `(GH_TOKEN)` 付きのログインを表示した。Claude Code の PowerShell tool は profile を読まない（tools reference）。Git Bash が無い作業機では、エージェントの `gh` は 1Password を通らない。

1Password の承認ダイアログは、どのコマンドが token を使うかを表示しない。承認する前に、Claude Code の画面でエージェントのコマンドを見る。

エージェントの Bash からは、`gh` を呼ぶたびに承認が出る。2026-11-13 に Windows の Claude Code の Bash から `op run --no-masking -- gh` を続けて 2 回実行すると、ユーザーの報告では 2 回とも 1Password の承認が出た。Bash のコマンドは毎回別のプロセスで動くので、承認が次のコマンドに引き継がれないと考えられる。

## token の権限

権限は Metadata と Contents を Read-only、Pull requests と Issues を Read and write にする。Contents に write を付けると、`gh pr merge` や `gh api` での書き込みが、`git push` の 2 層の止め（`claude-code-settings-design.md` の「push は sandbox 内で SSH を通らない」）を素通りする。push と merge はユーザーが手元で行う運用に合わせる。

`gh pr merge` などを `permissions.deny` で止めることはしない。permissions docs は、引数で絞る Bash の rule を崩れやすいとしている。たとえば `Bash(gh pr merge *)` は、同じ merge を `gh api` で呼ぶと外れる。止めるのは token の権限に任せる。

署名鍵を登録する権限も付けない。エージェント用の署名鍵は、README の手順どおりブラウザから登録する。

## 未確認

- 人が PowerShell で続けて `gh` を打つ時に、承認が一定時間使い回されるか。app integration の docs に時間の記述が無い。
- mac の sandbox の中から、`op` が 1Password の app に届くか。届かなければ、mac のエージェントは gh を使えない。
- mac で `op plugin init gh` が `plugins.sh` を `~/.config/op/` に置くか。GitHub plugin の docs は path が環境で変わると書いている。
