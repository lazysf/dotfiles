# basic-design: orchestrate-autonomous-run-until-final-gate

## 用語定義

- **自走 (autonomous run)**: orchestrate が Phase / Gate 間でユーザー入力を待たず、停止線に触れない範囲で次工程へ進めるモード。triage で tier を決めてから tier に応じた最終 Gate pass まで継続する。
- **中途報告 (interim report)**: Phase / Gate ごとに lead がユーザーに送る完了報告。自走モードでは最小化する。
- **進捗ステータス (status update)**: caveman モード等の短い 1 行 (例: `Phase 2 architect 起動中`)。tooling の statusMessage に近く、ユーザー介入を期待しない。継続して許容する。
- **まとめ報告 (final report)**: 最終 Gate pass 時に lead が出す 1 回の総括報告。変更内容 / 検証結果 / 未確認事項 / 次アクション (commit / push / 追加依頼) を含む。

## 変更概要

### 1. SKILL.md 基本方針節

`dot_claude/skills/orchestrate/SKILL.md` および `dot_codex/skills/orchestrate/SKILL.md` の基本方針節に次を追加する。

```markdown
- 停止線接触、Gate fail の同じ blocking 繰り返し、ユーザー入力必須の決定 を除き、triage 後から tier に応じた最終 Gate (`inquiry` Phase 0 / `micro` 自己確認 / `standard` 統合 Gate / `full` Gate 3) の pass まで自走する。commit / push は引き続きユーザー指示で実行する。
```

既存の停止線リスト・agent routing・出力フォーマットは無変更。

### 2. SKILL.md 手順節

両 surface の手順節に次を追加する。

```markdown
- 自走中の Phase / Gate 進行は、進捗ステータス (caveman の短い 1 行など) で十分とし、Phase / Gate ごとの完了報告を都度ユーザーに送らない。最終 Gate pass 時にまとめて変更内容・検証結果・未確認事項・次アクションを 1 回で報告する。
```

### 3. references/sdlc-flow.md

両 surface の `sdlc-flow.md` 冒頭 (Triage 節の直前または直後) に次を追加する。

```markdown
全 tier に共通して、停止線接触・Gate fail の同じ blocking 繰り返し・ユーザー入力必須の決定 を除き、orchestrate は triage 後から最終 Gate (tier に応じる) の pass まで自走する。Phase / Gate ごとの完了報告は都度送らず、最終 Gate pass 時に lead がまとめて報告する。commit / push は依然としてユーザー指示で実行する。
```

該当箇所は `Triage: tier 判定` 節の直後、`### inquiry` の前を想定。

### 4. ADR 0029 作成

`docs/adr/0029-orchestrate-autonomous-run-until-final-gate.md` を新規作成。

- Status: Accepted
- Amends: 0025, 0026
- 背景: ADR 0025 で全依頼を orchestrate に通す入口統一を行い、ADR 0026 で inquiry tier を加えた。tier 別フローと停止線は整ったが、Phase / Gate 進行ごとに lead が完了報告を返す運用で「自走できるはずの場面でユーザー介入が要る」流れになっていた。
- Decision: 停止線・Gate fail の同じ blocking 繰り返し・ユーザー入力必須の決定 を除き、最終 Gate pass まで自走、途中報告は最小化、最終 Gate pass 時にまとめ報告。commit / push trigger は現状通りユーザー指示。
- Consequences: 軽い案件ほど Phase / Gate を一気に通せる。caveman の短い進捗ステータスは継続。停止線リスト・autonomous-loop は変更しない。

### 5. runtime-surface-guidance.md

関連文書節に ADR 0029 リンクを追加する。本文の orchestrate 説明節は既に最新 (4 tier) で変更不要。

## 影響範囲

| File | 変更 |
|---|---|
| `dot_claude/skills/orchestrate/SKILL.md` | 基本方針節 + 手順節 |
| `dot_codex/skills/orchestrate/SKILL.md` | 同上 |
| `dot_claude/skills/orchestrate/references/sdlc-flow.md` | Triage 節周辺 |
| `dot_codex/skills/orchestrate/references/sdlc-flow.md` | 同上 |
| `docs/adr/0029-orchestrate-autonomous-run-until-final-gate.md` | 新規 |
| `docs/notes/runtime-surface-guidance.md` | ADR 0029 リンク追加 |

agent 定義 / handoff / gate-review / autonomous-loop / 進行節 (CLAUDE.md / AGENTS.md) は変更不要。

## 検証手順

1. SKILL.md (両 surface) で「自走」「最終 Gate」「まとめ報告」相当の文が含まれることを確認 (AC-1, AC-2)。
2. references/sdlc-flow.md (両 surface) で自走ルールが反映されていることを確認 (AC-3)。
3. 停止線節と autonomous-loop references の差分が無いことを確認 (AC-4)。
4. ADR 0029 の存在と構成を確認 (AC-5)。
5. runtime-surface-guidance.md に ADR 0029 リンクがあることを確認 (AC-6)。
6. `git diff --stat dot_*/agents/` で 0 件を確認 (AC-7)。

## リスクと対策

- **既存 Phase / Gate 報告との二重定義**: 既存の SKILL.md は handoff / gate-review references を参照しており、ここでは「報告タイミング」を集約する。SKILL.md と references の間で記述が重複しないよう、SKILL.md 内に「自走と最小報告」を 1 箇所だけ書き、Phase / Gate 個別の handoff schema は references を継続して正本にする。
- **停止線との曖昧さ**: 「ユーザー確認が必要な場面」は既存停止線リストで列挙済み。新規追加せず、停止線リストと自走モードを同じ場所 (SKILL.md) から参照させる。
- **caveman モードとの相互作用**: caveman は output-style で、ユーザー向け文体を圧縮する。中途報告そのものを送らない方針なので、caveman モードでも非該当 (出さないものを短縮するだけ)。
