# 0027: Codex 側の workflow skill 名を Claude 基準に揃える

- Status: Accepted
- Amends: 0020, 0024

ADR 0020 で Claude SDLC workflow を Codex に import し、各工程 skill を Codex に設置した。当時 Codex 側は名詞形 (`implementation` / `verification`) を採用し、Claude 側の動詞形 (`implement` / `inspect`) と意図的に別名で運用してきた。両 surface に同等の責務を持つ skill が存在するにもかかわらず名前が違うため、`docs/notes/runtime-surface-guidance.md` に「Codex では `implementation`、Claude Code では `implement`」と毎回但し書きが必要で、両 surface 横断の説明、agent 定義、references の表現が複雑化していた。`caveman` のように runtime 機能差（output-style の有無）に由来する差は意図的だが、`implementation` / `verification` は単なる命名差で機能差ではない。

両 surface の対応 skill 名を Claude 基準に揃える。Codex 側 `implementation` skill を `implement` に、`verification` skill を `inspect` に rename し、両 surface で同名で参照できるようにする。`caveman` は runtime 機能差由来の意図的な差として維持する。ADR 本文は履歴として保持し（ADR 0022）、現行運用の説明は新名に揃える。

## Decision

- Codex 側 skill dir を rename する。
  - `dot_codex/skills/implementation/` -> `dot_codex/skills/implement/`
  - `dot_codex/skills/verification/` -> `dot_codex/skills/inspect/`
- 各 SKILL.md frontmatter の `name` field を新名に更新する（Agent Skills specification: parent directory name と一致必須）。description / 本文の skill 名参照も新名に書き換える。
- 全 surface (`dot_codex/`、`dot_claude/`、`docs/notes/`、`docs/README.md`、`docs/CONTEXT.md` 等) で skill 名としての `implementation` / `verification` 参照を `implement` / `inspect` に統一する。
- `docs/notes/runtime-surface-guidance.md` の「両 surface で名前が違う」記述を撤回し、両 surface とも `implement` / `inspect` で揃った状態に書き換える。
- 既存 ADR (0017 / 0020 / 0023 / 0024 等) 本文は履歴保持のため書き換えない（ADR 0022 原則）。
- `caveman` skill は本 ADR の対象外。Codex 側 skill / Claude 側 output-style として両 surface に残す（runtime 機能差由来の意図的な差）。
- 次の用語は skill 名としての参照ではないため、書き換え対象外とする。
  - SDLC artifact filename: `implementation.md`、`test.md` 等。
  - reference filename: `implementation-format.md`、`implementation-heuristics.md`、`implementation-plan-format.md`、`implementation-guardrails.md`、`verification-fallbacks.md` 等。
  - `inspect` skill 内部の mode 名 (`acceptance` / `verification` / `consistency`)。
  - `git-commit` / `git-push` / `scribe` / `doc-followup` 等の出力フィールド名 (`verification: passed / skipped / ...`)。
  - 一般単語としての "implementation" / "verification"（例: interface vs implementation の用語）。
  - ADR 本文内の引用 (`docs/adr/`)。

## Consequences

- 両 surface で工程 skill 名が一致するため、横断説明、agent 定義、references の記述が単純化する。
- runtime trigger は skill 名と description を主軸にするため、rename によって Codex 側で `implementation` / `verification` 名指定の自動発火は失われる。skill 名指定で呼ぶワークフローや user prompt が存在する場合は新名 `implement` / `inspect` に追従する必要がある。
- ADR 本文では旧名 (`implementation` / `verification`) が履歴として残り、ADR 0017 / 0020 / 0023 / 0024 等を読む際は旧名表記であることに留意する。
- `docs/notes/runtime-surface-guidance.md` の「Frontmatter Description 設計ルール」「命名規約」「導線の考え方」節は引き続き正本として有効。
- `caveman` は Codex 側 skill / Claude 側 output-style として残るため、両 surface 間で `caveman` を直接対比する記述だけは現状維持する。
- ADR 0020 で導入された Codex SDLC workflow の構造（Phase / Gate / artifact / agent routing）は本 ADR で変更しない。rename と参照書き換えのみが対象。
