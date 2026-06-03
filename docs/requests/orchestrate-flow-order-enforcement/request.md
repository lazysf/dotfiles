# Request

## 元の要求・要望

Claude/Codex の orchestrate スキルについて、まだ先に実装されてからドキュメントが作成される。何ならドキュメントが作成されないことも多い。フローの順序を守らせ、前工程の成果物を持って次工程を進めさせたい。

## 背景

- 同じ問題への過去取り組み `docs/requests/orchestrate-prephase-artifact-order/`（2026-06-02）が存在する。そこでは standard / full に `Phase 3 entry condition` を prose 追加し、gate-review に後付け fail 条件を追加した。
- しかし「確定していることを確認する」という抽象指示にとどまり、lead が「実際に何を Read し、何を満たさなければ次工程へ進めないか」が具体化されていない。結果、lead の自己判断で確認を skip でき、実装先行・docs 後（または未作成）が再発している。
- researcher 調査（このセッション）の確認事実:
  - 順序強制は全て prose のみ。機械的 hook / script / CI は存在しない。
  - standard は Gate 3 のみ、micro は Gate なし。micro には Phase 3 entry condition 自体が存在しない。
  - lead が「entry condition を満たした」と自己判断する構造で、外部による Phase 3 entry 承認はない。
  - Claude (`dot_claude/skills/orchestrate/`) と Codex (`dot_codex/skills/orchestrate/`) は内容同一、surface 名のみ差分。

## 期待状態

- 各 Phase / Gate の遷移点で、lead が前工程成果物を「実際に Read で確認」してから次工程へ進む手順が、skip できない形で明示されている。
- 実装先行・docs 後（または未作成）が、prose 上の抽象指示ではなく具体的なチェック手順で抑止される。
- 現状の tier 別 docs 省略設計（standard で Phase 1/2 任意、micro で省略）は維持する。docs を新たに一律必須化はしない。
- Claude / Codex 両 surface の orchestrate reference が同じ方針になる。

## 確定した方針（ユーザー確認済み）

- 強制の手段: prose 強化中心。機械的 hook は入れない。artifact を実際に Read で確認する手順を明示し、確認を skip できない書き方にする。
- docs 未作成への対処: 順序強制で十分。tier 別 docs 省略設計は維持する。
- 対象 surface: Claude + Codex 両方を対称に更新する。

## 不明点

- none（方針は確定済み）

## 再定義履歴

- none
