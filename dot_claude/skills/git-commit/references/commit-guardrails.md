# Commit ガードレール

## 停止または確認

次の場合は commit しない。

- detached HEAD で対象 branch が曖昧
- merge / rebase / cherry-pick / revert 進行中
- worktree または index に未解決 conflict がある
- 無関係な変更が混ざり、1 つの commit message で説明できない
- interactive selection なしでは安全な staging 範囲が判断できない

## ステージング

- 合意済みの単一変更だけを明示 path で stage する。`git add .` と `git add -A` は使わない。
- 無関係、曖昧、危険、またはユーザー所有の変更は unstaged のまま残す。
- directory stage 時は、含まれる全 path が同じ変更に属することを確認する。

## Commit Message

- commit message は `<type>: <description>` を使う。
- `<type>(<scope>): <description>` のような scope は使わない。
- repo の規約が scope を要求する場合は、scope 付き message を作らず停止して報告する。
- title は 1 行。実用上可能なら 72 characters 以下。
- body は title だけで理由や影響を説明できない場合だけ使う。
- body や footer の詳細が必要な時は `references/commit-message-format.md` を読む。

## 失敗時

- `git commit` が失敗しても、`--no-verify` で hook を迂回しない。
- amend、squash、直接 ref 編集、その他 history 操作へ切り替えない。
- 一時的に見える失敗だけ、`git status -sb` と `git diff --staged` を再確認し、同じ commit command を 1 回 retry する。
- retry しても失敗する場合は停止し、理由の要点を報告する。
