# Stop Lines Catalog

このカタログは orchestrate 停止線で列挙する語・遷移句・standard / full 境界判定の正本。各停止線セクションはここを参照し、tier 固有差分のみ各自で持つ。tier 固有差分・ループ制御語はここに置かない。該当の可能性があればこのカタログを必ず開いて確認する。

## ブロックA: 公開挙動系

公開挙動 / 公開 API / data format / 永続化 / auth / 権限 / secret / 新依存 / 破壊的操作 / 本番設定 / runtime guardrail / CI permission / 外部送信 / deploy / publish。

## ブロックB: command 系

command / script / hook / workflow の実行入口 / 権限 / 失敗条件 / 外部 I/O / security boundary / validation 境界 / injection / path traversal / security-sensitive data flow。

## 遷移句テンプレ

- Triage 用: 「`full` に倒す。read-only 調査と artifact 作成は進めてよいが、実行、受容、Phase 3 着手の前にユーザー確認する。」
- 各 tier 用（standard / micro / inquiry）: 「`full` に移し、実行、受容、Phase 3 着手前にユーザー確認する。」
- full 用: 「実行、受容、Phase 3 着手判断はユーザー確認する。」

## standard / full 境界判定

- 明示基準:
  - (a) ブロックA / ブロックB の語に触れるなら常に `full`。
  - (b) 触れない前提で、複数 file でも機械的・等価変換的で公開挙動・interface・data flow を変えないなら `standard`。
  - (c) 公開挙動・interface・data flow・永続化・互換性の設計判断を要するなら `full`。
- 判定例:
  - 「複数 file の文言一括置換で挙動不変」= `standard`。
  - 「複数 file だが 1 つでも公開 interface / data format を変える」= `full`。
  - 「軽い設計判断（既存パターン内の小さな選択で公開挙動不変）」= `standard`。
  - 「軽い設計判断に見えても新 interface / 新依存 / 互換性影響を含む」= `full`。
