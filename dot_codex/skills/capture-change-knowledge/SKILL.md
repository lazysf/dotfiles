---
name: capture-change-knowledge
description: 「コミット後の変更から残すべき知見を拾いたい」「この change を knowledge か ADR へ振り分けたい」といった依頼で使う。evidence packet を集めて `skip | knowledge | adr` を判定し、残す先に応じた次の作業を整理する。知見メモを作りたい時は `write-knowledge-note` スキルを使い、ADR を作りたい時は `write-adr` スキルを使い、既存 ADR の状態を更新したい時は `update-adr-status` スキルを使う。
metadata:
  short-description: 変更後知見化
---

# Capture Change Knowledge

コミット後の単一 change から、共有知見として残すべきものを拾う。
この skill は evidence packet の整理と振り分けに責務を絞る。
本文を書きたい時は `write-knowledge-note` スキルまたは `write-adr` スキルを使う。

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
- 一時的な実験やその場限りの cleanup は `skip` にする。
- diff だけから durable decision を推測して ADR を作らない。
- direct `write-adr` による ADR の採用判断が明示されている場合は、`update-adr-status` スキルを使う。
- ADR が作られた場合でも、この skill だけでは `Accepted` に進めない。
- push 前の重複整理、状態整合、集約確認は `capture-push-knowledge` に委ね、この skill では扱わない。

## 手順

### 1) evidence packet をそろえる

- commit message、changed paths、diff summary、recent execution context を集める。
- 推測や未確認事項は packet に含めない。

### 2) skip 条件を確認する

- 一時的な実験やその場限りの cleanup だけなら `skip` にする。
- 既に knowledge / ADR 更新の follow-up だけなら `skip` にする。

### 3) triage する

- `capture-knowledge-triage` を使い、`skip | knowledge | adr` を判定する。
- `reason` と `evidence_used` を残す。
- `reason` は user-facing な短い根拠として扱う。

### 4) 次に使うスキルを決める

- `knowledge` なら `write-knowledge-note` スキルを使う。
- `adr` なら `write-adr` スキルを使う。
- `skip` ならここで終了する。

### 5) ADR 状態更新の要否を確認する

- ADR の採用判断が明示されている場合だけ、`update-adr-status` スキルを使って `Accepted` に進める。
- 新 ADR に `Supersedes` が明示されている場合だけ、採用後に旧 ADR へ `Superseded` 更新を別で行う。
- supersede 更新が必要な場合は、新 ADR 側に `Supersedes` が明示されているときだけ `update-adr-status` スキルを使う。

## 完了条件

- evidence packet が推測なしで説明できる
- `skip | knowledge | adr` の routing が根拠付きで決まっている
- knowledge または ADR を作成した場合は、次に使ったスキルの結果が返せる
