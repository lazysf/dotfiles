# basic-design: orchestrate-inquiry-tier

## 公式情報確認

設計判断のため次を確認した（最終返答で明示する）。

- [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)
  - description は trigger の唯一の機構。imperative phrasing + ユーザー意図 + 「pushy」気味（"even if ..." 形式で明示）+ 1024 文字制限。
  - agent は単純・単一ステップタスクで skill を consult しない傾向。「特殊知識・複雑タスク」と判定されないと発火しない。
- [Specification](https://agentskills.io/specification)
  - frontmatter: name 1-64 字、description 1-1024 字。
  - SKILL.md 本体は <500 行を推奨。長文は references に逃がす（progressive disclosure）。
- [Claude Code skills](https://code.claude.com/docs/en/skills)
  - SKILL.md は `/skill-name` で直接 invoke、または description match で auto-invoke。
  - CLAUDE.md の手順節は skill に分けると context 節約になる。

## 現状と問題

現 description（要約）:

> コード変更・実装・既存機能変更・複数ファイル変更・設計判断を伴う開発依頼の進行入口として常に使う。…単なる質問・相談・調査だけの依頼には使わない。

問題:

1. 末尾の除外句で「質問・相談・調査だけ」を明示的に外している -> ユーザー意図と逆。
2. 列挙が「開発依頼」中心で、質問依頼は trigger 候補に並ばない。
3. 質問依頼は agent から見ると単純タスク扱い -> 公式の「単純タスクで skill consult しない」傾向と相まって発火率が下がる。

## 設計方針

### description（SKILL.md frontmatter）

- imperative + pushy + scope を全依頼へ広げる。
- 「inquiry tier は軽量経路」と明示し、重工程を恐れた skill 回避を抑える。
- 既存の tier 列挙（micro / standard / full）と並べて inquiry を追加。
- 文字数は 1024 字内（日本語）。

draft:

```yaml
description: 全依頼の進行入口として常に使う。コード変更・実装・既存機能変更・複数ファイル変更・設計判断はもちろん、質問・相談・調査だけの依頼であっても、まずこの skill を通す。lead が Phase 0 で triage し、規模と性質に応じて inquiry / micro / standard / full の tier に振り分けて Phase / Gate、request folder、subagent routing、repository maintenance、handoff、ユーザー確認を管理する。inquiry tier は質問・相談・調査向けの軽量経路で、Phase / Gate / artifact を強制せず lead が直接回答する。typo / 1 行修正のような極小依頼から新機能まで、scope に関わらずまずこの skill を通す。
```

### SKILL.md 基本方針節

tier 列挙を `inquiry / micro / standard / full` の 4 値に更新する。本文の詳細は references/sdlc-flow.md に置き続け、SKILL.md 本体は薄く保つ（progressive disclosure）。

該当箇所の変更点:

- 「全依頼を入口として受ける。Phase 0 の後に triage し、`micro` / `standard` / `full` の tier を決める。」-> 「全依頼を入口として受ける。Phase 0 の後に triage し、`inquiry` / `micro` / `standard` / `full` の tier を決める。」
- 出力 `tier` の例示も同様に 4 値へ更新。

### references/sdlc-flow.md

#### Triage 節

判定順:

1. 停止線接触 -> `full`（変更なし）。
2. 停止線非接触 -> 性質と規模で振り分け:
   - **コード変更・差分作成・実装を伴わない質問・相談・調査** -> `inquiry`
   - 自明・単一箇所・設計判断なしのコード変更 -> `micro`
   - 複数 file または軽い設計判断あり -> `standard`

迷う場合は上位 tier に倒す（既存方針維持）。triage 結果と根拠は `request.md` に残す（既存方針維持）。

ただし inquiry は request folder を強制せず、回答だけで完了する経路を許す（次節）。

#### inquiry tier 節（新規）

- 対象: コード変更を伴わない質問、相談、調査依頼。「○○の仕組みは？」「△△の方針はどう考えるべき？」「□□を調べて」等。
- flow: Phase 0 -> lead が直接回答（必要なら `analyst` を 1 回呼ぶ）-> 完了。
- Gate: なし。
- artifact: 任意。request folder を作る場合でも `request.md`（triage 記録）のみで十分。継続的に同じテーマで質問が続くなら standard へ昇格させる。
- 昇格条件: 質問の途中でコード変更・実装・既存機能変更が必要になった時点で、lead が tier を再判定し `micro` / `standard` / `full` のいずれかへ移す。

### 影響範囲

- SKILL.md: description / 基本方針の tier 列挙 / 出力例 `tier` の 3 箇所。
- references/sdlc-flow.md: 冒頭説明、triage 節、tier 別節。
- 他の references（handoff / gate-review / autonomous-loop）: 変更不要。inquiry tier は Gate / handoff / loop を通さない経路のため、これら references の対象外として整合する。
- agent 定義（`dot_claude/agents/*.md`）: 変更不要。Phase 0 内で完結するため新 agent は不要。
- `dot_claude/CLAUDE.md` 進行節 / root `AGENTS.md` 進行節: 「質問・相談・調査だけの依頼は対象外」の文言が残る -> doc-followup で追従要否を判定。

## non-scope

- Codex 側 `dot_codex/skills/orchestrate/` の同期。
- description の自動最適化ループ（trigger eval を 20 件作って 5 iteration 回す手順）。今回は差分設計のため見送り、`docs/notes/` 等に follow-up メモを残さない（必要なら別 request）。

## 検証観点

- AC-1: 新 description が「質問・相談・調査依頼でも入口にする」前提を読み取れる。
- AC-2: SKILL.md と sdlc-flow.md の tier 列挙が 4 値で一致。
- AC-3: triage 判定文に「inquiry -> Phase 0 のみ」が読み取れる。
- AC-4: basic-design.md に公式情報の参照が明記されている（本ファイル）。
- AC-5: 旧除外句 "質問・相談・調査だけ" が SKILL.md と sdlc-flow.md から消える。CLAUDE.md / AGENTS.md 側は doc-followup で判定。
- 文字数: description が 1024 字以内。
