# Autonomous Loop

lead 集約 workflow は、ユーザー確認が不要な範囲では main セッションが戻り先を決め、該当 agent を起動し、修正と再 review を進める。Codex では agent 間の直接通信を前提にしない。

## 基本フロー

1. reviewer が fail と blocking 指摘を返す。
2. reviewer が `recommended_return` を返す。
3. lead が戻り先を確定する。
4. lead が該当 agent に修正を依頼する。
5. 該当 agent が担当成果物を修正する。
6. lead が再 review を起動する。
7. pass したら lead が `review.md` に最終判定だけ記録する。

## recommended_return

- `same-step`: 同じ工程内で修正する。
- `same-phase`: 同じフェーズ内の前工程へ戻る。
- `previous-phase`: 上位フェーズへ戻る。
- `restart`: 要求・要望を再定義して最初からやり直す。
- `change-request-candidate`: 変更要求候補として提示する。
- `none`: 戻りなし。

reviewer は戻り先を提案する。lead が最終決定する。

## Lead Loop Control

- `recommended_return` は提案として扱い、lead が成果物、ユーザー確認条件、変更範囲に照らして最小戻り先へ正規化する。
- `restart` / `change-request-candidate` はユーザー確認必須。
- 同一 `FINDING-*` が 2 回 fail したら停止してユーザー確認する。
- Gate 全体で fail が繰り返される場合は停止してユーザー確認する。
- scope が拡大する修正は自律ループ内で実施しない。必要ならユーザー確認する。
- auth / 権限 / secret / 外部送信 / CI / runtime guardrail / deploy / publish / command / script / hook / workflow / validation 境界 / injection / path traversal に触れる修正は自律実施せず、ユーザー確認または change-request 候補にする。
- ループごとに変更対象 artifact と target ID を限定する。

## 差戻し

- Gate 不合格時は最小戻り先へ戻し、修正後に再 review する。
- 後続フェーズで上流問題が見つかった場合は、原因フェーズへ戻り、そのフェーズ以降を再実行する。
- 要求・要望の理解、目的、成功条件、前提が大きく変わった場合は、要求・要望を再定義して最初からやり直す。

## 変更要求候補

原則として、上流問題は原因フェーズへ戻って直す。変更要求化は例外であり、ユーザーが新しい目的・対象・成果・制約を追加した場合だけ候補にする。

1. 現サイクルで見つかった問題を記録する。
2. 元の要求・要望を実現するための不足なら、変更要求化せず原因フェーズへ戻る。
3. 要求・要望の理解、目的、成功条件、前提が大きく変わった場合は、要求・要望を再定義して最初からやり直す。
4. 新しい目的・対象・成果・制約の追加であれば、変更要求候補として人間へ提示する。
5. 人間が承認した場合だけ、新しい要求・要望入力として別サイクルを開始する。
