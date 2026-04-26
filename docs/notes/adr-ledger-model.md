# ADR Ledger Model

この文書は、この repo で ADR をどう扱うかの正本をまとめる。
ADR は通常知見の置き場ではなく、採用された判断とその履歴関係を残す状態付き台帳として扱う。

## ADR に入れるもの

- 何を決めたか
- なぜその判断が必要だったか
- その判断が今も有効か
- どの ADR を置き換えたか、または何に置き換えられたか

次の内容は ADR に混ぜず、`docs/notes/` に送る。

- 手順メモ
- 確認ポイント
- 再発しやすい落とし穴
- 軽量な運用メモ

## 状態モデル

ADR の状態は次の 4 つを使う。

- `Proposed`: 新規作成されたが、まだ採用確定していない
- `Accepted`: 採用された判断として有効
- `Superseded`: 後続 ADR により置き換えられた
- `Rejected`: 判断案としては残すが採用しない

`Rejected` は自動で付けず、明示的な判断があるときだけ更新する。

## メタデータの形

ADR 本文は既存の Markdown 形式に寄せ、見出し直下のメタ行で状態と関係を表す。

必須:

- `- Status: Proposed|Accepted|Superseded|Rejected`

必要時のみ追加:

- `- Supersedes: 0003`
- `- Superseded-By: 0005`

`Superseded-By` は新規 ADR 作成時に推測で書かず、`capture-knowledge` の明示根拠に基づく更新でだけ付ける。
`Supersedes` も新規 ADR 作成時に明示されたものだけを使い、後段の状態更新が推測で補わない。

## 運用フロー

1. 知見蓄積が必要なら `capture-knowledge` で evidence を集める
2. `capture-knowledge` で `skip | captured | needs_user_input` を決め、必要な action を順序付きで並べる
3. 新しい判断記録が必要なら `docs/adr/NNNN-*.md` を `Proposed` として作る
4. その判断が採用済みと明示されている場合だけ、新 ADR を `Accepted` に更新する
5. 新 ADR 側に明示 `Supersedes` がある場合だけ、続けて旧 ADR を `Superseded` にする

## Acceptance Timing

ADR の `Accepted` 化は Git commit とは切り離し、採用判断が明示された時だけ `capture-knowledge` の action として行う。
project config や private config による自動切り替えは行わない。

- 新規 ADR はいったん `Proposed` として作る
- 採用判断が明示されたら、後続 action で `Accepted` に進める
- 新 ADR に `Supersedes` がある場合は、採用後に旧 ADR を後続 action で `Superseded` に進める

知見蓄積は Git push と切り離し、作業の締めや明示依頼で `capture-knowledge` を使う。
commit 前の差分確認と commit 作成は `git-commit` に任せる。

## Skill Mapping

- 知見蓄積 workflow: `capture-knowledge`
- 既存 docs のみの更新: `docs-update`
- commit 前の差分確認と commit 作成: `git-commit`
