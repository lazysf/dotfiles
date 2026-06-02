# Basic Design

## 設計方針

reviewer 4 種 + `researcher` + `inspector` の 6 agent 体制に集約し、要件・設計・task・実装の工程は lead が `scribe` skill を介して artifact を直接書く運用へ移行する。`researcher` / `inspector` は中間出力（grep、log、test output）を別 context window に隔離する用途で残し、reviewer は独立批判視点として agent 形態を維持する。削除によって失われる constraint enforcement（agent frontmatter / 本文での編集境界）は、`orchestrate/references/stop-lines.md` カタログ + 各 skill SKILL.md の境界記述 + lead 自走停止線（`dot_claude/CLAUDE.md` / `AGENTS.md` の停止線）で代替する。両 surface (`dot_claude/` / `dot_codex/`) を同期して更新し、surface 間で agent 集合・参照記述が対称であることを必須条件にする。対応する `REQ-001` から `REQ-012`、`AC-001` から `AC-010`。

## 構成と責務

- `dot_claude/agents/` / `dot_codex/agents/`: 残置する 6 agent (`researcher`、`inspector`、`requirements-reviewer`、`design-reviewer`、`security-reviewer`、`quality-reviewer`) の定義のみを持つ。削除対象 5 種 (`architect`、`requirements-engineer`、`task-planner`、`implementer`、`repository-maintainer`) のファイルは存在しない。
- `dot_claude/skills/orchestrate/` / `dot_codex/skills/orchestrate/`: 進行入口。tier reference (`full.md` / `standard.md` / `micro.md`) の各工程行で、削除対象 agent を主体としていた工程を「lead」または「lead が `<skill>` を使う」表記へ書き換える。`handoff.md` / `gate-review.md` の agent 列挙と stop-line 文も残置 agent 集合に揃える。
- `dot_claude/skills/architecture/` / `dot_codex/skills/architecture/`: SKILL.md 冒頭の description で `architect` を主語にしていた一文を、lead 主体 + skill 名表現へ書き換える。本文の手順は維持。
- `dot_claude/skills/implement/` / `dot_codex/skills/implement/`: SKILL.md description の `implementer` 主語を lead 主体表現へ書き換える。本文の手順は維持。
- `dot_claude/skills/scribe/references/implementation-format.md` / `dot_codex/skills/scribe/references/implementation-format.md`: template 内コメントの `implementer` / `inspector` の主語表現を lead 主体表現へ揃える。format の章立て・ID 規則・記述順は維持する（`REQ-005` 制約）。
- `docs/notes/`: `runtime-surface-guidance.md` / `harness-regression-checks.md` / `harness-design-principles.md` の本文を 6 agent 構成へ追従する。`docs/adr/` への過去 ADR リンクは保持する。
- `docs/adr/`: 新規 ADR (`0034-reduce-non-reviewer-agents.md` を提案) を追加し、`Supersedes: 0024, 0028` を持たせる。ADR 0024 / 0028 側に `Superseded-By: 0034` を追記する。ADR 本文の編集境界（ADR 0022）に従い、本文ではなく status と relationship metadata だけを触る。

## 基本設計項目

- `BD-001` (`REQ-001` / `REQ-002` / `AC-001` / `AC-009`): 削除対象 10 ファイル (`dot_claude/agents/{architect,requirements-engineer,task-planner,implementer,repository-maintainer}.md` と `dot_codex/agents/{...}.toml`) を物理削除する。残置 agent は両 surface とも `researcher`、`inspector`、`requirements-reviewer`、`design-reviewer`、`security-reviewer`、`quality-reviewer` の 6 個に揃え、ファイル名集合の同一性をもって surface 対称性を満たす。
- `BD-002` (`REQ-003` / `REQ-006` / `AC-003`): `orchestrate/references/full.md` の Phase 1 / Phase 2 / Phase 3 工程の `agent:` 行を以下に置き換える。
  - `要件定義`: `agent: lead`、`進め方` に「lead が `requirements` skill と `scribe` を使う」を追加。
  - `基本設計` / `詳細設計`: `agent: lead`、進め方に「lead が `architecture` skill と `scribe` を使う」。
  - `タスク分解`: `agent: lead`、進め方に「lead が `task-planning` skill と `scribe` を使う」。
  - `実装`: `agent: lead`、進め方に「lead が `implement` skill と `scribe` を使う」。
  - `repository maintenance`: 工程ごと削除し、進め方部分を Phase 3 の最後に「Gate 3 前 docs / 参照ずれ確認」工程として残し `agent: lead`、進め方に「lead が必要時に `doc-followup` skill を使う」と書く。`blocked` 概念は工程廃止に伴い stop-line から外す。`standard.md` / `micro.md` も同様に書き換える。Phase 構造そのものは変更しない（`requirements.md` non-scope）。
