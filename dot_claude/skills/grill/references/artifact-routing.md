# Artifact Routing

どの doc / artifact に確定事項を反映するか迷う時だけ読む。

## 選び方

既定は 1 変更 1 ノート（feature note）。確定事項は基本的にノートの該当層へ反映する。

- 目的、達成したいこと、受入条件が曖昧: feature note の `要件` 層（受入条件は `AC-*`）
- 全体方針、責務分担、インターフェース、処理、考慮ケースが曖昧: feature note の `設計` 層
- 変更内容、確認方法が曖昧: feature note の `実装・検証` 層（変更境界・実装順序・task 分解は handoff として渡し、ノートには残さない）

feature note 以外（`CONTEXT.md` / ADR / 大規模時の PRD・要件定義・基本設計・詳細設計・実装計画・テストケース・traceability matrix）の doc 選択は `scribe` の「成果物の選び方」に従う。

## 反映判断

- 既存 artifact が自然に受け止められるなら、そこへ最小追記する。
- 自然な置き場が明確で、依頼の流れ上必要なら新規 artifact を作ってよい。
- 置き場、artifact 種別、ID 体系、ADR lifecycle が曖昧なら、推測で作らず質問する。
- format 適用や複数 artifact の整合が必要なら `scribe` スキルを使う。
- 責務外の内容は対象 artifact に書かず、必要なら別 artifact の更新候補に分ける。
