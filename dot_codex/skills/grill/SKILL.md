---
name: grill
description: 要件整理、仕様化、設計、実装計画の前に、scope、成功条件、制約、検証入口、実装 readiness を対話で固める時に使う。関連する未確認事項を 1〜3 問にまとめて確認し、確定事項だけを doc / artifact に最小反映する。事実調査は `research`、docs 更新は `scribe`、差分作成は `implement`。
metadata:
  short-description: 共有理解の問い詰め
---

# Grill

実装や文書化に入る前に、共有理解へ到達するまで問い詰める。
往復の無駄とループを避けるため、関連する未確認事項は 1〜3 問にまとめて聞く。
回答ごとに確定事項、仮定、未確認事項を分け、確定事項だけを適切な doc / artifact に最小反映する。

## 手順

- 依頼を短く言い換え、目的、作る成果物、今回扱わないことを置く。
- `CONTEXT-MAP.md` / `CONTEXT.md`、docs、ADR、近傍 code、既存 tests で答えられる前提は先に確認する。
- 確定事項を request folder のどの artifact に反映するか決める時は、反映先の判断基準を [references/artifact-routing.md](references/artifact-routing.md) に置いているため、反映の前に読む。
- 要件（scope・成功条件・制約・受入条件）を詰める時は、確認すべき観点を [references/requirements-heuristics.md](references/requirements-heuristics.md) に置いているため、質問を組み立てる前に読む。
- 技術計画や実装方針を詰める時は、確認すべき観点を [references/implementation-heuristics.md](references/implementation-heuristics.md) に置いているため、質問を組み立てる前に読む。
- 最も影響が大きい未確認事項を中心に、関連する 1〜3 問をまとめて質問し、各問に推奨回答を添える。互いに依存して順序が崩れる問いは、先行する問いの回答を待ってから次を聞く。
- 回答を受けたら、確定事項、仮定、未確認事項、docs 更新候補を分ける。
- 確定事項は、置き場と形式が明確な場合だけ doc / artifact へ最小反映する。
- 責務外の内容は対象 artifact に書かない。
- 共有理解に到達するまで、未確認事項を 1〜3 問ずつ詰める。
- 実装へ進む前に、scope、成功条件、変更境界、検証入口、未確認事項、残リスクを明示する。

## 反映

- 小さい追記や未確認事項の移動は `grill` でよい。
- 新規 artifact、本格 docs 更新、format / ID / traceability 整理は `scribe`。
- `CONTEXT.md` は glossary として扱い、spec、作業メモ、実装判断、秘密情報を混ぜない。
- 既存 docs や note を更新する場合は、会話中に確認された evidence に限定し、自然な置き場が不明なら質問を続ける。
- ADR は作成や状態更新を提案してから `scribe` で扱う。
- `未確認事項` は確認済み知識として `CONTEXT.md`、ADR、notes に昇格させない。
- 秘密情報、認証情報、private config、未公開個人情報は durable artifact に残さない。

## 境界

- 事実調査は `research`。
- architecture 候補探索は `architecture`。
- docs 本文更新は `scribe`。
- 差分作成やテスト実装は `implement`。
- multi-agent workflow として進める時は `orchestrate`。
- Gate review は `requirements-reviewer`、`design-reviewer`、`quality-reviewer`、`security-reviewer` reviewer agent を使う。

## 出力

- `confirmed_context`
- `scope`
- `non_scope`
- `updated_docs`
- `open_questions`
- `readiness`
- `next_questions`

`confirmed_context` と `open_questions` を混ぜず、未確認事項を確認済み前提として扱わない。
`next_questions` は次に聞く 1〜3 問をまとめて置く。

## 停止条件

- scope、成功条件、目的がユーザー回答後も収束せず、問い詰めが進展しない。
- 停止線に触れる判断（公開挙動、権限、secret、本番設定、破壊的操作）が必要。
