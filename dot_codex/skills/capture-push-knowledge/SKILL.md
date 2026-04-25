---
name: capture-push-knowledge
description: 「push 前に前回 push 以降の知見を整理したい」「outgoing commit 群から knowledge / ADR の集約漏れを確認したい」といった依頼で使う。push 実行前の evidence packet をもとに、重複整理、既存 docs 更新、ADR 関係整合、状態更新漏れの有無を判定する。本文作成や状態更新が必要な時は `write-knowledge-note` スキル、`docs-update` スキル、`write-adr` スキル、`update-adr-status` スキルを使う。
metadata:
  short-description: Push 前知見集約
---

# Capture Push Knowledge

push 実行前に、前回 push 以降の outgoing commit 群を集約して、知見や ADR の整理が必要かを判定する。
この skill は push 前 preflight の routing に責務を絞り、docs 更新や commit 作成は行わない。

## 入力フォーマット

- `branch`
- `remote`
- `upstream_ref`
- `outgoing_commits`
- `changed_paths_summary`
- `knowledge_or_adr_paths_in_range`
- `recent_execution_context`

## 出力フォーマット

- `status`: `skipped` / `ready` / `consolidation_required`
- `reason`
- `target_paths`
- `evidence_used`

## 基本方針

- evidence packet には、会話、outgoing commit 群、変更 path、実行結果で明示された事実だけを入れる。
- commit 時の `skip | knowledge | adr` routing を再分類しない。
- push 前には、複数 commit を束ねて初めて見える重複、整合、集約だけを見る。
- docs 更新や ADR 状態更新が必要なら `consolidation_required` を返し、push 自体は止める。
- 自動で docs 更新 commit は作らない。follow-up commit は次の `git-commit` 導線に委ねる。

## 手順

### 1) evidence packet をそろえる

- branch、remote、upstream ref、outgoing commit 群、変更 path summary を確認する。
- `docs/knowledge/` または `docs/adr/` の変更が outgoing range に含まれるかを確認する。
- 推測や未確認事項は packet に含めない。

### 2) no-op 条件を確認する

- outgoing commit がなければ `skipped` にする。
- 知見、ADR、docs 整理に関係する兆候がなければ `skipped` にする。

### 3) 集約要否を判定する

- 同じテーマの knowledge が複数箇所に分散しているなら `consolidation_required` にする。
- 既存 docs を更新すべき内容が新規 note として重複しているなら `consolidation_required` にする。
- ADR に `Supersedes` があるのに旧 ADR 側の `Superseded` 更新が見当たらないなら `consolidation_required` にする。
- 新規 ADR が `Proposed` のまま outgoing range に含まれ、明示された採用判断の反映漏れが疑われるなら `consolidation_required` にする。
- 追加整理が不要なら `ready` にする。

### 4) 次に使うスキルを決める

- 通常知見の新規作成が必要なら `write-knowledge-note` を示す。
- 既存 docs の統合や追記が必要なら `docs-update` を示す。
- 判断記録の追加が必要なら `write-adr` を示す。
- ADR 状態や supersede 関係の更新が必要なら `update-adr-status` を示す。

## 完了条件

- outgoing range の evidence packet が推測なしで説明できる
- `skipped | ready | consolidation_required` の理由が説明できる
- `consolidation_required` の場合、push を止める理由と次アクションが分かる
