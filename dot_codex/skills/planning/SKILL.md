---
name: planning
description: 実装、機能追加、リファクタ、設定変更、設計変更、振る舞い変更に入る前に必ず使う。ユーザー意図、目的、成功条件、要件、制約、設計、実装順序、検証方法を一問ずつ確認し、合意済みの計画、成果物、durable knowledge へ整理する。バグ原因や外部変化の事実調査は `research` スキル、差分作成は `implementation` スキルを使う。
metadata:
  short-description: 計画作成
---

# 計画作成

計画や設計を、共有理解に到達するまで一問ずつ問い詰める。docs-aware な依頼では、既存の domain language、docs、ADR、code と照合し、確定した durable knowledge だけをその場で反映する。

## 手順

- 依頼を短く言い換え、目的、作る成果物、今回扱わないことを置く。
- `CONTEXT-MAP.md` / `CONTEXT.md`、関連 docs、ADR、近傍 code、既存 tests で答えられる前提は先に確認する。
- 最も影響が大きい未確定事項を 1 つ選ぶ。
- 質問は 1 つだけ出し、必ず推奨回答を添える。
- 複数案が自然に出る場合は、2-3 案、trade-off、推奨案を短く示す。
- 回答を受けたら、確定事項、仮定、未確定事項、docs 更新候補を分ける。
- 共有理解に到達するまで、最も影響が大きい未確定事項を 1 つずつ詰める。
- 十分に固まったら、必要な成果物や実装前計画にまとめる。迷う時は [references/artifact-workflows.md](references/artifact-workflows.md) を読む。
- 成果物本文を書く時は、対象 format reference に従う。
- draft を出したら、scope、矛盾、曖昧語、未確認事項、検証方法を self-review し、必要なら修正する。
- 実装へ進む前に、未確定事項と残リスクを明示する。

## 成果物

- PRD: [references/prd-format.md](references/prd-format.md)
- 要件定義: [references/requirements-format.md](references/requirements-format.md)
- 基本設計: [references/basic-design-format.md](references/basic-design-format.md)
- 詳細設計: [references/detailed-design-format.md](references/detailed-design-format.md)
- 実装計画: [references/implementation-plan-format.md](references/implementation-plan-format.md)
- テストケース: [references/test-case-format.md](references/test-case-format.md)
- traceability matrix: [references/traceability-matrix-format.md](references/traceability-matrix-format.md)
- CONTEXT: [references/context-format.md](references/context-format.md)
- ADR: [references/adr-format.md](references/adr-format.md)

## 補助

- 要件整理の観点で迷う時は [references/requirements-heuristics.md](references/requirements-heuristics.md) を読む。
- 技術計画の観点で迷う時は [references/implementation-heuristics.md](references/implementation-heuristics.md) を読む。

## 境界

- バグ原因、再現条件、外部変化の事実調査だけなら `research` スキルを使う。
- architecture 改善候補の探索なら `architecture` スキルを使う。
- 差分作成やテスト実装は `implementation` スキルを使う。
- 品質 review は `quality-reviewer`、security review は `security-reviewer` reviewer agent を使う。

## Durable Knowledge

- docs 更新なしの planning では、変更実装や docs 更新を行わない。
- `CONTEXT.md` は glossary であり、spec、作業メモ、実装判断、秘密情報を混ぜない。
- 工程成果物は `CONTEXT.md` や ADR に同じ内容を重複記録しない。
- `CONTEXT.md` を更新する時は [references/context-format.md](references/context-format.md) に従う。
- 用語が確定したら、対象 context の `CONTEXT.md` を inline 更新する。
- ADR は、あとから変えるコスト、文脈なしの意外性、実際の trade-off の 3 条件を満たす場合だけ扱う。
- ADR を作成または状態更新する時は [references/adr-format.md](references/adr-format.md) に従う。
- ADR 作成や状態更新は、提案してから実行する。
- 既存 docs や note を更新する場合は、会話中に確認された evidence に限定し、自然な置き場が不明なら確認する。
- 成果物の `Open Questions` に残すべき未確定事項は、確認済み知識として `CONTEXT.md`、ADR、notes に昇格させない。
- 秘密情報、認証情報、private config、未公開個人情報は durable artifact に残さない。

## 出力

- `artifact_type`
- `confirmed_context`
- `scope`
- `non_scope`
- `draft`
- `traceability_updates`
- `resolved_terms`
- `updated_docs`
- `adr_changes`
- `open_questions`
- `docs_update_candidates`
- `next_step`

`confirmed_context` と `open_questions` を混ぜず、未確認事項を確認済み前提として扱わない。
