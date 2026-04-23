# 0007: ハーネス検証専用スクリプトを廃止する

- Status: Proposed
- Supersedes: 0005

## Context

`scripts/verify-codex-harness.py` は、repo 固有契約の軽量な自動検知として `agent metadata`、`rule metadata`、Markdown 相対リンク、project-local `.codex` 推奨禁止を見ていた。

一方で、この repo ではハーネス更新頻度が高くなく、専用スクリプト自体を維持し続ける手間が、検知できる内容の価値を上回り始めていた。

repo 固有契約のうち汎用 lint で拾えない観点も、少人数での更新と review discipline を前提にすれば、手動回帰チェックへ寄せて十分に扱える。

## Decision

- `scripts/verify-codex-harness.py` は repo から削除する
- `.mise.toml` の `test:harness` と pre-commit の `verify codex harness` hook は削除する
- repo 固有契約の軽い確認は `docs/knowledge/harness-regression-checks.md` の手動回帰観点へ移す
- 既存の lint / format / test と review で拾える内容は専用スクリプトへ戻さない

## Consequences

- repo 保守対象が 1 つ減り、ハーネス整理時の追従コストを下げられる
- `mise run test` と pre-commit はより汎用的な確認だけを行う
- `agent metadata`、`rule metadata`、リンク整合、`.codex` 推奨禁止のような repo 固有観点は、変更時の手動 review と回帰チェックに依存する
