# 0016: reviewer agent surface を 2 個へ減らす

- Status: Accepted
- Amends: 0011, 0012

実行速度とコストを下げつつ worker の実装修正品質を保つため、要件 draft review と実装計画 draft review の専用 reviewer agent は退役し、計画 review は親 Codex が扱う。差分品質 review とセキュリティ review は実装後の見落とし検出として分離価値があるため、`quality-reviewer` と `security-reviewer` として残す。

## Consequences

- `dot_codex/agents/` の reviewer agent は 2 個にする。
- `quality-reviewer` / `security-reviewer` は番号 prefix を持たない名前にする。
- 計画系 skill は専用 reviewer agent を案内せず、差分 review が必要な場合だけ reviewer agent を案内する。
