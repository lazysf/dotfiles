# Full Flow

## Phase 0: 受付・Triage

### 要求整理 / triage

- 扱い: 必須
- agent: lead
- artifact: `request.md`
- format: [request-format.md](../../scribe/references/request-format.md)
- 進め方: tier、scope、停止線、request folder を整理する。

## Phase 1: 調査・要件

### 初期調査

- 扱い: 必須
- agent: `researcher`
- artifact: handoff
- format: [handoff.md](handoff.md)
- 進め方: 既存コード、設定、docs、関連仕様、影響範囲、検証入口を確認する。設計や実装判断は確定しない。

### 要件定義

- 扱い: 必須
- agent: lead
- artifact: `requirements.md`
- format: [requirements-format.md](../../scribe/references/requirements-format.md)
- 進め方: lead が requirements skill を使い、目的、scope / non-scope、REQ-*、AC-*、制約、前提、未確認事項を整理する。実装方法や詳細設計は決めない。artifact は scribe で書く。

### 要件追加調査

- 扱い: 必要時
- agent: `researcher`
- artifact: handoff
- format: [handoff.md](handoff.md)
- 進め方: 要件定義中に不足した事実を確認する。

## Gate 1: 要件レビュー

### 要件レビュー

- 扱い: 必須
- agent: `requirements-reviewer`
- artifact: `review.md`
- format: [review-format.md](../../scribe/references/review-format.md)
- 進め方: `request.md` と `requirements.md` の整合をレビューする。pass 後、lead が要件、未確認事項、残リスク、Phase 2 で扱う範囲を確認し、ユーザー確認が必要な事項がなければ承認待ちを挟まず Phase 2 へ進む。

## Phase 2: 設計・計画

### 設計追加調査

- 扱い: 必要時
- agent: `researcher`
- artifact: handoff
- format: [handoff.md](handoff.md)
- 進め方: 設計判断に必要な既存構造、API、data flow、制約を確認する。

### 基本設計

- 扱い: 必須
- agent: lead
- artifact: `basic-design.md`
- format: [basic-design-format.md](../../scribe/references/basic-design-format.md)
- 進め方: lead が architecture skill を使い、全体方針、責務分担、主要 component / module 境界、主要 interface / API / data flow、既存構造との接続点、security / 権限 / data / 外部 I/O の扱いを書く。artifact は scribe で書く。

### 詳細設計

- 扱い: 必須
- agent: lead
- artifact: `detailed-design.md`
- format: [detailed-design-format.md](../../scribe/references/detailed-design-format.md)
- 進め方: lead が architecture skill を使い、処理手順、入出力、validation、error handling、edge case、状態遷移、test 観点を書く。artifact は scribe で書く。

### タスク分解

- 扱い: 必須
- agent: lead
- artifact: `tasks.md`
- format: [tasks-format.md](../../scribe/references/tasks-format.md)
- 進め方: lead が task-planning skill を使い、TASK-*、実装順序、完了条件、確認方法、変更境界を書く。artifact は scribe で書く。

## Gate 2: 設計レビュー

### 設計・security レビュー

- 扱い: 必須
- agent: `design-reviewer` / `security-reviewer`
- artifact: `review.md`
- format: [review-format.md](../../scribe/references/review-format.md)
- 進め方: 設計、task、security 観点を 2 人体制でレビューする。pass 後、lead が設計、task、Security-Relevant Actions、残リスク、Phase 3 で実行する範囲を確認し、ユーザー確認が必要な事項がなければ承認待ちを挟まず Phase 3 へ進む。

## Phase 3: 実装・検証・仕上げ

### Phase 3 entry condition

- 扱い: 必須
- agent: lead
- artifact: `requirements.md`, `basic-design.md`, `detailed-design.md`, `tasks.md`
- format: なし
- 進め方: Gate 2 pass 後、コードに着手する前に、次の上流 artifact を実際に Read で開いて確認する:
  - `requirements.md`: REQ-* / AC-* が確定し実装判断に足るか。
  - `basic-design.md`: 責務・境界・主要 interface が確定しているか。
  - `detailed-design.md`: 処理・I/O・validation・error handling が実装者として迷わない状態か。
  - `tasks.md`: 作業単位・完了条件・確認方法が具体的か。
