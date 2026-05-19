# 0006: `AGENTS.md` は薄い surface 案内に留める

- Status: Accepted

## Context

`dot_codex/private_AGENTS.md.tmpl` は共通ハーネスの運用契約を置く source file だが、代表導線や開発フローの列挙まで抱えると、実際の運用とずれやすい。

現在の運用は、要件整理、実装、レビュー、修正、コミットといった作業ごとに、利用者がその都度チャットで依頼し、対応する skill や reviewer agent が選ばれる形で進む。
固定の開発フローを `AGENTS.md` に置くと、この逐次選択の運用より強い手順があるように読めてしまう。

また、詳細な導線列挙を `AGENTS.md`、`docs/notes/runtime-surface-guidance.md`、手動回帰チェックの複数箇所で持つと、surface 更新時に正本がぶれやすい。

## Decision

- `dot_codex/private_AGENTS.md.tmpl` は、全体契約と薄い runtime surface 案内に留める
- `dot_codex/private_AGENTS.md.tmpl` には固定の開発フローや代表導線の列挙を置かない
- `dot_codex/skills/` は通常作業の正式入口、`dot_codex/agents/` は専門化した read-only 補助役や review 入口、`dot_codex/rules/` は機械的ガードとして案内する
- 詳細な使い分けや発火条件は、各 `SKILL.md`、agent 定義、`docs/notes/runtime-surface-guidance.md` などの関連知識で管理する
- `docs/README.md` は index、`docs/notes/harness-regression-checks.md` は手動回帰シナリオとして役割を分ける

## Consequences

- `AGENTS.md` は実運用より強い線形フローを示唆せず、現在の逐次チャット運用に沿った薄い案内になる
- surface の背景説明、手動回帰、index の責務が分かれ、更新時の二重管理が減る
- surface 契約を変えるときは、`AGENTS.md` だけでなく関連 docs との整合も確認する必要がある
