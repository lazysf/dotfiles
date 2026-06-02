# Implementation

## 対応タスク / 対応範囲

- `TASK-001`: Claude surface に停止線カタログ `dot_claude/skills/orchestrate/references/stop-lines.md` を新設。見出しと役割 1 文 + ブロックA 15 語 + ブロックB 12 語 + 遷移句テンプレ 3 種 + standard / full 境界判定。`secret` のみを持ち `secret handling` は置かない。tier 固有差分・ループ制御語は含めない。
- `TASK-002`: 同カタログの `## standard / full 境界判定` に DD-007 の明示基準 (a)(b)(c) と判定例 4 件を記述。
- `TASK-003`: Claude `SKILL.md`「Triage 停止線」を参照化。ブロックA/B 語列挙を除去し、サマリ + カタログ参照行（`references/stop-lines.md`、Triage 用遷移句）+ Triage 固有項目（tier 判定不能 / 要求再定義等 / secret 操作 / 不確実性が高い・影響範囲が Phase 0 だけでは絞れない）に再構成。
- `TASK-004`: Claude `SKILL.md`「分岐」表直後に境界入口手掛かり（DD-007）を 1 行挿入。
- `TASK-005`: Claude `references/full.md`「停止線」を参照化。カタログ参照行（full 用遷移句）+ full 固有差分 4 行。`secret handling` を除去し `secret` に揃う。
- `TASK-006`: Claude `references/standard.md`「停止線」を参照化。カタログ参照行（各 tier 用遷移句）+ standard 固有差分 4 行。自律差戻し禁止リスト（3 行目）はカタログへ集約せず保全。
- `TASK-007`: Claude `references/micro.md`「停止線」を参照化。カタログ参照行 + micro 固有差分 2 行（tier 移行トリガー / 自己確認）保全。
- `TASK-008`: Claude `references/inquiry.md`「停止線」を参照化。カタログ参照行 + inquiry 固有差分 2 行（tier 再判定トリガー / 不明点返却）保全。
- `TASK-009`: Codex surface（`dot_codex` 配下の 6 ファイル）へ同一構造で同期反映。surface 固有語 `subagent`->`agent` のみ差し替え。停止線セクション・カタログは surface 固有語を含まないため Claude と同一文言。
- `TASK-010` / `TASK-011` / `TASK-012`: 実装側の自己確認として実施（本格検証は inspector / `test.md`）。

## 変更内容

- 分散していたブロックA（公開挙動系 15 語）/ ブロックB（command 系 12 語）の語列挙を `stop-lines.md` 1 箇所へ集約。各停止線セクションは「カテゴリサマリ + カタログ参照行 + 文脈遷移句 + tier 固有差分」のみを持つ構造へ変更。
- `secret handling`（full.md のみの語彙ゆれ）を `secret` に統一。捕捉対象に `secret` を含む状態は維持。
- 遷移句を文脈別（Triage 用 / 各 tier 用 / full 用）にカタログへ定義し、各セクションは文脈に合う遷移句を再掲。
- `standard` / `full` 境界判定（明示基準 + 判定例 4 件）をカタログに新設し、SKILL.md 分岐表直後に入口手掛かりを追加。
- NB-1（security-reviewer 指摘）反映: 各停止線セクションのカタログ参照行末尾に「該当の可能性があればカタログ（stop-lines.md）を必ず開いて確認する」の到達指示を一貫して付与。カタログ冒頭の役割文にも同旨を記載。

## 変更ファイル

- `dot_claude/skills/orchestrate/references/stop-lines.md`: 新設（カタログ正本）。
- `dot_codex/skills/orchestrate/references/stop-lines.md`: 新設（Codex 同期、内容は Claude と同一）。
- `dot_claude/skills/orchestrate/SKILL.md`: Triage 停止線参照化、分岐表直後に境界入口手掛かり挿入。
- `dot_codex/skills/orchestrate/SKILL.md`: 同上（surface 固有語のみ既存差分）。
- `dot_claude/skills/orchestrate/references/full.md`: 停止線参照化、`secret handling`->`secret`。
- `dot_codex/skills/orchestrate/references/full.md`: 同上。
- `dot_claude/skills/orchestrate/references/standard.md`: 停止線参照化、自律差戻し禁止リスト保全。
- `dot_codex/skills/orchestrate/references/standard.md`: 同上。
- `dot_claude/skills/orchestrate/references/micro.md`: 停止線参照化、tier 固有差分保全。
- `dot_codex/skills/orchestrate/references/micro.md`: 同上。
- `dot_claude/skills/orchestrate/references/inquiry.md`: 停止線参照化、tier 固有差分保全。
- `dot_codex/skills/orchestrate/references/inquiry.md`: 同上。

## Scope 外

- `references/autonomous-loop.md`（L33 含む）/ `references/gate-review.md` / `references/handoff.md` は両 surface とも変更なし（git status で未変更を確認）。
- 停止線の意味的網羅範囲の拡張・縮小はしていない（等価維持）。
- AC-003 語単位照合範囲への autonomous-loop.md L33 の追加はしない（DD-009 で照合範囲外）。
- 検証自動化の追加なし。

## 実装中に判明した事項

- 両 surface の停止線セクション・カタログ本文は surface 固有語（`subagent` / `agent`、Claude / Codex）を含まないため、stop-lines.md は両 surface で完全一致、編集した停止線セクションにも surface 間差分は生じなかった。残る surface 差分は既存の subagent/agent 表記のみ（SKILL.md 2 箇所、full.md 末尾「調査の扱い」1 箇所）。
- ブロックB の `権限` はブロックA の `権限` と別文脈で両ブロックに保持（DD-009 Edge Case どおり）。
- standard の自律差戻し禁止リスト・micro / inquiry の tier 移行トリガーは語が重なるがカタログへ集約せず tier 固有差分として保全（DD-008 Edge Case）。

## 実行した確認

- 語列挙重複の非残存: `rg "新依存.*破壊的操作.*本番設定"`（ブロックA）と `rg "security boundary.*validation 境界"`（ブロックB 連続列挙）が両 surface とも `stop-lines.md` のみにヒット。
- `secret handling` 残存: `rg -c "secret handling"` が両 surface 対象で 0 件。
- 語単位存在（Claude カタログ）: ブロックA 15 語 / ブロックB 12 語が個別 `rg -F` で存在。`権限` はブロックA / B 双方に保持。
- リンク解決: 参照先 `stop-lines.md` が両 surface に存在。参照表記は SKILL.md が `references/stop-lines.md`、各 reference が `stop-lines.md` で path 深さ一致。
- 両 surface diff: 6 対応ファイルを `diff` 比較し、差分は subgent/agent の surface 固有語のみ（SKILL.md 2 行、full.md 1 行）。standard / micro / inquiry / stop-lines.md は差分なし。
- 変更境界: `git status --short` で変更が想定 12 ファイル（新規 2 + 改修 10）のみ。autonomous-loop.md / gate-review.md / handoff.md は不変。
- chezmoi 反映: `chezmoi diff --no-pager`（read-only）で `.claude` / `.codex` 両 surface に対応反映、想定外エラーなし。`chezmoi apply` は実施せず。

## 未確認事項

- 本格検証（AC-001..AC-010 の網羅判定、`chezmoi apply --dry-run`）は inspector / `test.md` の責務。実装側自己確認は上記範囲。
- 実装側で上流（要件・設計）と矛盾する点や blocker は検出していない。
