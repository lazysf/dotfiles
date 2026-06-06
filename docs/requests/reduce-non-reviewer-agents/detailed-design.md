# Detailed Design

## 対象範囲

- `dot_claude/agents/` および `dot_codex/agents/` 配下の削除対象 5 種 agent 定義（計 10 ファイル）。
- `dot_claude/skills/orchestrate/` および `dot_codex/skills/orchestrate/` 配下の `SKILL.md`、`references/full.md`、`references/standard.md`、`references/micro.md`、`references/handoff.md`、`references/gate-review.md`。
- `dot_claude/skills/architecture/SKILL.md` と `dot_codex/skills/architecture/SKILL.md`。
- `dot_claude/skills/implement/SKILL.md` と `dot_codex/skills/implement/SKILL.md`。
- `dot_claude/skills/scribe/references/implementation-format.md` と `dot_codex/skills/scribe/references/implementation-format.md`。
- `docs/notes/runtime-surface-guidance.md`、`docs/notes/harness-design-principles.md`、`docs/notes/harness-regression-checks.md`。
- 新規 ADR `docs/adr/0034-reduce-non-reviewer-agents.md`、既存 ADR `docs/adr/0024-add-repository-maintainer-agent.md` および `docs/adr/0028-align-agent-names-with-skill-pairs.md` のメタデータ。
- `dot_claude/CLAUDE.md` および `dot_codex/AGENTS.md` の「置き場」節 `agents/` 説明文。
- `dot_claude/agents/security-reviewer.md` / `dot_claude/agents/quality-reviewer.md` および `dot_codex/agents/security-reviewer.toml` / `dot_codex/agents/quality-reviewer.toml` の `repository-maintainer` / `repository maintenance` 参照箇所。

## Interface 詳細

- `dot_claude/agents/*.md`: Claude Code の subagent 定義。frontmatter `name` と本文を持つ。`name` と basename が一致する命名規約。
- `dot_codex/agents/*.toml`: Codex の subagent 定義。`name` field と本文を持つ。
- `orchestrate/references/<tier>.md`: tier flow の正本。各工程を `### <工程名>` で書き、`- 扱い:` / `- agent:` / `- artifact:` / `- format:` / `- 進め方:` の 5 行を持つ。
- `orchestrate/references/handoff.md`: agent 出力 schema。`Engineering Agent Output` 対象列挙と template、`repository-maintainer` 追加 block、`Rules` 節を持つ。
- `scribe/references/implementation-format.md`: `implementation.md` の正本 template。`Rules` 節と markdown コードブロック内 template を持つ。

## 詳細設計項目

- `DD-001` (`BD-001` / `AC-001` / `AC-009`): 以下 10 ファイルを物理削除する。削除順序は無依存のため任意。
  - `dot_claude/agents/architect.md`
  - `dot_claude/agents/requirements-engineer.md`
  - `dot_claude/agents/task-planner.md`
  - `dot_claude/agents/implementer.md`
  - `dot_claude/agents/repository-maintainer.md`
  - `dot_codex/agents/architect.toml`
  - `dot_codex/agents/requirements-engineer.toml`
  - `dot_codex/agents/task-planner.toml`
  - `dot_codex/agents/implementer.toml`
  - `dot_codex/agents/repository-maintainer.toml`
- `DD-002` (`BD-002` / `AC-003`): `dot_claude/skills/orchestrate/references/full.md` を行単位で以下に書き換える。同変更を `dot_codex/skills/orchestrate/references/full.md` にも対称適用する。
  - line 26 `- agent: \`requirements-engineer\`` -> `- agent: lead`。直後の line 29 進め方を`lead が requirements skill を使い、目的、scope / non-scope、REQ-*、AC-*、制約、前提、未確認事項を整理する。実装方法や詳細設計は決めない。artifact は scribe で書く。` に置換。
  - line 62 `- agent: \`architect\`` -> `- agent: lead`。line 65 進め方を`lead が architecture skill を使い、全体方針、責務分担、主要 component / module 境界、主要 interface / API / data flow、既存構造との接続点、security / 権限 / data / 外部 I/O の扱いを書く。artifact は scribe で書く。` に置換。
  - line 70 `- agent: \`architect\`` -> `- agent: lead`。line 73 進め方を`lead が architecture skill を使い、処理手順、入出力、validation、error handling、edge case、状態遷移、test 観点を書く。artifact は scribe で書く。` に置換。
  - line 78 `- agent: \`task-planner\`` -> `- agent: lead`。line 81 進め方を`lead が task-planning skill を使い、TASK-*、実装順序、完了条件、確認方法、変更境界を書く。artifact は scribe で書く。` に置換。
  - line 114 `- agent: \`implementer\`` -> `- agent: lead`。line 117 進め方を`lead が implement skill を使い、Phase 3 entry condition を満たしたうえで、tasks.md と設計に沿って code / config / tests を実装し、対応 task、変更内容、変更ファイル、実行した確認、残リスクを書く。実装結果を根拠に上流 artifact を作り直さない。artifact は scribe で書く。` に置換。
  - line 127–133 の `### repository maintenance` セクション全体を以下に置換: `### Gate 3 前 docs 確認 / 扱い: 必要時 / agent: lead / artifact: なし、または request.md / implementation.md の自然な節 / format: なし / 進め方: lead が必要時に doc-followup skill を使って docs / references / prose の追従更新と参照ずれ確認を行う。request artifact は自分の docs/requests/<slug>/ 配下だけ編集する。Gate 3 着手前に確認結果と残リスクを request.md または implementation.md に短くまとめる。`
  - line 164 `- \`repository-maintainer\` が \`blocked\` を返した場合、Gate 3 へ進めない。` を削除（工程廃止）。
  - line 169 「lead が後続 agent へ必要分だけ渡す」は維持（researcher / inspector / reviewer は agent のまま）。
