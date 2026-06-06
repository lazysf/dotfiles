# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理する dotfiles リポジトリです。

この README では、セットアップ・更新・配布対象・repo-level knowledge の入口だけをまとめています。

## セットアップ

初回セットアップ:

```sh
chezmoi init --apply https://github.com/lazysf/dotfiles.git
```

セットアップスクリプトは OS 別に `scripts/` 配下へ分けています。Windows は用途別に `windows_personal` / `windows_work` に分けています。`scripts/` 全体が chezmoi の配布対象外です。

```text
scripts/
├─ macos/
│  ├─ Brewfile
│  └─ setup.sh
├─ windows_personal/
│  ├─ winget-packages.json
│  └─ setup.ps1
└─ windows_work/
   ├─ winget-packages.json
   └─ setup.ps1
```

### macOS の環境構築 (Homebrew + パッケージ)

macOS で Homebrew 本体と [`scripts/macos/Brewfile`](scripts/macos/Brewfile) のパッケージを揃えるには、次を手動で実行します。

```sh
scripts/macos/setup.sh
```

[`scripts/macos/setup.sh`](scripts/macos/setup.sh) は Homebrew が未導入なら入れたうえで `brew bundle` を流します。Brewfile は明示的にインストールしたパッケージのみを管理対象とし、`brew bundle dump` で現環境から生成しています。VSCode 拡張は別途同期するため含めません。更新するときは `brew bundle dump --file=scripts/macos/Brewfile --force --no-vscode` で取り直します。

### Windows の環境構築 (winget)

Windows では用途別に分けています。個人用は [`scripts/windows_personal/winget-packages.json`](scripts/windows_personal/winget-packages.json)、仕事用は [`scripts/windows_work/winget-packages.json`](scripts/windows_work/winget-packages.json)。PowerShell で対応する `setup.ps1` を手動実行します。

```powershell
scripts/windows_personal/setup.ps1   # 個人用
scripts/windows_work/setup.ps1       # 仕事用
```

各 `setup.ps1` は winget の有無を確認し、同階層の `winget-packages.json` を `winget import` で一括導入します（winget は Windows 10/11 標準同梱の App Installer。無ければ <https://aka.ms/getwinget>）。

新規 Windows の既定実行ポリシー (`Restricted`) では `.ps1` 直叩きが弾かれます。次のどちらかで回避してください。

```powershell
# セッション限定で許可してから実行
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
scripts/windows_personal/setup.ps1

# または起動時に都度バイパス
pwsh -ExecutionPolicy Bypass -File scripts/windows_personal/setup.ps1
```

`winget-packages.json` は macOS の Brewfile を手がかりに対訳した初版で、winget に無い / Windows 非対応のものは除外しています。`windows_work` の初版は `windows_personal` のコピーで、仕事用に不要なものは適宜削ってください。既存の Windows 機があれば `winget export -o <対象 json>` で実態から取り直せます。

Brewfile から除外・別経路にしたパッケージ:

- winget に無し: `resvg`、`font-symbols-only-nerd-font`
- Windows 非対応 (macOS 専用): `zsh`、`zsh-autosuggestions`、`zsh-syntax-highlighting`、`mos`
- Microsoft Store 別経路 (winget 公式 ID 無し): ChatGPT (`9NT1R1C2HH7J`)、Codex デスクトップアプリ (`9PLM9XGG6VKS`)

## 更新

リモートの変更を取り込んで適用:

```sh
chezmoi update
```

この repo がローカルの source directory で、手動で更新した内容を適用:

```sh
op signin  # `op` が使える環境では先に実行
chezmoi apply
```

適用前に差分を確認するなら `chezmoi diff`。

## macOS Terminal プロファイル

[`dot_config/terminal/Main.terminal`](dot_config/terminal/Main.terminal) は macOS では `chezmoi apply` で配布、`Terminal` への import は手動です（非 macOS では配布対象外）。

## Python 実行

repo 保守用 Python は `uv` で管理します。初回セットアップまたは依存更新後は `uv sync` を実行します。

## 管理対象と配布対象

`.chezmoiignore` は、chezmoi で home directory へ配布しない repo 保守用ファイルを定義します。
`docs/`、`scripts/`、`README.md`、root `AGENTS.md` / `CLAUDE.md`、`.tombi.toml`、`pyproject.toml`、`uv.lock` などは repo 保守専用のため配布対象外です。
`dot_codex/private_config.toml.tmpl` の展開先になる `.codex/config.toml` も、現在は配布対象外です。
`dot_config/terminal/Main.terminal` は macOS では展開対象、非 macOS では配布対象外です。

`.gitignore` は、この repo で Git 管理しないローカル生成物を定義します。
`.cache/`、`.venv/`、`nvim.log` などは Git 管理対象外です。

## Repo-Level Knowledge

この repo を保守するときの知見は `docs/` に置きます。

- `docs/notes/`: repo-level の通常知見
- `docs/adr/`: `Accepted` や `Superseded` を含む状態付き判断台帳

共通ハーネスの source は `dot_codex/` と `dot_claude/` に置きます。
root `CLAUDE.md` は Claude Code 向けの repo-local import shim で、root `AGENTS.md` を参照します。

現在 chezmoi の管理対象になる Codex surface は `~/.codex/AGENTS.md`、`~/.codex/skills/`、`~/.codex/agents/`、`~/.codex/rules/` です。
Claude Code surface は `~/.claude/CLAUDE.md`、`~/.claude/skills/`、`~/.claude/agents/`、`~/.claude/rules/`、`~/.claude/output-styles/`、`~/.claude/settings.json` です。
