# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理する dotfiles リポジトリです。

## セットアップ

初回セットアップ:

```sh
chezmoi init --apply https://github.com/lazysf/dotfiles.git
```

OS / 用途別のセットアップスクリプトを `scripts/` 配下に置いています（chezmoi の配布対象外）。

```text
scripts/
├─ macos/setup.sh
├─ windows_personal/setup.ps1
└─ windows_work/setup.ps1
```

各スクリプトは Homebrew / winget を未導入なら入れたうえで、用途別の `install_*_stack` (macOS) / `Install-*Stack` (Windows) ブロックを順に実行します。ブロック構成・除外したパッケージの理由はスクリプト内コメントを参照してください。

### macOS

```sh
scripts/macos/setup.sh
```

### Windows

```powershell
scripts/windows_personal/setup.ps1   # 個人用
scripts/windows_work/setup.ps1       # 仕事用
```

仕事用は個人用と構造を共有し、次のブロックを落としています:

- パスワード管理 (`AgileBits.1Password` 系): 会社管理ツール想定
- 研究 (`DigitalScholar.Zotero`): 不要

winget が無ければ <https://aka.ms/getwinget> で App Installer を導入。新規 Windows の既定実行ポリシー (`Restricted`) で `.ps1` が弾かれる場合は以下:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
scripts/windows_personal/setup.ps1
# または
pwsh -ExecutionPolicy Bypass -File scripts/windows_personal/setup.ps1
```

## 更新

リモートの変更を取り込んで適用:

```sh
chezmoi update
```

ローカル source directory として手動で更新した内容を適用:

```sh
op signin  # `op` が使える環境では先に
chezmoi apply
```

適用前に差分を確認するなら `chezmoi diff`。

## macOS Terminal プロファイル

[`dot_config/terminal/Main.terminal`](dot_config/terminal/Main.terminal) は macOS では `chezmoi apply` で配布されますが、`Terminal` への import は手動です。

## mole 週次チェック (macOS)

毎週月曜 9:00 に `mo clean --dry-run` を実行し、解放可能サイズを通知します。通知の「クリーンアップ」ボタンで `mo clean` を実行できます。依存する `mole` / `alerter` は `scripts/macos/setup.sh` の maintenance stack で導入されます。

`chezmoi apply` で [`dot_config/mole/executable_weekly-check.sh`](dot_config/mole/executable_weekly-check.sh) と [`Library/LaunchAgents/local.mole.weekly-check.plist.tmpl`](Library/LaunchAgents/local.mole.weekly-check.plist.tmpl) が配布され、[`run_onchange_after_register-mole-agent.sh.tmpl`](run_onchange_after_register-mole-agent.sh.tmpl) が launchd への登録まで行います。plist の内容が変わった場合も再登録されます。

即時実行して確認するなら `launchctl kickstart -k "gui/$(id -u)/local.mole.weekly-check"`。停止するなら `launchctl bootout "gui/$(id -u)/local.mole.weekly-check"`。

実行ログは `~/Library/Logs/mole/` 配下 (`weekly-check.log` / `weekly-check.err` / `weekly-clean.log`)。通知 backend の選定理由は [`docs/adr/0041-adopt-alerter-for-mole-weekly-notification.md`](docs/adr/0041-adopt-alerter-for-mole-weekly-notification.md) を参照してください。

## Python / Markdown lint

repo 保守用 Python は `uv` で管理 (`uv sync`)。
Markdown は `markdownlint-cli2` で lint:

```sh
npm install    # 初回。package-lock.json も commit 済み
npm run lint
npm run lint:fix
```

設定は [`.markdownlint-cli2.jsonc`](.markdownlint-cli2.jsonc) に集約。[`.pre-commit-config.yaml`](.pre-commit-config.yaml) にも hook 登録済みで、commit 時に staged Markdown を自動 lint / fix します。

## 管理対象と配布対象

`.chezmoiignore` で chezmoi が home directory へ配布しない repo 保守用ファイルを定義しています (`docs/`、`scripts/`、`README.md`、`pyproject.toml`、`package.json`、`uv.lock` など)。
`.gitignore` で Git 管理しないローカル生成物を定義しています (`.cache/`、`.venv/`、`node_modules/` など)。

## Repo-Level Knowledge

- [`docs/notes/`](docs/notes/): repo-level の通常知見
- [`docs/adr/`](docs/adr/): `Accepted` / `Superseded` を含む状態付き判断台帳

共通ハーネスの source は [`dot_claude/`](dot_claude/) と [`dot_codex/`](dot_codex/) に置きます。root `CLAUDE.md` は Claude Code 向けの repo-local import shim で root `AGENTS.md` を参照します。

## Codex

`dot_codex/` は chezmoi で `~/.codex/` へ配布する Claude 設定の移植版です。運用契約は [`AGENTS.md`](dot_codex/AGENTS.md)、実行設定の source は [`config.toml.tmpl`](dot_codex/config.toml.tmpl) を参照してください。再導入の判断は [ADR 0043](docs/adr/0043-reintroduce-codex-from-current-claude.md) に記録しています。

### 構成と権限

skills は [`skills/`](dot_codex/skills/)、reviewer は [`agents/`](dot_codex/agents/) に置きます。通常作業の既定値は `gpt-6.1-sol` / `medium` です。作業ごとのモデルと effort は client で上書きできます。reviewer は親のモデル選択に依存せず、`gpt-6.1-sol` を使います。effort は品質 reviewer が `high`、security reviewer が `xhigh` です。通常の応答には `caveman` skill を使います。自動 memory は無効です。

`workspace` 権限プロファイルは workspace、一時領域、`~/.cache/prek/` への書き込みを許可します。`protected` は reviewer 用の既定の読み取り専用プロファイルです。両プロファイルに credential store、`.env` / `.env.*`、`secrets/` へのアクセス拒否を設定します。これらの権限はローカルの sandbox 内コマンドが対象です。[Apps / MCP などは別の制御に従います](https://learn.chatgpt.com/docs/permissions)。

`.env` / `.env.*` / `secrets/` の拒否 glob は、Windows では home と workspace 内を対象にします。Unix 向けの `/**/...` は Windows の絶対パスとして扱われないため、home の指定には `~/**/...` を使います。macOS・Linux では従来の `/**/...` と workspace 内の指定を使います。

`protected` のネットワークは無効です。`workspace` は network proxy を有効にし、外部 domain の許可一覧を空に設定します。署名用の 1Password agent socket だけを許可します。Unix socket の許可には絶対パスが必要なため、chezmoi template で配布先の home directory を展開します。source に個人の絶対パスは保持しません。

stage / commit 用に workspace root 直下の `.git` への書き込みも明示します。[標準の `workspace-write` では `.git` が読み取り専用になる](https://learn.chatgpt.com/docs/agent-approvals-security)ためです。この許可は `.git` 全体が対象で、Git 設定と hooks も含みます。Git worktree などで実際の Git directory が workspace 外にある場合は、別途実効権限を確認してください。

[親のセッションで変更した sandbox と承認設定は、子の起動時にも適用されます](https://learn.chatgpt.com/docs/agent-configuration/subagents)。reviewer の `default_permissions = "protected"` と `approval_policy = "never"` より優先される場合があります。reviewer を使う際は、設定ファイルの既定値だけで読み取り専用と判断せず、実効権限を確認してください。

[`destructive.rules`](dot_codex/rules/destructive.rules) は列挙したディスク操作コマンドを sandbox 外で禁止する設定です。コマンド名と `/bin/`、`/sbin/`、`/usr/bin/`、`/usr/sbin/` の絶対パスに対応します。未知の `mkfs.*` / `newfs_*` や任意の script は網羅しません。契約と設定は管理者による強制ではありません。

### 検証範囲

移植時の記録では、Codex CLI 0.160.0 の一時 home で設定の strict 読み込みと `~/.codex/skills/` 相当のスキル発見を確認しています。[公式の user skill 配置](https://learn.chatgpt.com/docs/build-skills)は `~/.agents/skills/` です。client 更新後はスキル発見を再確認してください。

同じ記録では、macOS の合成ファイルで `.env` / `secrets/` のアクセス拒否、書き込み境界、ローカル TCP 接続の拒否を確認しています。検証コマンドと実行結果は repo に保存されていないため、この記述だけでは再現確認できません。

他 OS での deny-read、approval の自動審査、配布した reviewer の実際の起動と応答は未検証です。

2026-10-07 に Windows 用パスの修正を検証しました。macOS・Linux と、Windows の home をドライブ付き・バックスラッシュ・UNC 形式にした計5通りで、テンプレート展開と TOML の解析を確認しました。macOS・Linux の展開結果は修正前と同一です。Windows 実機での起動とアクセス拒否は未確認です。

`.git` の書き込み指定は Codex CLI 0.160.0 の strict 読み込みを通っています。2026-10-06 に ChatGPT アプリを再起動して分岐したセッションで、`git add` と pre-commit hook の成功を確認しています。proxy を有効にする前の `git commit` は 1Password の署名処理で停止しました。署名用 socket の接続検証も `PermissionError` で拒否されました。

proxy と絶対パスを使う修正後の設定は strict 読み込みを通っています。2026-10-06 に実機の設定が修正案と一致することも確認しました。ただし、そのセッションでも socket 接続は `PermissionError`、`git commit` は 1Password の署名エラーで失敗しました。既存セッションでの native sandbox の検証は、proxy の loopback listener を確保できず停止しました。

2026-10-06 にアプリを再起動して分岐したセッションで、1Password を使う署名付きコミットの成功を確認しました。外部通信の拒否は未確認です。

### 適用前の確認

配布前に `chezmoi diff ~/.codex` で内容を確認してください。`config.toml` は `config.toml.tmpl` からファイル単位で置き換わります。実機で変更した値や、アプリが追記した項目も再展開で上書きされます。

MCP、plugin、通知などの追加設定は、配布後にアプリで必要に応じて設定し直してください。削除された項目がすべて自動で復元されることは前提にしません。共通設定の変更を再展開後も残す場合は、source に反映してください。個人や作業機を特定する値、秘密情報を repo の source へ取り込まないでください。

[権限プロファイルと旧 sandbox 設定は併用できません](https://learn.chatgpt.com/docs/permissions)。読み込まれる user / project / profile の設定から `sandbox_mode` と `[sandbox_workspace_write]` を除き、起動時の `--sandbox` も併用しないでください。`sandbox_mode` や `--sandbox` が指定されると、旧方式が選ばれて今回の `default_permissions` が使われない場合があります。

適用後は `chezmoi managed` と target の実体を突き合わせてください。source から削除したファイルが target に残る場合があります。

Git の書き込み許可と署名接続の設定を反映したら、設定を読み直した新しいセッションで `workspace` を選び、stage / commit と外部通信の拒否を検証してください。既存セッションでの承認付き実行だけを根拠に、変更後の権限が有効だと判断しないでください。
