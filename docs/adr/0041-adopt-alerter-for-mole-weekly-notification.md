# 0041: mole 週次チェック通知に alerter を採用

- Status: Accepted

## 背景

dotfiles の launchd で月曜 9:00 に `mo clean --dry-run` を回し、通知を出す仕組みを `~/.config/mole/weekly-check.sh` に置いた。通知側で「クリーンアップ」「閉じる」2 ボタン UI を出して `mo clean` を user 操作で trigger したい要件があった。

## 決定

通知 backend に [alerter](https://github.com/vjeantet/alerter) (個人 tap `vjeantet/tap`、Swift CLI binary、active メンテ) を採用する。

## 検討した代替案

[terminal-notifier](https://github.com/julienXX/terminal-notifier) (homebrew-core、Objective-C 製、app bundle 持ち、2017 年以降メンテ停止) を最初に採用したが、action button 機能を持たず、本家が「action button が欲しいなら alerter を使え」と明言しているため不採用とした。

## 影響

- 個人 tap `vjeantet/tap` を信頼境界に含める。homebrew-core 由来ではないため、tap 所有者の GitHub アカウント乗っ取りや formula 書き換えのリスクは homebrew-core より高い。
- alerter の出力契約（action label を stdout に echo、`@TIMEOUT` / `@CLOSED` 等の sentinel で状態を伝える）に script が依存する。upstream が `--json` や activationType 形式に切り替えると selection 判定が壊れる。
- `mo clean` の non-interactive 契約に暗黙依存する。mole 側に `--yes` 相当のフラグが無いため、stdin を `</dev/null` で切断して呼んでいる。mole が interactive prompt を入れた場合は failsafe で no-op に倒れる前提。
- alerter は CLI binary で macOS app bundle を持たないため、システム設定の「通知」一覧には独立 entry が出ず、`--sender` default の `com.apple.Terminal` の傘下で扱われる。