- `DD-003` (`BD-002` / `AC-003`): `dot_claude/skills/orchestrate/references/standard.md` を以下に書き換える。Codex 側にも対称適用。
  - line 26 `- agent: lead / \`requirements-engineer\`` -> `- agent: lead`。進め方の skill 名併記を維持。
  - line 44 `- agent: \`architect\`` -> `- agent: lead`。
  - line 52 `- agent: \`architect\`` -> `- agent: lead`。
  - line 60 `- agent: lead / \`task-planner\`` -> `- agent: lead`。
  - line 78 `- agent: lead / \`implementer\`` -> `- agent: lead`。
  - line 91–97 の `### repository maintenance` セクションを `### Gate 3 前 docs 確認` に置き換え。標準 tier の文言は full と同方針で簡潔に書く。`agent: lead` / `扱い: 必要時`。
  - line 119 `- \`repository-maintainer\` が \`blocked\` を返した場合、Gate 3 へ進めない。` を削除。
- `DD-004` (`BD-003` / `AC-004`): `dot_claude/skills/orchestrate/references/micro.md` を以下に書き換える。Codex 側にも対称適用。
  - line 18 `- agent: lead / \`implementer\`` -> `- agent: lead`。
  - line 21 「lead が直接実装する。必要なら `implementer` か該当 skill を使う。」を「lead が直接実装する。必要なら該当 skill を使う。」に置換。
  - line 31–37 の `### repository maintenance` を `### Gate 3 前 docs 確認` に置き換え、`agent: lead` / `扱い: 任意`。`lead が必要時に doc-followup skill を使う。` 等の文言に揃える。
- `DD-005` (`BD-005` / `AC-006`): `dot_claude/skills/orchestrate/references/handoff.md` を以下に書き換える。Codex 側にも対称適用。
  - line 7 `対象: \`researcher\` / \`requirements-engineer\` / \`architect\` / \`task-planner\` / \`implementer\` / \`inspector\` / \`repository-maintainer\`` を `対象: \`researcher\` / \`inspector\`` に置換。
  - line 68–96 の「`repository-maintainer` は通常項目に加えて以下も返す。」段落と続く markdown コードブロック全体（`Repository Maintenance Impact` block）を削除。
  - `verifier_return_required` field を schema から**完全廃止**する。Engineering Agent Output template 内に同 field の出力指示があれば該当行を削除する。
  - line 165 `\`repository-maintainer\` の \`behavior_delta\` が \`changed\` を含む場合、\`verifier_return_required\` は \`yes\` にする。` を**削除**（field 廃止に伴い rule 不要）。
  - line 166 `\`repository-maintainer\` は品質ゲート弱体化や runtime guardrail 変更を行わず、必要なら \`Blockers\` に返す。` を削除。
  - line 167 `\`repository-maintainer\` が \`blocked\` を返した場合、lead は Gate 3 へ進めない。runtime guardrail / CI permission / secret / auth / 権限 / 外部送信 / deploy / publish に触れる blocker は、前工程へ自律差戻しせずユーザー確認または change-request 候補にする。` を `lead が doc-followup で品質ゲート弱体化や runtime guardrail / CI permission / secret / auth / 権限 / 外部送信 / deploy / publish 影響に触れる必要が出た場合は、前工程へ自律差戻しせずユーザー確認または change-request 候補にする。` に書き換える。
  - schema 互換破棄（`verifier_return_required` 廃止）は ADR 0034 で superseded 関係として記録する。
