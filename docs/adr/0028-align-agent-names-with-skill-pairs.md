# 0028: skill-agent ペアを語幹一致で揃える

- Status: Superseded
- Superseded-By: 0034
- Amends: 0020, 0024, 0027

ADR 0020 で Claude SDLC workflow を Codex に import し、ADR 0024 で `repository-maintainer` agent を追加、ADR 0027 で Codex 側の workflow skill 名を Claude 基準 (`implement` / `inspect`) に揃えた。残った課題は工程系の skill ⇔ agent ペアの語幹不一致で、`implement` ⇔ `developer`、`inspect` ⇔ `verifier`、`research` ⇔ `analyst` のように動詞と役職が別の語幹に分かれていた。`architecture` ⇔ `architect` だけが語幹一致しており、orchestrate references / docs / 他 agent 定義で「skill `inspect`」「agent `verifier`」を別々に説明する必要があった。

skill が「何をするか (動詞)」、agent が「誰がやるか (役職)」という設計を維持しつつ、対応関係を語幹一致 (`-er` / `-or` 形) にする。これにより skill ⇔ agent ペアが自明になり、参照側の認知コストが下がる。reviewer 系 (4 個) と `requirements-engineer` / `task-planner` / `repository-maintainer` は対応 skill がなく、別の命名規則 (`<対象>-<動詞 -er>`) で既に一貫しているため対象外。

## Decision

- agent file rename を 3 件行う。Claude (`.md`) / Codex (`.toml`) 両 surface 同期。
  - `verifier` -> `inspector`
  - `developer` -> `implementer`
  - `analyst` -> `researcher`
- 各 agent 定義の `name` field を新名に更新する (frontmatter / toml の双方)。description / 本文内の自己参照や対比文も新名に揃える。
- 全 surface (`dot_codex/`、`dot_claude/`、`docs/notes/`、`docs/README.md`、`docs/CONTEXT.md` 等) で agent 名としての参照を新名に統一する。ADR 本文は履歴保持 (ADR 0022) のため対象外。
- `docs/notes/runtime-surface-guidance.md` の関連箇所を新名で揃える。
- 次は agent 名としての参照ではないため、書き換え対象外とする。
  - ADR file 名 (例: `0007-retire-harness-verifier-script.md`)。
  - handoff の出力フィールド名 `verifier_return_required`。
  - Codex toml の `developer_instructions` field 名。
  - 一般単語としての `developer` / `analyst` / `verifier` (該当があれば文脈で判断)。
- 既存の reviewer / -engineer / -planner / -maintainer agent は本 ADR の対象外。
- skill 名は変更しない (ADR 0027 で確定済み)。

## Consequences

- skill ⇔ agent ペアが「動詞 ⇔ -er/-or 形」で語幹一致する。orchestrate references / 各 SKILL.md / agent 定義の説明が単純化する。
- `requirements-engineer` / `task-planner` / `repository-maintainer` は対応 skill を持たないため本規則の外側で命名を維持する。reviewer 系も同様。
- runtime trigger は agent 名 (file 名と name field) を主軸にするため、rename によって Codex / Claude の両セッションで旧名 (`verifier` / `developer` / `analyst`) の自動発火は失われる。プロンプトや workflow が旧名を指定している場合は新名に追従する必要がある。
- ADR 0020 / 0024 / 0027 本文では旧名 (`verifier` / `developer` / `analyst`) が履歴として残る。これら ADR を読む際は旧名表記であることに留意する。
- `verifier_return_required` のような複合 field 名は維持する。意味的には「inspector への返却要否」だが、handoff schema の互換のため field 名は変更しない。
