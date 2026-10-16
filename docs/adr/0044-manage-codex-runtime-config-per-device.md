# 0044: Codex の runtime 設定を作業機ごとに管理する

- Status: Accepted
- Amends: 0043

## 背景

ADR 0043 は、認証情報の deny を持つ permissions profile を管理すると決めた。この profile は model、sandbox、network の既定と共に `~/.codex/config.toml` として配布していた。仕事用の Windows 機では、配布した config を外すまで Codex の task が起動しなかった。

## 決定

`~/.codex/config.toml` をこの repo で管理・配布せず、`.chezmoiignore` で除外する。model、sandbox、network、認証情報の deny は作業機の config で管理する。reviewer は標準の `:read-only` を使う。

## 検討した代替案

- **配布を続け、Windows 向けに deny の glob を直す**: Windows で home 起点の glob を使う修正（`a91f288`）と、macOS 以外で glob の走査深さに上限を置く修正（`4dd452b`）は入れた。起動しなかった時の config にこれらが入っていたかは記録が無く、失敗の原因も記録に無い。runtime 設定は作業機ごとに管理するものと判断し、却下した。

## 影響

0043 の決定のうち、permissions profile を管理して実機の config へ統合する部分を置き換える。契約、skills、reviewer、Caveman、rules の配布は 0043 のまま続く。

reviewer は認証情報への独自の deny を持たない。この repo が配布するもののうち、認証情報の読み取りを止めるのは `dot_codex/AGENTS.md` の契約と reviewer 定義の停止線になる。作業機の config を chezmoi は作成・更新・削除しない。