- 確認した artifact 名と充足観点を `implementation.md` または `request.md` の冒頭に1行残してから着手する。痕跡を残していない実装着手は entry condition 未達として扱う。
- 確認の目的は、記憶や会話の流れでなく成果物そのものを実装の根拠にすること。Read で確認できない、または項目が未確定なら、着手せず Gate 2 以前へ戻すかユーザー確認する。実装結果から後付けで上流 artifact を作らない。

### 実装追加調査

- 扱い: 必要時
- agent: `researcher`
- artifact: handoff
- format: [handoff.md](handoff.md)
- 進め方: 実装中に出た不明点を確認する。調査結果が要件・設計・task の変更を必要とする場合は、Phase 3 内で吸収せず前工程へ戻す。

### 実装

- 扱い: 必須
- agent: lead
- artifact: `implementation.md`
- format: [implementation-format.md](../../scribe/references/implementation-format.md)
- 進め方: lead が implement skill を使い、Phase 3 entry condition を満たしたうえで、tasks.md と設計に沿って code / config / tests を実装し、対応 task、変更内容、変更ファイル、実行した確認、残リスクを書く。実装結果を根拠に上流 artifact を作り直さない。artifact は scribe で書く。

### 検証

- 扱い: 必須
- agent: `inspector`
- artifact: `test.md`
- format: [test-format.md](../../scribe/references/test-format.md)
- 進め方: `TC-*`、test / lint / build / manual check 結果、未確認事項、残リスクを書く。

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
- 進め方: 全変更セット（tracked diff、staged diff、secret-safe に確認した untracked summary）と handoff を 2 人体制でレビューする。pass 後、lead が変更内容、検証結果、残リスク、次アクションを確認し、ユーザー確認が必要な事項がなければ承認待ちを挟まず完了する。

## 追加 reference

- agent から最初の handoff を受け取る前に [handoff.md](handoff.md) を読む。
- 各 Gate 前に [gate-review.md](gate-review.md) を読む。
- Gate fail で自律修正する前に [autonomous-loop.md](autonomous-loop.md) を読む。

## ユーザー確認 checkpoint

- Gate pass は reviewer の判定であり、ユーザー承認ではない。
- Gate pass 後、lead は成果物、review 結果、残リスク、次工程または完了判断を確認し、ユーザー確認が必要な事項がなければ承認待ちを挟まず次工程または完了へ進む。
- Gate 1 pass 後は、要件、scope / non-scope、未確認事項にユーザー判断が必要な場合だけ提示して承認を得る。
- Gate 2 pass 後は、設計、task、Security-Relevant Actions、残リスク、Phase 3 で実行する範囲にユーザー判断が必要な場合だけ提示して承認を得る。停止線由来で `full` に倒した場合は、Phase 3 着手可否を確認する。
- Gate 3 pass 後は、変更内容、検証結果、未確認事項、残リスク、次アクションにユーザー判断が必要な場合だけ提示して承認を得る。

## 停止線

- 公開挙動系（ブロックA）/ command 系（ブロックB）の停止線は [stop-lines.md](stop-lines.md) のカタログに従い、実行、受容、Phase 3 着手判断はユーザー確認する。該当の可能性があればカタログ（stop-lines.md）を必ず開いて確認する。
- 要求・要望の再定義、change request 採否、scope / non-scope 変更、未解消リスク受容が必要ならユーザー確認する。
- secret を読んだ、生成した、移動した、削除した場合、値を出さずにユーザー確認する。
- 同じ Gate blocking が繰り返し残る場合はユーザー確認する。

## 調査の扱い

調査は独立成果物を持たない。`researcher` が handoff で事実を lead に返し、lead が後続 agent へ必要分だけ渡す。agent 間の直接通信は前提にしない。
