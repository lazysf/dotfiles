# Implementation: Split orchestrate tier flow references

## Changes

- `SKILL.md` に Phase 0 と Triage 判定を移し、tier 決定後に読む reference を明示した。
- `SKILL.md` に Triage 停止線と、Phase / Gate 単位の Tier Map を追加した。
- `references/inquiry.md` / `micro.md` / `standard.md` / `full.md` を Claude / Codex 両 surface に追加した。
- 分岐後の flow と停止線を各 tier reference に寄せた。
- 各 tier reference に工程ごとの agent 呼び出し、artifact、`scribe/references/*-format.md` への format link を追加した。
- 内容精査で、`SKILL.md` から Agent Routing 表と repository maintenance 詳細を外し、必要な routing は tier reference に寄せた。
- `references/sdlc-flow.md` は索引だけになったため削除し、必要な読み分けは `SKILL.md` に吸収した。
- `docs/notes/runtime-surface-guidance.md` に新しい正本配置を反映した。
- ADR 0030 を追加し、今回の分割方針を記録した。
- `quality-reviewer` / `security-reviewer` の指摘を受け、`full.md` の Gate 1 reviewer 数の矛盾、`standard.md` の任意調査 / 任意 artifact 表記、分岐後停止線の不足、`description` の trigger 語不足を修正した。
- `SKILL.md` では Phase / Gate 単位の Tier Map に絞り、工程単位の詳細は tier reference に寄せた。
- 再 review 指摘を受け、Tier Map と完了方法を分離した。
- tier reference の Phase 名を `SKILL.md` の語彙にそろえ、standard 停止線と Claude full の handoff 説明を修正した。
- Phase 3 は `実装・検証・仕上げ` とし、Phase 4 / Gate 4 は作らない方針に整理した。
- tier reference の `工程表` は廃止し、Phase / Gate セクション配下の工程小セクションに `扱い`、agent、artifact、format、進め方を記載する形に整理した。
- tier reference の書き振りをそろえ、`full.md` は Phase / Gate を先に読める順序へ変更し、review 工程名を日本語寄りに統一した。
- reviewer 指摘を受け、command / script / hook / workflow、validation 境界、injection / path traversal を `full` 昇格とユーザー確認の停止線に追加した。
- standard 軽量時は `request.md` の scope / acceptance / 実装範囲を Gate 3 の trace 元にすることを明示した。
- autonomous loop と Claude handoff の lead 集約表現をそろえ、security 系 remediation は自律修正しない停止線を追加した。
- fresh review 指摘を受け、`micro` は request folder を強制しないこと、standard の Gate は Gate 3 のみであることを明確化した。
- 追加 review とユーザー確認を受け、`自走` を「次 checkpoint まで進む」と定義し、Gate pass 後のユーザー承認 checkpoint を `SKILL.md` / `full.md` / `standard.md` / `gate-review.md` に反映した。
- standard / micro 軽量時に `tasks.md` を省略した場合の `implementation.md` / `test.md` trace 元を `request.md` の scope / acceptance / 実装範囲へそろえた。
- Gate 3 review と repository maintenance の untracked file 扱いを secret-safe summary に変更し、researcher の read-only external lookup を有効な handoff として扱えるようにした。
- request folder 作成時の slug と path boundary を `SKILL.md` に明記した。
- ADR 0031 を追加し、ADR 0029 の自走方針を Gate pass 後承認 checkpoint と整合させた。

## Notes

旧 ADR と過去 request artifact は履歴として保持した。削除前の `references/sdlc-flow.md` 参照は過去判断の記録として残る。
