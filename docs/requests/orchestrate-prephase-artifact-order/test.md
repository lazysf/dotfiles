# Test

## Summary

- Result: pass
- Scope: orchestrate の standard / full / Gate review reference が、実装前の上流 artifact 確定と実装後 backfill 禁止を明示していること。

## Test Cases

### TC-001: standard flow が実装前 trace 元を持つ

#### 対応

- `request.md` scope / acceptance

#### 種別

- manual

#### 手順

1. `rg -n 'Phase 3 entry condition|省略理由|実装後に作る' dot_codex/skills/orchestrate/references/standard.md dot_claude/skills/orchestrate/references/standard.md`

#### 結果

- pass
- Codex / Claude Code 両方の `standard.md` に `Phase 3 entry condition`、省略理由、実装後 artifact は上流 artifact の代替にしない旨がある。

#### 未実行理由 / 代替確認

- N/A

### TC-002: full flow が Gate 2 後にだけ Phase 3 へ進む

#### 対応

- `request.md` scope / acceptance

#### 種別

- manual

#### 手順

1. `rg -n 'Phase 3 entry condition|Gate 2 pass|実装結果を根拠' dot_codex/skills/orchestrate/references/full.md dot_claude/skills/orchestrate/references/full.md`

#### 結果

- pass
- Codex / Claude Code 両方の `full.md` に Gate 2 pass とユーザー承認後の Phase 3 entry condition、実装結果による上流 artifact 作り直し禁止がある。

#### 未実行理由 / 代替確認

- N/A

### TC-003: Gate review が後付け artifact を fail として扱う

#### 対応

- `request.md` scope / acceptance

#### 種別

- manual

#### 手順

1. `rg -n '上流 artifact|後付け|実装開始後' dot_codex/skills/orchestrate/references/gate-review.md dot_claude/skills/orchestrate/references/gate-review.md`

#### 結果

- pass
- Gate review の共通 pass / fail 条件と Gate 3 pass 条件に、次工程前の上流 artifact 確定と後付け禁止が入っている。

#### 未実行理由 / 代替確認

- N/A

### TC-004: Codex / Claude Code surface の同期

#### 対応

- `request.md` scope / acceptance

#### 種別

- manual

#### 手順

1. `diff -u dot_codex/skills/orchestrate/references/standard.md dot_claude/skills/orchestrate/references/standard.md`
2. `diff -u dot_codex/skills/orchestrate/references/gate-review.md dot_claude/skills/orchestrate/references/gate-review.md`
3. `diff -u dot_codex/skills/orchestrate/references/full.md dot_claude/skills/orchestrate/references/full.md`

#### 結果

- pass
- `standard.md` と `gate-review.md` は一致した。
- `full.md` は末尾の既存 wording (`agent` / `subagent`) だけ差分が残る。今回追加した Phase 3 entry condition と後付け禁止の記述は一致している。

#### 未実行理由 / 代替確認

- N/A

## Executed Checks

- `git diff --check`: pass
- `rg -n '実装後に作る|実装前に必要だった要件|実装や検証の結果を根拠|Phase 3 entry condition' dot_codex/skills/orchestrate/references dot_claude/skills/orchestrate/references`: pass
- quality-reviewer agent review: blocking なし。任意改善として standard の trace 反復と repository-maintainer 長文の削減を採用。
- `git status --short`: changed files and new request artifacts confirmed

## Unverified Items

- none

## Remaining Risks

- `dot_codex/skills/orchestrate/references/full.md` と `dot_claude/skills/orchestrate/references/full.md` には、今回の変更以前から末尾の `agent` / `subagent` wording 差分がある。今回の scope では変更していない。
