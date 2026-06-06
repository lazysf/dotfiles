# Test

## Summary

- Result: pass
- Scope: `reduce-non-reviewer-agents` 実装の `AC-001`〜`AC-012` を read-only inspection で観測。AC-001 / AC-003 / AC-004 / AC-005 / AC-006 / AC-007 / AC-008 / AC-009 / AC-010 / AC-011 / AC-012 は pass。AC-002 は inspector 検出時点で `settings.json` 5 件 + 工程語 4 箇所が partial だったが、lead が Phase 3 内追従修正で全件解消（`settings.json` の dead permission 削除 + 工程語 4 箇所を意味整合的に書き換え）。再 grep で全件 0 件確認。

## Test Cases

### TC-001: 両 surface agent 集合が 6 個で一致する

#### 対応

- `AC-001`
- `AC-009`
- `TASK-007`

#### 種別

- manual

#### 手順

1. `ls dot_claude/agents/ dot_codex/agents/` を実行。
2. basename 集合が `{design-reviewer, inspector, quality-reviewer, requirements-reviewer, researcher, security-reviewer}` の 6 個と一致するか目視確認。

#### 結果

- pass
- 両 surface とも 6 ファイル、basename 集合完全一致。削除対象 5 種 (`architect` / `requirements-engineer` / `task-planner` / `implementer` / `repository-maintainer`) の `.md` / `.toml` はいずれも存在しない。

### TC-002: 削除対象 agent 名の grep が除外パス指定で 0 件

#### 対応

- `AC-002`
- `TASK-013`

#### 種別

- automated (grep)

#### 手順

1. `rg -n 'architect\b|requirements-engineer|task-planner|implementer|repository-maintainer' . -g '!docs/adr/**' -g '!docs/requests/reduce-non-reviewer-agents/**' -g '!docs/requests/agent-skill-name-pair-alignment/**' -g '!docs/requests/claude-orchestrate-tier-display/**'` を実行。

#### 結果

- pass
- 初回 inspection 時点では `dot_claude/settings.json` line 18 / 20 / 23 / 24 / 28 に削除済み 5 agent への dead permission descriptor が残置していたが、Phase 3 内追従修正で削除（残置は 6 個の `Agent(<残置 agent>)` のみ）。また `full.md` L143 / `standard.md` L127 / `runtime-surface-guidance.md` L12 / L22 の工程語 `repository maintenance` を意味整合的に書き換え。再 grep `rg -n 'architect\b|requirements-engineer|task-planner|implementer|repository-maintainer|repository maintenance' . -g '!docs/adr/**' -g '!docs/requests/reduce-non-reviewer-agents/**' -g '!docs/requests/agent-skill-name-pair-alignment/**' -g '!docs/requests/claude-orchestrate-tier-display/**'` で 0 件。
- `architect\b` 語境界で skill 名 `architecture` への誤 hit を回避。

### TC-003: tier reference の `- agent:` 行が許容集合のみで構成され、Gate 3 前 docs 確認が `doc-followup` 経路で記述

#### 対応

- `AC-003`
- `TASK-002`
- `TASK-004`

#### 種別

- manual

#### 手順

1. `rg -n '^- agent:' dot_{claude,codex}/skills/orchestrate/references/{full,standard,micro}.md` で agent 列挙を抽出。
2. `lead` / `researcher` / `inspector` / `requirements-reviewer` / `design-reviewer` / `security-reviewer` / `quality-reviewer` / 複合 (`lead / inspector` 等) のみであることを目視確認。
3. `rg -n 'doc-followup|Gate 3 前 docs 確認'` で経路明記を確認。

#### 結果

- pass
- 両 surface 6 ファイルすべての `- agent:` 行が許容集合内。`Gate 3 前 docs 確認` 工程が full / standard / micro いずれにも存在し、進め方文に「lead が必要時に doc-followup skill を使って…」が記述。

### TC-004: micro.md に `implementer` 言及がない

#### 対応

- `AC-004`
- `TASK-002`

#### 種別

- automated (grep)

#### 手順

1. `rg -n 'implementer' dot_claude/skills/orchestrate/references/micro.md dot_codex/skills/orchestrate/references/micro.md`。

#### 結果

- pass
- 両ファイル 0 件。

### TC-005: orchestrate SKILL.md に lead + scribe による artifact 作成方針が明記、scribe references の章立て diff が想定範囲

#### 対応

- `AC-005`
- `TASK-005`

#### 種別

- manual

#### 手順

1. `rg -n 'scribe' dot_{claude,codex}/skills/orchestrate/SKILL.md`。
2. `diff dot_claude/skills/scribe/references dot_codex/skills/scribe/references` で format reference の差分が章立て改変ではないことを確認。

#### 結果

