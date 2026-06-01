# requirements: codex-skill-name-alignment

## 目的

Codex 側の工程系 skill 名を Claude 基準に揃える。`implementation` -> `implement`、`verification` -> `inspect`。

## scope

- Codex skill dir rename (2 件)。
- 各 SKILL.md frontmatter `name` 更新。
- 全 surface (`dot_codex/`、`dot_claude/`、`docs/`) 内の skill 名参照書き換え。
- 新 ADR 0027 作成。
- `docs/notes/runtime-surface-guidance.md` 名前差記述撤回。

## non-scope

- `caveman` の整合変更。
- ADR 本文 (`docs/adr/0001-0026`) の書き換え。
- Claude 側 skill の rename。
- skill description / 本文の内容変更。

## REQ

- **REQ-1**: `dot_codex/skills/implementation/` を `dot_codex/skills/implement/` に rename し、SKILL.md frontmatter `name: implementation` を `name: implement` に更新する。
- **REQ-2**: `dot_codex/skills/verification/` を `dot_codex/skills/inspect/` に rename し、SKILL.md frontmatter `name: verification` を `name: inspect` に更新する。
- **REQ-3**: 全 surface (`dot_codex/`、`dot_claude/`、`docs/notes/`、`docs/README.md`、`docs/CONTEXT.md` 等) の skill 名参照を `implementation` -> `implement`、`verification` -> `inspect` に統一する。ADR 本文 (`docs/adr/`) は対象外。
- **REQ-4**: 新 ADR `0027-align-codex-skill-names-with-claude.md` を作成し、関連 ADR (0020 / 0024) を Amends として記録する。0017 / 0023 等の旧名表記は本文の Consequences で履歴留意点として言及するに留める。
- **REQ-5**: `docs/notes/runtime-surface-guidance.md` の「Codex では `implementation`、Claude Code では `implement`」「変更後確認は Codex では `verification`、Claude Code では `inspect`」記述を撤回し、両 surface とも `implement` / `inspect` で揃った状態に書き換える。
- **REQ-6**: `caveman` skill / output-style の構成は変更しない。

## AC

- **AC-1**: `dot_codex/skills/implement/SKILL.md` が存在し、`name: implement` を含む。`dot_codex/skills/implementation/` が存在しない。
- **AC-2**: `dot_codex/skills/inspect/SKILL.md` が存在し、`name: inspect` を含む。`dot_codex/skills/verification/` が存在しない。
- **AC-3**: `rg "\bimplementation\b" dot_codex/ dot_claude/ docs/notes/ docs/README.md docs/CONTEXT.md` が、ADR 内の引用、`implementation.md` などの artifact filename、`implementation-format.md` などの reference filename を除き 0 件。
- **AC-4**: `rg "\bverification\b" dot_codex/ dot_claude/ docs/notes/ docs/README.md docs/CONTEXT.md` が、同様に artifact / reference filename と Git の verification context を除き 0 件。
- **AC-5**: `docs/adr/0027-align-codex-skill-names-with-claude.md` が存在し、Status / Amends / Decision / Consequences を含む。
- **AC-6**: `docs/notes/runtime-surface-guidance.md` で「Codex では `implementation`」「Codex では `verification`」相当の記述が消え、両 surface とも同名で記載される。
- **AC-7**: `caveman` 関連 file の差分なし（output-style と Codex skill 両方とも維持）。

## 制約

- ADR 本文は履歴保持原則（ADR 0022）に従い書き換えない。
- skill name field は kebab-case 1-64 字 / parent directory name と一致（Agent Skills specification）。
- 既存 implementation.md / verification.md などの artifact / reference filename は今回の対象外（skill 名参照ではなくドキュメントファイル名）。

## 前提

- chezmoi 管理下の `dot_codex/` が truth source。
- `caveman` は runtime 機能差（Codex に output-style 機能なし）による意図的な差で維持。

## 未確認事項

- 別 thread で同じ rename 作業が走っていないか。実装前に再確認する。
