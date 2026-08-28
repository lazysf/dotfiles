# 0015: RTK を Codex shell proxy として不採用にする

- Status: Superseded
- Superseded-By: 0042
- Supersedes: 0014

## Context

RTK は `rtk init -g --codex` により `AGENTS.md` と `RTK.md` の prose instruction として導入される。
Codex integration では shell command の自動 rewrite は行われず、agent が指示を守る必要がある。
実運用では `rtk` が Homebrew から uninstall され、`rtk` command は利用できない状態になった。

## Decision

RTK を Codex ハーネスの deployable runtime surface から外す。
`dot_codex/RTK.md` は管理対象から削除し、`dot_codex/AGENTS.md` から `~/.codex/RTK.md` 参照を削除する。
shell command は通常の Codex shell 実行と approval / rule 境界で扱う。

## Consequences

- shell command は `rtk` prefix を前提にしない。
- RTK による token 圧縮は使わない。
- `rtk` 未導入による command failure や、prose instruction だけでは強制できない問題を避ける。
- command の安全境界は `approval_policy`、`approvals_reviewer`、`sandbox_mode`、`dot_codex/rules/` の `forbidden` / `allow` rule で扱う。
