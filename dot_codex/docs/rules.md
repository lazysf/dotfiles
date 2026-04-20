# Rules の原則

`rules/` は、Codex が shell 実行で踏み外しやすい操作を機械的にガードする層です。

## 目的

- 日常的で安全な操作は allow する
- 影響範囲が大きい操作は prompt で止める
- 明確に避けるべき操作は forbidden にする

## 基本方針

- 読み取り専用の確認操作は allow を検討する
- 破壊的、広域、副作用の大きい操作は prompt を優先する
- 履歴破壊や危険な既定操作は forbidden を検討する
- 複数 rule が一致する場合は、より厳しい判定を期待する

## 追加時の考え方

- 既存の rule と粒度をそろえる
- 1 file 1 intent を基本にする
- `match` と `not_match` の例は、判断を誤りやすいものから書く
- 広すぎる allow を避ける

## 重点監視対象

- Git の履歴改変や worktree 破壊
- package manager による依存追加
- 権限昇格、削除、外部接続
