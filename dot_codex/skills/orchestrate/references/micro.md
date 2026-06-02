# Micro Flow

## Phase 0: 受付・Triage

### 要求整理 / triage

- 扱い: 任意
- agent: lead
- artifact: `request.md`
- format: [request-format.md](../../scribe/references/request-format.md)
- 進め方: request folder を作る場合だけ `request.md` に整理する。

## Phase 3: 実装・検証・仕上げ

### 実装

- 扱い: 必須
- agent: lead / `implementer`
- artifact: `implementation.md`
- format: [implementation-format.md](../../scribe/references/implementation-format.md)
- 進め方: lead が直接実装する。必要なら `implementer` か該当 skill を使う。request folder を作らない場合、artifact は作らず最終出力に変更内容と確認結果をまとめる。

### 自己確認

- 扱い: 必須
- agent: lead
- artifact: `test.md` または最終出力
- format: [test-format.md](../../scribe/references/test-format.md)
- 進め方: lead が意図外差分、未確認リスク、scope ずれを確認する。Gate はない。request folder を作る場合だけ `test.md` を使う。

### repository maintenance

- 扱い: 任意
- agent: lead / `repository-maintainer`
- artifact: handoff または最終出力
- format: [handoff.md](handoff.md)
- 進め方: docs / references / prose 追従や repo hygiene 確認が必要な場合だけ行う。

## 停止線

- 複数 file、設計判断、影響調査が必要になったら `standard` 以上へ移す。
- 公開挙動 / 公開 API / data format / 永続化 / auth / 権限 / secret / 新依存 / 破壊的操作 / 本番設定 / runtime guardrail / CI permission / 外部送信 / deploy / publish に触れるなら `full` に移し、実行、受容、Phase 3 着手前にユーザー確認する。
- command / script / hook / workflow の実行入口、権限、失敗条件、外部 I/O、security boundary、validation 境界、injection / path traversal、security-sensitive data flow に触れるなら `full` に移し、実行、受容、Phase 3 着手前にユーザー確認する。
- 自己確認で意図外差分、未確認リスク、scope ずれが出たら完了扱いにしない。
