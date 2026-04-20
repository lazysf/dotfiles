# 0004: Codex Hooks は当面採用しない

- Status: Accepted

## Context

2026年4月20日時点の Codex docs では `features.codex_hooks` は開発中機能として扱われている。
共通ハーネスでは、展開後に安定して使える機能だけを前提にしたい。

## Decision

Codex Hooks は今回の共通ハーネスには組み込まない。
`features.codex_hooks = false` を明示し、rules・docs・pre-commit・検証スクリプトを主軸にする。

## Consequences

- 即時フィードバックの一部は手動または既存コマンドで補う
- Hooks が安定化した時点で別 ADR で再判断する
