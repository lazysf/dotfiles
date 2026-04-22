---
name: capture-change-knowledge
description: 「コミット後の変更から残すべき知見を拾いたい」「この change を knowledge か ADR へ振り分けたい」といった依頼で使う。evidence packet を集めて `capture-knowledge-triage` へ渡し、`skip | knowledge | adr` を判定して必要な writer skill へ handoff する。新規作成は `write-knowledge-note` / `write-adr`、既存 ADR の状態遷移は `update-adr-status` で扱う。
metadata:
  short-description: 変更後知見化
---

# Capture Change Knowledge

コミット後の change から、共有知見として残すべきものを拾う。
この skill は evidence packet の整理、routing、handoff に責務を絞り、本文の正本は隣接 skill に委ねる。

## 入力フォーマット

- `commit_sha`
- `branch`
- `commit_message`
- `changed_paths`
- `diff_summary`
- `recent_execution_context`

## 出力フォーマット

- `status`: `skipped` / `knowledge_created` / `adr_created`
- `path`
- `reason`
- `evidence_used`

## 基本方針

- evidence packet には、会話、change、実行結果で明示された事実だけを入れる。
- docs-only の change や一過性の change は `skip` にする。
- diff だけから durable decision を推測して ADR を作らない。
- project policy は current project の `[projects."<repo-root>"].adr_acceptance_policy` を正本にし、未設定は `commit`、不正値は `skipped(invalid-adr-acceptance-policy)` にする。
- direct `write-adr` の `ADR-only commit` 受理は `git-commit` 側の例外導線で扱い、この skill では docs-only skip を維持する。
- ADR が作られた場合だけ、project policy に応じて `update-adr-status` へ handoff する。

## 手順

### 1) evidence packet をそろえる

- commit message、changed paths、diff summary、recent execution context を集める。
- 推測や未確認事項は packet に含めない。

### 2) skip 条件を確認する

- docs-only の change なら `skip` にする。
- 一時的な実験やその場限りの cleanup だけなら `skip` にする。
- 既に knowledge / ADR 更新の follow-up だけなら `skip` にする。

### 3) triage する

- `capture-knowledge-triage` を使い、`skip | knowledge | adr` を判定する。
- `reason` と `evidence_used` を残す。

### 4) writer skill へ渡す

- `knowledge` なら `write-knowledge-note` を使う。
- `adr` なら `write-adr` を使う。
- `skip` ならここで終了する。

### 5) policy を解決して ADR 状態を進める

- current project の `[projects."<repo-root>"].adr_acceptance_policy` を読み、key がない場合は `commit` として扱う。
- 値が `commit | default_branch` 以外なら、writer skill の作成結果は保持したまま自動 `Accepted` 化だけを進めず `reason` に `skipped(invalid-adr-acceptance-policy)` を残す。
- ADR が作成され、project policy `adr_acceptance_policy = "commit"` なら `update-adr-status` を使って `Accepted` に進める。
- 新 ADR に `Supersedes` が明示されている場合だけ、受理後に旧 ADR へ `Superseded` 更新を別で行う。
- project policy `adr_acceptance_policy = "default_branch"` なら、新 ADR は `Proposed` に留める。
- supersede 更新が必要な場合は、新 ADR 側に `Supersedes` が明示されているときだけ `update-adr-status` を使う。

## 完了条件

- evidence packet が推測なしで説明できる
- `skip | knowledge | adr` の routing が根拠付きで決まっている
- knowledge または ADR を作成した場合は、writer skill の結果が返せる
