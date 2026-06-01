# 0020: Claude Code SDLC workflow を Codex に逆輸入する

- Status: Accepted
- Supersedes: 0016
- Amends: 0006, 0011, 0019

`dot_claude/` で育てた Agent Teams 型の SDLC workflow は、要求、要件、設計、task、実装、検証、review の責務を artifact と agent で分離できる。Codex でも custom subagent と multi-agent feature が公式に提供されており、`dot_codex/private_config.toml.tmpl` には `[agents] max_threads / max_depth` と、multi-agent tools を有効にする既存の `[features] multi_agent = true` がある。

従来の ADR 0016 は Codex の reviewer agent surface を 2 個に絞り、計画 review は親 Codex が扱う方針だった。この方針は軽量運用には合っていたが、複数工程や設計判断を伴う依頼では、調査、要件、設計、実装、検証、Gate review の責務が main セッションに集まりやすい。

Claude Code 側の workflow の考え方を Codex にも取り込み、main セッションを lead、`orchestrate` skill を進行入口、`dot_codex/agents/` を工程 agent / reviewer の定義場所として扱う。ただし Codex では agent 間の直接通信を前提にせず、handoff、差戻し、再 review、追加調査依頼は main セッションの lead が仲介する。

## Decision

- Codex に `orchestrate` skill を追加し、Phase 0〜3、Gate 1〜3、request folder、handoff、自律修正ループ、ユーザー確認を管理する入口にする。
- agent 同士は直接やり取りせず、agent 出力は lead が受け取り、次 agent への入力を lead が明示的に構成する。
- `dot_codex/agents/` は read-only reviewer だけでなく、`analyst`、`requirements-engineer`、`architect`、`task-planner`、`developer`、`verifier`、Gate reviewer を含む specialist agent surface とする。
- Codex の agent 定義は公式仕様に合わせ、Claude Code の Markdown + YAML frontmatter ではなく TOML で管理する。
- Codex の既存 skill 名に合わせ、Claude Code 側の `implement` は `implementation`、`inspect` は `verification` として受ける。
- 小さい修正や単一 skill で閉じる作業は引き続き main セッションが直接処理してよく、agent workflow を常時必須にはしない。
- request folder artifact の format は `scribe` skill の references に追加し、通常 docs / PRD / ADR の format と併存させる。

## Consequences

- ADR 0016 の「Codex reviewer agent は 2 個」という制約は退役する。
- `dot_codex/private_AGENTS.md.tmpl` は固定の細かい作業手順ではなく、lead / workflow / request folder の薄い入口案内を持つ。
- `docs/requests/<slug>/` は個別要求に閉じる SDLC artifact の既定置き場になる。
- Gate review 用 reviewer は workflow の一部として増えるが、reviewer は read-only を維持する。
- `dot_codex/private_config.toml.tmpl` の既存 `multi_agent = true` は維持し、`[agents] max_threads / max_depth` を workflow の同時実行と深さを制御する設定として扱う。
