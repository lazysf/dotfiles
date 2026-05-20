# ADR Ledger Model

この文書は、この repo で ADR をどう扱うかの正本をまとめる。
ADR は通常知見の置き場ではなく、採用された判断とその履歴関係を残す状態付き台帳として扱う。
ただし本文は重いテンプレートを必須にせず、短い判断なら 1-3 文で残せる状態付き軽量 ADR として扱う。

## ADR に入れるもの

- 何を決めたか
- なぜその判断が必要だったか
- その判断が今も有効か
- どの ADR を置き換えたか、または何に置き換えられたか

ADR を新規作成する条件は次の 3 つをすべて満たす場合に限る。

- あとから変えるコストが意味を持つ
- 文脈なしに見ると将来の読み手が驚く
- 実際の trade-off から選ばれた判断である

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
- `- Amends: 0003`
- `- Amended by: 0005`

`Superseded-By` は新規 ADR 作成時に推測で書かず、`planning` の明示根拠に基づく更新でだけ付ける。
`Supersedes` も新規 ADR 作成時に明示されたものだけを使い、後段の状態更新が推測で補わない。
`Amends` / `Amended by` は、既存 ADR の判断を置き換えずに一部だけ補正または拡張する時だけ使う。

## 本文の形

新規 ADR は、見出し直下のメタ行に続けて 1-3 文で文脈、決定、理由を書くだけでもよい。
必要な場合だけ、既存 ADR と同じ `Context` / `Decision` / `Consequences` 見出しを使う。
具体的な形式は [planning の ADR format](../../dot_codex/skills/planning/references/adr-format.md) を参照する。

## 運用フロー

1. 知見蓄積が必要なら `planning` で evidence を集める
2. `planning` で確定した用語、既存 docs / note 更新、ADR 作成、ADR 状態更新の必要性を切り分ける
3. 新しい判断記録が ADR 条件を満たすなら `docs/adr/NNNN-*.md` を `Proposed` として作る
4. その判断が採用済みと明示されている場合だけ、新 ADR を `Accepted` に更新する
5. 新 ADR 側に明示 `Supersedes` がある場合だけ、続けて旧 ADR を `Superseded` にする
6. 新 ADR 側に明示 `Amends` がある場合だけ、続けて旧 ADR に `Amended by` を追記する

## Acceptance Timing

ADR の `Accepted` 化は Git commit とは切り離し、採用判断が明示された時だけ `planning` の docs-aware 更新として行う。
project config や private config による自動切り替えは行わない。

- 新規 ADR はいったん `Proposed` として作る
- 採用判断が明示されたら、後続 action で `Accepted` に進める
- 新 ADR に `Supersedes` がある場合は、採用後に旧 ADR を後続 action で `Superseded` に進める

知見蓄積は Git push と切り離し、作業の締めや明示依頼で `planning` を使う。
commit 前の差分確認と commit 作成は `git-commit` に任せる。

## Skill Mapping

- docs-aware な知見蓄積: `planning`
- 既存 docs のみの更新: `docs-update`
- commit 前の差分確認と commit 作成: `git-commit`
