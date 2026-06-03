# Gate Review

Gate は次フェーズへ進めるための最小条件を見る。詳細な checklist ではなく、責務、対応関係、未確認事項、停止線を確認する。

Gate reviewer の pass はユーザー承認ではない。pass 後、lead が成果物、review 結果、残リスク、次工程または完了判断を確認し、ユーザー確認が必要な事項がなければ承認待ちを挟まず次へ進む。

## 共通 pass 条件

- 対象成果物が自分の責務内に収まっている。
- 次工程へ進むために必要な上流 artifact が、次工程着手前に作成・更新・確認されている。lead が前工程成果物を Read で確認した痕跡（確認 artifact 名と充足観点）が残っている。
- 後続工程の内容を先取りしていない。
- 他成果物に書くべき内容を混ぜていない。
- 推測が事実として書かれていない。
- 未確認事項が次工程の判断をブロックしない。

## 共通 fail 条件

- 上流成果物との矛盾がある。
- ID 対応が欠落している。
- 実装や検証の結果を根拠に、要件・設計・task などの上流 artifact を後付けしている。
- 成果物の責務超過、次工程の先取り、他ファイルへ書くべき内容の混入がある。
- scope 外の変更が混ざっている。
- reviewer が blocking 指摘を出した。

## Gate 1: 要件レビュー

reviewer: `requirements-reviewer`

Pass 条件:

- 元の要求・要望と `requirements.md` が矛盾していない。
- scope / non-scope が分かれている。
- `REQ-*` が実現したい振る舞いとして読める。
- `AC-*` が観測可能。
- 制約・前提・未確認事項が分かれている。
- 未確認事項が残っていても、設計へ進めてよい理由がある。
- `requirements.md` に実装方法や詳細設計を書いていない。

## Gate 2: 設計レビュー

reviewer: `design-reviewer` / `security-reviewer`

Pass 条件:

- `BD-*` が `REQ-*` / `AC-*` に対応している。
- `DD-*` が `BD-*` / `AC-*` に対応している。
- `TASK-*` が `DD-*` / `AC-*` に対応している。
- 基本設計で責務・境界・主要 data flow が分かる。
- 詳細設計で実装者が処理、I/O、validation、error handling を判断できる。
- タスク分解で実装者が作業単位、完了条件、確認方法を判断できる。
- security / 権限 / data / 外部 I/O の扱いが必要範囲で明示されている。
- 実装判断に影響する未確認事項が残っていない、または out-of-scope / ユーザー承認済みとして扱いが明確。
- auth / authorization / secret / permission / external I/O / validation / path traversal / data format の判断に影響する未確認事項は fail。
- security-relevant な元要求や制約が `REQ-*` / `AC-*` から設計と task へ trace されている。
- `basic-design.md` に詳細処理を書きすぎていない。
- `detailed-design.md` に実装ログやテスト結果を書いていない。
- `tasks.md` に実装結果や作業ログを書いていない。

## Gate 3: 完了レビュー

reviewer: `quality-reviewer` / `security-reviewer`

Pass 条件:

- `TC-*` が `AC-*` / `TASK-*` に対応している。standard 軽量時に `requirements.md` / `tasks.md` を省略した場合は、`request.md` の scope / acceptance / 実装範囲に対応している。
- security-relevant な元要求や制約が検証対象へ trace されている。
- 全変更セット（tracked diff、staged diff、secret-safe に確認した untracked summary）が scope 内に収まっている。
- 該当する自動テスト / lint / build の結果が確認済み。
- 該当しない test / lint / build は、N/A の理由と残リスクが明示されている。
- 自動化できない確認がある場合、理由、代替確認、残リスクが明示されている。
- Gate 3 前 docs 確認が必要時に実行され、追従不要の場合も `request.md` または `implementation.md` の自然な節に理由と確認範囲が明示されている。
- lead が doc-followup で行った確認結果に変更有無、挙動差分、品質ゲート影響、security / CI 影響、確認結果が明示されている。
- 全変更セットが reviewer 入力に含まれている。
- lead が doc-followup で変更したファイル差分は、必要に応じて補助情報として reviewer 入力に含まれている。
- untracked file は path / file type / secret-looking name を先に確認し、secret 疑いがある内容は読まずに `redacted` または `skipped_due_to_secret_risk` として扱われている。必須範囲が secret risk で確認不能なら pass にしない。
- standard Gate 3 では Triage 停止線と Security-Relevant Actions を再評価し、該当、missing、unknown のいずれかなら `security-reviewer` が review している。
- lead が doc-followup で tooling 挙動差分を観測した場合、`inspector` の再確認結果と更新後の `test.md` がある。
- 未解消の docs / repo hygiene / tooling 追従漏れ、品質ゲート弱体化、security / CI risk が Gate 3 reviewer によって許容不能と判断されていない。
- `implementation.md` に要件変更や設計変更を勝手に書いていない。
- 実装開始後に `requirements.md` / `basic-design.md` / `detailed-design.md` / `tasks.md` が作成・更新されている場合、その変更が前工程への明示的な差戻しまたはユーザー承認済み change request として扱われている。
- `test.md` に仕様変更を混ぜていない。
- `review.md` に修正済み指摘の詳細ログを残していない。
