# Request

## 元の要求・要望

折衷案を採用する。Claude/Codex 両方に反映しよう。また、別セッションでワークフローをブラッシュアップしているので、現時点の構成を再度取得すること。

## 背景

- このセッションで non-reviewer agent の要否を相談し、以下の比較を行った。
  - 案 A: 現状維持（reviewer 4 + non-reviewer 7 = 11 agent）。
  - 案 B: 折衷（reviewer 4 + `researcher` + `inspector` = 6 agent）。
  - 案 C: reviewer のみ（4 agent）。lead 一貫 + skill 直叩き。
- 失う価値として 2 つを切り分けた:
  - **isolation**: subagent 別 context window で中間出力（grep、test/lint/build log）を隔離し、lead に結論だけ返す。
  - **constraint enforcement**: agent frontmatter の `tools:` や本文の編集境界で危険操作を機械的に封じる。
- 折衷案の根拠:
  - 要件〜設計〜実装を lead 一貫で持つことで handoff loss を避ける。
  - `researcher` / `inspector` は中間出力が嵩むので isolation を維持。
  - reviewer は独立批判視点を agent で維持。
- 別セッションで orchestrate workflow がブラッシュアップ済み（最新 commit: `9098582 docs: record orchestrate-stop-line-catalog SDLC artifacts`、`2a24ed2 refactor: consolidate orchestrate stop-line catalog`）。実装前に再取得が必要。

## 期待状態

- Claude / Codex 両 surface で、reviewer 系 4 agent + `researcher` + `inspector` のみ残る。
- 削除対象（両 surface）: `architect`、`requirements-engineer`、`task-planner`、`implementer`、`repository-maintainer`。
- `orchestrate` の tier reference（特に `full.md` / `standard.md`）で、削除対象 agent を参照する工程が lead + skill 直叩きに置き換わる。
- 関連 docs（`AGENTS.md`、`CLAUDE.md`、`agents/` を参照する rules / skill / docs）の追従更新が済み、参照ずれがない。
- Claude / Codex の片側更新漏れがない。

## 不明点

- lead 一貫で実装する場合の `implementation.md` / `test.md` 等 artifact 作成主体（lead が `scribe` skill で書くで良いか、書式自体は維持か）。
- `repository-maintainer` が担っていた "Gate 3 前の docs / 参照ずれ確認" の責任の移譲先（lead が `doc-followup` skill で直接実施で良いか）。
- `full.md` の Phase 1 / 2 / 3 工程記述の書き換え粒度（agent 名を消すだけか、Phase 構造自体を見直すか）。
- `researcher` / `inspector` agent 定義側に変更が必要か（参照する skill / handoff 仕様の確認のみで足りるか）。
