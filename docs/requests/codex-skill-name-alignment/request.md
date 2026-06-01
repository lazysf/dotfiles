# request: codex-skill-name-alignment

## 元要求

- Claude / Codex 両 surface の skill 名を Claude 基準に揃える。具体的には Codex 側の `implementation` -> `implement`、`verification` -> `inspect` に rename する。

## 背景

- 現状、両 surface で工程系 skill が意図的に別名（Claude: `implement` / `inspect`、Codex: `implementation` / `verification`）。`docs/notes/runtime-surface-guidance.md` に「Codex では `implementation`、Claude Code では `implement`」と明記されている。
- 命名差は runtime 機能差ではなく、Codex 側で過去経緯による名残。揃えると 2 surface 横断の説明、agent 定義、docs の表現が単純化する。
- `caveman` は output-style 機能の有無による意図的な差なので、今回の rename 対象外。Codex 側 skill のまま残す。

## 期待状態

- Codex 側 `dot_codex/skills/implementation/` -> `implement/`、`dot_codex/skills/verification/` -> `inspect/` に dir rename。
- 各 SKILL.md frontmatter `name` を新名に揃える（specification: parent directory name と一致必須）。
- 既存の skill 名参照を全 surface で `implement` / `inspect` に書き換える（agent 定義、docs/notes、CONTEXT.md、`orchestrate` references を含む）。
- ADR 本文は履歴として保持し、新 ADR 0027 で rename の判断を記録（0020 / 0024 等を Amends）。
- `docs/notes/runtime-surface-guidance.md` の「両 surface は意図的に名前が違う」記述を撤回。

## triage

- 停止線接触: なし。
  - skill name 変更は trigger に影響するが、auth / 権限 / secret / 公開挙動 / data format / 永続化 / 新依存 / 本番設定には触れない。
  - dir rename は破壊的だが git 追跡内で reversible。
- 規模: 約 50 file の参照書き換え + dir rename 2 件 + ADR 1 件 + notes 1 件。
- tier: **standard**。
- 根拠: 設計判断は確定済み（rename 対象、caveman 維持、ADR 履歴扱い）。最小工程で実装可能。

## 合意済み事項

- rename 対象: `implementation` -> `implement`、`verification` -> `inspect` の 2 件のみ。
- `caveman`: Codex 側 skill のまま残す（runtime 機能差による意図的な差）。
- ADR: 0017 / 0020 / 0024 等の本文は履歴保持（ADR 0022 の原則）。新 ADR 0027 で rename を記録し、関連 ADR を Amends。
- `docs/notes/runtime-surface-guidance.md`: 名前差説明を撤回し、新名で揃った状態に書き換え。

## scope

- `dot_codex/skills/implementation/` -> `implement/` の dir rename + frontmatter name 更新。
- `dot_codex/skills/verification/` -> `inspect/` の dir rename + frontmatter name 更新。
- 全 surface (`dot_codex/`, `dot_claude/`, `docs/`) 内の skill 名参照を `implement` / `inspect` へ統一。ただし ADR 本文 (`docs/adr/`) は対象外。
- 新 ADR `docs/adr/0027-align-codex-skill-names-with-claude.md` 作成。
- `docs/notes/runtime-surface-guidance.md` の名前差記述撤回。

## non-scope

- `caveman` skill の Codex / Claude 間の整合変更。
- ADR 本文の現行運用に合わせた書き換え（履歴保持のため）。
- Claude 側 skill の rename。
- skill description / 本文の内容変更（name field と参照箇所のみ更新）。

## 未確認事項

- 別 thread での並行 rename 作業の有無。実装直前に git log を再確認する。
