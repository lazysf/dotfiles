# ADR Ledger Model

この文書は、この repo で ADR をどう扱うかの正本をまとめる。
ADR は通常知見の置き場ではなく、採用された判断とその履歴関係を残す状態付き台帳として扱う。
ただし本文は重いテンプレートを必須にせず、短い判断なら 1-3 文で残せる状態付き軽量 ADR として扱う。
採用済み ADR の本文は履歴として保持し、後続方針に合わせた上書き先にしない。

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

`Superseded-By` は新規 ADR 作成時に推測で書かず、ユーザー依頼、会話上の合意、または `grill` で確認した明示根拠に基づく `scribe` 更新でだけ付ける。
`Supersedes` も新規 ADR 作成時に明示されたものだけを使い、後段の状態更新が推測で補わない。
`Amends` / `Amended by` は、既存 ADR の判断を置き換えずに一部だけ補正または拡張する時だけ使う。

## 既存 ADR の編集境界

既存 ADR 本文は採用時点の履歴として扱う。方針変更、既存判断の補正、判断理由や影響の再解釈は、既存本文を書き換えずに新しい ADR として記録する。

既存 ADR に直接追記・修正してよいもの:

- `Status`、`Superseded-By`、`Amended by` などの状態・関係メタデータ
- typo、リンク切れ、Markdown の明白な破損など、判断内容を変えない修正

既存 ADR に直接反映しないもの:

- 採用済み判断の本文、理由、影響の書き換え
- 後続方針に合わせた説明の上書き
- 明示根拠のない `Supersedes` / `Superseded-By` / `Amends` / `Amended by` の backfill

## 本文の形

新規 ADR は、見出し直下のメタ行に続けて 1-3 文で文脈、決定、理由を書くだけでもよい。
必要な場合だけ、既存 ADR と同じ `Context` / `Decision` / `Consequences` 見出しを使う。
具体的な形式は [scribe の ADR format](../../dot_codex/skills/scribe/references/adr-format.md) を参照する。

## 運用フロー

1. 知見蓄積が必要なら、ユーザー依頼や会話で確認した evidence と採用判断を整理する
2. 確定した用語、既存 docs / note 更新、ADR 作成、ADR 状態更新の必要性を切り分ける
3. 新しい判断記録が ADR 条件を満たすなら `scribe` で `docs/adr/NNNN-*.md` を作る
4. 採用判断が未確定なら `Proposed`、ユーザーの明示依頼または会話上の合意で採用済みなら `Accepted` とする
5. 新 ADR 側に明示 `Supersedes` がある場合だけ、続けて旧 ADR を `Superseded` にする
6. 新 ADR 側に明示 `Amends` がある場合だけ、続けて旧 ADR に `Amended by` を追記する
7. 旧 ADR 本文は履歴として保持し、後続判断の内容で上書きしない

## Acceptance Timing

ADR の `Accepted` 化は Git commit とは切り離し、採用判断が明示された時だけ `scribe` の docs-aware 更新として行う。
project config や private config による自動切り替えは行わない。

- 新規 ADR は、採用判断が未確定なら `Proposed` として作る
- 採用判断が明示済みなら、作成時点で `Accepted` にしてよい
- 新 ADR に `Supersedes` がある場合は、採用後に旧 ADR を後続 action で `Superseded` に進める

知見蓄積は Git push と切り離し、作業の締めや明示依頼で `grill` / `scribe` を使う。
commit 前の差分確認と commit 作成は `git-commit` に任せる。

## Skill Mapping

- 知見蓄積の問い詰めと置き場判断: `grill`
- 既存 docs、CONTEXT、ADR の作成・更新・整形: `scribe`
- commit 前の差分確認と commit 作成: `git-commit`
