---
name: implement
description: 合意済みの変更をコード、設定、テスト、スクリプトへ実装または修正する時に使う。テスト、再現手順、比較観点などを先に置き、最小差分で実装して再確認する。原因調査は `research`、合意形成は `grill`、変更後の検証整理だけなら `inspect`。
---

# 実装ループ

テスト可能な変更を、確認方法先行の小さなループで進める。

## 基本方針

- 先に失敗する確認を置く。
- 最小差分で進め、次の差分を増やしすぎない。未検証事項は成功扱いにしない。
- `src/**` の実装では [coding-standards rule](../../rules/coding-standards.md) を正本とする。

## 手順

- 先にテスト、再現手順、比較観点のいずれかを置く。
- 近傍実装と明示規約に寄せて、いま必要な振る舞いだけを満たす。
- 追加した確認を再実行し、結果と未確認事項を分けて残す。

## 境界

- 原因調査は `research`。
- 要件整理や技術計画は `grill`。
- 実装計画の合意形成は `grill`。計画やその他 docs の文書化は `scribe`。
- Excel VBA の exported `.bas` / `.cls` を作成・編集する時は [references/vba-best-practices.md](references/vba-best-practices.md) を読む。
- 抽象化、分割、コメント、検証報告などの適用で迷う時は [references/coding-guidelines.md](references/coding-guidelines.md) を読む。
- テスト化しにくい変更では [references/verification-fallbacks.md](references/verification-fallbacks.md) を読む。

## 完了条件

- 変更意図に対応する確認方法がある
- 実装後に確認が通っている
- 整理した場合は、整理後も同じ確認が通っている
