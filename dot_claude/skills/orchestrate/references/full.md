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
- agent: `requirements-engineer`
- artifact: `requirements.md`
- format: [requirements-format.md](../../scribe/references/requirements-format.md)
- 進め方: 目的、scope / non-scope、`REQ-*`、`AC-*`、制約、前提、未確認事項を整理する。実装方法や詳細設計は決めない。

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
- 進め方: `request.md` と `requirements.md` の整合をレビューする。pass 後、lead が要件、未確認事項、残リスク、Phase 2 で扱う範囲をまとめ、ユーザー承認を得てから Phase 2 へ進む。

## Phase 2: 設計・計画

### 設計追加調査

- 扱い: 必要時
- agent: `researcher`
- artifact: handoff
- format: [handoff.md](handoff.md)
- 進め方: 設計判断に必要な既存構造、API、data flow、制約を確認する。

### 基本設計

- 扱い: 必須
- agent: `architect`
- artifact: `basic-design.md`
- format: [basic-design-format.md](../../scribe/references/basic-design-format.md)
- 進め方: 全体方針、責務分担、主要 component / module 境界、主要 interface / API / data flow、既存構造との接続点、security / 権限 / data / 外部 I/O の扱いを書く。

### 詳細設計

- 扱い: 必須
- agent: `architect`
- artifact: `detailed-design.md`
- format: [detailed-design-format.md](../../scribe/references/detailed-design-format.md)
- 進め方: 処理手順、入出力、validation、error handling、edge case、状態遷移、test 観点を書く。

### タスク分解

- 扱い: 必須
- agent: `task-planner`
- artifact: `tasks.md`
- format: [tasks-format.md](../../scribe/references/tasks-format.md)
- 進め方: `TASK-*`、実装順序、完了条件、確認方法、変更境界を書く。

## Gate 2: 設計レビュー

### 設計・security レビュー

- 扱い: 必須
- agent: `design-reviewer` / `security-reviewer`
- artifact: `review.md`
- format: [review-format.md](../../scribe/references/review-format.md)
- 進め方: 設計、task、security 観点を 2 人体制でレビューする。pass 後、lead が設計、task、Security-Relevant Actions、残リスク、Phase 3 で実行する範囲をまとめ、ユーザー承認を得てから Phase 3 へ進む。

## Phase 3: 実装・検証・仕上げ

### 実装追加調査

- 扱い: 必要時
- agent: `researcher`
- artifact: handoff
- format: [handoff.md](handoff.md)
- 進め方: 実装中に出た不明点を確認する。

### 実装

- 扱い: 必須
- agent: `implementer`
- artifact: `implementation.md`
- format: [implementation-format.md](../../scribe/references/implementation-format.md)
- 進め方: `tasks.md` と設計に沿って code / config / tests を実装し、対応 task、変更内容、変更ファイル、実行した確認、残リスクを書く。

### 検証

- 扱い: 必須
- agent: `inspector`
- artifact: `test.md`
- format: [test-format.md](../../scribe/references/test-format.md)
- 進め方: `TC-*`、test / lint / build / manual check 結果、未確認事項、残リスクを書く。

### repository maintenance

- 扱い: 必須
- agent: `repository-maintainer`
- artifact: handoff
- format: [handoff.md](handoff.md)
- 進め方: docs / references / prose 追従と repo hygiene / tooling 影響を見る。request artifact の作成・更新は自分の `docs/requests/<slug>/` 配下だけに限定し、別の `docs/requests/<other-slug>/` と `docs/requests/<slug>/` 外の docs は read-only とする。過去 request や slug 外 docs の修正が必要に見える場合は、自分の `implementation.md` または `test.md` に残リスクとして記録し、ユーザー確認なしに編集しない。`blocked` の場合、lead は Gate 3 へ進めない。

## Gate 3: 完了レビュー

### 完了レビュー

- 扱い: 必須
- agent: `quality-reviewer` / `security-reviewer`
- artifact: `review.md`
- format: [review-format.md](../../scribe/references/review-format.md)
- 進め方: repository maintenance 後の全変更セット（tracked diff、staged diff、secret-safe に確認した untracked summary）と handoff を 2 人体制でレビューする。pass 後、lead が変更内容、検証結果、残リスク、次アクションをまとめ、ユーザー承認を得て完了する。

## 追加 reference

- agent から最初の handoff を受け取る前に [handoff.md](handoff.md) を読む。
- 各 Gate 前に [gate-review.md](gate-review.md) を読む。
- Gate fail で自律修正する前に [autonomous-loop.md](autonomous-loop.md) を読む。

## ユーザー承認 checkpoint

- Gate pass は reviewer の判定であり、ユーザー承認ではない。
- Gate 1 pass 後は、要件、scope / non-scope、未確認事項、Phase 2 へ進める理由を提示して承認を得る。
- Gate 2 pass 後は、設計、task、Security-Relevant Actions、残リスク、Phase 3 で実行する範囲を提示して承認を得る。停止線由来で `full` に倒した場合も、この checkpoint で Phase 3 着手可否を確認する。
- Gate 3 pass 後は、変更内容、検証結果、未確認事項、残リスク、次アクションを提示して承認を得る。

## 停止線

- 要求・要望の再定義、change request 採否、scope / non-scope 変更、未解消リスク受容が必要ならユーザー確認する。
- 公開挙動 / 公開 API / data format / 永続化 / auth / 権限 / secret handling に触れる実行、受容、Phase 3 着手判断はユーザー確認する。
- secret を読んだ、生成した、移動した、削除した場合、値を出さずにユーザー確認する。
- 新依存、破壊的操作、本番設定、runtime guardrail / CI permission / 外部送信 / deploy / publish に触れる実行、受容、Phase 3 着手判断はユーザー確認する。
- command / script / hook / workflow の実行入口、権限、失敗条件、外部 I/O、security boundary、validation 境界、injection / path traversal、security-sensitive data flow に触れる実行、受容、Phase 3 着手判断はユーザー確認する。
- `repository-maintainer` が `blocked` を返した場合、Gate 3 へ進めない。
- 同じ Gate blocking が繰り返し残る場合はユーザー確認する。

## 調査の扱い

調査は独立成果物を持たない。`researcher` が handoff で事実を lead に返し、lead が後続 subagent へ必要分だけ渡す。subagent 間の直接通信は前提にしない。
