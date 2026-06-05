# Claude Lightweight Workflow

`dot_claude` surface の現在の姿。決定論 SDLC workflow を撤去し、軽量 LLM-native へ再設計した結果を記録する。判断記録は ADR 0035。

## 現在の構成

- **CLAUDE.md**: 共通契約 + 進行ガイド + doc 3 層 + 停止線 + 置き場。進行は強制でなくガイド（道標）。
- **skills (3)**: `scribe`（doc 生成）/ `git-commit` / `git-push`。
- **agents (3)**: `researcher`（low, read-only, Bash なし）/ `quality-reviewer`（high）/ `security-reviewer`（high）。全 read-only・self-contained。
- **rules (4)**: `coding-standards` / `docs-artifacts` / `claude-surface-consistency` / `vba`。
- **output-styles (1)**: `caveman`。
- **settings**: model `opus` alias、main effort medium。

## 進行ガイドと発火条件

```
掘り下げ → 方針(Plan) → 実装 ⇄ 検証 → review → doc → commit/push
```

各工程は発火条件を満たす時だけ通す。満たさなければ飛ばし code-first で回す。

- **掘り下げ（4 条件 AND）**: ①解釈が 2 通り以上 ②妥当なデフォルトを推測で置けない ③外すと手戻り大 ④探索で埋まらない（ユーザー意図依存）。掘り下げと Plan は「探索で埋まる曖昧さか」で振り分ける。
- **方針(Plan)**: 複数案 or 広範囲。`EnterPlanMode` 自己発動 + 承認が捨てた Gate の代替。
- **doc（silent skip 禁止）**: 実装一段落時と commit 前に仕様 doc 要否を明示。3 層は仕様(README/docs) / ADR / notes。
- **ADR（3 条件 AND）**: 複数案を実比較 / 覆すコスト高 / 捨てた案に再検討価値。
- **review**: ユーザー明示時に reviewer を呼ぶ。diff は呼び出し元が渡す。

## Codex との非対称（重要）

この repo は **意図的に非対称な harness** を運用する。

- **Codex surface**: 決定論 SDLC（orchestrate / tier / Phase/Gate / 工程 doc）を維持。
- **Claude surface**: 上記の軽量 guide。

そのため、`docs/notes/runtime-surface-guidance.md` と `docs/notes/harness-regression-checks.md` が記述する「両 surface 対称」モデルは **Codex には有効だが Claude には当てはまらない**。これら共有 note の Claude 記述は乖離しており、全面整合は follow-up。

## 廃止したもの（Claude 側）

- skill: `orchestrate` / `grill` / `research` / `architecture` / `implement` / `inspect` / `doc-followup`
- agent: `inspector` / `requirements-reviewer` / `design-reviewer`
- 体系: request folder（`docs/requests/<slug>/`）の 4 枚 doc、`AC-*` などの traceability ID、tier / Phase / Gate

## 既知の follow-up

- `runtime-surface-guidance.md` / `harness-regression-checks.md` の Claude 記述を非対称前提へ整合。
- `claude-code-permission-policy.md` は「明示 allow を置かない」と書くが、現 settings は `Agent(...)` allow を持つ。例外を追記して整合する。
