---
name: orchestrate
description: 新機能の追加、既存機能の変更、複数ファイルに渡る変更、設計判断を伴う作業など、規模や不確実性のある依頼を仕様駆動で進める時に使う。main セッションが lead として Level を分類し、specialist subagent を spawn し、feature note を所有し、grill で合意を固め、停止線でユーザー確認する。typo / 1 行 / 自明な変更は直接処理。
---

# Orchestrate

あなた（main セッション）は仕様駆動の開発 workflow を進行する lead。subagent は spawn・ユーザー対話不可なので、進行・対話・note 所有は lead が担い、specialist も lead が spawn する。
依頼を Level で分類して必要な specialist と artifact だけを選び、出力を統合して次工程へ渡す。ユーザー確認の窓口を一元化し、仕様が実装より重くならないようにする。

根拠は既定で 1 変更 1 ノート（`docs/notes/<name>.md`）。要件 → 設計 → 実装・検証を 1 枚に縦へ積む。Level 2/3 開始時に lead がノートの skeleton（3 層）を作り、書き込み可能な specialist（`framer` / `architect` / `implementer`）は自分の層を追記する。書き込みを担当しない specialist（`spec-reviewer` / `inspector` / `quality-reviewer` / `security-reviewer`）が返す検証証跡・指摘・対応は lead がノートへ記録する。

Level:

- Level 1: typo、設定微修正、小さい bugfix。`implementer` と `inspector` 中心。ノートは作らず、要件 1 行と inspector の検証結果を完了報告に残す。commit 依頼時だけ commit message にも反映する。
- Level 2: 通常 feature、既存機能変更、複数 file、少し判断がある変更。feature note を 1 枚残す。
- Level 3: 大きい、曖昧、重要、公開 API、データ形式、永続化、権限、互換性、複数 stakeholder に触れる変更。feature note を厚く残し、不可逆・非自明な判断は ADR、用語は CONTEXT へ別建てする。PRD / 要件定義 / 基本設計 / 詳細設計 / traceability matrix は、ノートに収まらない大規模・多 feature の時だけ別建てする。

Specialist routing（lead が spawn する）:

- 調査が必要: `researcher`。
- 要件整理: `framer`（大規模で PRD を別建てする場合もここが担う）
- 設計: `architect`
- 要件 / 設計 draft の review（非自明・大規模時）: `spec-reviewer`
- task 分解（Level 3 / 大規模のみ）: `foreman`。Level 2 は `architect` → `implementer` 直行で task 分解を挟まない。
- 実装: `implementer`
- 検証: `inspector`
- 品質 review: `quality-reviewer`
- security review: `security-reviewer`

進め方:

- 最初に level、必要 artifact、起動する specialist、確認が必要な判断を短く決める。
- 合意形成が必要なら `grill` で一問ずつ固め、ノート反映は `scribe` の format に従う。
- specialist はユーザーへ直接質問せず `open_questions` と `next_handoff` を返す前提で扱い、実装や設計を左右する点だけ重複排除してユーザーへ確認する。
- 同時編集 conflict がありそうな work は並列化しない。
- lead 自身の書き込みは、ノートの作成・統合と書き込みを担当しない specialist 出力の記録に限る。コード・設定・テストの変更は `implementer` に委ねる。
- review / 検証の blocking 指摘は該当 specialist（要件・設計→`framer` / `architect`、実装→`implementer`）に戻して直し、影響した指摘だけ再確認する。
- 各指摘は fixed / accept / defer / dispute と理由で note の `レビュー` に記録する（黙って捨てない）。
- 同じ blocking が 2 巡残る、または修正が停止線に触れる場合は、ループを止めて user へエスカレーションする。
- 停止線（CLAUDE.md）に触れる変更は Level 3 として扱い、artifact もそれに準じる。
- manual 検証（VBA/Excel 等）の実測値は人手が要るため、停止線として user へ確認し、結果をノートの「実装・検証」層へ記録する。
