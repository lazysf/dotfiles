# Basic Design

## 設計方針

過去施策（`Phase 3 entry condition` の prose 追加）が効かなかった原因は、「確定していることを確認する」が lead の内部状態の自己申告であり、(a) 何を確認すべきか具体でない、(b) 確認したかどうかの痕跡が残らず skip を検知できない、ことにある (REQ-001, REQ-002)。

したがって本変更は、確認を「実際に Read で前工程成果物を参照する具体手順」にし、かつ「確認した artifact 名と充足観点を既存 artifact 内に1行残す」ことで観測可能にする。痕跡が残らない＝skip したことが Gate reviewer / ユーザーから検知できる構造にして、抽象指示を実行可能・skip 不能に変える (REQ-002, REQ-003)。機械的 enforcement は導入せず prose で実現し、tier 別 docs 省略設計は変えない (REQ-005, REQ-007)。

## 構成と責務

- `dot_claude/skills/orchestrate/SKILL.md` / `dot_codex/.../SKILL.md`: 全 tier 共通の原則（遷移点で前工程成果物を Read 確認してから着手）を1か所だけ置く。tier 別の具体手順は持たない。
- `references/full.md` / `references/standard.md`: Phase 3 entry condition を具体化し、各遷移点で確認する前工程成果物と痕跡記録を明示する。
- `references/micro.md`: Phase 0→Phase 3 直結構造に最小 entry 確認を追加する。
- `references/gate-review.md`: 「確認痕跡が残っている」ことを pass 条件として補強する。
- `dot_codex/skills/orchestrate/`: 上記の Codex 側対称ファイル群。surface 名以外同内容。

## 基本設計項目

- `BD-001`: 各 Phase / Gate の遷移点（特に Phase 3 着手前）に「直前工程の成果物を実際に Read で確認する」手順を置き、確認する成果物名と観点を具体列挙する (REQ-001, REQ-002 / AC-001, AC-002)。
- `BD-002`: 確認を観測可能にするため、「確認した artifact 名 + 満たした観点」を既存 artifact（`request.md` または `implementation.md`、micro で request folder 無しなら最終出力）内に1行残してから着手する、と規定する。これは新規 docs の強制ではなく順序遵守の痕跡であり、tier 別 docs 省略設計を変えない (REQ-002, REQ-005, REQ-007 / AC-001, AC-004, AC-006)。
- `BD-003`: 前工程成果物が未作成・不足の場合は実装結果から後付けで作らず、前工程へ戻すかユーザー確認する分岐を、各遷移点で skip 不能な表現にする (REQ-003 / AC-002, AC-004)。
- `BD-004`: micro.md の Phase 0 と Phase 3 の間に「実装着手前の最小 entry 確認」（変更対象の現状と変更意図を Read で確認）を1ステップ追加する。docs は作らせず確認だけ求め、micro を重くしない (REQ-004 / AC-003)。
- `BD-005`: SKILL.md 本体（`自走と確認 checkpoint` 付近）に、遷移点で前工程成果物を Read 確認してから進む原則を簡潔に1か所追記する。tier reference の具体手順は転記しない (REQ-008 / AC-007)。
- `BD-006`: gate-review.md の共通 pass 条件に、「上流 artifact が確認されている」だけでなく「確認痕跡（確認 artifact 名と充足観点）が残っている」ことを加える (REQ-002, REQ-003 / AC-002)。
- `BD-007`: 上記すべてを Claude / Codex 両 surface に surface 名差分のみで反映する (REQ-006 / AC-005)。

## 主要 interface / API / data flow

- ここでの「interface」は prose の手順記述。data flow は「前工程 artifact → lead が Read 確認 → 充足なら着手 / 不足なら前工程へ戻す」という遷移判断フロー。
- 確認痕跡の置き場: request folder がある場合は `request.md` または `implementation.md` の自然な節に1行。request folder が無い micro では最終出力に含める。

## 既存構造との接続点

- 既存の `Phase 3 entry condition` セクション（full.md L95-101, standard.md L67-73）を置換・具体化する。
- 既存 gate-review.md 共通 pass 条件 L10「次工程着手前に作成・更新・確認されている」を痕跡要件で補強する。
- 既存 Tier Map、tier 体系、Phase/Gate 構造、docs 省略規定（standard の「任意」、micro の省略）は変更しない (AC-006)。
- scribe の `*-format.md` は変更しない（正本）。

## Security / 権限 / Data / 外部 I/O

- 本変更は orchestrate の prose 手順のみ。secret / auth / 権限 / 外部 I/O / command 実行の処理は追加しない。
- ただし orchestrate skill 定義の変更であり、AGENTS.md 上 docs-only ではない。Gate 2 で security-reviewer も起動する。

## 主要判断と理由

- 機械的 hook を採らない理由: workflow 内部の phase 遷移を hook で正確に捉えるのは技術的に困難で脆い（researcher 確認事実）。ユーザーも prose 強化中心を選択。
- 痕跡を「新規ファイル」でなく「既存 artifact 内 1 行」にする理由: docs 一律必須化を避けつつ skip 検知を可能にするため。docs 省略設計との両立 (REQ-007)。
- why を手順に添える理由: skill-creator / Claude Code skills 公式の best practice。ALWAYS/NEVER の機械的強制より、「なぜ Read 確認が必要か（記憶や推測でなく成果物そのものを根拠にするため）」を理解させる方が遵守されやすい。

## 未確認事項

- micro の最小 entry 確認を「1 行の自己確認」に留めるか（detailed-design で確定）。
