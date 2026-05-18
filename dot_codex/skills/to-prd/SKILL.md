---
name: to-prd
description: 「PRD を作りたい」「この会話を要求文書にして」「要望や要求要件を明文化したい」といった、既に話した内容を PRD draft にまとめる依頼で使う。会話、既存 context、関連 docs、codebase 理解から、目的、成功条件、範囲、非範囲、未確定事項を要求文書として整理する。要件をまだ問いで固めたい時は `product-planning` スキル、docs や ADR と照合更新したい時は `grill-with-docs` スキルを使う。
metadata:
  short-description: PRD draft 作成
---

# To PRD

会話や既存 context から、後続開発で参照できる PRD draft を作る。

## 前提

- PRD は正式な要求文書になりうるが、この skill で生成した時点では draft として扱う。
- repo の正式要求文書として保存する、issue 化する、既存 docs に反映する、といった durable 化は、ユーザーが明示した場合だけ扱う。
- root に `CONTEXT-MAP.md` があれば対象 context を選び、該当 `CONTEXT.md`、関連 docs、ADR を読む。
- PRD の詳細テンプレートが必要な時は `references/prd-template.md` を読む。

## 対象

- 現在の会話を PRD draft に変換したい依頼。
- 要望、背景、成功条件、範囲、非範囲、未確定事項を要求文書として明文化したい依頼。
- product planning 済みの内容を、後続の実装計画や review に渡せる文書へ整える依頼。

## 対象外

- 目的や成功条件がまだ曖昧で、質問しながら要件を固める依頼。`product-planning` スキルを使う。
- 実装順序、影響範囲、検証方法を詰める依頼。`implementation-planning` スキルを使う。
- PRD の採用判断、docs 反映、ADR 作成。必要なら `grill-with-docs` スキルを使う。
- GitHub issue など外部 issue tracker への公開。ユーザーが明示した場合だけ別途扱う。

## 基本方針

- 追加 interview を前提にせず、確認済みの会話、context、docs、codebase facts から synthesis する。
- 未確認事項は決め打ちせず、PRD の `Open Questions` に残す。
- 実装タスクの列挙だけで PRD を埋めず、ユーザー価値、成功条件、非範囲、制約を分ける。
- ファイルパスやコード断片は、すぐ古くなるため原則入れない。判断を prose より正確に表す短い schema、状態遷移、型形状だけ例外的に入れてよい。
- PRD draft の保存先が自然に決まらない場合は、本文を返すだけに留める。

## Workflow

1. PRD 化する範囲を一文で言い換える。
2. 会話、`CONTEXT-MAP.md` / `CONTEXT.md`、関連 docs、ADR、必要な近傍 code から確認済み事実を集める。
3. 目的、対象利用者、成功条件、範囲、非範囲、制約、未確定事項を分ける。
4. 必要なら `references/prd-template.md` を読み、PRD draft を作る。
5. 未確認事項、採用判断、保存先、issue 化、docs 反映を `Open Questions` または次 action として分離する。

## Output Guide

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

PRD draft を作る依頼では、この項目を本文見出しとして自然な Markdown に整える。
