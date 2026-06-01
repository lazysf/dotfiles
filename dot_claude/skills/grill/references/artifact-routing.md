# Artifact Routing

request folder 内の artifact は工程ごとに責務を分ける。確定事項は責務に合う artifact へだけ反映する。

## ルーティング

- 元要求、背景、期待状態、再定義履歴: `request.md`
- 目的、背景 / 課題、scope / non-scope、`REQ-*`、`AC-*`、制約、前提、未確認事項: `requirements.md`
- 全体方針、責務分担、主要 component / module 境界、主要 interface / API / data flow、既存構造との接続点、security / 権限 / data / 外部 I/O: `basic-design.md`
- 処理手順、入出力、validation、error handling、edge case、状態遷移、test 観点: `detailed-design.md`
- `TASK-*`、実装順序、完了条件、確認方法、変更境界、リスク: `tasks.md`
- 対応 task、変更内容、変更ファイル、実装中に判明した事項: `implementation.md`
- `TC-*`、test / lint / build / manual check 結果、未確認事項、残リスク: `test.md`
- Gate の最終判定、reviewer、未解消リスク、ユーザー承認状態: `review.md`

## 判断

- 迷う場合は、後続工程の判断に必要な最上流 artifact へ置く。
- 実装方法は `requirements.md` に書かない。
- 実装ログやテスト結果は design artifact に書かない。
- 修正済み review finding の詳細ログは `review.md` に残さない。
- 広い調査が必要なら `researcher` を起動し、調査結果は後続 agent が担当 artifact へ吸収する。
