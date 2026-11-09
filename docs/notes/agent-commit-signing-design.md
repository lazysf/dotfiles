# エージェントの commit 署名の設計

- Date: 2026-11-07
- 出典: [hamakou108.com の記事](https://hamakou108.com/posts/coding-agent-credentials-for-claude-code) / [Hooks reference](https://code.claude.com/docs/en/hooks) の `CLAUDE_ENV_FILE` と shell form、sandboxing docs の「What runs outside the sandbox」（2026-11-06 確認） / hooks docs の Windows の shell、permissions docs の「What `Read` and `Edit` rules cover」（2026-11-07 確認） / Claude Code 2.1.317 の binary にある sandbox profile の生成コード（2026-11-06） / 使い捨ての HOME での署名 hook の実測と、apply 後の実際の session での実測（2026-11-06） / Windows の Git Bash で使い捨ての HOME を使った署名 hook の実測（2026-11-07） / cwd が home の mac の session での `~/.ssh` への `mv` と `ssh-keygen -f` の実測（2026-11-07、v2.1.311） / cwd が home の mac の session での `denyWrite` の path への書き込みの実測、mac の session での Write ツールの `~/.ssh` の拒否の実測、Edit ツールでの `start-signing-agent` の拒否の実測（2026-11-07） / Windows の session での `~/.ssh` への書き込みの実測（2026-11-07、Claude Code 2.1.317） / GitHub の commits API の `verification`（2026-11-07） / [GitHub の署名検証記録](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification#persistent-commit-signature-verification)

エージェントの commit を、人の 1Password とは別の専用の鍵で署名する構成の理由と実測を残す。人の commit の署名を sandbox 内で通す設定は [claude-code-settings-design.md](./claude-code-settings-design.md) の「署名 agent の socket を通す理由」にある。手元での署名の検証は [git-signature-verification-design.md](./git-signature-verification-design.md)、Codex 側の設定は [codex-harness-operation.md](./codex-harness-operation.md) にある。

## 専用の鍵で署名する理由

1Password の署名は commit ごとに承認を求めるので、エージェントの作業がそこで止まる。エージェントの commit には署名専用の鍵を使わせ、人の commit は 1Password のままにする。構成は [hamakou108.com の記事](https://hamakou108.com/posts/coding-agent-credentials-for-claude-code) のうち署名の部分だけを取った。gh の PAT と HTTPS での push は入れていない（push は人が行う運用のまま）。

## 構成

- 鍵は `~/.ssh/agent_signing_ed25519` で、パスフレーズなし。作業機ごとに作る。`personal` では、macOS は `scripts/macos/setup.sh`、Windows は `scripts/windows/setup.ps1` が、鍵が無い時だけ作る。`chezmoi init` より前に作るので、最初の apply で allowed_signers に行が出る。GitHub への登録は手作業のまま（README の「手作業が要るもの」）。GitHub には Signing Key としてだけ登録し、Authentication Key には登録しないので、漏れても push には使えない。macOS の sandbox 内のコマンドは、sandbox の read 制限に合流する `permissions.deny` の `Read(~/.ssh/**)` で `~/.ssh` を読めない。Windows については「Windows では鍵を持ち出せる」にある。
- `SessionStart` hook（`dot_claude/hooks/executable_signing-agent.sh`）は、Claude Code と Codex で共用する `~/.config/git/start-signing-agent` を呼ぶ。このスクリプトが専用の ssh-agent（socket は `~/.local/state/agent-signing/agent.sock`）を起動して鍵を載せる。Claude Code の公式 docs によると、command hook は sandbox の外で動く。
- hook は `CLAUDE_ENV_FILE` に、`SSH_AUTH_SOCK` と `GIT_CONFIG_COUNT` 系（`gpg.ssh.program=ssh-keygen`、`user.signingkey=key::<公開鍵>`）を書く。公式によると、この値はその session の Bash コマンドにだけ効く。人の terminal の git には届かない。Claude Code 自身も sandbox のコマンドに `GIT_CONFIG_COUNT` 系（`safe.directory` の 2 件）を入れているので（2026-11-06 に env で確認）、番号は固定せず、env file が読まれた時点の `GIT_CONFIG_COUNT` の後ろへ足す。
- `settings.json` の `env` に書かないのは、記事によると `env` では `~` も `$HOME` も展開されず（この repo では実測していない）、home の絶対パスを repo に置くことになるため。hook は実行時に `$HOME` と公開鍵を読むので、repo には絶対パスも鍵も残らない。`settings.json` を `.tmpl` にしなくて済み、`check json` も残る。
- env を書く前に失敗した時は、stderr に理由を出して exit 0 で抜け、env を書かない。この場合は `~/.config/git/config` の 1Password 署名に戻る。鍵を作っていない作業機でも同じ経路になる。env を書いた後で agent が止まったり鍵が消えたりした時は 1Password に戻らず、その session の commit が署名に失敗する。`commit.gpgsign` が `true` なので、署名の無い commit にはならない。

## socket の path を sandbox から守る

`security-reviewer`（当時の reviewer agent）の指摘（2026-11-06）。Claude Code 2.1.317 の binary にある sandbox profile の生成コードを読むと、`allowUnixSockets` の path には connect だけでなく bind も許可が出ている。sandbox が state ディレクトリに書ける session では、sandbox 内のプロセスが socket を消して偽の agent を bind できる。たとえば cwd が `$HOME` か `~/.local` の session がそうなる。hook が、接続できる agent に鍵が無い時に `ssh-add` で鍵を送る形だと、次の `SessionStart` でパスフレーズの無い秘密鍵が偽の agent へ出る。

これに 2 つの対策を重ねた。

- hook は、自分が今起動した agent にだけ鍵を渡す。接続できる agent に鍵が無い時は、何も渡さずに抜ける。偽の agent が鍵を持っているふりをしても、署名ができず commit が失敗するだけになる。
- `sandbox.filesystem.denyWrite` に `~/.local/state/agent-signing` を足し、cwd がどこでも sandbox からこのディレクトリを書き換えられないようにする。

共有スクリプトは sandbox の外で実行される。Claude Code の Bash と編集ツールからの書き換えを防ぐため、`~/.config/git/start-signing-agent` を `sandbox.filesystem.denyWrite` と `permissions.deny` の `Edit` ルールに入れる。mac の session（auto mode）で、Edit ツールにこのファイルの書き換えを頼むと、実行前に permission の設定で拒否された（2026-11-07 実測）。置き換えを頼んだのはファイルに無い文字列で、拒否されなくても中身は変わらない形で試した。

agent は `-P '!*'` で起動し、PKCS#11 / FIDO の middleware をどれも読み込ませない。既定の `/usr/lib*/*` のままだと、sandbox 内から `ssh-add -s` で、sandbox の外にいる agent に system の library を dlopen させられる（同じ review の指摘）。

hook を sandbox 内で動かすと、`ssh-agent -a` が socket を作れずに失敗し、上の失敗経路を通った（2026-11-06 実測）。この時の socket の path は使い捨ての HOME の下で、`allowUnixSockets` の外だった。hook は sandbox の外で動くことが前提になる。

## 実測

sandbox の外で、使い捨ての HOME と鍵を使って次を確かめた（2026-11-06、git 2.56.0）。

- 3 本を並行に起動しても agent は 1 つで、ロックは残らず、どの env file にも同じ内容が書かれる。
- agent を `kill -9` して socket だけが残った状態でも、次の起動で agent が立ち直り、鍵が載る。
- env file を読み込んだ shell で `git commit` すると署名され、allowed_signers に鍵を置くと `%G?` が `G` になる。
- 鍵が無いと exit 0 で抜け、env file には何も書かない。
- 鍵の無い別の agent が socket に居座っていると、hook は鍵を渡さずに exit 0 で抜け、env file には何も書かない。その agent は鍵を持たないまま残る。
- hook が起動した agent に `ssh-add -s /usr/lib/ssh-keychain.dylib` を送ると、`agent refused operation` で拒否される。

`chezmoi apply` の後に起動した実際の session（auto mode）で、sandbox 内のコマンドから次を確かめた（2026-11-06、git 2.56.0）。

- `SSH_AUTH_SOCK` は `~/.local/state/agent-signing/agent.sock` を指す。
- `GIT_CONFIG_COUNT` は `4`。0・1 番は Claude Code が入れた `safe.directory` の 2 件のまま残り、2 番が `gpg.ssh.program=ssh-keygen`、3 番が `user.signingkey=key::ssh-ed25519 ...` になる。
- `ssh-add -l` は comment が `agent-signing` の ED25519 鍵 1 本だけを返す。`denyWrite` を入れても、socket への connect は通る。
- 使い捨ての repo で `commit.gpgsign=true` の commit は 1Password の承認を待たずに終わり、`%G?` は `G` になる。
- `~/.local/state/agent-signing/` の下への `touch` は `Operation not permitted` で失敗する。

cwd が home の session（auto mode）でも、sandbox 内の python から `~/.local/state/agent-signing/` の下にファイルを作る操作と、`~/.config/git/start-signing-agent` を追記モードで開く操作は、どちらも `PermissionError: [Errno 1] Operation not permitted` で失敗した。同じ session で、home の直下へのファイルの作成は通った（2026-11-07 実測）。cwd の内側でも止まるので、cwd の外という既定の制限だけでは説明できない。設定の中でこの 2 つへの書き込みを禁じているのは `denyWrite` だけである。`denyWrite` を外した A/B は取っていない。

GitHub に Signing Key として登録した後、README の「手作業が要るもの」にある SSH 接続コマンドで、署名専用の鍵を指定して認証を試した。GitHub は `Permission denied (publickey)` を返し、この鍵での SSH 認証を拒否した（2026-11-06）。

## 代償と失効

sandbox 内のコマンドは、専用 agent に任意のデータへの署名を依頼できる。GitHub に Signing Key として登録すれば、この鍵の署名も Verified になる。エージェントの commit と人の commit は、署名に使った鍵で見分けられる。

パスフレーズが無いので、sandbox の外で動く同じユーザーのプロセスなら、承認なしで鍵を読める。漏れると、他人が自分の credential で push する commit にも、本人の Verified 署名を付けられる。漏れた疑いがある時は、GitHub の Signing Key からその作業機の鍵を消し、`~/.ssh/agent_signing_ed25519*` を作り直す。あわせて Signing Key の一覧を全部見て、登録した覚えの無い鍵を消す。gh の token に `write:ssh_signing_key` scope があると、同じユーザーのプロセスは別の鍵を Signing Key に追加でき、その鍵は作業機の鍵を消しても残るためである。README の CLI での登録手順は、登録後にこの scope を外す。

GitHub の仕様では、検証記録がある commit は署名鍵を更新・失効した後も、同じ repo とその fork で Verified のままになる。手元の `allowed_signers` に入るエージェント用の公開鍵は、その作業機で使っている現在の鍵だけである。鍵更新後に旧鍵の署名を見返す時は GitHub の Verified を確認する。

鍵ファイルを消しても、エージェントの署名は止まらない。`scripts/macos/setup.sh` と `scripts/windows/setup.ps1` は鍵が無いと作り直し、それぞれが変わるたびに `chezmoi apply` から実行し直される。鍵を作り直した後は、下記の手順で署名専用の agent を手動で止めてから、新しい session を開く。`dot_config/git/executable_start-signing-agent` は、接続できる agent に現在の公開鍵が無ければ、鍵を渡さずに終了する。socket への応答だけでは、起動スクリプトが管理する agent かどうかを確認できないためである。この場合、Claude Code の hook は署名用の環境変数を書かず、既定の 1Password の署名設定を使う。

Windows の Git Bash では、専用の agent の PID は `/proc/<pid>/cmdline` の起動引数（`-a ~/.local/state/agent-signing/agent.sock`）で見分けられ、`kill <pid>` で止まった。止めると socket のファイルも消えた。その後に `~/.config/git/start-signing-agent` を実行すると agent が起動し直して鍵を載せ、使い捨ての repo の commit は `%G? = G` になった（2026-11-07 実測）。

macOS では、Terminal で `ps -axww -o pid=,uid=,comm=,args=` を実行する。同じユーザーの `ssh-agent` のうち、起動引数の `-a` が `~/.local/state/agent-signing/agent.sock` を指すものが 1 件だけなら、その PID に `kill -TERM <pid>` を実行する。ユーザーがこの手順を実行すると、プロセスと socket のファイルが両方消えた（2026-11-07 実測）。

Claude Code の新しい session で agent を自動起動させない場合は、`dot_claude/settings.json` から `SessionStart` hook を外す。この設定は全作業機に配られ、作業機ごとに止める仕組みは用意していない。

## `~/.ssh` への書き込みを止める

setup スクリプトは鍵ペアが既にあると生成をスキップする。エージェントが鍵ペアを置くと、人がその公開鍵を GitHub に登録するおそれがある。そのため、`~/.ssh` へのエージェントの書き込みを、`permissions.deny` の `Edit(~/.ssh/**)` と `sandbox.filesystem.denyWrite` の `~/.ssh` で止める。

公式の permissions docs によると、`Edit` rule が止めるのは、組み込みの編集ツールと、Claude Code が認識する Bash の書き込み（`tee` やリダイレクト）。python のように自分でファイルを開くプロセスの書き込みは、`Edit` rule では止まらない。`Read(~/.ssh/**)` の deny は sandbox に read 制限として合流する層で、sandboxing docs はそれが書き込みも止めるとは書いていない。cwd が home の session では、sandbox は既定で home 全体に書き込める。そのため `denyWrite` に `~/.ssh` を入れる。

2026-11-07 に auto mode の session で次を確かめた。

- mac の session では、Write ツールが `~/.ssh` の下の path で、permission の設定による拒否を返した。
- cwd がこの repo の mac の session（Claude Code 2.1.317）では、`mv <一時ファイル> ~/.ssh/<probe>` と `ssh-keygen -f ~/.ssh/<probe>` は permission rule では止まらずに実行され、sandbox が `Operation not permitted` で失敗させた。この時の `~/.ssh` は、sandbox が既定で書き込みを許す cwd の外にあった。
- `denyWrite` に `~/.ssh` を入れた後、cwd が home の mac の session（Claude Code 2.1.311）でも、同じ `mv` と `ssh-keygen -f` は `Operation not permitted` で失敗した。`<sandbox_violations>` のブロックは出なかった。`denyWrite` を外した状態で cwd が home の session を測る A/B は取っていない。
- Windows の session（Claude Code 2.1.317）では、Write ツール、`echo ... > ~/.ssh/<probe>`、`cp /dev/null ~/.ssh/<probe>` が実行前に拒否され、ファイルはできなかった。deny に無い場所への `cp` は通ったので、rule が `cp` の書き込み先を見ていると読める。
- 同じ Windows の session で、`mv <一時ファイル> ~/.ssh/<probe>`、`ssh-keygen -f ~/.ssh/<probe>`、`rm ~/.ssh/<probe>` は通った。エージェントは Windows で、鍵ペアを置くことも消すこともできる。

## Windows では鍵を持ち出せる

native Windows では、sandbox の層（`Read` deny の sandbox への合流、`denyWrite`、`allowUnixSockets`）が効かない（[claude-code-settings-design.md](./claude-code-settings-design.md) の「Windows では sandbox の防御が効かない」）。

その結果、Windows のエージェントの Bash と PowerShell のコマンドは、パスフレーズの無い秘密鍵を読んで外へ送れる。mac の sandbox 内のコマンドは agent に署名を頼めるだけで、鍵そのものは持ち出せない。Windows では鍵を持ち出せるので、session が終わった後も別の場所で署名できる。漏れた後の影響と失効の手順は「代償と失効」と同じ。それでも、エージェントの作業が 1Password の承認で止まらないことを優先し、Windows の `personal` にも入れる。sandbox を使える WSL2 で Claude Code を動かす案は、環境を作り直す範囲が大きいので採らない。

Codex には Windows の署名設定を入れていない。mac の Codex の署名用プロファイルにある `~/.ssh` の deny も Windows には入らないので、Windows の Codex の session がこの鍵を読めるかは確かめていない。

## Windows の hook

hook は Windows でも同じスクリプトを使う。hooks docs によると、Windows の command hook は Git Bash で動く。2026-11-07 に Git for Windows 2.56.0.windows.4（MSYS 3.6.10）の Git Bash で、使い捨ての HOME と鍵を使って次を確かめた。

- hook は env file に mac と同じ内容を書き、env file を読み込んだ shell の `git commit` は署名され、`%G?` が `G` になる。
- 2 回目の起動は agent を起動し直さずに使い、env file の内容は 1 回目と同じになる。
- agent を `kill -9` して socket だけが残った状態でも、次の起動で agent が立ち直り、鍵が載る。
- `gpg.ssh.program=ssh-keygen` は、Git Bash の `PATH` で `/usr/bin/ssh-keygen`（Git for Windows の同梱）に解決される。`C:\Windows\System32\OpenSSH` の `ssh-keygen` は `PATH` の後ろにある。
- socket の path が長いと `ssh-agent -a` が `too long for Unix domain socket` で失敗する。127 文字で失敗した。`~/.local/state/agent-signing/agent.sock` は短いので当たらないが、テストで長い一時ディレクトリを HOME にすると当たる。

`setup.ps1` は鍵を、hook の `ssh-add` と同じ Git for Windows の `ssh-keygen` で作る。上の実測で agent に載せたのも、この `ssh-keygen` で作った鍵になる。

`chezmoi apply` で `setup.ps1` が鍵を作った後に開いた実際の Windows の session で、次を確かめた（2026-11-07）。

- `SSH_AUTH_SOCK` は `~/.local/state/agent-signing/agent.sock` を指す。`GIT_CONFIG_COUNT` は `2` で、0 番が `gpg.ssh.program=ssh-keygen`、1 番が `user.signingkey=key::ssh-ed25519 ...` になる。mac と違い、Claude Code は `safe.directory` の 2 件を入れていない。
- `ssh-add -l` は comment が `agent-signing` の ED25519 鍵 1 本だけを返す。
- 使い捨ての repo で `commit.gpgsign=true` の commit は 1Password の承認を待たずに終わり、`%G?` は `G` になる。`%GK` の fingerprint は `~/.ssh/agent_signing_ed25519.pub` と一致する。
- この鍵で署名して push した commit は、GitHub の commits API で `verification.verified` が `true`、`reason` が `valid` になった（`1246874` など、2026-11-07 確認）。1Password で署名した commit とは、`%GK` の fingerprint で見分けられる。

## 未確認

- `sandbox.filesystem.denyWrite` に入れた `~/.local/state/agent-signing` と `~/.config/git/start-signing-agent` について、親ディレクトリの rename による置き換えも防ぐか。cwd が `~` や `~/.config` の session で問題になる。
