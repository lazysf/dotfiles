# 0005: ハーネス知見は runtime surface ごとに昇格先を分ける

- Status: Accepted

## Context

ハーネスエンジニアリングの知見は、外部ベストプラクティスの調査メモ、repo-level の保守判断、展開後にも参照する共通ガイド、繰り返し手順、機械的なガード、専門化した探索作業が混ざりやすい。
これらを同じ置き場に集めると、`dot_codex/` に repo-level の履歴が混入したり、逆に実運用物が root docs へ散らばったりして責務が崩れる。

## Decision

ハーネス知見は次の順で昇格先を判断する。

`調査メモ -> repo-level 判断は root docs/ADR -> deployable な恒久ガイドは dot_codex/docs -> 繰り返し手順は skills -> 機械的ガードは rules -> 専門化した読取作業は agents`

## Consequences

- root `docs/` には、この repo を保守するための知見と手動シナリオを置く
- `dot_codex/docs/` には、展開後にも参照する共通運用ガイドだけを置く
- 同じ知見を docs と skills に二重管理せず、繰り返し使う手順だけを skill に昇格する
- 破壊的操作の抑止や許可境界は文章ではなく rules を優先する
- 調査専用の再利用単位が必要な場合は、read-only agent として追加する
