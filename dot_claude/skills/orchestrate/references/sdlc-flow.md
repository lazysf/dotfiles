# SDLC Flow

AI 駆動開発 / 仕様駆動開発の基本フローは、Phase 0〜3 と Gate 1〜3 で進める。

## Phase 0: 要求・要望入力

lead がユーザーの要求、背景、期待状態、不明点を受け取り、`request.md` に整理する。

## Phase 1: 要件フェーズ

1. 初期調査: `analyst`
   - 既存コード、設定、docs、関連仕様を確認する。
   - 類似実装、既存パターン、既存 test / lint / build 入口を確認する。
   - 影響範囲と停止線に触れそうな点を把握する。
   - 設計や実装判断は確定しない。

2. 要件定義: `requirements-engineer`
   - `requirements.md` に目的、背景、scope / non-scope、`REQ-*`、`AC-*`、制約、前提、未確認事項を整理する。
   - 実装方法や詳細設計を決めない。

3. 必要時の追加調査: `analyst`
   - 要件定義中に不足した事実を確認する。

## Gate 1: 要件レビュー

`requirements-reviewer` が `request.md` と `requirements.md` を確認する。

pass 後、ユーザー確認が必要な事項がなければ Phase 2 へ進む。

## Phase 2: 設計フェーズ

1. 必要時の追加調査: `analyst`
   - 設計判断に必要な既存構造、API、data flow、制約を確認する。

2. 基本設計 / 詳細設計: `architect`
   - `basic-design.md` に全体方針、責務分担、主要 component / module 境界、主要 interface / API / data flow、既存構造との接続点、security / 権限 / data / 外部 I/O の扱いを書く。
   - `detailed-design.md` に処理手順、入出力、validation、error handling、edge case、状態遷移、test 観点を書く。

3. タスク分解: `task-planner`
   - `tasks.md` に `TASK-*`、実装順序、完了条件、確認方法、変更境界を書く。

## Gate 2: 設計レビュー

`design-reviewer` と `security-reviewer` の 2 人体制で review する。

pass 後、ユーザー確認が必要な事項がなければ Phase 3 へ進む。

## Phase 3: 実装・テストフェーズ

1. 必要時の追加調査: `analyst`
   - 実装中に出た不明点を確認する。

2. 実装: `developer`
   - `tasks.md` と設計に沿って code / config / tests を実装する。
   - `implementation.md` に対応 task、変更内容、変更ファイル、実行した確認、残リスクを書く。

3. 検証: `verifier`
   - `test.md` に `TC-*`、test / lint / build / manual check 結果、未確認事項、残リスクを書く。

4. repository maintenance: `repository-maintainer`
   - 実装差分、追加 / rename / delete された file、変更された skill / agent / docs / tooling 設定を確認する。
   - docs / references / prose の追従更新を行う。
   - repo hygiene / tooling 設定は影響確認し、必要な変更は handoff / blocker / review_focus に返す。
   - 結果、追従不要の理由、Gate 3 で見るべき影響を handoff に残す。
   - tooling の `behavior_delta` が `changed` の場合は Gate 3 へ進む前に `verifier` へ戻し、影響する check と `test.md` を更新する。
   - `repository-maintainer` が `blocked` を返した場合、lead は Gate 3 へ進めない。runtime guardrail / CI permission / secret / auth / 権限 / 外部送信 / deploy / publish に触れる blocker は、前工程へ自律差戻しせずユーザー確認または change-request 候補にする。

## Gate 3: 完了レビュー

`quality-reviewer` と `security-reviewer` の 2 人体制で review する。

Gate 3 では repository maintenance 後の全変更セット（tracked diff、staged diff、untracked file list / content）と handoff を review 入力に含める。pass 後、ユーザー確認が必要な事項がなければ完了する。

## 調査の扱い

調査は独立成果物を持たない。`analyst` が handoff で事実を返し、後続 agent が担当 artifact に必要分だけ吸収する。
