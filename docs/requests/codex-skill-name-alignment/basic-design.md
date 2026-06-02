# basic-design: codex-skill-name-alignment

## 公式情報確認

[Skill Specification](https://agentskills.io/specification) の `name` field 制約に従う。

- `name` は 1-64 字、kebab-case (`a-z`, `0-9`, `-`)、先頭末尾 `-` 不可、連続 `--` 不可。
- `name` は **parent directory name と一致必須**。dir rename と同期して更新する。
- `implement` / `inspect` はいずれも規約適合。

## 変更概要

### 1. Dir rename

- `dot_codex/skills/implementation/` -> `dot_codex/skills/implement/`
- `dot_codex/skills/verification/` -> `dot_codex/skills/inspect/`

実装方法: `git mv` で履歴追跡を維持。

### 2. SKILL.md frontmatter

- `dot_codex/skills/implement/SKILL.md`: `name: implementation` -> `name: implement`
- `dot_codex/skills/inspect/SKILL.md`: `name: verification` -> `name: inspect`

description / 本文は変更しない（REQ-3〜6 の範囲外）。

### 3. 参照書き換え方針

#### 書き換え対象

skill 名としての参照を全 surface で `implement` / `inspect` に統一。

- `dot_codex/AGENTS.md`
- `dot_codex/skills/*/SKILL.md` および `references/`
- `dot_codex/agents/*.toml`
- `dot_claude/CLAUDE.md`、`dot_claude/skills/*/SKILL.md` および `references/`
- `dot_claude/agents/*.md`
- `dot_claude/rules/*.md`
- `docs/notes/*.md`
- `docs/README.md`、`docs/CONTEXT.md`

#### 書き換え対象外

- `docs/adr/0001-0026`: ADR 本文は履歴保持（ADR 0022）。
- `dot_claude/skills/scribe/references/implementation-format.md` の filename: ファイル名そのものは skill 名ではなく artifact format 名。**ファイル名は変えない**。本文内で skill 名として参照している箇所のみ書き換える。
- artifact filename としての `implementation.md` / `test.md`: SDLC artifact name で skill 名ではない。書き換え対象外。
- Git の verification context（commit signature 等）: 一般単語の使用。書き換え対象外。

#### 識別方針

実装時に grep 結果を 1 件ずつ確認し、context で「skill 名」か「artifact/file 名」か「一般単語」かを判定する。skill 名としての使用は概ね次のパターン:

- `` `implementation` ``、`` `verification` `` の inline code 引用
- `implementation` / `verification` skill / agent と並ぶ文脈
- `Codex では \`implementation\``、`Codex では \`verification\`` の対比文

artifact filename パターンは:

- `implementation.md`、`scribe/references/implementation-format.md`
- `docs/requests/<slug>/implementation.md`

### 4. ADR 0027 作成

`docs/adr/0027-align-codex-skill-names-with-claude.md` を新規作成。

- Status: Accepted
- Amends: 0020, 0024
- 背景: 過去経緯で Codex 側に Claude と異なる skill 名 (`implementation` / `verification`) を採用したが、両 surface 横断の説明と参照が複雑化。runtime 機能差ではなく単なる命名差なので、Claude 基準に揃える。
- Decision: rename 2 件、frontmatter 更新、参照書き換え、runtime-surface-guidance.md 名前差記述撤回、`caveman` は対象外。
- Consequences: 両 surface で同名 skill。ADR 本文は履歴保持。

### 5. runtime-surface-guidance.md 撤回

該当箇所 (line 35):

> 実装は Codex では `implementation`、Claude Code では `implement`、変更後確認は Codex では `verification`、Claude Code では `inspect` を使う。

変更後:

> 実装は `implement`、変更後確認は `inspect` を使う。

その他 `implementation` / `verification` を skill 名として参照している箇所も同様に書き換える。

ADR 関連文書節に 0027 を追加。

## 検証手順

1. `dot_codex/skills/implementation/` / `verification/` が存在しないこと、`implement/` / `inspect/` が存在することを確認 (AC-1, AC-2)。
2. SKILL.md frontmatter `name` が新名であることを確認。
3. `rg -w "implementation" dot_codex/ dot_claude/ docs/notes/ docs/README.md docs/CONTEXT.md` の結果を 1 件ずつ確認し、skill 名としての残存が 0 件であることを確認 (AC-3)。
4. 同様に `verification` も確認 (AC-4)。
5. `docs/adr/0027-*.md` の存在を確認 (AC-5)。
6. `docs/notes/runtime-surface-guidance.md` で名前差記述が消えていることを確認 (AC-6)。
7. `git diff` で `caveman` 関連 file 差分なしを確認 (AC-7)。

## 実装順序

1. **計画フェーズ**: grep で全参照箇所を一覧化し、書き換え対象 / 対象外を分類。
2. **rename フェーズ**: `git mv` で dir rename。frontmatter `name` 更新。
3. **参照書き換えフェーズ**: 対象 file を順次更新。
4. **ADR / notes フェーズ**: ADR 0027 作成、runtime-surface-guidance.md 撤回。
5. **検証フェーズ**: AC-1〜AC-7 確認。

## リスクと対策

- **dir rename での履歴追跡**: `git mv` を使い、Git rename detection に任せる。
- **誤書き換え**: artifact filename を skill 名と誤認して書き換えるリスク。実装中に inline code (` `) パターンと filename パターンを区別する。
- **ADR 本文への誤書き換え**: 書き換え対象 path を明示的に絞る (`docs/adr/` を除外)。
- **別 thread の並行作業**: 実装直前に `git log -5` で最新コミットを再確認。
