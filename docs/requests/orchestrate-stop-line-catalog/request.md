# Request

## 元の要求・要望

orchestrate workflow の評価で挙げた懸念/改善余地を修正する。評価で挙げた主要点のうち、本要求で扱うのは次の 2 点（ユーザー確認で確定）。

1. 停止線重複の DRY 化を「カタログ集約」方式で行う。挙動（停止線が捕捉する網羅範囲）は等価に保つ。
2. `standard` / `full` 境界の判定基準を明確化する。

## 背景

- 現状、停止線リスト（公開挙動 / 公開 API / data format / 永続化 / auth / 権限 / secret / 新依存 / 破壊的操作 / 本番設定 / runtime guardrail / CI permission / 外部送信 / deploy / publish、および command / script / hook / workflow の実行入口 …）が SKILL.md / full.md / standard.md / micro.md / inquiry.md に各々コピーされている。語の追加・修正時に複数箇所の手修正が必要で drift 源になる。
- `standard`↔`full` の振り分け条件（「軽い設計判断」「複数 file」）は主観的で、判定例が無い。
- Claude（dot_claude）と Codex（dot_codex）の両 surface に同一構造で存在し、実差分は `subagent`/`agent` 語のみ。両 surface を同期して変更する必要がある。
- 本 repo は chezmoi 管理。`dot_claude` / `dot_codex` 配下が配布対象。
- AGENTS.md 上、skill の設計変更は判断前に skill-creator 使用 + Agent Skills 公式情報確認が必須。停止線・skill 定義・承認ルールに触れるため docs-only として扱わない。

## 期待状態

- 停止線の共通カタログが 1 reference に集約され、SKILL.md / 各 tier reference はそれを参照 + tier 固有差分のみを持つ。停止線の網羅範囲は変更前と等価。
- `standard` / `full` の境界判定が、判定例または明示基準で曖昧さが減っている。
- Claude / Codex 両 surface が同期している。
- 既存の参照 path / リンクに drift が無い。

## 不明点

- Phase 1 で確認: 各 tier reference の停止線文言の正確な差異、tier 固有差分として残すべき行、共通カタログ reference の最適な置き場とリンク方式（相対 path の深さ）、境界明確化の置き場（SKILL の分岐表近傍か別 reference か）。

## scope 外（今回扱わない）

- lead 集約による並列化制約、inquiry tier の triage overhead は、正確性優先の意図的トレードオフとして現状維持。
- agent の model / effort 配分の見直し。
- 検証自動化の追加。

## Triage

- tier: full
- 根拠: skill 定義および停止線定義そのものの変更で、workflow の停止線カテゴリ（command / script / hook / workflow の実行入口・権限・停止線・承認ルール・skill 定義）に該当。
