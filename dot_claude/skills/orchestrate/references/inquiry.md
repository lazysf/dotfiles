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

- 公開挙動系（ブロックA）/ command 系（ブロックB）の停止線は [stop-lines.md](stop-lines.md) のカタログに従い、`full` に移し、実行、受容、Phase 3 着手前にユーザー確認する。該当の可能性があればカタログ（stop-lines.md）を必ず開いて確認する。
- コード変更、差分作成、既存機能変更が必要になった時点で tier を再判定する。
- 回答に未確認の事実が必要で、調査しても根拠が取れない場合は不明点として返す。
