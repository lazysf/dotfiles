# 0025: orchestrate を全依頼の triage 入口にし tier 別フローへ分岐する

- Status: Superseded
- Superseded-By: 0036
- Amended-By: 0026, 0029
- Amends: 0020

ADR 0020 で `orchestrate` を複数工程・設計判断を伴う依頼の進行入口とし、小さい修正や単一 skill で閉じる作業は main セッションが直接処理してよいとした。この入口分けは軽量運用を保つ意図だったが、運用上 2 つの非効率が出た。1 つは、依頼ごとに「orchestrate を通すか直接処理するか」をその場で判断する必要があり、入口判断そのものが迷いになること。もう 1 つは、いったん workflow に乗ると軽微な修正から大規模な実装まで一律で Phase 0〜3 と Gate 1〜3 を通り、中量級の受け皿がないこと。

入口を規模で分けるのをやめ、入口は常に `orchestrate` の Phase 0 + Triage に一本化する。そのうえで Triage で tier を決め、tier ごとに通す Phase / Gate を変える。これにより入口判断の迷いを無くし、かつ軽微な依頼に full の重い工程を機械的に課さないようにする。

## Decision

- コード変更・実装・開発依頼は、規模に関わらず `orchestrate` の Phase 0 + Triage を入口にする。単なる質問・相談・調査だけの依頼は対象外。
- Triage は 2 段で判定する。
  - 停止線（公開挙動 / 公開 API / data format / 永続化 / auth / 権限 / secret / 新依存 / 破壊的操作 / 本番設定）に触れるなら、規模に関わらず `full`。
  - 触れないなら規模で振り分ける。自明・単一箇所・設計判断なしは `micro`、複数 file または軽い設計判断ありは `standard`。迷う場合は上位 tier に倒す。
- tier 別フロー。
  - `micro`: Phase 0 -> 実装（lead 直接または該当 skill / `developer` を 1 つ）-> lead 自己確認。Gate なし。
  - `standard`: 要件・設計を軽量化または skip し、repository maintenance 後に統合 Gate を 1 回（`quality-reviewer` 必須、security に触れる兆候があれば `security-reviewer` 追加）。
  - `full`: 従来どおり Phase 0〜3 と Gate 1〜3 を 2 人体制で通す。
- Triage 結果（tier と判定根拠）は `request.md` に残す。
- ADR 0020 の「小さい修正や単一 skill で閉じる作業は直接処理してよく、agent workflow を常時必須にしない」方針を更新する。極小依頼も `orchestrate` を通すが、Triage で `micro` と判定し最小工程に省く。

## Consequences

- tier 別の通す Phase / Gate は `orchestrate` の `references/sdlc-flow.md` を正本にする。
- Claude / Codex 両 surface の `orchestrate` SKILL.md と `references/sdlc-flow.md`、進行節（`dot_claude/CLAUDE.md`、`dot_codex/AGENTS.md`）、`docs/notes/runtime-surface-guidance.md` を同期して更新する。
- `orchestrate` の description は「全依頼の進行入口」を表す内容にし、規模で使用を限定する記述を外す。
- 入口判断は規模分類ではなく、Triage の停止線判定と規模判定に統一される。
