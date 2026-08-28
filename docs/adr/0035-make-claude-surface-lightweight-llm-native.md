# 0035: Claude surface を軽量 LLM-native workflow へ再設計する

- Status: Superseded
- Superseded-By: 0036
- Amended-By: 0038

## 背景

`dot_claude` の運用は `orchestrate` を必須入口にした重厚な SDLC workflow（Phase 0 → triage → tier(inquiry/micro/standard/full) → Phase/Gate → reviewer subagent → request folder の 4 枚 doc 体系）だった。これは ADR 0020 / 0025 / 0026 / 0029-0033 の lineage と、agent 構成 ADR 0034 の上に立つ。

運用した実感として、決定論的 workflow が LLM の強み（探索的・反復的・code-first）と噛み合わず、テンポが悪い。特に **実装前の doc 作成（requirements / basic-design / detailed-design / tasks）が長く**、LLM が動くコードへ最短で到達するのを妨げていた。

一方で「流れ自体（掘り下げ→設計→実装→検証→doc→commit）」と「third-party 保守に渡せる doc」は依然必要。

## 決定

**Claude surface（`dot_claude`）に限り**、決定論 workflow を撤去し、要所だけ固定して残りを LLM に自律させる。Codex surface は本 ADR の対象外で不変。

- **進行はガイド**。`orchestrate` 必須入口・tier・Phase/Gate を廃止し、`CLAUDE.md` に「掘り下げ→方針(Plan)→実装⇄検証→review→doc→commit」のガイドと工程ごとの独立発火条件を置く。各工程は条件を満たす時だけ通す。
- **掘り下げ 4 条件 AND** と **ADR 3 条件 AND** で過剰／過少を抑える。掘り下げと Plan mode は「探索で埋まる曖昧さか」で振り分ける。重い変更は Plan mode の承認を捨てた Gate の代替にする。
- **doc は後追い**。開発駆動の事前 doc（requirements / design / tasks）と request folder を廃止し、実装が固まった後に確定事実から 3 層（仕様＝README/docs、ADR、notes）で作る。doc 要否は silent skip 禁止で明示する。
- **agent は read-only 3 つに集約**し self-contained 化する。`researcher` / `quality-reviewer` / `security-reviewer` を残し、Claude 側の `inspector` / `requirements-reviewer` / `design-reviewer` を廃止する。reviewer はユーザー明示トリガで、diff を呼び出し元が渡す前提。read-only は frontmatter の `tools:` で強制する（`researcher` から Bash を外す）。
- **skill を 3 つに集約**。`scribe`（doc 生成へ改修）/ `git-commit` / `git-push` を残し、`orchestrate` / `grill` / `research` / `architecture` / `implement` / `inspect` / `doc-followup` を廃止する。
- **coding-standards を拡充**。「成果物の最終責任と運用・保守は人間が持つ」を起点に、品質の優先順位（正しさ→人による可読性→一貫性→性能→DRY→短さ）と可読性の具体（直線化・命名・副作用分離・予防的抽象化回避）を明示する。
- **hook はグローバルに足さない**（macOS/Windows 両対応の複雑性 > 利得。安全系は permission deny でカバー済み）。
- **model は `opus` alias**、main effort は medium、`researcher` effort は low。
- spawn の standing authorization（ADR 0033）は `CLAUDE.md` 側で維持する。

## 検討した代替案

- **対称な重量 workflow を Claude 側でも維持**: テンポ悪化が運用で確認された理由により却下。
- **安全のためグローバル hook を追加**: クロスプラットフォーム複雑性が利得を上回り、既存 permission deny で安全要件を満たすため却下。
- **事前 doc を残す**: LLM の code-first の強みを殺すため却下。ただし third-party 保守の必要は後追い doc（仕様・ADR・notes）で満たす。

## 影響

- **Codex / Claude の非対称化**: この repo は意図的に非対称な harness を運用する。Codex は決定論 SDLC を維持し、Claude は軽量。ADR 0025 / 0029-0034 や一部 notes が前提していた「両 surface 対称」は **Claude については成立しない**。これらの本文・metadata は履歴として保持し（ADR 0022）、本 ADR が Claude 適用分の見直しを prose で示す。
- **機械的 constraint の縮小**: 廃止した Claude agent の `tools:` 制限と工程別 stop-line が消える。代替は `CLAUDE.md` の停止線、各 skill SKILL.md の境界、ユーザー明示トリガの reviewer の 3 層。reviewer は read-only を frontmatter で維持する。
- **doc 追従の残作業**: `docs/notes/runtime-surface-guidance.md` と `docs/notes/harness-regression-checks.md` は対称モデルを記述しており、Codex には有効だが Claude 記述は乖離した。新 note `docs/notes/claude-lightweight-workflow.md` に乖離を記録し、これら共有 note の全面整合は follow-up とする。
- 本 ADR は Claude 限定。Codex surface の変更を含意しない。
