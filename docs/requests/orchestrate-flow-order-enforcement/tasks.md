# Tasks

## 実装方針

detailed-design の DD-001〜DD-006 に沿い、Claude 側を先に全変更し、その後 Codex 側へ対称反映する。各 reference は既存の節構造・文体・粒度を保ち、最小差分で確認手順と痕跡要件を埋め込む (DD-001..DD-006)。

## 実装タスク

- `TASK-001`: SKILL.md（Claude）の `自走と確認 checkpoint` に前工程確認原則を1項目追記。完了条件: 原則が1か所あり tier 具体手順を転記していない。確認方法: 該当節を Read。(DD-004 / AC-007)
- `TASK-002`: full.md（Claude）の `Phase 3 entry condition` を具体化（確認対象 artifact 列挙・Read 確認・痕跡記録・未充足分岐・skip 不能表現）。完了条件: 3要素+対象列挙が揃う。確認方法: 該当節 Read。(DD-001 / AC-001, AC-002)
- `TASK-003`: standard.md（Claude）の `Phase 3 entry condition` を具体化（作成済み artifact / request.md フォールバック・Read 確認・痕跡・未充足分岐）。完了条件: 同上かつ docs 省略規定を壊さない。確認方法: 該当節+Notes Read。(DD-002 / AC-001, AC-002, AC-004)
- `TASK-004`: micro.md（Claude）に「実装着手前確認」小セクション追加 + 実装節に痕跡根拠の1行追加。完了条件: 最小1ステップ確認があり docs を強制していない。確認方法: 該当 Read。(DD-003 / AC-003, AC-004)
- `TASK-005`: gate-review.md（Claude）共通 pass 条件に確認痕跡要件を追記。完了条件: pass 条件に痕跡項目がある。確認方法: 該当節 Read。(DD-005 / AC-002)
- `TASK-006`: TASK-001〜005 を Codex 側（`dot_codex/skills/orchestrate/`）へ surface 名差分のみで対称反映。完了条件: 対応5ファイルに同趣旨反映。確認方法: 各ファイル Read。(DD-006 / AC-005)
- `TASK-007`: 検証。両 surface 対応ファイル diff（surface 名以外一致）、AC-001〜007 の grep 確認、Tier Map / docs 省略規定の無変更確認、参照ずれ確認。完了条件: 全 AC 充足を観測。確認方法: diff / grep。(全 DD / AC-005, AC-006)

## 実装順序

1. `TASK-001`（SKILL.md 原則）
2. `TASK-002` `TASK-003` `TASK-004`（full / standard / micro）
3. `TASK-005`（gate-review）
4. `TASK-006`（Codex 対称反映）
5. `TASK-007`（検証）

## 変更境界

- `dot_claude/skills/orchestrate/SKILL.md`, `references/full.md`, `references/standard.md`, `references/micro.md`, `references/gate-review.md`
- `dot_codex/skills/orchestrate/` の対応5ファイル
- request folder の artifact（記録）

## Scope 外にしたこと

- scribe `*-format.md`、agent 定義、settings.json、hooks、ADR 本文。
- inquiry.md（実装工程を持たないため対象外）。
- Tier Map / tier 体系 / docs 省略規定の変更。

## リスク

- 痕跡要件が「新規 docs 強制」と読まれる過剰反映リスク → 既存 artifact 内1行/最終出力に限定し AC-006 を確認。
- 両 surface の片側反映漏れ → TASK-007 の diff で担保。
- 既存 reference の参照リンク破損 → TASK-007 で確認。

## 未確認事項

- none
