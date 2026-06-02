# 0033: orchestrate workflow agent 起動を事前許可する

- Status: Accepted
- Amends: 0020, 0029, 0032

`orchestrate` は lead が工程 agent / reviewer agent を束ねる workflow であり、ADR 0029 / 0032 によりユーザー判断が必要な場面以外は自走する方針になった。一方で、workflow 上必須の agent / subagent 起動ごとにユーザー確認が発生すると、自走性が落ち、Gate review や repository maintenance が実質的に手動 checkpoint になる。

`orchestrate` workflow 上で必要と定義された repo-local / managed agent / subagent は、ユーザーの standing authorization があるものとして lead が追加確認なしで起動してよい。これは agent / subagent 起動だけの許可であり、各 agent 内の tool 実行、sandbox escalation、secret / auth / 外部 I/O / 破壊的操作の停止線は維持する。

Claude Code では `permissions.allow` に workflow agent の `Agent(...)` rules を追加する。Codex では既存の `multi_agent = true`、`[agents] max_threads = 6` / `max_depth = 1`、`approvals_reviewer = "auto_review"` を維持し、standing authorization を `AGENTS.md` と `orchestrate` skill の運用契約として明記する。

## Consequences

- `orchestrate` が Gate review、repository maintenance、設計 / 実装 / 検証 agent を必要に応じて起動する時、ユーザーへの追加許可入力を挟まない。
- tool 実行や sandbox escalation の承認、deny rule、停止線はこの ADR で緩めない。
- reviewer agent 起動時の `agent_type` 明示、review 対象と観点の指定、Codex で `fork_context=true` を併用しない制約は維持する。
