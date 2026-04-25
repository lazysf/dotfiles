---
name: update-adr-status
description: 「ADR を Accepted にしたい」「supersede に合わせて旧 ADR を更新したい」といった判断台帳の更新で使う。対象 ADR の `Status` と `Supersedes / Superseded-By` を一次情報に沿って更新する。新規 ADR を作りたい時は `write-adr` スキル、既存 docs 本文を更新したい時は `docs-update` スキルを使う。
metadata:
  short-description: ADR 状態更新
---

# Update ADR Status

既存 ADR の状態遷移と関係更新を行う。
この skill は lifecycle metadata の更新に責務を限定し、新規 ADR の作成は行わない。

## 対象

- `Proposed -> Accepted`
- `Accepted -> Superseded`
- `Proposed -> Rejected`
- 新 ADR と旧 ADR の `Supersedes / Superseded-By` の整合

## 対象外

- 新しい ADR の作成
- 通常知見メモの作成や更新
- README や一般 docs の本文更新

## 入力フォーマット

- `target_adr`: 状態を変える ADR
- `new_status`: `Accepted` / `Superseded` / `Rejected`
- `event_basis`: その状態に進める根拠
- `related_adrs`: supersede 更新時だけ必要。`target_adr` を置き換える新 ADR を指す

## 基本方針

- 明示された根拠なしに状態を変えない。
- `Accepted` は利用者の明示的な採用判断を根拠に進める。project config による切り替えは行わない。
- `Superseded` は、新 ADR 側に `Supersedes` が明示されている場合だけ更新する。
- `Rejected` は明示的な不採用判断がある場合だけ更新する。
- 新 ADR 側の `Supersedes` は検証対象であり、この skill が補完しない。
- `Accepted` と関連する旧 ADR の `Superseded` は別更新として扱ってよい。
- README は触らない。

## 手順

### 1) 対象 ADR を確認する

- `target_adr` が既存 ADR であることを確認する。
- 現在の `Status` とメタ行を読む。

### 2) 遷移根拠を確認する

- `Accepted` は利用者の明示的な採用根拠がある場合だけ進める。
- `Rejected` は明示的な不採用判断がある場合だけ進める。
- `Superseded` は `related_adrs` が示す新 ADR 側に、`target_adr` と一致する `Supersedes` が既にある場合だけ進める。

### 3) 対象 ADR を更新する

- `Accepted` または `Rejected` の場合だけ、この段階で `Status` を `new_status` に更新する。
- `Superseded` の場合は、次の手順の検証を通ったときだけ `Status` を更新する。
- `Superseded-By` は `Superseded` の更新時だけ追加または更新する。

### 4) 関連 ADR を更新する

- `Superseded` の場合は、`related_adrs` が示す新 ADR 側に一致する `Supersedes` が既にあることを確認する。
- 条件を満たす場合だけ、旧 ADR 側に `- Status: Superseded` と `- Superseded-By:` を反映する。
- 条件を満たさない場合は旧 ADR を変更せず、`reason=skipped(missing-explicit-supersedes)` を返す。
- 新 ADR 側の関係行は補完しない。

### 5) 結果を返す

- `status=updated|skipped`
- `target_paths`
- `reason`
- `event_basis`

## 完了条件

- 対象 ADR の状態が根拠に沿って更新されている
- supersede 更新時は新 ADR 側の明示 `Supersedes` を検証できている
- 根拠不足なら `skipped` 理由が説明できる
