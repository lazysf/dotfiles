# 0005: ハーネス検証は repo 固有契約に絞る

- Status: Superseded
- Superseded-By: 0007

## Context

`scripts/verify-codex-harness.py` は、共通ハーネスの更新で壊したくない契約を軽量に検知するための専用スクリプトとして運用してきた。

一方で、移行期に有効だった `docs/README.md` の掲載網羅、旧 skill surface 文言、旧 skill ディレクトリ残骸まで自動検査に抱え続けると、repo 固有契約の検証と docs 保守や移行完了確認の責務が混ざる。

この repo では、runtime で気づきにくい metadata 欠落やリンク切れは自動検知の価値が高いが、docs の網羅性や移行完了の残骸確認は手動回帰チェックでも十分に扱える。

## Decision

- `scripts/verify-codex-harness.py` は、repo 固有契約の自動検知に必要な最小チェックだけを担当する
- 維持する自動検査は、agent metadata 必須キー、rule metadata 必須項目、`dot_codex/` と `docs/` 配下 Markdown の相対リンク切れ、knowledge の置き場として project-local `.codex` を勧める文面の禁止とする
- `docs/README.md` の掲載網羅、旧 skill surface 文言、旧 skill ディレクトリ残骸の確認は自動検査から外す
- 自動検査から外した観点は `docs/notes/harness-regression-checks.md` に手動回帰チェックとして残す

## Consequences

- 専用スクリプトは、汎用 lint で代替しにくい repo 固有契約の検知に責務を絞れる
- docs の網羅性や移行完了確認は、機械的な失敗条件ではなく、変更時に見るべき手動観点として運用する
- `mise run test` に含まれるハーネス検証は維持するが、失敗理由は runtime 契約とリンク整合に寄るようになる
