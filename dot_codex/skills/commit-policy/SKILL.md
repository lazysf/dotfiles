---
name: commit-policy
description: コミット可否ポリシーを判定する。コミット本文の必須条件・例外条件・判定根拠の明示が必要な場合に使用する。`git-commit` 実行前のゲートとして使う。
metadata:
  short-description: Commit policy gate
---

# Commit Policy

コミットメッセージ本文の必須判定を行い、`git-commit` に判定結果を渡す。

## 基本方針

- 判定は staged 差分 (`git diff --cached`) を基準に行う。
- 判定結果は必ず構造化して返す（曖昧な文章のみで返さない）。
- ルールの根拠となる数値（変更ファイル数・変更行数）を必ず示す。
- 例外判定は機械的に行い、主観で例外にしない。
- 判定不能または情報不足の場合は `allow_commit=no` として安全側に倒す。

## 対象外

- コミットメッセージ本文の作成・推敲（`commit-message` を使用）。
- `git add` / `git commit` などの Git 実操作（`git-commit` を使用）。

## 判定ルール

- 次のいずれかを満たす場合、本文を必須とする。
  - 変更ファイル数が 8 以上
  - 追加行数 + 削除行数が 200 以上
- 例外（本文省略可）:
  - 機械的 rename のみ
  - 自明な一括整形（formatter/linter による実質 whitespace-only 変更）

## 例外判定の指針

- rename-only:
  - `name-status` が rename のみで構成される。
  - 実質的な内容変更がないことを確認する。
- format-only:
  - 差分が whitespace/整形由来のみであることを確認する。
  - 機能変更・設定値変更・文言変更が含まれる場合は例外にしない。

## 返却フォーマット（必須）

```markdown
# Commit Policy Result

- allow_commit: yes / no
- require_body: yes / no
- reason:
- changed_files:
- added_lines:
- deleted_lines:
- total_changed_lines:
- exception: none / rename-only / format-only / unknown
- notes:
```

## 手順

### 1) 差分情報の取得

- staged 変更ファイル数を取得する。
- staged の追加行・削除行・合計行を取得する。
- `name-status` と差分内容から例外候補を判定する。

### 2) ルール評価

- 例外に該当すれば `require_body=no`。
- 例外に該当しない場合は閾値で `require_body` を決定する。
- 判定可能かつ矛盾がない場合は `allow_commit=yes` にする。
- 判定不能なら `allow_commit=no` にする。

### 3) 判定結果の出力

- 返却フォーマットで必須項目をすべて埋める。
- `reason` に閾値条件または例外条件を簡潔に記載する。

## 連携ルール

- `git-commit` はこの判定がない限りコミットしない（fail-closed）。
- `require_body=yes` の場合、`git-commit` は `commit-message` を呼び出して本文あり最終案を取得する。
- `commit-message` は `require_body` を受け取り、本文必須時は必ず本文を含む最終案を返す。
