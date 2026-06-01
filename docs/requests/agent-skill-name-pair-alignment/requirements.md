# requirements: agent-skill-name-pair-alignment

## 目的

skill-agent ペアを語幹一致で揃える。`verifier` -> `inspector`、`developer` -> `implementer`、`analyst` -> `researcher`。

## scope

- Claude / Codex 両 surface の agent file rename (6 file)。
- 各 agent 定義の `name` field 更新。
- 全 surface 内の agent 名参照書き換え。
- 新 ADR 0028 作成。
- `docs/notes/runtime-surface-guidance.md` 関連箇所更新。

## non-scope

- 他 agent (reviewer 系 / -engineer / -planner / -maintainer) の rename。
- skill 名の rename。
- agent 定義の description / 本文改訂。
- ADR 本文 (`docs/adr/0001-0027`) の書き換え。

## REQ

- **REQ-1**: `dot_claude/agents/verifier.md` を `dot_claude/agents/inspector.md` に rename し、frontmatter `name: verifier` を `name: inspector` に更新する。
- **REQ-2**: `dot_claude/agents/developer.md` を `dot_claude/agents/implementer.md` に rename し、frontmatter `name: developer` を `name: implementer` に更新する。
- **REQ-3**: `dot_claude/agents/analyst.md` を `dot_claude/agents/researcher.md` に rename し、frontmatter `name: analyst` を `name: researcher` に更新する。
- **REQ-4**: 同様に `dot_codex/agents/verifier.toml` → `inspector.toml`、`developer.toml` → `implementer.toml`、`analyst.toml` → `researcher.toml`。toml の `name` field も更新する。
- **REQ-5**: 全 surface (`dot_codex/`、`dot_claude/`、`docs/notes/`、`docs/README.md`、`docs/CONTEXT.md`) の agent 名参照を `verifier` -> `inspector`、`developer` -> `implementer`、`analyst` -> `researcher` に統一する。ADR 本文は対象外。
- **REQ-6**: 新 ADR `0028-align-agent-names-with-skill-pairs.md` を作成し、関連 ADR (0020 / 0024 / 0027) を Amends として記録する。
- **REQ-7**: `docs/notes/runtime-surface-guidance.md` で旧 agent 名を新名に置き換える。
- **REQ-8**: 一般単語としての `developer` `analyst` `verifier` (例: "developer documentation"、"security analyst" 等の文脈) は対象外。`agent` の文脈で使われている箇所のみ書き換える。

## AC

- **AC-1**: `dot_claude/agents/{inspector,implementer,researcher}.md` が存在し、frontmatter `name` がそれぞれ `inspector` / `implementer` / `researcher`。`dot_claude/agents/{verifier,developer,analyst}.md` が存在しない。
- **AC-2**: `dot_codex/agents/{inspector,implementer,researcher}.toml` が存在し、toml `name` がそれぞれ `inspector` / `implementer` / `researcher`。`dot_codex/agents/{verifier,developer,analyst}.toml` が存在しない。
- **AC-3**: `rg -w 'verifier|developer|analyst' dot_codex dot_claude docs/notes docs/README.md docs/CONTEXT.md` が、ADR 本文と一般単語の使用 (文脈で agent を指さない箇所) を除いて 0 件。
- **AC-4**: `docs/adr/0028-align-agent-names-with-skill-pairs.md` が存在し、Status / Amends / Decision / Consequences を含む。
- **AC-5**: `docs/notes/runtime-surface-guidance.md` で新 agent 名で揃った状態に書き換わっている。
- **AC-6**: reviewer 系 (`requirements-reviewer`, `design-reviewer`, `quality-reviewer`, `security-reviewer`) / `requirements-engineer` / `task-planner` / `repository-maintainer` の file 名と本文に差分なし。

## 制約

- ADR 本文は履歴保持原則 (ADR 0022) に従い書き換えない。
- agent name field は Claude / Codex 各 runtime の仕様に従う (kebab-case 等)。
- skill 名は変更しない (前 ADR 0027 で確定済み)。

## 前提

- chezmoi 管理下の `dot_codex/` `dot_claude/` が truth source。
- 別 thread での並行 rename がないことを実装直前に確認する。

## 未確認事項

- `developer` / `analyst` / `verifier` が一般単語として使われている箇所の特定。grep 結果を context で精査する。
