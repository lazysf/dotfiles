# 0039: docs/requests 配下の既存 artifact を整理して廃止する

- Status: Accepted
- Amends: 0036

## 背景

ADR 0036 `make-codex-surface-lightweight-and-restore-symmetry` で **request folder 体系を凍結** し、「既存 `docs/requests/<slug>/` 配下の artifact は履歴として残し、新規 request folder は作らない」と決めた。

その後 2026-06 に既存 16 dir (76 files) を triage したところ、`docs/requests/` を「履歴として保持する」状態のままにしても次の理由で実質的な追跡価値が薄いことが判明した:

- **対応 ADR 集約済み**: orchestrate 系 / skill 名整合 / agent 削減など 8 dir (29 files) の判断は ADR 0026〜0034 に既に取り込まれており、request 側は SDLC 中間記録 (requirements / design / tasks / test) で重複している。
- **superseded 済み**: orchestrate 系 5 dir (35 files) は ADR 0035 (Claude lightweight LLM-native) / 0036 (Codex 軽量化) で orchestrate skill 自体が撤廃されたため、判断記録としても再参照価値がない。
- **ADR 未化の経緯記録**: model / effort 調整 3 dir (12 files) は ADR を切らず request に置いたままだったが、ADR 化するほどの分岐判断ではなく、時系列で追える notes が後継として適切。

## 決定

`docs/requests/<slug>/` 配下の artifact を次の 3 つに振り分けて廃止し、`docs/requests/` dir 自体を削除する。

- **対応 ADR があり判断が十分集約済みのもの (8 dir)**: 削除のみ。
  - 対象: `agent-skill-name-pair-alignment` (0028), `codex-skill-name-alignment` (0027), `orchestrate-agent-standing-authorization` (0033), `orchestrate-auto-gate-approval` (0032), `orchestrate-autonomous-run-until-final-gate` (0029), `orchestrate-inquiry-tier` (0026), `orchestrate-tier-reference-split` (0030), `reduce-non-reviewer-agents` (0034)。
- **ADR 化していない経緯記録 (3 dir)**: `docs/notes/model-and-effort-tuning-history.md` に時系列で統合してから削除。
  - 対象: `change-claude-model-opus-46`, `tune-codex-reasoning-effort`, `align-claude-effort-with-codex`。
- **superseded 済みで notes 化価値もないもの (5 dir)**: 削除のみ。
  - 対象: `claude-orchestrate-tier-display`, `orchestrate-flow-order-enforcement`, `orchestrate-prephase-artifact-order`, `orchestrate-stop-line-catalog`, `orchestrate-tier-display`。

今後の judgment 追跡は ADR / notes の 2 層で完結させる。`docs/requests/` への参照は ADR 0020 / 0034 / 0036 本文に履歴として残るが、参照先 dir は存在しないことを許容する (ADR は判断記録として書かれた時点の事実を保持するため、本 ADR で本文を書き換えない)。

## 検討した代替案

- **ADR は触らず notes に状況を一文追記する**: `docs/notes/lightweight-workflow.md` に「2026-06 で既存 artifact は ADR/notes 集約後に削除」と書く案。判断台帳としてのトレーサビリティを取らないため、後から「なぜ 0036 の方針が変わったのか」を追えない。却下。
- **何もしない (現状維持)**: 0036 と現状の乖離は履歴として読める範囲、という許容。ただし「履歴として残す」と決めた状態を黙って変えたまま放置することになり、ADR 台帳の意味が薄れる。却下。

## 影響

- **`docs/requests/` の完全廃止**: 空 dir も削除する。新規 SDLC artifact 体系はそもそも 0036 で凍結済みのため、復活経路は ADR 改定が要る。
- **ADR 0036 の Amend**: ADR 0036 line 36 の「既存 `docs/requests/<slug>/` 配下の artifact は履歴として残し」を、本 ADR で「2026-06 に triage して ADR / notes に集約後、`docs/requests/` ごと削除」へ更新したものとして扱う。同 line の「新規 request folder は作らない」部分は維持。ADR 0022 `preserve-adr-body-history` を尊重し、0036 本文は書き換えず、relationship metadata (`Amended by: 0039`) を追加する。
- **過去 ADR からの参照リンク**: 0020 / 0034 / 0036 が `docs/requests/<slug>/` を参照しているが、削除済みの dir は復元しない。リンク切れではなく「過去存在した path を判断記録の文脈で参照している」として扱う。
- **個別 file の復元経路**: ADR / notes に集約しきれなかった file が将来必要になった場合は、`git log -- "docs/requests/<slug>/"` で過去 commit を辿る (slug は本 ADR 決定節に列挙)。working tree からは消えているが git history からは復元可能。
- **judgment 追跡の 2 層化**: 今後の判断記録は ADR、経緯や調査メモは notes に分け、SDLC 中間 artifact は持たない運用に統一する。lead が「これは ADR か notes か」を毎回判断する必要があるが、3 条件 AND の判定基準は `scribe` skill にあり、運用負荷は低い。
