# request: orchestrate-inquiry-tier

## 元要求

- orchestrate skill が「質問・相談・調査だけの依頼」では発火しない現状を変える。
- 質問・相談・調査依頼も orchestrate を入口に通し、triage で適切なフローへ分岐させる。

## 背景

- 現在の SKILL.md description と `dot_claude/CLAUDE.md` 進行節に「単なる質問・相談・調査だけの依頼は対象外」と明記している。
- 実際の運用で、別セッションでも orchestrate を経由しないケースが発生した（ユーザー観測）。
- 入口を一本化することで、依頼種別の取り違えと進行ルートの場当たり対応を減らす。

## 期待状態

- 全依頼が Phase 0 + triage を通る。triage は既存 `micro` / `standard` / `full` に加え、新 tier `inquiry` で質問・相談・調査を扱う。
- `inquiry` 判定なら artifact / Gate を強制せず、回答だけ返す軽量経路を取る。
- 開発系依頼の既存フロー（micro / standard / full）は変更しない。

## triage

- 停止線接触: なし（公開挙動 / API / data / auth / secret / 依存 / 破壊的 / 本番 のいずれも非該当）。
- 規模: 複数 file + 軽い設計判断（tier 概念の追加）。
- tier: **standard**。
- 根拠: SKILL.md と references/sdlc-flow.md の 2 file 変更。skill 定義変更のため skill-creator + Agent Skills 公式情報確認が必要だが scope は最小（合意済み: A 案・全依頼入口・最小変更）。

## 合意済み事項

- 取り扱い方: 新 tier `inquiry` を追加する（A 案）。micro 拡張や素通りは取らない。
- 対象範囲: 全依頼を orchestrate 入口にする。SKILL.md description の「単なる質問・相談・調査だけの依頼には使わない」除外句を削除する。
- 波及範囲: 最小変更（SKILL.md + references/sdlc-flow.md）。他の references / agents 定義は触れない。
- skill 定義変更のため、設計段階で skill-creator + Agent Skills 公式情報（description optimizing / specification / best practices）を確認する。

## scope

- `dot_claude/skills/orchestrate/SKILL.md` の description と基本方針の文言更新。
- `dot_claude/skills/orchestrate/references/sdlc-flow.md` の triage 節と tier 定義に `inquiry` を追加。
- 参照側の追従漏れ確認（CLAUDE.md 進行節、root AGENTS.md、関連 references）。

## non-scope

- handoff.md / gate-review.md / autonomous-loop.md 本文の構造改訂。
- agent 定義（`dot_claude/agents/*.md`）の変更。
- Codex 側（`dot_codex/skills/orchestrate/`）の同期。今回は Claude 側のみ。
- 既存 micro / standard / full の tier 定義そのものの見直し。

## 未確認事項

- Codex 側にも orchestrate skill が存在する場合の片側漏れ。実装後に doc-followup で確認する。
