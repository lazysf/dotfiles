# Commit ガードレール

## 停止または確認

次の場合は、状況が解消されるまで commit しない。

- detached HEAD で対象 branch が曖昧
- merge / rebase / cherry-pick / revert が進行中
- worktree または index に未解決 conflict がある
- 無関係な変更が混ざっており、自然な 1 つの commit message で説明できない
- interactive selection なしでは安全な staging 範囲が判断できない

## ステージング

- 合意済みの単一変更だけを stage する。
- 明示的な path を使う。`git add .` と `git add -A` は使わない。
- 無関係、曖昧、危険、またはユーザー所有の変更は unstaged のまま残す。
- directory を stage した場合は、含まれる全 path が同じ変更に属することを確認する。

## Commit Message

- repo の規約がある場合はそれを優先する。
- 規約がない場合は `<type>: <description>` を使う。
- title は 1 行にする。実用上可能なら 72 characters 以下を優先する。
- body は title だけで理由や影響を説明できない場合だけ使う。
- body や footer の詳細が必要な時は `references/commit-message-format.md` を読む。

## 失敗時

- `git commit` が失敗しても、`--no-verify` で hook を迂回しない。
- amend、squash、直接 ref 編集、その他の history 操作へ切り替えない。
- 一時的に見える失敗では、少し待ってから `git status -sb` と `git diff --staged` を再確認し、同じ commit command を 1 回だけ retry する。
- retry しても失敗する場合は停止し、理由の要点を報告する。

## 報告

次を返す。

- `branch`: 現在 branch。不明な場合は `none`
- `commit`: short SHA。ない場合は `none`
- `message`: 実際または試行した commit message。ない場合は `none`
- `files`: commit した path の要約。ない場合は `none`
- `verification`: `passed`、`skipped`、`not run`、または `already run`
- `left_unstaged`: 無関係または意図的に除外した変更。ない場合は `none`
- `notes`: hook warning、停止理由、失敗理由。ない場合は `none`
