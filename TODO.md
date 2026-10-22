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
- `chezmoi init` で `personal` を選び、`chezmoi apply` が `run_onchange_after_install-packages.cmd` から setup.ps1 を実行する。2 回目の `apply` では実行されない。
- `dot_config/git/config.tmpl` の `lstat` が `%LOCALAPPDATA%\Microsoft\WindowsApps\op-ssh-sign.exe` を見つけ、展開が止まらない。
- `git log --show-signature -1` で、新しい commit に `Good "git" signature` が出る。

仕事の Windows では、`work` を選んだ時に 1Password と Zotero が入らず、git の identity と署名の設定が出ないことを確かめる。
