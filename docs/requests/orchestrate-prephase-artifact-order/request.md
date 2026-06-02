# Request

## 元の要求・要望

orchestrate スキルで、実装後にドキュメントが作られることがある。ADR でも前工程ありきで次工程に着手するようにしているはずなので、その方針に沿って直す。

## 背景

- ADR 0025 は `orchestrate` を Phase 0 + Triage 入口にし、tier 別 flow を正本にする。
- ADR 0029 は最終 Gate までの自走を認めるが、停止線と Gate fail の扱いは変更しない。
- ADR 0030 は tier 決定後の flow を `references/standard.md` / `references/full.md` などの tier reference に分ける。

## 期待状態

- 実装前に上流 artifact または `request.md` が実装判断に足る状態で確定している。
- 実装後の `implementation.md` / `test.md` / repository maintenance が、要件・設計・task の後付け作成に使われない。
- Codex / Claude Code 両 surface の `orchestrate` reference が同じ方針になる。

## 不明点

- none

## 再定義履歴

- none
