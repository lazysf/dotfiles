# 0036: Codex surface を軽量化し両 surface を対称（軽量）に戻す

- Status: Accepted
- Supersedes: 0025, 0026, 0029, 0030, 0032, 0035
- Amended by: 0039

## 背景

ADR 0035 で Claude surface（`dot_claude/`）だけを軽量 LLM-native workflow へ再設計し、Codex surface（`dot_codex/`）は決定論 SDLC（`orchestrate` 必須入口 / tier / Phase/Gate / request folder / 工程別 doc）を維持して**意図的に非対称**にした。

運用した結果、対称運用の方が repo 全体として扱いやすく、Codex 側でも軽量設計のテンポと、第三者保守に渡せる後追い doc 体系の組合せが有効と判断した。

## 決定

**Codex surface も Claude と同じ軽量 LLM-native workflow へ再設計し、両 surface を再び対称にする**。ただし「対称＝軽量」であり、ADR 0035 以前の重 SDLC 対称へは戻らない。

- **進行はガイド**。`orchestrate` 必須入口・tier・Phase/Gate・request folder を撤去し、`dot_codex/AGENTS.md` に「掘り下げ→方針→実装⇄検証→review→doc→commit」のガイドと工程ごとの独立発火条件を置く。各工程は条件を満たす時だけ通す。
- **「方針」工程は会話ベース**。Codex には Claude の `EnterPlanMode` 相当がないため、方針提示＋ユーザー承認の会話手順として記述する。
- **doc は後追い**。事前 doc（requirements / design / tasks）と request folder（`docs/requests/<slug>/`）を廃止し、実装が固まった後に確定事実から 3 層（仕様＝README/docs、ADR、notes）で作る。doc 要否は silent skip 禁止で明示する。
- **agent は read-only 3 つに集約**。`researcher` / `quality-reviewer` / `security-reviewer` を残し、Codex 側の `inspector` / `requirements-reviewer` / `design-reviewer` を廃止する。reviewer はユーザー明示トリガで、diff を呼び出し元が渡す前提。read-only は `sandbox_mode = "read-only"` で強制する。effort は researcher = `medium → low`、reviewer 2 つは `high` 維持で Claude と対称化。
- **skill は doc / git / caveman の 4 つ**。`scribe`（doc 生成へ改修、references を `adr-format` / `notes-format` / `readme-format` の 3 つへ削減）/ `git-commit` / `git-push` / `caveman`（Codex は output-style 非対応のため skill のまま）を残し、`orchestrate` / `grill` / `research` / `architecture` / `implement` / `inspect` / `doc-followup` を廃止する。
- **`AGENTS.md` に prose な行動指針を集約**。Codex の `rules/` は command guard 専用（公式仕様）のため、`coding-standards` / `docs-artifacts` 相当の prose は `dot_codex/AGENTS.md` 本体に統合する。
- **Codex 固有作法は維持**: agent 間直接通信なし・lead 仲介、handoff 形式の agent 出力、`.rules` による command guard、`AGENTS.md` を全体共有契約として扱う構造。
- **runtime 安全層は触らない**: `approval_policy` / `approvals_reviewer = auto_review` / sandbox / `.rules` guard / network 制限は現状維持。`model_reasoning_effort` のみ Claude 対称化のため `high → medium`。

## 検討した代替案

- **非対称維持（ADR 0035 を保持）**: 対称運用の利便性と、Codex でも軽量化のテンポメリットを得たい運用判断により却下。
- **Codex も Claude と同様 prose を `rules/` に置く**: Codex 公式仕様（[rules](https://developers.openai.com/codex/rules)）で `.rules` は command guard 専用と定義されており、prose を置けないため却下。代わりに `AGENTS.md` 集約（[AGENTS.md](https://developers.openai.com/codex/guides/agents-md) 公式仕様で行動指針の正規置き場）を選択。
- **runtime 安全層も軽量化（auto_review / approval を緩める）**: review はユーザー明示時のみという思想と Codex runtime 安全機能は別レイヤとして扱い、後者は現状維持と判断。

## 影響

- **両 surface の再対称化（軽量で）**: ADR 0035 で記録した「非対称」の前提は本 ADR で覆る。共有 note（`runtime-surface-guidance` / `harness-regression-checks` / `harness-design-principles`）の Codex 重 SDLC 前提（orchestrate / tier / Gate / `doc-followup` / `inspect` 等）は無効化される。これら本文は履歴として保持し（ADR 0022）、scope banner で「現行は両 surface 軽量、詳細は `lightweight-workflow.md` を参照」と示す。`claude-lightweight-workflow.md` は両 surface カバーへ更新し `lightweight-workflow.md` へ rename する。
- **Codex 廃止 skill / agent の参照ずれ**: `orchestrate` / `grill` / `research` / `architecture` / `implement` / `inspect` / `doc-followup` skill と `inspector` / `requirements-reviewer` / `design-reviewer` agent への参照は、過去 ADR / request folder 内に大量にあるが、それらは履歴として保持する。新規 doc / skill / agent 定義からこれらへ参照しない。
- **request folder 体系の凍結**: 既存 `docs/requests/<slug>/` 配下の artifact は履歴として残し、新規 request folder は作らない。
- **runtime 安全層は無影響**: approval / auto_review / sandbox / `.rules` / network は変更なし。