- `DD-006` (`BD-002` / `BD-005`): `dot_claude/skills/orchestrate/references/gate-review.md` line 74 `repository-maintainer が変更したファイル差分は、必要に応じて補助情報として reviewer 入力に含まれている。` を `lead が doc-followup で変更したファイル差分は、必要に応じて補助情報として reviewer 入力に含まれている。` に書き換える。Codex 側にも対称適用。同節内 `repository maintenance` 主語の関連行（line 67、71、72、73、77 等）を「Gate 3 前 docs 確認」「lead が doc-followup で行った確認」表現に揃える。
- `DD-007` (`BD-002` / `BD-007`): `dot_claude/skills/orchestrate/SKILL.md` line 26 `\`repository-maintainer\`、docs follow-up、Gate fail 修正でもこの境界を維持する。` を `Gate 3 前 docs 確認、Gate fail 修正でもこの境界を維持する。` に書き換える。Codex 側 line 26 にも対称適用。
- `DD-008` (`BD-004` / `AC-005`): `dot_claude/skills/orchestrate/SKILL.md` の「自走と確認 checkpoint」セクション末尾に、`要件 / 設計 / task / 実装 / 検証 artifact は、lead が scribe skill を使って書く。format reference (scribe/references/*-format.md) は正本として変更しない。` の 1 行を追加する。Codex 側にも対称適用。
- `DD-009` (`BD-006` / `AC-002`): `dot_claude/skills/implement/SKILL.md` line 3 description `implementer が tasks.md と detailed-design.md に沿って code、config、tests を実装し、implementation.md に変更内容を記録する時に使う。` を `lead が tasks.md と detailed-design.md に沿って code、config、tests を実装し、implementation.md に変更内容を記録する時に使う。` に書き換える。Codex 側 description にも対称適用。
- `DD-010` (`BD-006` / `AC-002`): `dot_claude/skills/architecture/SKILL.md` line 3 description `architect が basic-design.md / detailed-design.md を作る前に、構造改善、責務分担、module boundary、interface、data flow、testability、security boundary を整理する時に使う。` を `lead が basic-design.md / detailed-design.md を作る前に、構造改善、責務分担、module boundary、interface、data flow、testability、security boundary を整理する時に使う。` に書き換える。Codex 側にも対称適用。
- `DD-011` (`BD-006` / `AC-002`): `dot_claude/skills/scribe/references/implementation-format.md` line 40 `- [implementer が実行した確認。inspector の最終結果は \`test.md\` に置く。]` を `- [lead または inspector が実行した確認。inspector の最終結果は \`test.md\` に置く。]` に書き換える。Codex 側にも対称適用。format の章立て・ID 規則・記述順は変更しない。
- `DD-012` (`BD-007` / `AC-002` / `AC-003`): `docs/notes/runtime-surface-guidance.md` を以下に書き換える。
  - line 15 `architecture` 説明文の主語が agent ではなく skill 自体のため、本文は維持。`architect` 単語の参照はないため変更不要。
  - line 18 `\`doc-followup\`: ... \`orchestrate\` では \`repository-maintainer\` が docs 追従更新の手順として使う` を `\`doc-followup\`: ... \`orchestrate\` では lead が Gate 3 前 docs 追従更新の手順として使う` に書き換える。
  - line 35 `workflow 内の実装後 repo hygiene / docs / tooling 設定の仕上げは \`repository-maintainer\` agent を使う。` を `workflow 内の実装後 repo hygiene / docs / tooling 設定の仕上げは lead が \`doc-followup\` skill を使う。` に書き換える。
  - line 42 `Gate 3 前の docs / references / prose の追従更新と repo hygiene / tooling 設定の影響確認は \`repository-maintainer\` を使い、Gate 3 reviewer は repository maintenance 後の全変更セットと handoff の品質ゲート影響、security / CI 影響を確認する` を `Gate 3 前の docs / references / prose の追従更新と repo hygiene / tooling 設定の影響確認は lead が \`doc-followup\` skill で行い、Gate 3 reviewer は全変更セットと品質ゲート影響、security / CI 影響を確認する` に書き換える。
  - line 79 `[ADR 0024](../adr/0024-add-repository-maintainer-agent.md)` の直下に `[ADR 0034](../adr/0034-reduce-non-reviewer-agents.md)` を追加する。
