# Codex harness の運用

- Date: 2026-11-09
- 出典: [Permissions](https://learn.chatgpt.com/docs/permissions) / [Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents) / [Build skills](https://learn.chatgpt.com/docs/build-skills) / [Config basics](https://learn.chatgpt.com/docs/config-file/config-basic) / [Custom instructions with AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md) / [Code review](https://learn.chatgpt.com/docs/code-review) / [Personalize](https://learn.chatgpt.com/docs/personalize) / [Security review of code changes](https://learn.chatgpt.com/docs/security/plugin/code-changes)（2026-11-09 確認） / 作業機の `~/.codex/skills/.system/review-agent/SKILL.md`（2026-11-09） / 一時領域への chezmoi 展開と Codex CLI 0.162.0-alpha.2 での設定読み込みの確認（2026-10-08） / 移植時の Codex CLI 0.160.0 でのスキル発見の確認 / 実際の作業機での Codex の署名設定と署名の確認、GitHub の commits API の `verification`（2026-11-07）

`dot_codex/` は chezmoi で `~/.codex/` へ配布する Claude 設定の移植版。運用契約は [`dot_codex/AGENTS.md`](../../dot_codex/AGENTS.md) にある。`config.toml` 全体はこの repo から配布しない。macOS の `personal` では [ADR 0046](../adr/0046-distribute-codex-signing-settings.md) に従い、署名に必要な設定だけを追加する。再導入の判断は [ADR 0043](../adr/0043-reintroduce-codex-from-current-claude.md)、`config.toml` を管理しない判断は [ADR 0044](../adr/0044-manage-codex-runtime-config-per-device.md) にある。

## 構成と権限

契約と skills は、Claude 側（`dot_claude/CLAUDE.md` と `dot_claude/skills/`）と同じ意図で書く。違えているのは、runtime の仕組みが違う箇所だけ。通常作業のモデル、effort、権限、自動 memory は実機側の設定に委ねる。

- 返答の文体: Claude 側は組み込みの output style（`Concise`）で決めている。Codex には output style の仕組みが無い。公式の Personalize は、Codex の個人の指示は global の `AGENTS.md` に置くとしている。そのため `AGENTS.md` の「返答」に、`Concise` の要点を書いている。
- 権限: Claude 側は `settings.json` の deny と sandbox で credential の読み取りを止めている。Codex の `config.toml` はこの repo から配布しないので、credential を読まないことと承認経路の扱いを `AGENTS.md` の「権限」に書いている。
- 独立した review: 自作の reviewer agent は置かない。Claude 側と同じく、必要になってから作る。`skills/lapidary` は組み込みの `/review` を提案する。作業機の `review-agent` system skill は、`/review` の preset と同じ対象（uncommitted changes、base branch との差分、commit、custom instructions）を扱い、正しさに加えて security、performance、保守性への影響も指摘の対象にしている。`/review` がこの skill を使うことは、docs では確かめていない。Codex Security の plugin は作業機に入っていないので、提案しない。
- commit: `workspace-write` の sandbox は `.git` を読み取り専用にする（[Protected paths in writable roots](https://learn.chatgpt.com/docs/agent-approvals-security#protected-paths-in-writable-roots)）。`skills/git-commit` は、`git add` と `git commit` をそのコマンドだけに限って申請する手順を Gotchas に持つ。

[`destructive.rules`](../../dot_codex/rules/destructive.rules) は、列挙したディスク操作コマンドを sandbox 外で禁止する設定。コマンド名と `/bin/`、`/sbin/`、`/usr/bin/`、`/usr/sbin/` の絶対パスに対応する。未知の `mkfs.*` / `newfs_*` や任意の script は網羅しない。契約と設定は管理者による強制ではない。

## 検証範囲

2026-10-08 に macOS・Linux・Windows の 3 通りの OS 分岐で、一時領域への chezmoi 展開を確認した。`config.toml` は管理対象から除外される。既存 config の内容は保持され、存在しない場合も作成されない。AGENTS、skills、rules の配布は継続する。

移植時の記録では、Codex CLI 0.160.0 の一時 home で `~/.codex/skills/` 相当のスキル発見を確認している。公式の user skill 配置は `~/.agents/skills/`。client 更新後はスキル発見を再確認する。

## 適用前後の確認

配布前に `chezmoi diff ~/.codex` でファイルの差分を確認する。`config.toml` はファイル単位の配布から除外している。macOS の署名設定は、適用後に動くスクリプトが追加するため、この差分には出ない。

MCP、plugin、通知、モデル、権限などは、アプリまたは実機の `~/.codex/config.toml` で管理する。既存 config を手動で削除・変更する場合は、必要な追加設定を事前に退避する。個人や作業機を特定する値、秘密情報を repo の source へ取り込まない。

適用後は `chezmoi managed` と target の実体を突き合わせる。source から削除したファイルが target に残る場合がある。

実機の権限設定を変更したら、設定を読み直した新しいセッションで必要な作業とアクセス境界を検証する。既存セッションでの承認付き実行だけを根拠に、変更後の権限が有効だと判断しない。

## macOS のエージェント用署名

Codex は Claude Code と同じ署名鍵と ssh-agent を使う。macOS の `personal` では `chezmoi apply` が、鍵と共有スクリプトの準備後に `~/.codex/hooks.json` の `SessionStart` と `~/.codex/config.toml` の署名に必要な設定を追加する。公開鍵がまだ無い場合は次回の適用まで見送る。設定が競合した場合は適用時のエラーに対象の設定キーが出る。

初回は Codex CLI の `/hooks` で `"$HOME/.config/git/start-signing-agent" >/dev/null` を確認して信頼する。適用を繰り返しても同じ hook の定義は書き直さない。GitHub への鍵の登録は [README](../../README.md#手作業が要るもの) を参照。[Codex Hooks](https://learn.chatgpt.com/docs/hooks)

新しいセッションで、使い捨ての repo に署名付きコミットを作り、`git log -1 --format='%G?'` が `G` になることを確かめる。秘密鍵の読み取りと socket の置き換えが拒否されることも確かめる。プロキシが動いていないと `network.enabled = true` は直接通信を許すため、許可外の Unix socket とローカルのテスト用 TCP ポートへの直接接続が拒否されることを確かめる。[Codex Permissions](https://learn.chatgpt.com/docs/permissions#unix-sockets)

Codex の Git 署名設定はコマンドの環境変数に入る。zsh の初期化は、専用 socket が明示されている時だけ `SSH_AUTH_SOCK` を維持する。通常の terminal の Git は 1Password で署名する。

Codex の command hook はログインシェルから起動する。署名用プロファイルは、この repo が使う zsh の初期化ファイルを読み取り専用にする。別のシェルや独自の `ZDOTDIR` を使う端末では、その初期化ファイルも確認する。

2026-11-06 に macOS の Codex CLI 0.166.0-alpha.6 で確認した。信頼済みの `SessionStart` は、一時ホームの使い捨て鍵を専用 agent に載せた。1Password が起動した実機で、新しく起動した app-server の `command/exec` から zsh のログインシェルを使うと、一時 repo の署名が `%G? = G` になった。一時ホームでの sandbox 検証では、秘密鍵の読み取り、起動スクリプトへの書き込み、socket の削除、許可外の Unix socket とローカル TCP への接続が拒否された。

2026-11-07 に、実際の作業機（macOS の `personal`）で、apply 後の `~/.codex` を確かめた。確認はユーザーが実行し、ChatGPT app 同梱の Codex CLI は 0.167.0-alpha.3.2 だった。

- `hooks.json` には `SessionStart` の hook が入っていた。
- `config.toml` には `default_permissions`、`features.network_proxy`、`permissions.agent-signing`、`shell_environment_policy.set` が入っていた。
- `user.signingkey` の公開鍵は、専用 agent が載せた鍵と fingerprint が一致した。
- 新しい Codex の session で、使い捨ての repo に署名付きコミットを作ると、`%G? = G` になった。`%GK` はエージェント用の鍵の fingerprint だった。
- 同じ鍵で署名して push した Claude Code のコミットは、GitHub の commits API で `verification.verified` が `true`、`reason` が `valid` になった（`04622bf` など）。

この時、専用 agent は Claude Code の session の hook がすでに起動していた。Codex の hook が agent を起動して鍵を載せることは、この確認には含まれない。

2026-11-07 に、ユーザーは実際の作業機で署名専用 agent を停止した。プロセスと socket の消失を確認してから新しい Codex の session を開くと、`SessionStart` hook が agent を起動して鍵を載せた。session 内の `SSH_AUTH_SOCK` は専用 socket を指していた。`ssh-add -l` は comment が `agent-signing` の ED25519 鍵を 1 本だけ返した。`$TMPDIR` の使い捨て repo で `git -c commit.gpgsign=true commit --allow-empty -m probe` を実行すると、`git log -1 --format='%G? %GK'` の `%G?` は `G` になった。`%GK` は `ssh-add -l` の fingerprint と一致した。

停止後の起動を確かめる時は、Claude Code より先に Codex の session を開く。Claude Code の `SessionStart` も同じ agent を起動するためである。停止の手順は [代償と失効](agent-commit-signing-design.md#代償と失効)を参照。

## 未確認

- Windows 実機での動作。
- 署名用プロファイルで、許可していない外部ドメインへの通信を proxy が拒否するか。2026-11-06 の確認は、許可外の Unix socket とローカル TCP への接続に限る。公式によると、proxy が動いていない時の `network.enabled = true` はドメインを制限しない。
- 署名用プロファイルの `read` が、親ディレクトリの rename による置き換えも防ぐか。cwd が `~` や `~/.config` のセッションで問題になる。