- `BD-003` (`REQ-004` / `AC-004`): `orchestrate/references/micro.md` の `実装` 工程 `agent: lead / implementer` を `agent: lead`、進め方の「必要なら `implementer` か該当 skill を使う」を「必要なら該当 skill を使う」に書き換える。`repository maintenance` 工程の `agent: lead / repository-maintainer` も `agent: lead` へ揃える。
- `BD-004` (`REQ-005` / `AC-005`): `orchestrate` reference 群に「要件 / 設計 / task / 実装 / 検証 artifact は lead が `scribe` を使って書く。format は `scribe/references/*-format.md` を正本とする」旨を 1 箇所明文化する。明文化先は `orchestrate/SKILL.md` の「自走と確認 checkpoint」セクション末尾に短い段落を追加する形にする。`scribe/references/*-format.md` の章立て・ID 規則・記述順は変更しない。
- `BD-005` (`REQ-009` / `AC-006`): `orchestrate/references/handoff.md` の `Engineering Agent Output` 対象 list から削除対象 5 agent を外し、`researcher` / `inspector` のみを残す。`repository-maintainer` の追加 block (`Repository Maintenance Impact`) は工程廃止に伴い block ごと削除する。`verifier_return_required` field も**完全廃止**する（Gate 2 design review FINDING-002 の結論）。`repository-maintainer` 経由の inspector 再呼出し need が消えるため field を残す動機が失われ、schema を綺麗に保つ。Rules 節 (L165-167) のうち `verifier_return_required` / `Repository Maintenance Impact` を指す行も整合的に削除する。Gate 3 前 docs 確認の最小記録は lead が `request.md` または `implementation.md` の自然な節に残す運用とし、handoff schema には専用 block / field を持たせない。意味遷移と schema 互換破棄は ADR 0034 で superseded 関係として記録する。
- `BD-006` (`REQ-007` / `AC-002`): `implement/SKILL.md` description の「implementer が tasks.md と detailed-design.md に沿って...」を「lead が tasks.md と detailed-design.md に沿って...（本 skill を使う）」へ書き換える。`architecture/SKILL.md` の「architect が basic-design.md / detailed-design.md を作る前に...」を「lead が basic-design.md / detailed-design.md を作る前に...（本 skill を使う）」へ書き換える。`scribe/references/implementation-format.md` の template 注釈 `implementer が実行した確認。inspector の最終結果は test.md に置く。` を `lead または inspector が実行した確認。inspector の最終結果は test.md に置く。` に書き換える。
- `BD-007` (`REQ-008` / `AC-002`): `docs/notes/runtime-surface-guidance.md` の `repository-maintainer` を主語にしている 3 箇所と `doc-followup` の説明文を、Gate 3 前 docs 追従を lead が `doc-followup` を使って行う表現に書き換える。ADR 0024 への参照リンクは履歴として残し、新規 ADR 0034 へのリンクを併記する。`docs/notes/harness-design-principles.md` の 2 箇所と `docs/notes/harness-regression-checks.md` の 8 箇所も同方針で書き換える。`architect` を主語にしている `harness-regression-checks.md` の `9.5` 系記述は lead + `architecture` skill 表現に揃える。
- `BD-008` (`REQ-010` / `REQ-011` / `AC-007` / `AC-008`): 新規 ADR `0034-reduce-non-reviewer-agents.md` を `docs/adr/` に追加する。番号は `Glob` 結果上の最大値 0033 の次。本文は背景・決定・影響の 3 節で、(a) 折衷案採用（reviewer 4 + researcher + inspector）、(b) isolation 維持と constraint enforcement 喪失のトレードオフ、(c) 代替戦略 (`stop-lines.md` カタログ + skill 境界 + lead 停止線) を含める。`Status: Accepted`、`Supersedes: 0024, 0028`。同時に ADR 0024 と 0028 の `Status` を `Accepted` から `Superseded` に変更し、`Superseded-By: 0034` を追加する。これは ADR format reference の「ライフサイクル更新」節で許容されたメタデータ更新範囲に収まる（R5 の結論）。
- `BD-009` (`REQ-012` / `AC-010`): Phase 2 着手前に取得した最新 `orchestrate` 構成の commit hash を `basic-design.md`（本ドキュメント）末尾の `未確認事項` の直前に記録し、researcher handoff の行番号と差分があった場合は `BD-002` / `BD-003` / `BD-006` の対象行を再確認する。
- `BD-010` (`REQ-002` / `AC-009`): Claude / Codex 両 surface の対称性を以下の 3 条件で観測可能にする。(1) `dot_claude/agents/*.md` と `dot_codex/agents/*.toml` の basename 集合が一致する、(2) 各 tier reference の行構造（Phase / Gate セクション順、工程名、`扱い` 値）が両 surface で一致する、(3) 削除対象 5 agent 名の grep が両 surface で同じ件数（除外パスを除き 0 件）になる。
- `BD-011` (`REQ-013` / `AC-011`): `dot_claude/CLAUDE.md`「置き場」節の `agents/` 説明文「仕様駆動 workflow を担う専門 agent 群（要件・設計・実装・検証・repository maintenance の各役と review 入口）」を「専門 agent 群（調査・検証の specialist と review 入口）」相当に書き換える。`dot_codex/AGENTS.md`「置き場」節の `~/.codex/agents/` 説明文「multi-agent workflow を担う専門 agent 群（調査・要件・設計・実装・検証・repository maintenance の各役と review 入口）」を「specialist agent 群（調査・検証の specialist と review 入口）」相当に書き換える。意味は「6 agent 構成（researcher + inspector + reviewer 4）」を示す表現に統一し、「lead が spawn する」「進行は main セッションが決める」等の枠付け文は維持する。
- `BD-012` (`REQ-014` / `AC-012`): `dot_claude/agents/security-reviewer.md` および `dot_claude/agents/quality-reviewer.md`、ならびに対称 path の `dot_codex/agents/{security,quality}-reviewer.toml` から、`repository-maintainer handoff` / `repository maintenance 後の全変更セット` / `security_ci_impact` / `behavior_delta` / `quality_gate_impact` / `verifier_return_required` への参照、および役割節 / 進め方節 / 停止線節 / description / 入力節の `repository maintenance` 工程語前提依存記述をすべて除去する。書き換え方針:
  - `security-reviewer`: Gate 3 入力一覧を「全成果物、全変更セット、`test.md`、researcher handoff の security-relevant observations、lead の `doc-followup` 結果」へ。役割節の前提分岐は「lead が `doc-followup` で docs / 参照ずれ確認や tooling / runtime guardrail 差分を観測した場合は、CI permission、secret、外部 I/O、deploy / publish 経路、script / command 変更の security impact を確認する。」へ。security 観点の確認項目は「全変更セットおよび `test.md` から CI permission / token / secret / OIDC / external I/O / deploy / publish への影響を確認する」「lead が `doc-followup` で観測した tooling / runtime guardrail 差分があればその記録も併せて確認する」へ。
  - `quality-reviewer`: description 末尾の「, repository maintenance 影響」を削除（「scope、可読性、回帰、テスト妥当性を read-only review する時に使う。」）。役割節 / 入力節 / 進め方節 / 停止線節の `repository maintenance 後の全変更セット` を `全変更セット` へ。役割節「repository maintenance がある場合は、docs / repo hygiene / tooling 設定の変更が scope 内で、品質ゲートを不当に弱めていないか確認する。」を「lead が `doc-followup` で docs / repo hygiene / tooling 設定に変更を加えた場合は、scope 内で品質ゲートを不当に弱めていないか確認する。」へ。入力節「repository-maintainer handoff」を「lead が `doc-followup` で行った docs / 参照ずれ確認結果」へ。進め方節「repository-maintainer handoff の `behavior_delta` と `quality_gate_impact` を見て、lint / format / test / build の対象、rule、失敗条件、実行入口が不当に弱まっていないか見る。」を「lead が `doc-followup` で観測した tooling 挙動差分があれば、lint / format / test / build の対象、rule、失敗条件、実行入口が不当に弱まっていないか見る。」へ。進め方節「`verifier_return_required: yes` の場合、`inspector` の再確認結果と更新後の `test.md` があるか見る。」を「lead が `doc-followup` 後に inspector 再確認を行った場合、更新後の `test.md` があるか見る。」へ。
  - security-reviewer / quality-reviewer の責務範囲（read-only review、`modified_artifacts: none`、`external_io: none`、stop-lines、Reviewer Execution Boundary）は変更しない。両 surface 対称適用。

