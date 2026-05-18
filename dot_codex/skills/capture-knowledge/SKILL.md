---
name: capture-knowledge
description: 「今回の知見を整理したい」「作業で得た知見を残したい」「この用語を CONTEXT に残したい」「この判断を ADR として残したい」「この ADR を Accepted にしたい」といった依頼で使う。明示された evidence をもとに、durable knowledge として残す価値と置き場を判断し、CONTEXT 更新 / 既存 docs 更新 / note 作成 / ADR 作成 / ADR 状態更新を 1 つの知見蓄積 workflow 内の順序付き action として扱う。commit 前の差分確認や commit 作成は `git-commit` スキルを使う。
metadata:
  short-description: 知見蓄積
---

# Capture Knowledge

明示された evidence から、durable knowledge として残すか、どこに残すか、どの action を実行するかを決める 1 つの知見蓄積 workflow として扱う。
この skill は evidence 収集、知見化要否の判断、CONTEXT 更新、既存 docs 更新、note 作成、ADR 作成、ADR 状態更新までを同じ workflow 内の action として扱う。
成果物や metadata 更新の種類が分かれても、別 workflow には分けない。
commit 前の差分確認と commit 作成は扱わない。

## 入力

使える evidence source は次に限る。

- `current diff`
- `latest commit`
- `commit range`
- `recent execution context`
- `user-provided summary`

推測、未確認の意図、diff だけから読み取れない durable decision は evidence に含めない。
秘密情報、認証情報、private config、未公開個人情報は durable artifact に転記しない。

## 出力

- `decision`: `skip` / `captured` / `needs_user_input`
- `actions`: 順序付き action の配列
- `changed_paths`
- `evidence_used`
- `remaining_risks`

主な action:

- `update_existing_docs` (置き場判断を伴う知見蓄積 workflow 内で既存 docs を更新する action)
- `create_knowledge_note` (`docs/notes/` に置く note を作成する action)
- `update_context` (`CONTEXT.md` に context 固有の用語を反映する action)
- `create_adr`
- `accept_adr`
- `supersede_old_adr`

`actions` は実行順に並べる。
これらの action は独立した workflow 名ではなく、同じ知見蓄積 workflow の中で必要に応じて選ばれる実行単位として扱う。
未確定な mutation がある場合は、その mutation を実行せず `needs_user_input` にする。
すでに安全に作成済みの差分がある場合は、`changed_paths` と残りの確認事項を返す。

## 基本方針

- 再利用価値が説明できない内容は `skip` にする。
- 既存 docs の更新で足りる内容を新規 note として重複させない。
- 手順、確認ポイント、落とし穴、軽量な運用メモは通常知見として扱う。
- context 固有の用語、避けたい別名、用語間の関係は `CONTEXT.md` として扱う。
- 複数案から選んだ理由、方針変更、互換性判断、採用 / 不採用の決定は、ADR 条件を満たす場合だけ ADR として扱う。
- 通常知見と ADR の置き場を混ぜない。
- CONTEXT は glossary であり、spec、作業メモ、実装判断、一般的なプログラミング用語を混ぜない。
- 秘密情報、認証情報、private config、未公開個人情報が evidence に含まれる場合は、必要に応じて redact するか `needs_user_input` で止める。
- commit は作らない。commit したい時は後続の `git-commit` に渡す。

## 成果物の形式

### note

note は `docs/notes/` に置く durable な通常知見メモを指す。
短命な作業メモは note に含めない。
note は `docs/notes/kebab-case-title.md` に作成し、1 ファイル 1 テーマの短い Markdown にする。
次の形は必須テンプレートではなく、迷ったときの default shape として使う。

```markdown
# [短いタイトル]

このメモは、[何についての知見か] をまとめる。

## Context

[確認済みの背景・前提・根拠]

## Guidance

[次回以降に使う判断、手順、注意点]

## References

- [正本や関連ファイルがある場合だけ列挙]
```

- 空の見出しは作らない。
- 既存ファイルに自然な形式がある場合は、既存形式を優先する。
- 表、チェックリスト、短い箇条書きの方が読みやすい場合は使ってよい。
- `References` は、明示できる正本、関連ファイル、実行結果がある場合だけ置く。

### CONTEXT

`CONTEXT.md` は context 固有の language を置く glossary を指す。
`update_context` を選ぶ時、または CONTEXT の配置や形式を判断する時は [references/context-format.md](references/context-format.md) を読む。
対象 context が不明な場合は、推測で新しい context を作らず `needs_user_input` にする。

### ADR

ADR は `docs/adr/NNNN-kebab-case-title.md` に作成する状態付き軽量の判断記録を指す。
`create_adr`、`accept_adr`、`supersede_old_adr` を選ぶ時、または ADR の採番や形式を判断する時は [references/adr-format.md](references/adr-format.md) を読む。
新規 ADR は、明示された判断内容があり、ADR 条件をすべて満たす場合だけ作成する。

## 手順

### 1) evidence をそろえる

- 利用できる source から、会話、変更、実行結果で明示された事実だけを集める。
- 不明点が知見化の判断や mutation の安全性に影響する場合は、そこで止める。

### 2) 残す価値を判断する

- その場限りの調査、短命な作業メモ、既に反映済みの follow-up だけなら `skip` にする。
- 次回以降も参照する手順、確認ポイント、落とし穴、判断理由なら蓄積対象にする。

### 3) 置き場と action を決める

- context 固有の用語なら `update_context` にする。
- 既存 docs に自然な置き場があるなら `update_existing_docs` にする。
- 新しい note が必要なら `create_knowledge_note` にする。
- 判断記録が必要で ADR 条件を満たすなら `create_adr` にする。
- ADR の採用判断や supersede 反映が明示されているなら、必要に応じて `accept_adr`、`supersede_old_adr` を後続 action にする。

### 4) 差分を作る

- 既存 docs 更新は既存の章構成、用語、粒度に寄せる。
- CONTEXT、note、ADR は、成果物の形式に従って作成する。
- 既存ファイルを上書きする必要があるが根拠が足りない場合は、変更せず `needs_user_input` にする。

### 5) 結果を返す

- 実行した action、作成・更新した path、使った evidence、残るリスクを返す。
- commit 前の差分確認は行わず、必要なら `git-commit` を次アクションとして示す。

## ADR ルール

- 新規 ADR は常に `Proposed` で作成する。
- 新規 ADR は、明示された判断内容があり、ADR 条件をすべて満たす場合だけ作成する。
- `Accepted` への更新は、利用者の明示的な採用判断がある場合だけ行う。
- `Rejected` への更新は、明示的な不採用判断がある場合だけ行う。
- 旧 ADR の `Superseded` 更新は、新 ADR 側に対象 ADR を指す `Supersedes` が明示されている場合だけ行う。
- 新 ADR 側の `Supersedes` は検証対象であり、旧 ADR 更新時に補完しない。
- ADR 作成と状態更新を同じ workflow で扱う場合、action 順序は `create_adr`、`accept_adr`、`supersede_old_adr` にする。
- 根拠が不足する段階で `needs_user_input` にする。

## 完了条件

- `decision` が根拠付きで説明できる
- `actions` が必要な順序で並んでいる
- `changed_paths` と `evidence_used` が説明できる
- 推測で CONTEXT / docs / note / ADR / ADR metadata を更新していない
- 秘密情報を durable artifact に残していない
- commit 境界を越えていない