- `DD-013` (`BD-007` / `AC-002`): `docs/notes/harness-design-principles.md` を以下に書き換える。
  - line 72 `実装後の repo hygiene / docs / tooling 設定の仕上げは \`repository-maintainer\` agent に分け、lead は handoff 統合とユーザー確認を担う` を `実装後の repo hygiene / docs / tooling 設定の仕上げは lead が \`doc-followup\` skill を使って行い、ユーザー確認を含めて lead が一貫して担う` に書き換える。
  - line 100 `[ADR 0024](../adr/0024-add-repository-maintainer-agent.md)` の直下に `[ADR 0034](../adr/0034-reduce-non-reviewer-agents.md)` を追加する。
- `DD-014` (`BD-007` / `AC-002`): `docs/notes/harness-regression-checks.md` を以下に書き換える。
  - line 122 `変更後の参照ずれや docs 追従更新は \`doc-followup\` または \`repository-maintainer\` と切り分けられる` を `変更後の参照ずれや docs 追従更新は lead が \`doc-followup\` skill を使って行う` に書き換える。
  - line 125 `### 9.5. 変更後の repo maintenance が \`repository-maintainer\` に乗る` を `### 9.5. 変更後の repo maintenance を lead が doc-followup で扱う` に書き換える。
  - line 129 `\`orchestrate\` workflow では、実装・検証後かつ Gate 3 前に \`repository-maintainer\` が docs / references / prose の追従更新と repo hygiene / tooling 設定の影響確認を行う` を `\`orchestrate\` workflow では、実装・検証後かつ Gate 3 前に lead が \`doc-followup\` skill で docs / references / prose の追従更新と repo hygiene / tooling 設定の影響確認を行う` に書き換える。
  - line 186 `workflow 内で実装後の repo hygiene / docs / tooling 設定まで仕上げる場合は \`repository-maintainer\` に進む` を `workflow 内で実装後の repo hygiene / docs / tooling 設定まで仕上げる場合は lead が \`doc-followup\` skill を使う` に書き換える。
  - line 189 `\`doc-followup\` または \`repository-maintainer\` が修正を加えた場合、次の commit 導線で差分と 1 コミット 1 変更のまとまりが確認される` を `lead が \`doc-followup\` で修正を加えた場合、次の commit 導線で差分と 1 コミット 1 変更のまとまりが確認される` に書き換える。
  - line 228 `architecture 改善候補を見つけたい依頼は \`architecture\` に案内される` は skill 名のため維持。
  - line 229 / line 230 も skill `architecture` への言及であり agent ではないため維持。
  - line 242 `実装後の repo hygiene / docs / tooling 設定の仕上げは \`repository-maintainer\` に分離されている` を `実装後の repo hygiene / docs / tooling 設定の仕上げは lead が \`doc-followup\` skill で行う` に書き換える。
  - line 286 `\`repository-maintainer\` へは、実装差分、inspector handoff、repo hygiene / tooling 設定の確認範囲、Gate 3 reviewer に渡すべき観点を明示して渡す` を `lead は \`doc-followup\` skill 適用前に、実装差分、inspector handoff、repo hygiene / tooling 設定の確認範囲、Gate 3 reviewer に渡すべき観点を整理する` に書き換える。
  - line 324 `[ADR 0024](../adr/0024-add-repository-maintainer-agent.md)` の直下に `[ADR 0034](../adr/0034-reduce-non-reviewer-agents.md)` を追加する。
- `DD-015` (`BD-008` / `AC-007` / `AC-008`): 新規 ADR ファイル `docs/adr/0034-reduce-non-reviewer-agents.md` を以下構造で作成する（実際の作成は Phase 3）。
  - 1 行目: `# 0034: non-reviewer agent を researcher / inspector のみへ集約する`
  - `Status: Accepted`
  - `Supersedes: 0024, 0028`
  - 背景: 11 agent 構成と subagent 化の 2 価値（isolation / constraint enforcement）整理、handoff loss の課題、最新 `orchestrate` workflow への追従。
  - 決定: reviewer 4 + researcher + inspector の 6 agent に集約、要件・設計・task・実装は lead 一貫 + `scribe`、Gate 3 前 docs 追従は lead が `doc-followup` を使う。
  - 影響: constraint enforcement 喪失を `stop-lines.md` カタログ + skill 境界 + lead 停止線で代替（`REQ-011`）、ADR 0024 / 0028 superseded、ADR 本文編集境界（ADR 0022）に従い旧 ADR 本文は履歴維持、`verifier_return_required` field 名は schema 互換維持。
