# Implementation

## 対応タスク / 対応範囲

- `request.md`: orchestrate の standard / full flow で、Phase 3 前に上流 artifact を確定し、実装後の後付け作成を禁止する。

## 変更内容

- standard flow に `Phase 3 entry condition` を追加し、`requirements.md` / `tasks.md` 省略時も `request.md` の scope / acceptance / 実装範囲 / 省略理由を実装前 trace 元にするよう明示した。
- full flow に `Phase 3 entry condition` を追加し、Gate 2 pass とユーザー承認後にだけ Phase 3 へ進むこと、Phase 3 中の上流不足は前工程へ戻すことを明示した。
- Gate review に、上流 artifact の次工程前確定と、実装・検証結果による後付け artifact 作成を fail 条件として追加した。
- レビュー後、standard の trace 元説明の反復と repository-maintainer の長文を削り、必要な禁止事項だけ残した。

## 変更ファイル

- `dot_codex/skills/orchestrate/references/standard.md`: standard flow の Phase 3 entry condition と後付け禁止を追加。
- `dot_codex/skills/orchestrate/references/full.md`: full flow の Phase 3 entry condition と後付け禁止を追加。
- `dot_codex/skills/orchestrate/references/gate-review.md`: Gate pass / fail 条件へ前工程確定の確認を追加。
- `dot_claude/skills/orchestrate/references/standard.md`: Codex 側と同じ変更を反映。
- `dot_claude/skills/orchestrate/references/full.md`: Codex 側と同じ変更を反映。
- `dot_claude/skills/orchestrate/references/gate-review.md`: Codex 側と同じ変更を反映。
- `docs/requests/orchestrate-prephase-artifact-order/request.md`: 今回の要求と根拠を記録。

## Scope 外

- ADR 本文の改稿。既存 ADR は履歴として保持する方針のため、今回は reference 側を更新した。
- agent 定義、runtime config、permission 設定の変更。

## 実装中に判明した事項

- ADR 0030 は、tier flow の変更時に該当 tier reference を確認・更新する方針を明示している。
- Codex / Claude Code 両 surface に同じ `orchestrate` tier reference 構造がある。

## 実行した確認

- `rg` / `sed` で ADR 0025 / 0029 / 0030 と現行 `orchestrate` references を確認した。
- quality-reviewer agent で冗長性、過不足、配置、過剰複雑化を read-only review した。

## 未確認事項

- none
