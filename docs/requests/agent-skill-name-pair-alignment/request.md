# request: agent-skill-name-pair-alignment

## 元要求

- skill と agent の名前ペアが工程ごとに語幹で揃っていない。`inspect` skill ⇔ `verifier` agent などのペアを語幹一致 (`inspect` ⇔ `inspector`) に揃えたい。

## 背景

- 現状の skill-agent 対応:
  - `architecture` skill ⇔ `architect` agent → 語幹一致 (OK)
  - `implement` skill ⇔ `developer` agent → 不一致
  - `inspect` skill ⇔ `verifier` agent → 不一致
  - `research` skill ⇔ `analyst` agent → 不一致
- 不一致のため、orchestrate references や docs で「skill `inspect`」「agent `verifier`」を別々に説明する必要があり、ペアの把握コストが上がる。
- 直前の ADR 0027 で skill 名 (`implementation` -> `implement`、`verification` -> `inspect`) は両 surface 同期したが、agent 名は手付かず。

## 期待状態

- 全 skill-agent ペアが「skill 動詞 + agent -er/-or 形」で語幹一致する。
- Claude `.md` / Codex `.toml` 両 surface で agent file rename + 内部 name field 更新。
- 参照箇所 (SKILL.md / orchestrate references / docs/notes / CONTEXT.md / 他 agent 定義) を全て新名に統一。
- ADR 本文は履歴保持 (ADR 0022 原則)。新 ADR 0028 で rename を記録。
- `docs/notes/runtime-surface-guidance.md` の skill / agent 説明を新名で揃える。

## triage

- 停止線接触: なし。skill / agent 名は runtime trigger に影響するが、auth / 権限 / secret / 公開挙動 / data format / 永続化 / 新依存 / 本番設定には触れない。
- 規模: agent file rename 3 件 × 2 surface = 6 file。参照書き換えは ADR 0027 と同等規模を見込む。設計判断は確定済み (推奨 = skill 動詞 + agent -er/-or)。
- tier: **standard**。ただし参照範囲が広いため慎重に進める。
- 根拠: 設計判断は合意済み。機械的書き換え中心。最小工程で実装可能。

## 合意済み事項

- rename 対象 3 件:
  - `verifier` -> `inspector`
  - `developer` -> `implementer`
  - `analyst` -> `researcher`
- reviewer 系 (4 個) / `requirements-engineer` / `task-planner` / `repository-maintainer` は別の命名規則 (`<対象>-<動詞 -er>`) で既に一貫しているため対象外。
- `architect` agent は `architecture` skill と既に語幹一致のため対象外。
- Claude / Codex 両 surface 同期。
- ADR 本文は履歴保持。新 ADR 0028 で 0020 / 0024 / 0027 を Amends として記録。

## scope

- `dot_claude/agents/{verifier,developer,analyst}.md` の rename + frontmatter `name` 更新。
- `dot_codex/agents/{verifier,developer,analyst}.toml` の rename + toml `name` 更新。
- 全 surface (`dot_codex/`、`dot_claude/`、`docs/notes/`、`docs/CONTEXT.md`、`docs/README.md`) 内の agent 名参照を新名へ統一。ADR 本文 (`docs/adr/`) は対象外。
- 新 ADR `docs/adr/0028-align-agent-names-with-skill-pairs.md` 作成。
- `docs/notes/runtime-surface-guidance.md` の関連箇所更新。

## non-scope

- 他 agent (reviewer 系 / requirements-engineer / task-planner / repository-maintainer) の rename。
- skill 名の rename。
- agent 定義の description / 本文の改訂 (name field と参照箇所のみ更新)。
- ADR 本文の現行運用に合わせた書き換え (履歴保持)。

## 未確認事項

- 別 thread での並行作業の有無。実装直前に git log を再確認する。
