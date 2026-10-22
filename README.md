# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理する dotfiles リポジトリです。

## セットアップ

初回セットアップ:

```sh
chezmoi init --apply https://github.com/lazysf/dotfiles.git
```

初回の `chezmoi init` で `Machine profile` として `personal` か `work` を選びます。選んだ値は `~/.config/chezmoi/chezmoi.toml` に保存され、次回からは聞かれません。git の identity と署名鍵を 1Password から読むのは、macOS と Windows の `personal` のマシンだけです。`work` のマシンでは identity を `~/.config/git/config.local` に書いてください。

対話なしで選ぶ場合は `--promptChoice` に prompt の文言と値を渡します。

```sh
chezmoi init --apply --promptChoice "Machine profile=work" https://github.com/lazysf/dotfiles.git
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

## Claude Code の mod

[`dot_claude/mods/`](dot_claude/mods/) は chezmoi で `~/.claude/mods/` へ配布する Claude Code の mod です。[`settings.json`](dot_claude/settings.json) の `env.CLAUDE_CODE_PLUGIN_DIRS` に列挙した folder を、この作業機で起動する session で読み込みます。帯を描くのは terminal と desktop app で、VS Code 拡張は描きません。この配布方法を選んだ理由は [ADR 0045](docs/adr/0045-distribute-claude-mods-via-plugin-dirs.md) に記録しています。

| mod | 内容 |
| --- | --- |
| `usage-band` | プロンプトの上に、5 時間と週の使用率をバーで表示する。リセットまでの時間も示す。コンテキストの使用率も、応答が 1 度返った後にバーで表示する |

source の folder では `.claude-plugin/` を `dot_claude-plugin/` と書きます。そのため、`claude plugin validate` と `claude plugin test` は展開先の folder に対して実行してください。test の `*.test.ts` は mod と一緒に配布します。engine は test を読み込みません。

## Codex

`dot_codex/` は chezmoi で `~/.codex/` へ配布する Claude 設定の移植版です。運用契約は [`AGENTS.md`](dot_codex/AGENTS.md) を参照してください。`config.toml` はこの repo で管理・配布しません。再導入の判断は [ADR 0043](docs/adr/0043-reintroduce-codex-from-current-claude.md)、`config.toml` を管理しない判断は [ADR 0044](docs/adr/0044-manage-codex-runtime-config-per-device.md) に記録しています。

### 構成と権限

skills は [`skills/`](dot_codex/skills/)、reviewer は [`agents/`](dot_codex/agents/) に置きます。通常作業のモデル、effort、権限、自動 memory は実機側の設定に委ねます。reviewer は親のモデル選択に依存せず、`gpt-6.1-sol` を使います。effort は品質 reviewer が `high`、security reviewer が `xhigh` です。通常の応答には `caveman` skill を使います。

reviewer の既定の権限は [標準の `:read-only`](https://learn.chatgpt.com/docs/permissions) です。credential store などへの独自の deny 設定は、この標準プロファイルには追加していません。

[親のセッションで変更した sandbox と承認設定は、子の起動時にも適用されます](https://learn.chatgpt.com/docs/agent-configuration/subagents)。reviewer の `default_permissions = ":read-only"` と `approval_policy = "never"` より優先される場合があります。reviewer を使う際は、設定ファイルの既定値だけで読み取り専用と判断せず、実効権限を確認してください。

[`destructive.rules`](dot_codex/rules/destructive.rules) は列挙したディスク操作コマンドを sandbox 外で禁止する設定です。コマンド名と `/bin/`、`/sbin/`、`/usr/bin/`、`/usr/sbin/` の絶対パスに対応します。未知の `mkfs.*` / `newfs_*` や任意の script は網羅しません。契約と設定は管理者による強制ではありません。

### 検証範囲

2026-10-08 に macOS・Linux・Windows の3通りの OS 分岐で、一時領域への chezmoi 展開を確認しました。`config.toml` は管理対象から除外されます。既存 config の内容は保持され、存在しない場合も作成されません。AGENTS、skills、agents、rules の配布は継続します。macOS 上の Codex CLI 0.162.0-alpha.2 では、独自の `protected` がなくても両 reviewer のモデル・権限設定が読み込めることを確認しました。reviewer の実際の起動と Windows 実機での動作は未確認です。

移植時の記録では、Codex CLI 0.160.0 の一時 home で `~/.codex/skills/` 相当のスキル発見を確認しています。[公式の user skill 配置](https://learn.chatgpt.com/docs/build-skills)は `~/.agents/skills/` です。client 更新後はスキル発見を再確認してください。

### 適用前の確認

配布前に `chezmoi diff ~/.codex` で内容を確認してください。`config.toml` は `.chezmoiignore` で除外しているため、chezmoi は作成・更新・削除しません。過去に配布した config も自動では消えません。

MCP、plugin、通知、モデル、権限などは、アプリまたは [実機の `~/.codex/config.toml`](https://learn.chatgpt.com/docs/config-file/config-basic) で管理してください。既存 config を手動で削除・変更する場合は、必要な追加設定を事前に退避してください。個人や作業機を特定する値、秘密情報を repo の source へ取り込まないでください。

適用後は `chezmoi managed` と target の実体を突き合わせてください。source から削除したファイルが target に残る場合があります。

実機の権限設定を変更したら、設定を読み直した新しいセッションで必要な作業とアクセス境界を検証してください。既存セッションでの承認付き実行だけを根拠に、変更後の権限が有効だと判断しないでください。