## 主要 interface / API / data flow

- agent 起動 interface: lead -> `Task` tool (`subagent_type`) で `researcher` / `inspector` / reviewer 4 種だけが対象になる。これら 6 名以外の `subagent_type` 指定は lead が拒否する（runtime 上は agent ファイルが存在しないため自動的に発火しないが、ドキュメント上も列挙集合を 6 名に揃える）。
- artifact 作成 data flow: 削除前は agent (`requirements-engineer` 等) -> artifact 直接書き込み。削除後は lead -> `scribe` skill を読む -> lead が `Write`/`Edit` tool で artifact を書く。観測点は `scribe/references/*-format.md` の章立て準拠と、対応 `REQ-*` / `AC-*` / `BD-*` / `DD-*` / `TASK-*` の trace が `traceability-matrix-format.md` どおりに残ること。
- Gate review data flow: 変更なし。reviewer agent (`requirements-reviewer` / `design-reviewer` / `security-reviewer` / `quality-reviewer`) が `review.md` を書き、lead が次工程判断する。
- 調査 data flow: 変更なし。`researcher` が handoff で事実を lead に返し、lead が次工程へ必要分だけ渡す。
- 検証 data flow: `inspector` が `test.md` を書く。`verifier_return_required` field は廃止し、lead が `doc-followup` で観測した結果が inspector 再確認を要する場合は lead 判断で直接 inspector を起動する（field 経由ではなく lead orchestration で扱う）。