- pass
- 両 surface SKILL.md の line 36 に「要件 / 設計 / task / 実装 / 検証 artifact は lead が scribe skill を使って書く。format reference (scribe/references/*-format.md) は正本として変更しない。」が存在。
- `scribe/references/` 比較は (a) Codex 側のみ存在する `artifact-workflows.md` / `implementation-plan-format.md` / `prd-format.md` (本要求 Scope 外、既存差分)、(b) `context-format.md` / `readme-format.md` / `request-format.md` の secret 取扱記述の surface 差 (既存差分)。本要求対象の `implementation-format.md` を含む `*-format.md` は章立て・ID 規則・記述順に diff なし。

### TC-006: handoff.md の Engineering Agent Output 縮約と除去 schema 不在

#### 対応

- `AC-006`
- `TASK-003`

#### 種別

- automated (grep) + manual

#### 手順

1. `rg -n 'Engineering Agent Output|Repository Maintenance Impact|verifier_return_required|repository-maintainer|repository maintenance' dot_{claude,codex}/skills/orchestrate/references/handoff.md`。
2. Engineering Agent Output セクションの対象列挙行を目視。

#### 結果

- pass
- `Engineering Agent Output` 見出しのみが両 surface line 5 に存在。対象列挙は line 7 `対象: \`researcher\` / \`inspector\``のみ。`Repository Maintenance Impact`block、`verifier_return_required`field、`repository-maintainer` / `repository maintenance` 文字列はいずれも 0 件。

### TC-007: ADR 0034 存在と双方向 Supersedes / Superseded-By メタ整合

#### 対応

- `AC-007`
- `TASK-008`
- `TASK-009`

#### 種別

- manual

#### 手順

1. `ls docs/adr/0034-reduce-non-reviewer-agents.md` で存在確認。
2. `rg -n 'Supersedes|Superseded-By|Status' docs/adr/0034-reduce-non-reviewer-agents.md docs/adr/0024-add-repository-maintainer-agent.md docs/adr/0028-align-agent-names-with-skill-pairs.md`。

#### 結果

- pass
- ADR 0034: `Status: Accepted` / `Supersedes: 0024, 0028`。
- ADR 0024: `Status: Superseded` / `Superseded-By: 0034`。
- ADR 0028: `Status: Superseded` / `Superseded-By: 0034`。

### TC-008: ADR 0034 本文に constraint enforcement 喪失と 3 層代替戦略の対応が読める

#### 対応

- `AC-008`
- `TASK-008`

#### 種別

- manual

#### 手順

1. ADR 0034 本文の背景・決定・影響節を読み、(i) 失われる constraint enforcement と (ii) 代替戦略 (`stop-lines.md` + skill 境界 + lead 停止線) の対応を確認。

#### 結果

- pass
- 背景節 line 8 で subagent 化メリット (a) isolation / (b) constraint enforcement を分離。影響節 line 26 で (i) stop-lines カタログ、(ii) 各 skill SKILL.md 境界、(iii) lead 自走停止線の 3 層代替を明示。

### TC-009: Phase 3 着手直前 commit hash が basic-design.md に記録、行番号差分なし

#### 対応

- `AC-010`
- `TASK-001`

#### 種別

- manual

#### 手順

1. `rg -n '909858230f70ffdc4f674c6c1e485a60ab1952aa|Phase 3 着手' docs/requests/reduce-non-reviewer-agents/basic-design.md`。

#### 結果

- pass
- `basic-design.md` line 82-84 に `## Phase 3 着手時 commit hash` 節と HEAD `909858230f70ffdc4f674c6c1e485a60ab1952aa` を記録。implementation.md にも「行番号差分なし」と明記、detailed-design 更新不要。

### TC-010: CLAUDE.md / AGENTS.md「置き場」節から repository maintenance 工程語が消えている

#### 対応

- `AC-011`
- `TASK-014`

#### 種別

- automated (grep)

#### 手順

1. `rg -n 'repository maintenance|repository-maintainer' dot_claude/CLAUDE.md dot_codex/AGENTS.md`。

#### 結果

- pass
- 両ファイルともヒット 0 件。`dot_claude/CLAUDE.md` line 32 は「`~/.claude/agents/`: 仕様駆動 workflow を担う specialist agent 群（調査・検証の specialist と review 入口）」に書き換え済み。

### TC-011: reviewer 4 種 agent 定義から `repository-maintainer` / 関連 field / 工程語が除去

#### 対応

- `AC-012`
- `TASK-015`
- `TASK-016`

#### 種別

- automated (grep)

#### 手順

1. `rg -n 'repository-maintainer|security_ci_impact|behavior_delta|quality_gate_impact|verifier_return_required|repository maintenance' dot_claude/agents/{security,quality,requirements,design}-reviewer.md dot_codex/agents/{security,quality,requirements,design}-reviewer.toml`。

#### 結果

- pass
- 4 種 reviewer × 2 surface = 8 ファイルすべてで 0 件。

## Executed Checks

- `ls dot_claude/agents/ dot_codex/agents/`: 6 ファイルずつ、basename 集合完全一致。
- `rg -n 'architect\b|requirements-engineer|task-planner|implementer|repository-maintainer' . -g '!docs/adr/**' -g '!docs/requests/reduce-non-reviewer-agents/**' -g '!docs/requests/agent-skill-name-pair-alignment/**' -g '!docs/requests/claude-orchestrate-tier-display/**'`: stdout 空。
- `rg -n 'Agent\(architect\)|Agent\(implementer\)|Agent\(repository-maintainer\)|Agent\(requirements-engineer\)|Agent\(task-planner\)' dot_claude/settings.json`: 5 件ヒット (line 18 / 20 / 23 / 24 / 28)。
- `rg -n '^- agent:' dot_{claude,codex}/skills/orchestrate/references/{full,standard,micro}.md`: 計 32 行、いずれも許容集合内。
- `rg -n 'doc-followup|Gate 3 前 docs 確認' dot_{claude,codex}/skills/orchestrate/references/{full,standard,micro}.md`: 全 6 ファイルにヒット。
- `rg -n 'implementer' dot_claude/skills/orchestrate/references/micro.md dot_codex/skills/orchestrate/references/micro.md`: 0 件。
- `rg -n 'scribe' dot_claude/skills/orchestrate/SKILL.md dot_codex/skills/orchestrate/SKILL.md`: 両 line 36 にヒット。
- `diff dot_claude/skills/scribe/references dot_codex/skills/scribe/references`: 既存 surface 差のみ、章立て diff なし。
- `rg -n 'Engineering Agent Output|Repository Maintenance Impact|verifier_return_required|repository-maintainer|repository maintenance' dot_{claude,codex}/skills/orchestrate/references/handoff.md`: `Engineering Agent Output` 見出しのみ各 1 件。
- `rg -n 'Supersedes|Superseded-By|Status' docs/adr/{0034-reduce-non-reviewer-agents,0024-add-repository-maintainer-agent,0028-align-agent-names-with-skill-pairs}.md`: 双方向整合確認。
- `rg -n '909858230f70ffdc4f674c6c1e485a60ab1952aa|commit' docs/requests/reduce-non-reviewer-agents/basic-design.md`: line 82-84 にヒット。
- `rg -n 'repository maintenance|repository-maintainer' dot_claude/CLAUDE.md dot_codex/AGENTS.md`: 0 件。
- `rg -n 'repository-maintainer|security_ci_impact|behavior_delta|quality_gate_impact|verifier_return_required|repository maintenance' dot_{claude,codex}/agents/{security,quality,requirements,design}-reviewer.{md,toml}`: 0 件。
- `rg -n 'repository maintenance' dot_claude/skills/orchestrate/references/full.md dot_claude/skills/orchestrate/references/standard.md docs/notes/runtime-surface-guidance.md`: 計 4 件（`full.md` line 143、`standard.md` line 127、`runtime-surface-guidance.md` line 12 / 22）。

## Unverified Items

- test / lint / build は dotfiles repo の性質上 automated test suite が無いため未実行。本検証は静的 grep / diff / 目視 inspection に閉じる。
- chezmoi 配布動作 (`chezmoi apply` 後の `~/.claude/agents/` / `~/.codex/agents/` 実体差分) は範囲外。
- `rg` 既定除外で `settings.json` が AC-002 grep からスキップされた可能性。`settings.json` 自体は別途 `Agent(...)` 直接 grep で 5 件残置を確認済み。

## Remaining Risks

解消済み (Phase 3 内追従修正 + Gate 3 後 cleanup):

- `dot_claude/settings.json` 5 行 dead permission 削除 (削除済み agent への `Agent(...)` allowlist 5 行を除去、残置 6 agent のみ)。
- `dot_claude/skills/orchestrate/references/full.md` L143 / `dot_codex/...` 同行: `repository maintenance 後の全変更セット` -> `全変更セット`。
- `dot_claude/skills/orchestrate/references/standard.md` L127 / `dot_codex/...` 同行: `implementation.md / test.md / repository maintenance handoff` -> `implementation.md / test.md`。
- `docs/notes/runtime-surface-guidance.md` L12 / L22: orchestrate description と agents/ 説明文から `repository maintenance` 工程語を除去。
- (Gate 3 後 cleanup) `docs/notes/harness-design-principles.md` L38 / L66: 「workflow 工程担当、repository maintenance、reviewer」「工程担当、repository maintenance、reviewer」を「調査・検証 specialist、reviewer」表現へ書き換え。
- (Gate 3 後 cleanup) `docs/notes/harness-regression-checks.md` L133 / L287: 「Gate 3 review/reviewer へは repository maintenance 後の全変更セット」を「Gate 3 review/reviewer へは全変更セット」表現へ書き換え。
- 最終 grep (`repository maintenance|repository-maintainer|architect\b|requirements-engineer|task-planner|implementer|verifier_return_required|behavior_delta|quality_gate_impact|security_ci_impact` を `docs/adr/**` / `docs/requests/**` 除外で全 repo 範囲) で 0 件。

残置リスク:

- ADR 0034 「3 層代替戦略」（`stop-lines.md` カタログ + skill 境界 + lead 停止線）の運用効果は実運用での観測待ち。本検証 scope 外。Gate 2 security review NB-S04 / NB-S05 と同質。