- `DD-016` (`BD-008` / `AC-007`): `docs/adr/0024-add-repository-maintainer-agent.md` の `- Status: Accepted` を `- Status: Superseded` に変更し、その直下に `- Superseded-By: 0034` を追加する。本文は変更しない。
- `DD-017` (`BD-008` / `AC-007`): `docs/adr/0028-align-agent-names-with-skill-pairs.md` の `- Status: Accepted` を `- Status: Superseded` に変更し、その直下に `- Superseded-By: 0034` を追加する。本文は変更しない。
- `DD-018` (`BD-009` / `AC-010`): Phase 3 着手直前に lead が `git log -1 --format=%H HEAD` で最新 commit hash を取得し、`basic-design.md` 末尾「未確認事項」直前に短い節として記録する。researcher handoff 取得時 commit hash と差分があり、本 detailed-design の行番号が変動している場合、影響を受ける `DD-002` から `DD-014` の行番号を更新する。差分が agent 名以外の構造変更（Phase / Gate 構造、工程追加削除）を含む場合は Phase 2 に差し戻す。
- `DD-019` (`BD-010` / `AC-009`): 検証時に両 surface 対称性を以下で観測する。(1) `Glob` で `dot_claude/agents/*.md` と `dot_codex/agents/*.toml` を取得し、basename 集合 (`{researcher, inspector, requirements-reviewer, design-reviewer, security-reviewer, quality-reviewer}`) と一致することを確認。(2) 各 tier reference の Phase / Gate セクション、工程名集合、`扱い` 値が両 surface で一致することを目視確認。
- `DD-020` (`BD-011` / `AC-011`): `dot_claude/CLAUDE.md` line 32 `- \`~/.claude/agents/\`: 仕様駆動 workflow を担う専門 agent 群（要件・設計・実装・検証・repository maintenance の各役と review 入口）。lead が spawn する specialist。進行は main セッション（lead, \`skills/orchestrate\`）が決める。` を `- \`~/.claude/agents/\`: 仕様駆動 workflow を担う specialist agent 群（調査・検証の specialist と review 入口）。lead が spawn する specialist。進行は main セッション（lead, \`skills/orchestrate\`）が決める。`に書き換える。`dot_codex/AGENTS.md` line 55 `- \`~/.codex/agents/\`: multi-agent workflow を担う専門 agent 群（調査・要件・設計・実装・検証・repository maintenance の各役と review 入口）` を `- \`~/.codex/agents/\`: multi-agent workflow を担う specialist agent 群（調査・検証の specialist と review 入口）` に書き換える。前後の枠付け文（lead spawn / main セッション進行 / skill 参照）は維持。
- `DD-021` (`BD-012` / `AC-012`): `dot_claude/agents/security-reviewer.md` および `dot_codex/agents/security-reviewer.toml` を以下に書き換える。
  - line 20 (`.md`) / line 13 (`.toml`) `- repository maintenance がある場合は、CI permission、secret、外部 I/O、deploy / publish 経路、script / command 変更の security impact を確認する。` を `- lead が \`doc-followup\` で docs / 参照ずれ確認や tooling / runtime guardrail 差分を観測した場合は、CI permission、secret、外部 I/O、deploy / publish 経路、script / command 変更の security impact を確認する。` に書き換える。
  - line 27 (`.md`) / line 19 (`.toml`) `Gate 3: 全成果物、repository maintenance 後の全変更セット、\`test.md\`、repository-maintainer handoff、researcher handoff の security-relevant observations。` を `Gate 3: 全成果物、全変更セット、\`test.md\`、researcher handoff の security-relevant observations、lead が \`doc-followup\` で行った docs / 参照ずれ確認結果。` に書き換える。
  - line 46 (`.md`) / line 29 (`.toml`) `repository-maintainer handoff の \`security_ci_impact\` を見て、CI permission / token / secret / OIDC / external I/O / deploy / publish への影響を確認する。` を `全変更セットおよび \`test.md\` から、CI permission / token / secret / OIDC / external I/O / deploy / publish への影響を確認する。lead が \`doc-followup\` で観測した tooling / runtime guardrail 差分があればその記録も併せて確認する。` に書き換える。
  - その他の節（責務、停止線、出力 schema、Reviewer Execution Boundary）は変更しない。両 surface 対称適用。