## 既存構造との接続点

- `orchestrate/SKILL.md` 「自走と確認 checkpoint」: `BD-004` に従い、artifact 作成主体を明文化する短い段落を追加。
- `orchestrate/references/full.md` / `standard.md` / `micro.md`: `BD-002` / `BD-003` の書き換え対象。
- `orchestrate/references/handoff.md`: `BD-005` の書き換え対象。
- `orchestrate/references/gate-review.md`: `repository-maintainer` 主語の `74` 行目を lead + `doc-followup` 表現に揃える。
- `dot_claude/CLAUDE.md` / `dot_codex/AGENTS.md` 「置き場」節: `BD-011` の書き換え対象。`agents/` 説明文の役割語を 6 agent 構成（researcher / inspector + reviewer 4）に整合させる。root `AGENTS.md` / `CLAUDE.md` には agent 集合への直接参照がない（researcher 確認済み）ため touch しない。
- `dot_claude/agents/{security,quality}-reviewer.md` / `dot_codex/agents/{security,quality}-reviewer.toml`: `BD-012` の書き換え対象。`repository-maintainer` / `repository maintenance` / `security_ci_impact` / `behavior_delta` / `quality_gate_impact` / `verifier_return_required` 参照を除去し、Gate 3 入力一覧、役割節、進め方節、停止線節を lead + `doc-followup` 主体に整合させる。`requirements-reviewer` / `design-reviewer` は grep clean。
- `docs/notes/runtime-surface-guidance.md`、`harness-design-principles.md`、`harness-regression-checks.md`: `BD-007` の書き換え対象。
- `docs/adr/0024-add-repository-maintainer-agent.md` と `docs/adr/0028-align-agent-names-with-skill-pairs.md`: `BD-008` に従い、`Status` と `Superseded-By` のみ更新する。本文は履歴として保持。

## Security / 権限 / Data / 外部 I/O

- secret / auth / 外部 I/O / 破壊的操作の停止線: agent frontmatter の `tools:` 制限が削除対象 5 agent から失われるが、`orchestrate/references/stop-lines.md` カタログ + 各 skill SKILL.md の境界記述 + lead 自走停止線（`CLAUDE.md` / `AGENTS.md`）で代替する。これにより public behavior、interface、data format、persistence、auth、permission、secret、新依存、破壊的操作、新規 deploy / publish 経路への lead 直接アクセスは tier 判定で `full` に倒される。
- reviewer 4 agent の `Reviewer Execution Boundary` (`modified_artifacts: none` / `write_operations: none` / `external_io: none`) は変更なし。
- `researcher` の `external_io` は read-only lookup に限定（`handoff.md` Rules 既存）を維持。
- request folder 境界: `docs/requests/<slug>/` 外 docs の編集には `BD-007` で触れる `docs/notes/` 更新が含まれるため、本要求の Scope に明示済み（`requirements.md` の制約節）。lead は変更前に該当 path をユーザー確認済みの Scope 範囲として扱う。
- ADR 本文編集境界: ADR 0022 / ADR format reference に従い、0024 / 0028 の本文は触らず status と relationship metadata のみ更新する。

## 主要判断と理由

