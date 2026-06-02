# Test: Split orchestrate tier flow references

## Checks

- `rg "references/sdlc-flow.md|sdlc-flow.md" dot_codex/skills/orchestrate dot_claude/skills/orchestrate` で現行 skill surface に参照が残っていないことを確認した。
- Codex / Claude の `SKILL.md` に tier 別 reference link があることを確認した。
- Codex / Claude の `references/` に `inquiry.md` / `micro.md` / `standard.md` / `full.md` があることを確認した。
- Codex / Claude の `SKILL.md` に Triage 停止線と Phase / Gate 単位の Tier Map があることを確認した。
- tier reference に分岐後停止線があることを確認した。
- tier reference に agent / artifact / format 指定があることを確認した。
- `quality-reviewer` / `security-reviewer` を起動し、分割方針と実装差分を review した。
- reviewer 指摘への対応後、`full.md` の Gate 1 が `requirements-reviewer` 単独、Gate 2 / 3 が 2 人体制であることを確認した。
- reviewer 指摘への対応後、`standard.md` に任意の `researcher` 工程と artifact 必須 / 任意の扱いがあることを確認した。
- reviewer 指摘への対応後、Triage 停止線と inquiry / micro / full の分岐後停止線に公開 API、永続化、外部送信などの高リスク項目が含まれることを確認した。
- `SKILL.md` は Phase / Gate 単位に絞られ、tier reference 側に工程小セクションがあることを確認した。
- 再 review 指摘への対応後、inquiry / micro が Gate なし、standard / full が Gate 3 と読めることを確認した。
- 再 review 指摘への対応後、standard 停止線が Triage 停止線の高リスク項目とそろっていることを確認した。
- Phase 3 が `実装・検証・仕上げ`、Gate 3 が `完了レビュー` として Codex / Claude の `SKILL.md` と tier reference にそろっていることを確認した。
- tier reference に `工程表` がなく、Phase / Gate セクション配下の工程小セクションに agent、artifact、format、進め方が記載されていることを確認した。
- tier reference の見出し順が Phase / Gate を先に読める形でそろい、古い工程表見出し、`Phase 4` / `Gate 4`、英語の `review` 工程見出しが残っていないことを確認した。
- `quality-reviewer` / `security-reviewer` の再 review 指摘を確認し、停止線、standard 軽量時 trace、autonomous loop、Claude handoff へ反映した。
- fresh review 指摘への対応として、`micro` の request folder 例外と standard Gate 表現が Codex / Claude 両 surface に反映されていることを確認した。
- 追加 review 指摘への対応として、Gate pass 後のユーザー承認 checkpoint、standard / micro 軽量時の trace 元、untracked secret-safe summary、researcher read-only external lookup、request folder path boundary の扱いが Codex / Claude 両 surface に反映されていることを確認した。
- `mise exec -- markdownlint-cli2 ...` で今回変更した Markdown file の markdownlint を実行した。
- `git diff --check` を実行した。

## Result

- Targeted markdownlint: pass。
- `git diff --check`: pass。
- Full `mise run lint`: fail。失敗箇所は既存 request artifact の Markdown style (`docs/requests/agent-skill-name-pair-alignment/basic-design.md`、`docs/requests/orchestrate-autonomous-run-until-final-gate/basic-design.md`) で、今回 scope 外。