- `DD-022` (`BD-012` / `AC-012`): `dot_claude/agents/quality-reviewer.md` および `dot_codex/agents/quality-reviewer.toml` を以下に書き換える。
  - description (`.md` line 3 / `.toml` line 2) `Gate 3 と workflow 外の diff review で、scope、可読性、回帰、テスト妥当性、repository maintenance 影響を read-only review する時に使う。` を `Gate 3 と workflow 外の diff review で、scope、可読性、回帰、テスト妥当性を read-only review する時に使う。` に書き換える（「、repository maintenance 影響」を削除）。
  - 役割節 (`.md` line 17 / `.toml` line 11) `要件、設計、task、repository maintenance 後の全変更セット、test 結果の整合を read-only で確認する。` を `要件、設計、task、全変更セット、test 結果の整合を read-only で確認する。` に書き換える。
  - 役割節 (`.md` line 22 / `.toml` line 16) `repository maintenance がある場合は、docs / repo hygiene / tooling 設定の変更が scope 内で、品質ゲートを不当に弱めていないか確認する。` を `lead が \`doc-followup\` で docs / repo hygiene / tooling 設定に変更を加えた場合は、scope 内で品質ゲートを不当に弱めていないか確認する。` に書き換える。
  - 入力節 (`.md` line 27 / `.toml` line 20) `repository maintenance 後の全変更セット。` を `全変更セット。` に書き換える。
  - 入力節 (`.md` line 29 / `.toml` 該当行) `repository-maintainer handoff。` を `lead が \`doc-followup\` で行った docs / 参照ずれ確認結果。` に書き換える。
  - 進め方節 (`.md` line 43) `repository maintenance 後の全変更セットが scope 内か見る。` を `全変更セットが scope 内か見る。` に書き換える。
  - 進め方節 (`.md` line 47 / `.toml` line 24) `repository-maintainer handoff の \`behavior_delta\` と \`quality_gate_impact\` を見て、lint / format / test / build の対象、rule、失敗条件、実行入口が不当に弱まっていないか見る。` を `lead が \`doc-followup\` で観測した tooling 挙動差分があれば、lint / format / test / build の対象、rule、失敗条件、実行入口が不当に弱まっていないか見る。` に書き換える。
  - 進め方節 (`.md` line 49 / `.toml` 該当行) `\`verifier_return_required: yes\` の場合、\`inspector\` の再確認結果と更新後の \`test.md\` があるか見る。` を `lead が \`doc-followup\` 後に inspector 再確認を行った場合、更新後の \`test.md\` があるか見る。` に書き換える。
  - 停止線節 (`.md` line 58 / `.toml` line 34) `Gate 3 で、repository maintenance 後の全変更セット、または \`test.md\` / N/A 理由 / 未実行理由 / 残リスクが確認できない。` を `Gate 3 で、全変更セット、または \`test.md\` / N/A 理由 / 未実行理由 / 残リスクが確認できない。` に書き換える。
  - その他の節（編集権限、出力 schema、Reviewer Execution Boundary）は変更しない。両 surface 対称適用。

## 処理フロー

1. Phase 2 着手直前: lead が `git log -1 --format=%H HEAD` で最新 commit hash を取得し、researcher handoff の取得時点との差分を確認する (`DD-018`)。差分がない、または agent 名置換に閉じることを確認したら次へ進む。
2. Phase 3 task 分解時: `DD-001` から `DD-019` を実装単位の `TASK-*` に分割する。両 surface 同期は 1 task = 両 surface の対称 path セットを 1 単位にする。
3. 実装単位の進め方:
   a. 削除 task (`DD-001`): 10 ファイルを物理削除。両 surface セットで 1 単位。
   b. orchestrate references 書き換え task (`DD-002` から `DD-007`): tier reference / SKILL.md / handoff.md / gate-review.md を書き換える。両 surface セットで 1 単位。
   c. orchestrate SKILL.md 追記 task (`DD-008`): artifact 作成主体明文化。両 surface 1 単位。
   d. skill description 書き換え task (`DD-009` から `DD-011`): implement / architecture / scribe 配下。両 surface 1 単位。
   e. docs/notes 追従 task (`DD-012` から `DD-014`): 3 ファイル。両 surface に対する影響はないが、各ファイル単位で task を分けてよい。
   f. ADR 作成 / メタ更新 task (`DD-015` から `DD-017`): 新規 ADR 作成と既存 2 ADR のメタ更新。
4. 検証: `DD-019` の対称性確認と `AC-002` の grep を実行する。

## Validation

