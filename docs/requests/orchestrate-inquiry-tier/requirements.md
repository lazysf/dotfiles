# requirements: orchestrate-inquiry-tier

## 目的

質問・相談・調査依頼を含む全依頼を orchestrate skill の入口に通し、Phase 0 + triage で適切な経路へ振り分ける。

## scope

- `dot_claude/skills/orchestrate/SKILL.md` の description と基本方針文言を更新。
- `dot_claude/skills/orchestrate/references/sdlc-flow.md` に新 tier `inquiry` を追加し、triage 判定文を更新。

## non-scope

- 既存 `micro` / `standard` / `full` の定義変更。
- handoff / gate-review / autonomous-loop の構造改訂。
- agent 定義変更。
- Codex 側 orchestrate との同期（実装後 doc-followup で漏れ確認のみ）。

## REQ

- **REQ-1**: SKILL.md description は「全依頼を入口にする」内容にする。「単なる質問・相談・調査だけの依頼には使わない」の除外句を削除する。
- **REQ-2**: SKILL.md 基本方針の tier 列挙に `inquiry` を追加する。
- **REQ-3**: sdlc-flow.md の triage 節に `inquiry` 判定を追加する。判定順序は「停止線接触 -> 規模 (inquiry / micro / standard / full)」とし、停止線非接触で「コード変更・差分作成・実装を伴わない質問・相談・調査」なら `inquiry` にする。
- **REQ-4**: sdlc-flow.md に `inquiry` tier 節を追加する。flow は「Phase 0 -> lead が直接回答」、Gate なし、artifact は request.md の triage 記録のみ（任意）。
- **REQ-5**: 既存 `micro` / `standard` / `full` の定義文と flow は変更しない。

## AC

- **AC-1**: SKILL.md description を読んだ Claude Code が、質問・相談・調査依頼でも skill を発火させる前提に立てる文言になっている。
- **AC-2**: SKILL.md と sdlc-flow.md の tier 列挙が一致する（4 tier: inquiry / micro / standard / full）。
- **AC-3**: sdlc-flow.md の triage 判定文に「inquiry 判定 -> Phase 0 のみで終了」が読み取れる。
- **AC-4**: skill-creator + Agent Skills 公式情報（description / specification / best practices）の確認結果が basic-design.md に明記されている。
- **AC-5**: `rg "質問・相談・調査だけ"` で旧除外句が SKILL.md と CLAUDE.md 進行節以外に残らない。CLAUDE.md 側の追従要否は doc-followup で判定する。

## 制約

- 最小変更。SKILL.md と sdlc-flow.md を必須対象とし、矛盾を解消するため CLAUDE.md 進行節も doc-followup で追従する（実装結果は 3 file）。
- AGENTS.md 指示通り、設計段階で Agent Skills 公式情報を確認し、参照ページを最終返答で明示する。

## 前提

- chezmoi 管理下の `dot_claude/skills/orchestrate/` が truth source。
- 展開先 `~/.claude/skills/orchestrate/` は chezmoi apply で同期される。

## 未確認事項

- CLAUDE.md 進行節（`~/.claude/CLAUDE.md` と `dot_claude/CLAUDE.md`）の文言「単なる質問・相談・調査だけの依頼は対象外」を更新するかは doc-followup の判断に委ねる。本 request の scope では SKILL.md と sdlc-flow.md のみを必須対象とする。
- Codex 側 orchestrate との片側漏れは doc-followup で報告し、必要なら別 request にする。
