# Micro Flow

## Phase 0: 受付・Triage

### 要求整理 / triage

- 扱い: 任意
- agent: lead
- artifact: `request.md`
- format: [request-format.md](../../scribe/references/request-format.md)
- 進め方: request folder を作る場合だけ `request.md` に整理する。

## Phase 3: 実装・検証・仕上げ

### 実装着手前確認

- 扱い: 必須
- agent: lead
- artifact: なし（request folder がある場合は `request.md` の節）
- format: なし
- 進め方: コードに着手する前に、変更対象ファイルの現状と、何をなぜ変えるか（request 相当の意図）を Read で確認する。request folder を作らない場合は確認内容を最終出力にも反映する。確認の結果、複数 file・設計判断・影響調査が要ると分かったら `standard` 以上へ移す。

### 実装

- 扱い: 必須
- agent: lead
- artifact: `implementation.md`
- format: [implementation-format.md](../../scribe/references/implementation-format.md)
- 進め方: lead が直接実装する。必要なら該当 skill を使う。request folder を作らない場合、artifact は作らず最終出力に変更内容と確認結果をまとめる。`implementation.md` / `test.md` は記録用であり、着手判断の根拠は事前確認に置く。

### 自己確認

- 扱い: 必須
- agent: lead
- artifact: `test.md` または最終出力
- format: [test-format.md](../../scribe/references/test-format.md)
- 進め方: lead が意図外差分、未確認リスク、scope ずれを確認する。Gate はない。request folder を作る場合だけ `test.md` を使う。

### Gate 3 前 docs 確認

- 扱い: 任意
- agent: lead
- artifact: なし、または request.md / implementation.md の自然な節
- format: なし
- 進め方: lead が必要時に doc-followup skill を使って docs / references / prose の追従更新と参照ずれ確認を行う。request folder を作る場合、artifact の作成・更新は自分の `docs/requests/<slug>/` 配下だけに限定し、別の `docs/requests/<other-slug>/` と `docs/requests/<slug>/` 外の docs は read-only とする。

## 停止線

- 公開挙動系（ブロックA）/ command 系（ブロックB）の停止線は [stop-lines.md](stop-lines.md) のカタログに従い、`full` に移し、実行、受容、Phase 3 着手前にユーザー確認する。該当の可能性があればカタログ（stop-lines.md）を必ず開いて確認する。
- 複数 file、設計判断、影響調査が必要になったら `standard` 以上へ移す。
- 自己確認で意図外差分、未確認リスク、scope ずれが出たら完了扱いにしない。
