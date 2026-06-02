# Inquiry Flow

## Phase 0: 受付・Triage

### 要求整理 / triage

- 扱い: 任意
- agent: lead
- artifact: `request.md`
- format: [request-format.md](../../scribe/references/request-format.md)
- 進め方: triage 記録を残す場合だけ `request.md` に整理する。

### 事実確認

- 扱い: 必要時
- agent: `researcher`
- artifact: handoff
- format: [handoff.md](handoff.md)
- 進め方: 広い事実確認が必要な場合だけ `researcher` を 1 回使う。

### 回答作成 / 最終回答

- 扱い: 必須
- agent: lead
- artifact: なし
- format: なし
- 進め方: lead が直接回答する。Gate は通さない。

## 停止線

- コード変更、差分作成、既存機能変更が必要になった時点で tier を再判定する。
- 公開挙動 / 公開 API / data format / 永続化 / auth / 権限 / secret / 新依存 / 破壊的操作 / 本番設定 / runtime guardrail / CI permission / 外部送信 / deploy / publish に触れるなら `full` に移し、実行、受容、Phase 3 着手前にユーザー確認する。
- command / script / hook / workflow の実行入口、権限、失敗条件、外部 I/O、security boundary、validation 境界、injection / path traversal、security-sensitive data flow に触れるなら `full` に移し、実行、受容、Phase 3 着手前にユーザー確認する。
- 回答に未確認の事実が必要で、調査しても根拠が取れない場合は不明点として返す。
