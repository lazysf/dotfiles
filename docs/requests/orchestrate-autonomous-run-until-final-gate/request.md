# request: orchestrate-autonomous-run-until-final-gate

## 元要求

- orchestrate skill について、ユーザーへの質問・確認以外は処理が進んだら最終 Gate pass までフローを自動で流し切るようにしたい。Phase / Gate 進行中の中途報告は最小化し、commit / 次アクションの判断はユーザーに残す。

## 背景

- 現状の orchestrate は Phase / Gate ごとに lead が結果報告するため、ユーザー側の体感では「区切りごとに介入が要る」流れになる。実際には停止線 / Gate fail 以外で確認は不要だが、丁寧な報告が逆に進行を区切ってしまう。
- 自走しても良い場面 (停止線非接触、Gate pass の系列) で都度ユーザーに渡されると、handoff のコストが積み上がる。

## 期待状態

- 停止線接触 / Gate fail で同じ blocking が繰り返す / ユーザー入力必須の決定事項 を除き、orchestrate は triage 後から tier に応じた最終 Gate (`inquiry` は Phase 0、`micro` は実装+自己確認、`standard` は統合 Gate、`full` は Gate 3) の pass まで自走する。
- Phase / Gate 進行中の途中報告は最小化し、最終 Gate pass 後に lead が変更内容・検証結果・未確認事項・次アクション (commit / push / 追加依頼) を 1 度にまとめてユーザーへ返す。
- commit / push は依然としてユーザー指示待ち。skill 自身が commit / push を勝手に発火しない (現状維持)。

## triage

- 停止線接触: なし。orchestrate skill 本体の挙動仕様変更は auth / 権限 / secret / 公開挙動 / data format / 永続化 / 新依存 / 本番設定 に触れない。
- 規模: SKILL.md 2 file + references/sdlc-flow.md 2 file + ADR 1 件 + notes 1 件 = 約 6 file。
- tier: **standard**。
- 根拠: 設計判断は合意済み (終端 = 最終 Gate pass、途中報告最小化、停止線は現状維持)。最小工程で実装可能。

## 合意済み事項

- 終端: tier に応じた最終 Gate pass (`inquiry` Phase 0 / `micro` 自己確認 / `standard` 統合 Gate / `full` Gate 3)。
- 途中報告: 不要、最終 Gate pass 時にまとめて 1 回報告。
- 停止線: 現状維持。
- commit / push の trigger は現状通りユーザー指示待ち。

## scope

- `dot_claude/skills/orchestrate/SKILL.md` の基本方針 / 手順節に自走モードと最小報告を明記。
- `dot_codex/skills/orchestrate/SKILL.md` 同様。
- `dot_claude/skills/orchestrate/references/sdlc-flow.md` の Phase / Gate 説明に自走と最小報告を反映。
- `dot_codex/skills/orchestrate/references/sdlc-flow.md` 同様。
- 新 ADR `0029-orchestrate-autonomous-run-until-final-gate.md`。
- `docs/notes/runtime-surface-guidance.md` に ADR 0029 リンク追加。

## non-scope

- 停止線 (`SKILL.md` 停止線節) の変更。
- handoff / gate-review / autonomous-loop references の本文改訂。
- agent 定義の変更。
- commit / push trigger の自動化。
- `caveman` output-style や応答文体の変更 (報告そのものの粒度は SKILL.md 内に閉じる)。

## 未確認事項

- 「途中報告」と「進捗ステータス (caveman モードの短い 1 行)」の境界。最終仕様は basic-design.md で固める。