- 折衷案採用 (reviewer 4 + researcher + inspector): 要件〜設計〜実装の handoff loss を避けるため lead 一貫で持ち、中間出力が嵩む調査・検証のみ subagent で context isolation を維持する。reviewer は独立批判視点として agent 形態が価値を持つ。`request.md` 背景節およびユーザー確認済み方針。
- `Repository Maintenance Impact` block 全廃 + `verifier_return_required` field 廃止 (Gate 2 FINDING-002 解消): `repository-maintainer` 工程廃止に伴い block と field を残す動機は失われる。docs / 参照ずれ確認は lead が `doc-followup` skill を使い、結果は `request.md` または `implementation.md` の自然な節に残す。inspector 再確認が必要なら lead が直接 inspector を起動する。専用 block / field を残すと schema 上宙に浮く field 名になるため整合的に除去する。schema 互換破棄は ADR 0034 で superseded 関係として記録する。
- ADR superseded-by メタ追記 (R5): ADR format reference の「ライフサイクル更新」節で `Supersedes` を明示する新 ADR が古い ADR の Status を `Superseded` にし `Superseded-By` を追加することが明示許容されている。本文の編集境界（typo / リンク切れ / Markdown 破損のみ許可）には抵触しない。
- AC-010 観測手段 (R1): Phase 2 着手前に取得した最新 commit hash を `basic-design.md` 末尾に記録し、researcher handoff の行番号と現行 HEAD の差分があれば設計対象行を本ドキュメントへ反映する形で観測可能にする（`BD-009`）。
- AC-002 grep 除外パス (R2): 削除対象 agent 名の grep で参照ありとみなさない除外パスを以下に明示する。(1) `docs/adr/**` (ADR 本文は履歴), (2) `docs/requests/reduce-non-reviewer-agents/**` (本 request folder), (3) `docs/requests/agent-skill-name-pair-alignment/**` (ADR 0028 関連の過去 request folder の handoff), (4) `docs/requests/claude-orchestrate-tier-display/handoff.md` 等の handoff 過去経緯記述, (5) `docs/CONTEXT.md` / `docs/README.md` の歴史的記述があれば履歴扱い。`verifier_return_required` 複合 field 名は本要求で field 自体を廃止するため除外不要。CHANGELOG はこのリポジトリにないため除外不要。grep pattern は `architect\b` のように語境界を付けることで skill 名 `architecture` への誤 hit を避ける。
- Codex / Claude 両 surface 同期戦略: 同一の論理変更を `dot_claude/` と `dot_codex/` の対称 path に同時適用し、削除と書き換えは両 surface セットで 1 単位として扱う。`task-planning` フェーズで両 surface 分の TASK を pair として並べる。検証段階で `BD-010` の 3 条件を grep / find で観測する。

## Codex / Claude 両 surface 同期戦略

- 各 BD 項目は両 surface 同時更新を前提とし、`detailed-design.md` の手順では Claude 側変更と Codex 側変更を pair として並べる。
- 両 surface で agent 名 (`name` field と file basename) と tier reference 構造が対称になることを `BD-010` で観測する。
- 片側更新漏れの検出は、`dot_claude/agents/*.md` の basename 集合と `dot_codex/agents/*.toml` の basename 集合の差分を取り、空集合であることを確認する。tier reference は両 surface の同名ファイル間で `diff` を取り、agent 名以外の差分が想定外でないかを目視確認する。

## Phase 3 着手時 commit hash

- Phase 3 着手直前 HEAD: `909858230f70ffdc4f674c6c1e485a60ab1952aa` (`BD-009` / `DD-018`)。`detailed-design.md` の `DD-002`〜`DD-014` 対象行番号は本 hash 時点の構成で確認済み、行番号差分なし。

## 未確認事項

- Phase 2 着手時点の最新 `orchestrate` 構成 commit hash と researcher handoff 取得時点 commit hash の差分（`BD-009`）。実装着手前に lead が `git log` で再取得する。
- Gate 2 design review (FINDING-001) で `dot_claude/CLAUDE.md` L32 と `dot_codex/AGENTS.md` L55 の `repository maintenance` 参照が実態として確認された。`BD-011` で書き換え対象に追加済み。同様に Gate 2 security review (NB-S03) で `security-reviewer.{md,toml}` の `repository-maintainer` / `security_ci_impact` 参照、Gate 2 design 再レビュー (FINDING-003 / FINDING-004) で `security-reviewer.{md,toml}` 役割節と `quality-reviewer.{md,toml}` の `repository maintenance` 工程語前提依存 + `behavior_delta` / `quality_gate_impact` / `verifier_return_required` 参照が確認された。`BD-012` で両 reviewer の書き換え対象を網羅済み。`requirements-reviewer` / `design-reviewer` は grep clean。
