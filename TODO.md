# 残タスク

- Date: 2026-10-22

このファイルは、着手を保留している項目の一覧。

`CLAUDE.md` は「1 つの作業（着手から commit まで）で扱うスコープは 1 つに保つ。作業中に別の問題へ気づいたら、その場で着手せずユーザーへ伝える。今のスコープを閉じてから扱う」と定めている。**逸れた分の行き先がここ。** ある作業の途中で見つかった別スコープの問題を、その場で直さずに移し、今のスコープを閉じてから改めて扱う。

各項目に記載日と、どの作業中に見つけたかを書く。どの文脈で浮上したかが分かると、再開時に前提を取り直せる。

判断の記録は `docs/adr/`、設計の理由は `docs/notes/` を正本とし、ここには重複させない。

---

## 1. Windows 実機での動作確認

- 記載: 2026-10-22（machine profile の導入、セットアップスクリプトの統合、`chezmoi apply` からのセットアップ実行）

mac では確かめたが、Windows では確かめていない。この mac に `pwsh` が無く、Windows の分岐は `.chezmoi.os` を差し替えた展開でしか試せていない。

個人の Windows で確かめること。

- `scripts/windows/setup.ps1 personal` が `powershell`（5.1）で構文エラーなく動き、日本語の出力が化けない。先頭に UTF-8 の BOM を付けてある。
- 引数なしで実行すると、`PromptForChoice` で profile の選択肢が出る。
- 1Password が未設定の時は、Developer の設定画面が開いて待つ。設定すると Enter で先へ進む。`Update-SessionPath` で、winget で入れた `op` が見つかる。設定済みなら待たずに進む。
- 選んだ profile が `~/.config/chezmoi/chezmoi.toml` に書かれ、`chezmoi init --apply lazysf` で profile を聞かれない。
- `chezmoi apply` が `run_onchange_after_install-packages.cmd` から setup.ps1 を実行する。2 回目の `apply` では実行されない。
- `dot_config/git/config.tmpl` の `lstat` が `%LOCALAPPDATA%\Microsoft\WindowsApps\op-ssh-sign.exe` を見つけ、展開が止まらない。
- `git log --show-signature -1` で、新しい commit に `Good "git" signature` が出る。
- setup の後、`Get-ExecutionPolicy -List` で CurrentUser が RemoteSigned になっている（未設定だった場合）。
- `chezmoi cd` で `cmd.exe` ではなく `powershell` が開く（`.chezmoi.toml.tmpl` の `[cd]`）。
- `powershell`（5.1）を開くと、`Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1` が読み込まれ、starship と zoxide が効く。`$PROFILE` が同じ path を指す。

仕事の Windows では、`work` を選んだ時に 1Password と Zotero が入らず、git の identity と署名の設定が出ないことを確かめる。

---

## 2. mac で 1Password が未設定の時の待機

- 記載: 2026-10-22（setup で 1Password の設定を待つようにした時）

この mac は 1Password を設定済みなので、`scripts/macos/setup.sh` の `wait_for_onepassword` は「設定済み」の経路しか通していない。未設定の経路は、関数だけを取り出し、`op` を偽物にして試した範囲に留まる。

新しい mac、または 1Password の CLI 連携と SSH agent を切った状態で確かめること。

- Developer の設定画面（`onepassword://settings/developers`）が開き、やることの一覧と、未設定の項目が出る。
- 設定する前に Enter を押すと、まだ未設定の項目を出して待ち続ける。
- 両方を設定して Enter を押すと、「1Password は設定済みです」と出て先へ進む。
