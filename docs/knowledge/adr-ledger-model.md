# ADR Ledger Model

この文書は、この repo で ADR をどう扱うかの正本をまとめる。
ADR は通常知見の置き場ではなく、採用された判断とその履歴関係を残す状態付き台帳として扱う。

## ADR に入れるもの

- 何を決めたか
- なぜその判断が必要だったか
- その判断が今も有効か
- どの ADR を置き換えたか、または何に置き換えられたか

次の内容は ADR に混ぜず、`docs/knowledge/` に送る。

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

`Superseded-By` は新規 ADR 作成時に推測で書かず、`update-adr-status` による明示更新でだけ付ける。
`Supersedes` も新規 ADR 作成時に明示されたものだけを使い、`update-adr-status` が後から補わない。

## 運用フロー

1. 判断か通常知見かが未確定なら `capture-knowledge-triage` で `skip | knowledge | adr` を決める
2. 新しい判断記録が必要なら `write-adr` で `docs/adr/NNNN-*.md` を `Proposed` として作る
3. その判断が採用されたら `update-adr-status` で新 ADR を `Accepted` に更新する
4. 新 ADR 側に明示 `Supersedes` がある場合だけ、続けて別の `update-adr-status` で旧 ADR を `Superseded` にする

## Acceptance Policy

ADR の `Accepted` 化は current project の `[projects."<repo-root>"].adr_acceptance_policy` を正本にして決める。

- `commit`: その project で判断がコミット時点で採用扱いなら、commit 後に `Accepted` へ進める
- `default_branch`: default branch 反映時点を採用扱いにするなら、commit 後は `Proposed` に留め、後段で `Accepted` にする
- key がない場合は `commit` として扱う
- 値が `commit | default_branch` 以外なら、自動 `Accepted` 化を行わず `skipped(invalid-adr-acceptance-policy)` にする
- `commit` policy では `新規 ADR 1 件 + 任意の docs/README.md 変更` だけの commit も `ADR-only commit` として受理対象に含める
- 新 ADR に `Supersedes` がある場合は、受理後に旧 ADR を別更新で `Superseded` に進める

この repo の既定値は `commit` とする。
project ごとの設定は `adr_acceptance_policy = "commit" | "default_branch"` で持つ。

## Skill Mapping

- ルーティング: `capture-knowledge-triage`
- 新規 knowledge 作成: `write-knowledge-note`
- 新規 ADR 作成: `write-adr`
- 既存 ADR の状態更新と関係更新: `update-adr-status`
- 変更後知見化 helper: `capture-change-knowledge`
