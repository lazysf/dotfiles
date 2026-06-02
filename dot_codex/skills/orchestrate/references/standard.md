# Standard Flow

## Phase 0: 受付・Triage

### 要求整理 / triage

- 扱い: 必須
- agent: lead
- artifact: `request.md`
- format: [request-format.md](../../scribe/references/request-format.md)
- 進め方: tier、scope、acceptance、request folder を整理する。`requirements.md` / `basic-design.md` / `detailed-design.md` / `tasks.md` を省略する場合でも、Phase 3 着手前に `request.md` へ省略理由、実装境界、検証入口を残す。

## Phase 1: 調査・要件

### 初期調査

- 扱い: 任意
- agent: `researcher`
- artifact: handoff
- format: [handoff.md](handoff.md)
- 進め方: 既存事実、影響範囲、検証入口が不明な場合だけ調査する。

### 要件整理

- 扱い: 任意
- agent: lead
- artifact: `requirements.md`
- format: [requirements-format.md](../../scribe/references/requirements-format.md)
- 進め方: 軽量なら `request.md` に scope / acceptance を残すだけでよい。

## Phase 2: 設計・計画

### 設計追加調査

- 扱い: 任意
- agent: `researcher`
- artifact: handoff
- format: [handoff.md](handoff.md)
- 進め方: 設計判断に不足する既存構造や制約がある場合だけ調査する。

### 基本設計

- 扱い: 任意
- agent: lead
- artifact: `basic-design.md`
- format: [basic-design-format.md](../../scribe/references/basic-design-format.md)
- 進め方: 複数 file や軽い設計判断がある場合に軽量に作る。

### 詳細設計

- 扱い: 必要時
- agent: lead
- artifact: `detailed-design.md`
- format: [detailed-design-format.md](../../scribe/references/detailed-design-format.md)
- 進め方: 詳細な処理順、状態、edge case が必要な場合だけ作る。

### タスク分解

- 扱い: 必要時
- agent: lead
- artifact: `tasks.md`
- format: [tasks-format.md](../../scribe/references/tasks-format.md)
- 進め方: 実装順序や完了条件を分ける必要がある場合だけ作る。

## Phase 3: 実装・検証・仕上げ

### Phase 3 entry condition

- 扱い: 必須
- agent: lead
- artifact: `request.md` または Phase 1 / 2 artifact
- format: なし
- 進め方: 実装前に、上流 artifact が今回の実装範囲を判断できる状態で確定していることを確認する。`requirements.md` / `tasks.md` を省略した場合は、`request.md` の scope / acceptance / 実装範囲 / 省略理由を trace 元にする。実装中または実装後に上流 artifact 不足が判明した場合は、後付けで成果物を作らず Phase 1 / 2 へ戻すか、ユーザー確認する。

### 実装

- 扱い: 必須
- agent: lead
- artifact: `implementation.md`
- format: [implementation-format.md](../../scribe/references/implementation-format.md)
- 進め方: Phase 3 entry condition を満たしたうえで、合意済み scope と設計に沿って code / config / tests を変更する。実装結果を根拠に上流 artifact を作り直さない。

### 検証

- 扱い: 必須
- agent: lead / `inspector`
- artifact: `test.md`
- format: [test-format.md](../../scribe/references/test-format.md)
- 進め方: test / lint / build / manual check と残リスクを確認する。`tasks.md` を省略した場合は `request.md` の scope / acceptance / 実装範囲へ trace する。

### Gate 3 前 docs 確認

- 扱い: 必要時
- agent: lead
- artifact: なし、または request.md / implementation.md の自然な節
- format: なし
- 進め方: lead が必要時に doc-followup skill を使って docs / references / prose の追従更新と参照ずれ確認を行う。request artifact は自分の `docs/requests/<slug>/` 配下だけ編集する。Gate 3 着手前に確認結果と残リスクを request.md または implementation.md に短くまとめる。

## Gate 3: 完了レビュー

### 完了レビュー

- 扱い: 必須
- agent: `quality-reviewer` / `security-reviewer`
- artifact: `review.md`
- format: [review-format.md](../../scribe/references/review-format.md)
- 進め方: `quality-reviewer` は必須。Gate 3 前に Triage 停止線と Security-Relevant Actions を再評価し、該当、missing、unknown のいずれかなら `security-reviewer` も起動する。pass 後、lead が変更内容、検証結果、残リスク、次アクションを確認し、ユーザー確認が必要な事項がなければ承認待ちを挟まず完了する。

## 追加 reference

- agent から最初の handoff を受け取る前に [handoff.md](handoff.md) を読む。
- Gate 3 前に [gate-review.md](gate-review.md) を読む。
- Gate fail で自律修正する前に [autonomous-loop.md](autonomous-loop.md) を読む。

## 停止線

- 公開挙動系（ブロックA）/ command 系（ブロックB）の停止線は [stop-lines.md](stop-lines.md) のカタログに従い、`full` に移し、実行、受容、Phase 3 着手前にユーザー確認する。該当の可能性があればカタログ（stop-lines.md）を必ず開いて確認する。
- scope / non-scope 変更、change request 採否、未解消リスク受容が必要ならユーザー確認する。
- runtime guardrail / CI permission / secret / auth / 権限 / 外部送信 / deploy / publish / command / script / hook / workflow / validation 境界 / injection / path traversal に触れる blocker は、自律差戻しせずユーザー確認または change-request 候補にする。
- 同じ Gate blocking が繰り返し残る場合はユーザー確認する。

## Notes

- `requirements.md` / `basic-design.md` は必要時のみ軽量に作る。軽量 standard では `request.md` に scope / acceptance を残してよい。
- `detailed-design.md` とタスク分解は必要時のみ。
- `requirements.md` / `tasks.md` を省略した場合、`implementation.md` / `test.md` / Gate 3 は、実装前に確定した `request.md` の scope / acceptance / 実装範囲 / 省略理由を trace 元にする。
- 実装後に作る `implementation.md` / `test.md` は記録と検証用であり、実装可否を判断する上流 artifact の代替にしない。
- standard の Gate は Gate 3 のみ。`quality-reviewer` 必須、Triage 停止線または Security-Relevant Actions が該当、missing、unknown の場合は `security-reviewer` 追加。
- Phase / Gate ごとの完了報告は不要。Gate 3 pass 時に変更内容・検証結果・未確認事項・次アクションをまとめ、ユーザー確認が必要な事項がなければ承認待ちを挟まず完了する。