- `AC-001` / `AC-009` validation: `Glob` で `dot_claude/agents/*.md` と `dot_codex/agents/*.toml` を取り、basename 集合が `{researcher, inspector, requirements-reviewer, design-reviewer, security-reviewer, quality-reviewer}` と完全一致することを観測する。
- `AC-002` validation: `Grep` (rg) で `architect\b|requirements-engineer|task-planner|implementer|repository-maintainer` を repo 全体に対し検索する。`-g '!docs/adr/**'`、`-g '!docs/requests/reduce-non-reviewer-agents/**'`、`-g '!docs/requests/agent-skill-name-pair-alignment/**'`、`-g '!docs/requests/claude-orchestrate-tier-display/**'` で除外し、ヒット件数が 0 であることを観測する。`architect\b` 語境界により skill 名 `architecture` への誤 hit を避ける。`verifier_return_required` field は本要求で廃止するため除外指定不要。
- `AC-003` validation: `dot_claude/skills/orchestrate/references/full.md` / `standard.md` / `micro.md` を読み、`- agent:` 行が `lead` / `researcher` / `inspector` / reviewer 4 種のみで構成されることを確認する。Gate 3 前 docs 確認工程が `doc-followup` 経路で記述されている。Codex 側も同様。
- `AC-004` validation: `dot_claude/skills/orchestrate/references/micro.md` および Codex 側で `implementer` 文字列が 0 件であることを確認する。
- `AC-005` validation: `orchestrate/SKILL.md`（両 surface）に「lead が `scribe` を使って artifact を書く」旨の文が含まれることを目視確認する。`scribe/references/*-format.md` の章立て diff が空であることを確認する。
- `AC-006` validation: `handoff.md` の `Engineering Agent Output` 対象列挙が `researcher / inspector` のみで、`Repository Maintenance Impact` block と `verifier_return_required` field が完全に除去され、Rules 節にも該当語が残らないことを観測する（両 surface）。
- `AC-007` validation: `docs/adr/0034-reduce-non-reviewer-agents.md` が存在し `Supersedes: 0024, 0028` を持ち、`0024` と `0028` の Status が `Superseded` / `Superseded-By: 0034` であることを観測する。
- `AC-008` validation: `0034` 本文に constraint enforcement 喪失と代替手段 (`stop-lines.md` カタログ + skill 境界 + lead 停止線) の対応が読み取れることを目視確認する。
- `AC-010` validation: Phase 2 着手直前に取得した commit hash が `basic-design.md` に記録され、researcher handoff の行番号との差分が detailed-design に反映されていることを確認する。
- `AC-011` validation: `dot_claude/CLAUDE.md` と `dot_codex/AGENTS.md` を grep し、`repository maintenance` を含む agent 集合説明が残っていないことを確認する。「置き場」節の `agents/` 説明文が 6 agent 構成（調査・検証 specialist + reviewer）に整合している。
- `AC-012` validation: `dot_claude/agents/{security,quality}-reviewer.md` と `dot_codex/agents/{security,quality}-reviewer.toml` を grep し、`repository-maintainer` / `security_ci_impact` / `behavior_delta` / `quality_gate_impact` / `verifier_return_required` / `repository maintenance` が 0 件であることを確認する。Gate 3 入力一覧、役割節、進め方節、停止線節が lead + `doc-followup` 主体に整合している。`requirements-reviewer` / `design-reviewer` も同 grep が 0 件であることを併せて確認する。

## Error Handling

- 部分削除で停止: `DD-001` の途中で停止しても、削除した agent 名は orchestrate references で参照されていない状態へ書き換える前に止まれば、片側 surface だけが broken になる。Phase 3 で「reference 書き換え -> agent 削除」順を採用すれば、削除途中で停止しても両 surface の agent 集合が orchestrate reference 上で「lead」になっており runtime 上の発火がない状態を保てる。順序は `tasks.md` で明示する。
- 片側 surface 更新漏れ: `AC-009` validation で basename 集合 diff を観測する。片側だけ削除して停止した場合、もう片側の delete を完了する rollback 方向ではなく forward fix を選ぶ。これは agent ファイルが存在しても reference 側で参照していなければ runtime 発火しないため。
- ADR メタ更新漏れ: `AC-007` validation で `Status: Superseded` と `Superseded-By: 0034` を観測する。`0034` の `Supersedes` line と双方向整合が崩れている場合は forward fix で `0024` / `0028` 側のメタを揃える。
- docs/notes 追従漏れ: `AC-002` の grep で検出される。除外パスに該当しないヒットがあれば該当 path を追従修正する。
- handoff field 廃止: `verifier_return_required` field 名は本要求で完全廃止する。schema 互換破棄は ADR 0034 で superseded として記録し、別 request の過去 handoff 履歴は `AC-002` の除外パスで履歴として保持する。

## Edge Case

