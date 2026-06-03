# Requirements

## 目的

orchestrate workflow で、各 Phase / Gate の遷移点で lead が前工程成果物を実際に確認してから次工程へ進むことを、skip できない具体手順として明示し、実装先行・docs 後（または未作成）を抑止する。

## 背景 / 課題

過去取り組み（`orchestrate-prephase-artifact-order`）で `Phase 3 entry condition` と後付け禁止を prose 追加したが、「確定していることを確認する」という抽象指示にとどまり、lead が実際に何を Read し何を満たせば進めるかが無い。lead の自己判断で確認を skip でき、問題が再発している。今回は prose を「実行可能・skip 不能な確認手順」に具体化する。

## Scope

- full / standard / micro の各 tier reference で、次工程着手前に「実際に Read で確認する前工程成果物」と「満たすべき前提」を具体列挙し、未充足なら進めない（前工程へ戻すかユーザー確認する）ことを明示する。
- micro tier に、最小限の entry 確認（request.md ないし変更対象の現状確認）を追加する。
- SKILL.md 本体に、各遷移点で前工程成果物を確認してから進む原則を簡潔に追記する（重複転記はしない）。
- Claude (`dot_claude/skills/orchestrate/`) と Codex (`dot_codex/skills/orchestrate/`) 両 surface を対称に更新する。

## Non-Scope

- 機械的 hook / script / CI による artifact 存在チェックの導入。
- tier 別 docs 省略設計の変更（standard で Phase 1/2 任意、micro で省略は維持）。docs の一律必須化。
- agent 定義、runtime config、permission、settings.json の変更。
- scribe の format reference 群（`*-format.md`）の変更。
- ADR 本文の改稿（必要なら別途）。

## 要求事項

- `REQ-001`: 各 Phase / Gate の遷移点で、次工程に着手する前に lead が確認すべき前工程成果物（ファイル）と確認観点が、tier reference 上で具体的に特定できる。
- `REQ-002`: 確認は「成果物を実際に Read で参照する」ことを前提とした手順として書かれ、自己判断による skip を許さない表現になっている。
- `REQ-003`: 前工程成果物が未作成・不足の場合、実装結果から後付けで作らず、前工程へ戻すかユーザー確認する分岐が遷移点ごとに明示されている。
- `REQ-004`: micro tier にも、Phase 3 着手前の最小 entry 確認が存在する。
- `REQ-005`: docs を作る場合は前工程で先に作り、後工程の成果物（implementation.md / test.md）を上流 artifact の代替にしないことが、各 tier で一貫して読み取れる。
- `REQ-006`: 上記の変更が Claude / Codex 両 surface に同内容（surface 名差分のみ）で反映されている。
- `REQ-007`: 現状の tier 別 docs 省略設計が変更されていない（docs が一律必須化されていない）。
- `REQ-008`: SKILL.md 本体に、各遷移点で前工程成果物を確認してから進む原則が簡潔に1か所反映され、tier reference の重複転記になっていない。

## 受入条件

- `AC-001`: (REQ-001, REQ-002) full.md / standard.md の Phase 3 entry condition（および各 Gate 前）に、Read で確認する前工程成果物名と確認観点が列挙され、「確認してから進む」「未充足なら進めない」が skip 不能な表現で書かれている。
- `AC-002`: (REQ-003) full.md / standard.md / micro.md の各遷移点に、前工程成果物が不足した場合の差戻し / ユーザー確認分岐が明示されている。
- `AC-003`: (REQ-004) micro.md に、Phase 3 着手前の最小 entry 確認（request 相当の意図と変更対象現状の確認）が追加されている。
- `AC-004`: (REQ-005) standard.md / full.md / micro.md のいずれを読んでも、「docs を作る場合は前工程で先に作る」「implementation.md / test.md を上流 artifact の代替にしない」が一貫して読み取れる。
- `AC-005`: (REQ-006) `dot_claude/skills/orchestrate/` と `dot_codex/skills/orchestrate/` の対応ファイル diff が、surface 名（Claude/Codex, subagent/agent）以外で内容一致する。
- `AC-006`: (REQ-007) tier 別 docs 省略の規定（standard の Phase 1/2「任意」、micro の Phase 1/2/Gate 省略、Tier Map）が変更されていない。
- `AC-007`: (REQ-008) SKILL.md 本体に、遷移点で前工程成果物を確認してから進む原則が簡潔に1か所追記され、tier reference の重複転記になっていない。

## 制約

- 順序強制は prose のみ（機械的 enforcement なし）。最終的に lead の遵守に依存する点は変わらない。これを前提に、確認手順の具体性・skip 不能性で遵守率を上げる。
- orchestrate skill / agent 定義 / runtime 設定に触れるため、AGENTS.md 上 docs-only ではない。skill 設計変更として skill-creator と Agent Skills 公式情報の確認を Phase 2 で行う。
- scribe format reference は正本として変更しない。
- 既存の Phase / Gate 構造、tier 体系、Tier Map は維持し、その上に確認手順を具体化する。

## 前提

- 同じ要求の過去 folder `orchestrate-prephase-artifact-order` は完了済みの別 request として read-only 扱いとし、本 request は新 slug で進める。
- researcher 調査でファイル構成・既存記述・弱点は確認済み（request.md 背景参照）。

## 未確認事項

- micro tier の entry 確認をどこまで重くするか（最小確認 1 ステップで足りるか、設計判断は Phase 2 で詰める）。
