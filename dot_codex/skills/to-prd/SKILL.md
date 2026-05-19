---
name: to-prd
description: 「PRD を作りたい」「この会話を要求文書にして」「要望を明文化したい」といった、既に話した内容を PRD draft にまとめる依頼で使う。目的、成功条件、範囲、非範囲、未確定事項を整理する。要件をまだ問いで固める時は `product-planning` スキルを使う。
metadata:
  short-description: PRD draft 作成
---

# PRD Draft 作成

会話や既存 context から、後続開発で参照できる PRD draft を作る。

## 手順

- PRD は正式な要求文書になりうるが、この skill で生成した時点では draft として扱う。
- PRD 化する範囲を一文で言い換える。
- 会話、`CONTEXT-MAP.md` / `CONTEXT.md`、関連 docs、ADR、必要な近傍 code から確認済み事実を集める。
- 目的、対象利用者、成功条件、範囲、非範囲、制約、未確定事項を分ける。
- PRD の詳細テンプレートが必要な時は `references/prd-template.md` を読む。
- 未確認事項、採用判断、保存先、issue 化、docs 反映は `Open Questions` または次アクションとして分離する。

## 境界

- 追加の聞き取りを前提にせず、確認済みの会話、context、docs、codebase の事実から統合整理する。
- 変わりやすい file path や code snippet は原則入れない。判断を最も明確に表せる場合だけ短く使う。
- 目的や成功条件がまだ曖昧なら `product-planning` スキルを使う。
- 実装順序、影響範囲、検証方法を詰める時は `implementation-planning` スキルを使う。
- PRD の採用判断、docs 反映、ADR 作成まで進める時は `grill-with-docs` スキルを使う。
- repo の正式要求文書として保存する、issue 化する、外部 issue tracker へ公開する、といった durable 化はユーザーが明示した場合だけ扱う。

## 出力

- `title`
- `problem`
- `goals`
- `success_criteria`
- `scope`
- `non_goals`
- `user_stories`
- `requirements`
- `constraints`
- `implementation_notes`
- `testing_notes`
- `open_questions`

PRD draft を作る依頼では、この項目を自然な Markdown 見出しとして整える。未確認事項は決め打ちせず `Open Questions` に残す。
