# Implementation

## Phase 3 entry confirmation

確認した artifact: requirements.md (REQ-001..008, AC-001..007), basic-design.md (BD-001..007), detailed-design.md (DD-001..006), tasks.md (TASK-001..007)。全て Read 済み、実装判断に足る状態。

## 対応タスク / 対応範囲

TASK-001..007 / DD-001..006。orchestrate skill の各 tier reference に、前工程成果物の Read 確認・痕跡記録・未充足分岐を skip 不能な形で具体化する。

## 変更内容

- SKILL.md「自走と確認 checkpoint」に前工程確認原則を1項目追記。tier 具体手順は tier reference に委ね転記していない。
- full.md Phase 3 entry condition を具体化: 確認対象4 artifact を列挙、Read 確認・痕跡記録・未達定義・未充足→戻す分岐・why を明示。
- standard.md Phase 3 entry condition を具体化: 作成済み artifact / request.md フォールバック、Read 確認・痕跡・未充足分岐を明示。
- micro.md に「実装着手前確認」小セクションを追加（Phase 0 と実装の間）。1ステップの Read 確認のみ、docs 強制なし。実装節に「記録用であり着手判断は事前確認に置く」を追記。
- gate-review.md 共通 pass 条件に「Read 確認痕跡が残っている」を追記。

## 変更ファイル

- `dot_claude/skills/orchestrate/SKILL.md`
- `dot_claude/skills/orchestrate/references/full.md`
- `dot_claude/skills/orchestrate/references/standard.md`
- `dot_claude/skills/orchestrate/references/micro.md`
- `dot_claude/skills/orchestrate/references/gate-review.md`
- `dot_codex/skills/orchestrate/SKILL.md`（surface 名以外同一）
- `dot_codex/skills/orchestrate/references/full.md`（同上）
- `dot_codex/skills/orchestrate/references/standard.md`（同上）
- `dot_codex/skills/orchestrate/references/micro.md`（同上）
- `dot_codex/skills/orchestrate/references/gate-review.md`（同上）

## Scope 外

- scribe format reference、agent 定義、settings.json、hooks、ADR、inquiry.md。

## 実行した確認

- 両 surface 5ファイルの diff: `sed 's/subagent/agent/g'` で正規化後に diff → 全て identical (AC-005)。
- AC-001〜007 grep 確認: 全 AC 充足。
- Tier Map 無変更 (AC-006): SKILL.md の Tier Map 行が変更なし。
- SKILL.md 追記が1か所のみで tier 具体手順を転記していない (AC-007)。

## 未確認事項

- none
