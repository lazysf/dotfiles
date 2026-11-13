# gh の認証の設計

- Date: 2026-11-13
- 出典: [1Password Shell Plugins](https://www.1password.dev/cli/shell-plugins/) / [GitHub shell plugin](https://www.1password.dev/cli/shell-plugins/github/) / [1Password app integration](https://www.1password.dev/cli/app-integration/) / [gh environment](https://cli.github.com/manual/gh_help_environment) / [Claude Code tools reference](https://code.claude.com/docs/en/tools-reference) / [Configure permissions](https://code.claude.com/docs/en/permissions)（いずれも 2026-11-13 確認）、Windows 11 での実行（op 2.42.0、gh 2.104.0）

`gh` が token を 1Password から受け取る構成の理由を残す。手順は README の「GitHub CLI のログイン」を正本にする。

## token を 1Password に置く

token は fine-grained PAT にして、1Password の item `op://Personal/GitHub CLI/token` に置く。field 名は GitHub の Shell Plugin が求める `token` に合わせる。2026-11-13 に mac で `op plugin init gh` を実行すると、item の `credential` field が `token` に rename された。ユーザーの確認では、値は変わらなかった。GitHub plugin の docs は、必要な名前の field が無ければ既存の field の rename を求めると書いている。Windows の `op run` も同じ field を参照する。field を変えて apply した後の 2026-11-13 に、Windows で PowerShell の profile の `gh`（`pwsh -Command`）と、`~/.bashrc` の `gh`（`bash -ic`）の両方で、`gh auth status` が `(GH_TOKEN)` 付きのログインを表示した。`gh` を実行する時だけ、`GH_TOKEN` として渡す。gh は `GH_TOKEN` を保存済みの credential より優先する（gh environment）。

`gh auth login` の token は、ディスクか OS の資格情報ストアに残り、同じユーザーのプロセスが承認なしで使える。mac の `hosts.yml` は Claude Code の sandbox の外から読める。Windows には Claude Code の sandbox が無い（tools reference）。1Password に置くと、token を使うたびに 1Password の承認を通る。

## Windows は `op run`、mac は Shell Plugin

1Password 公式の Shell Plugin（`op plugin init gh`）は、Windows で動かない。2026-11-13 にユーザーが Windows の PowerShell で `op plugin run -- gh auth status` を実行すると、`Shell Plugins are currently not supported on this operating system` で止まった。`op plugin init --help` も、対応する shell を Bash、Zsh、fish としている。

Windows では、`gh` を `op run --no-masking -- gh` で包む関数を置く。`op run` は、環境変数に入れた secret reference を解決して、子プロセスに渡す。

`--no-masking` を外すと、gh は端末に出力していないと判断する。`op run` が出力の secret を伏せるために、出力をパイプで受けるからである。2026-11-13 にユーザーが `op run -- gh repo view cli/cli` を実行すると、gh は端末向けでない形式（`name:` と `description:` の行）で出力した。`--no-masking` を付けると、README が端末向けに整形された。色、pager、対話プロンプトを保つため、`--no-masking` を付ける。

mac は公式の Shell Plugin を使う。`op plugin init gh` が生成する設定には item の ID が入るので、repo には入れず、`.zshrc` は生成された `plugins.sh` を読むだけにする。2026-11-13 に mac で `op plugin init gh`（op 2.42.0）を実行すると、`plugins.sh` は `~/.config/op/plugins.sh` に置かれ、中身は `gh` を `op plugin run -- gh` で包む関数だった。使う item の設定は、同じ場所の `plugins/gh.json` と `plugins/used_items/gh.json` に置かれた。その後にユーザーが mac の terminal で実行した `gh auth status` は、`(GH_TOKEN)` 付きのログインを表示した。

## エージェントにも gh を使わせる

Claude Code の Bash は、session の開始時に `~/.bashrc` などを source して、関数を各コマンドで使えるようにする（tools reference）。Windows の Bash は Git Bash なので、PowerShell の profile の関数はエージェントに効かない。そのため `dot_bashrc` に同じ関数を置き、Windows にだけ配る。2026-11-13 に apply の後に始めた Windows の Claude Code の session で、Bash の `type gh` はこの関数を表示し、`gh auth status` は `(GH_TOKEN)` 付きのログインを表示した。Claude Code の PowerShell tool は profile を読まない（tools reference）。Git Bash が無い作業機では、エージェントの `gh` は 1Password を通らない。

mac の Claude Code の sandbox の中では、エージェントの `gh` は動かない。2026-11-13 に sandbox の中の Bash で `plugins.sh` を読んで `gh auth status` を実行すると、`op` が `couldn't connect to the 1Password desktop app` で止まった。同じ時刻に、ユーザーが sandbox の外の terminal で実行した `op account list` は成功した。sandbox の中から 1Password の socket に `connect` すると、`~/Library/Group Containers/2BUA8C4S2C.com.1password/t/` の `agent.sock` にはつながり、`s.sock` は `EPERM` で拒否された。`dot_claude/settings.json.tmpl` の `allowUnixSockets` は、1Password の socket のうち SSH agent の `agent.sock` だけを許している。`op` が app integration に使う socket が `s.sock` であることは確かめていない。エージェントに gh を使わせるには sandbox の設定を変える必要があり、権限の境界に触れるので保留している。

1Password の承認ダイアログは、どのコマンドが token を使うかを表示しない。承認する前に、Claude Code の画面でエージェントのコマンドを見る。

エージェントの Bash からは、`gh` を呼ぶたびに承認が出る。2026-11-13 に Windows の Claude Code の Bash から `op run --no-masking -- gh` を続けて 2 回実行すると、ユーザーの報告では 2 回とも 1Password の承認が出た。Bash のコマンドは毎回別のプロセスで動くので、承認が次のコマンドに引き継がれないと考えられる。

## token の権限

権限は Metadata と Contents を Read-only、Pull requests と Issues を Read and write にする。Contents に write を付けると、`gh pr merge` や `gh api` での書き込みが、`git push` の 2 層の止め（`claude-code-settings-design.md` の「push は sandbox 内で SSH を通らない」）を素通りする。push と merge はユーザーが手元で行う運用に合わせる。

`gh pr merge` などを `permissions.deny` で止めることはしない。permissions docs は、引数で絞る Bash の rule を崩れやすいとしている。たとえば `Bash(gh pr merge *)` は、同じ merge を `gh api` で呼ぶと外れる。止めるのは token の権限に任せる。

署名鍵を登録する権限も付けない。エージェント用の署名鍵は、README の手順どおりブラウザから登録する。

## 未確認

- 人が PowerShell で続けて `gh` を打つ時に、承認が一定時間使い回されるか。app integration の docs に時間の記述が無い。
- mac の `op` が app integration に使う socket の名前。sandbox で許す socket を足すなら、先に確かめる。
