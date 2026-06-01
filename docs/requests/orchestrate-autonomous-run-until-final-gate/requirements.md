# requirements: orchestrate-autonomous-run-until-final-gate

## 目的

orchestrate を、ユーザー確認が必要な場面を除き、tier に応じた最終 Gate pass まで自走させ、中途報告を最小化する。

## scope

- 両 surface の SKILL.md + references/sdlc-flow.md。
- 新 ADR 0029。
- runtime-surface-guidance.md ADR リンク追加。

## non-scope

- 停止線リストの変更。
- handoff / gate-review / autonomous-loop の構造改訂。
- agent 定義改訂。
- commit / push 自動化。

## REQ

- **REQ-1**: SKILL.md (両 surface) の基本方針節に「停止線・Gate fail のループ・ユーザー入力必須の決定を除き、最終 Gate pass まで自走する」旨を明記する。
- **REQ-2**: SKILL.md (両 surface) の手順節に「Phase / Gate 進行中の途中報告は最小化し、最終 Gate pass 時にまとめて報告する」旨を明記する。
- **REQ-3**: references/sdlc-flow.md (両 surface) の冒頭または triage 節に「自走モード」「最小報告」のルールを反映する。
- **REQ-4**: 停止線節 (SKILL.md) の内容は変更しない。`autonomous-loop` references の本文も変更しない。
- **REQ-5**: 新 ADR `0029-orchestrate-autonomous-run-until-final-gate.md` を作成し、関連 ADR (0025 / 0026) を Amends として記録する。
- **REQ-6**: `docs/notes/runtime-surface-guidance.md` の関連文書節に ADR 0029 リンクを追加する。
- **REQ-7**: caveman output-style や応答文体の指針には触れない。報告ポリシーは orchestrate skill 内に閉じる。

## AC

- **AC-1**: 両 surface の SKILL.md 基本方針節に「自走」「最終 Gate pass まで」相当の文が含まれる。
- **AC-2**: 両 surface の SKILL.md 手順節に「途中報告最小化」「最終 Gate pass でまとめ報告」相当の文が含まれる。
- **AC-3**: 両 surface の references/sdlc-flow.md に自走モードのルールが反映される。
- **AC-4**: 停止線節と autonomous-loop references が無変更。
- **AC-5**: `docs/adr/0029-orchestrate-autonomous-run-until-final-gate.md` が Status / Amends / Decision / Consequences を備えて存在する。
- **AC-6**: `docs/notes/runtime-surface-guidance.md` の関連文書節に ADR 0029 リンクがある。
- **AC-7**: agent 定義 (`dot_*/agents/*.{md,toml}`) に差分なし。

## 制約

- ADR 履歴保持 (ADR 0022)。
- skill description 変更は本 request の scope 外 (trigger surface は維持)。
- 自走モードは「ユーザー確認が要らない場面に限る」を明示し、停止線リストとの整合を取る。

## 前提

- chezmoi 管理下の dot_codex / dot_claude が truth source。
- 過去 ADR 0025 / 0026 (orchestrate triage / inquiry tier) で確立した tier 構造を変更しない。

## 未確認事項

- 「進捗ステータス (caveman 1 行)」と「中途報告」の差は basic-design.md で文言定義する。
