# basic-design: agent-skill-name-pair-alignment

## 公式情報確認

[Claude Code subagents](https://code.claude.com/docs/en/sub-agents) と [Codex Subagents](https://developers.openai.com/codex/subagents) の agent 定義仕様に従う。

- Claude: `.md` + frontmatter (`name`, `description`, `tools`, `model` 等)。`name` は parent filename (拡張子なし) と一致するのが慣例。
- Codex: `.toml`。`name = "..."` field と filename (拡張子なし) が一致するのが慣例。
- いずれも kebab-case 推奨。`inspector` / `implementer` / `researcher` はすべて規約適合。

## 変更概要

### 1. Dir / file rename (6 件)

| 旧 | 新 |
|---|---|
| `dot_claude/agents/verifier.md` | `dot_claude/agents/inspector.md` |
| `dot_claude/agents/developer.md` | `dot_claude/agents/implementer.md` |
| `dot_claude/agents/analyst.md` | `dot_claude/agents/researcher.md` |
| `dot_codex/agents/verifier.toml` | `dot_codex/agents/inspector.toml` |
| `dot_codex/agents/developer.toml` | `dot_codex/agents/implementer.toml` |
| `dot_codex/agents/analyst.toml` | `dot_codex/agents/researcher.toml` |

`git mv` で履歴追跡を維持する。

### 2. 各 agent の name field 更新

- Claude (`.md` frontmatter): `name: verifier` -> `name: inspector` 等。
- Codex (`.toml`): `name = "verifier"` -> `name = "inspector"` 等。

description / 本文の自己参照や対比文 (例: "実装前の確認は `developer` に...") の名前も更新。

### 3. 参照書き換え方針

#### 書き換え対象

agent 名としての参照を全 surface で新名に統一。

- `dot_claude/CLAUDE.md` (進行節、置き場)
- `dot_claude/skills/*/SKILL.md` および `references/`
- `dot_claude/agents/*.md` (相互参照)
- `dot_codex/AGENTS.md`
- `dot_codex/skills/*/SKILL.md` および `references/`
- `dot_codex/agents/*.toml` (相互参照)
- `docs/notes/*.md`
- `docs/README.md`
- `docs/CONTEXT.md`

#### 書き換え対象外

- `docs/adr/*.md`: ADR 本文は履歴保持。
- 一般単語としての `developer` / `analyst` / `verifier`:
  - "developer documentation" / "developer experience" 等の一般用法
  - Git の committer/author に近い "verifier" の自然言語的な使用 (現状ない見込み)
- 出力フィールド名としての `verifier` (handoff 出力等で `verifier_return_required` のような複合語) -- 該当があれば確認

#### 識別方針

実装時に grep 結果を 1 件ずつ確認し、context で「agent 名」「一般単語」を判定する。agent 名としての使用は概ね次のパターン:

- ``` `verifier` ```、``` `developer` ```、``` `analyst` ``` の inline code
- "工程 N: `developer`" のような Phase 説明
- agent から / agent への handoff の文脈
- "Codex では `verifier` agent を使う" 等の対比文

### 4. ADR 0028 作成

`docs/adr/0028-align-agent-names-with-skill-pairs.md` を新規作成。

- Status: Accepted
- Amends: 0020, 0024, 0027
- 背景: ADR 0020 で Claude SDLC を Codex に import し、ADR 0024 で repository-maintainer を追加、ADR 0027 で skill 名 (implement / inspect) を Codex に揃えた。残った skill-agent ペアの語幹不一致 (implement/developer, inspect/verifier, research/analyst) で、orchestrate references や docs の説明が複雑化していた。
- Decision: rename 3 件、両 surface 同期、ADR 履歴保持。
- Consequences: skill ⇔ agent ペアが「動詞 ⇔ -er/-or 形」で語幹一致する。ADR 0020 / 0024 / 0027 本文の旧名表記は履歴留意点として残る。

### 5. runtime-surface-guidance.md 更新

`docs/notes/runtime-surface-guidance.md` で:

- `agents/` 説明節の「workflow 工程 agent」リスト (該当があれば)
- review 系 surface 役割分担節の `verifier` 参照 (Phase 3 で `verifier` へ戻すなどの記述)
- 関連文書節に ADR 0028 リンク追加

を更新する。

## 検証手順

1. `dot_claude/agents/`、`dot_codex/agents/` 配下の旧名 file が存在しないこと、新名 file が存在することを確認 (AC-1, AC-2)。
2. 各 agent 定義の `name` field が新名であることを確認。
3. `rg -nw 'verifier|developer|analyst' dot_codex dot_claude docs/notes docs/README.md docs/CONTEXT.md` の結果を 1 件ずつ確認し、agent 名としての残存が 0 件であることを確認 (AC-3)。
4. `docs/adr/0028-*.md` の存在を確認 (AC-4)。
5. `docs/notes/runtime-surface-guidance.md` の更新を確認 (AC-5)。
6. reviewer 系 / -engineer / -planner / -maintainer agent file の差分なしを確認 (AC-6)。

## 実装順序

1. **計画フェーズ**: grep で全参照箇所を一覧化し、書き換え対象 / 対象外を分類。
2. **rename フェーズ**: `git mv` で 6 file rename。各 agent 定義の `name` field 更新。
3. **agent 自己 / 相互参照フェーズ**: 各 agent file 内部の description / 本文の `verifier` / `developer` / `analyst` 参照を新名へ。
4. **横断参照書き換えフェーズ**: SKILL.md / orchestrate references / docs/notes / docs/CONTEXT.md / docs/README.md / 進行節を順次更新。
5. **ADR / notes フェーズ**: ADR 0028 作成、runtime-surface-guidance.md 更新。
6. **検証フェーズ**: AC-1〜AC-6 確認。

## リスクと対策

- **dir rename での履歴追跡**: `git mv` を使い、Git rename detection に任せる。
- **誤書き換え**: 一般単語を agent 名と誤認するリスク。inline code (`...`) パターンと前後の文脈で区別する。
- **handoff 出力フィールド名**: 既存に `verifier_return_required` 等の複合語フィールドがある場合、フィールド名は維持する判断を取る (skill ADR 0027 と同方針)。
- **別 thread の並行作業**: 実装直前に `git log -5` で最新コミットを再確認する。