- handoff 過去履歴: `docs/requests/<other-slug>/handoff.md` に削除対象 agent の出力履歴が残っている。これは過去経緯であり書き換えない。`AC-002` の除外対象。
- ADR 本文の旧 agent 名参照: ADR 0020 / 0024 / 0027 / 0028 等に旧 agent 名が残る。本文は履歴として保持 (ADR 0022)。`AC-002` の除外対象。
- `verifier_return_required` 複合 field 名: 本要求で完全廃止する。過去 request 配下 (`docs/requests/<other-slug>/handoff.md`) の出現は履歴として `AC-002` の除外対象。
- `architecture` skill 名と `architect` agent 名の区別: skill 名 `architecture` は維持。`architect` 単独語の参照のみ書き換える。`docs/notes/harness-regression-checks.md` line 228–230 の `architecture` は skill 名のため対象外。
- 削除対象 5 agent が `Phase 3 entry condition` セクション (`full.md` line 99) に列挙されている `agent: lead` 表記: ここはもともと lead なので変更不要。
- `agents/` 説明文の「要件・設計・実装・検証・repository maintenance の各役と review 入口」: Gate 2 design review で `dot_claude/CLAUDE.md` line 32 と `dot_codex/AGENTS.md` line 55 に実在することが確認された。`DD-020` で書き換え対象に追加済み。同様に Gate 2 security review で `dot_claude/agents/security-reviewer.md` と `dot_codex/agents/security-reviewer.toml` の `repository-maintainer` / `security_ci_impact` 参照が確認された。`DD-021` で書き換え対象に追加済み。Gate 2 design 再レビューでさらに `dot_claude/agents/quality-reviewer.md` / `dot_codex/agents/quality-reviewer.toml` にも対称構造の参照が大量に残ることが確認された。`DD-022` で書き換え対象に追加済み。`requirements-reviewer` / `design-reviewer` は grep clean。

## 状態遷移 / 分岐条件

N/A。本要求は agent 集合の縮約とそれに伴う reference 書き換えであり、runtime 状態遷移を伴わない。

## Test 観点

- 観点 1 (`AC-001` / `AC-009`): 両 surface の agent file basename 集合が `{researcher, inspector, requirements-reviewer, design-reviewer, security-reviewer, quality-reviewer}` と完全一致する。
- 観点 2 (`AC-002`): 削除対象 agent 名 5 種の grep が、除外パス (ADR、本 request folder、過去 request folder の handoff、`verifier_return_required` 複合語) を除き 0 件になる。
- 観点 3 (`AC-003`): tier reference 3 種で工程の主体が lead + skill 直叩きで一貫している。Gate 3 前 docs 整備が `doc-followup` 経路で説明されている。
- 観点 4 (`AC-004`): micro tier に `implementer` 並列言及がない。
- 観点 5 (`AC-005`): `orchestrate` reference のいずれかに「lead が `scribe` で artifact を書く」旨が明記されている。`scribe/references/*-format.md` の章立て・ID 規則は不変。
- 観点 6 (`AC-006`): `handoff.md` の `Engineering Agent Output` 対象が `researcher / inspector` のみ、`Repository Maintenance Impact` block と `verifier_return_required` field が完全に除去され、Rules 節にも該当語が残らない。
- 観点 7 (`AC-007`): 新規 ADR 0034 と既存 ADR 0024 / 0028 の status / superseded 関係メタが双方向に整合している。
- 観点 8 (`AC-008`): 新規 ADR で constraint enforcement 喪失と代替の対応が読み取れる。
- 観点 9 (`AC-010`): Phase 2 着手前取得 commit hash が `basic-design.md` に記録され、行番号差分があれば detailed-design に反映されている。
- 観点 10 (`AC-002` 追加 / docs/notes): `docs/notes/runtime-surface-guidance.md` / `harness-design-principles.md` / `harness-regression-checks.md` の本文に削除対象 agent 名がない（skill 名 `architecture` は対象外）。
- 観点 11 (`AC-011`): `dot_claude/CLAUDE.md` / `dot_codex/AGENTS.md` 「置き場」節の `agents/` 説明文が 6 agent 構成に整合。`repository maintenance` 等の役割語が agent 集合説明として残らない。
- 観点 12 (`AC-012`): `dot_claude/agents/security-reviewer.md` / `dot_codex/agents/security-reviewer.toml` に `repository-maintainer` / `security_ci_impact` が残らない。Gate 3 入力が lead + `doc-followup` 主体に整合。

## 未確認事項

- Phase 3 着手時点の最新 `orchestrate` 構成 commit hash と researcher handoff 取得時点 commit hash の差分。行番号が変動している場合の対象行更新は `DD-018` で吸収する。
- Gate 2 design / security review 結果（FINDING-001、FINDING-002、NB-S03）は本 detailed-design に反映済み（`DD-005` 修正 + `DD-020` / `DD-021` 追加 + `AC-002` grep pattern `architect\b` 化）。Gate 2 再実施で確認する。
