---
paths:
  - "docs/**/*.md"
  - "**/README.md"
  - "**/CLAUDE.md"
  - "**/AGENTS.md"
---

# Docs / Artifact Rules

- doc は事前に書いて実装を駆動しない。実装が固まった後に確定事実から作る。
- 仕様（README / docs）は既存への最小追記を優先、ADR（`docs/adr/`）は分岐点で 1 枚、notes（`docs/notes/`）は任意。詳細は `skills/scribe`。
- doc 要否は黙って飛ばさない（silent skip 禁止）。
- 未確認事項を確認済み前提として書かない。観測可能な形で書く。
- 追加・削除・rename した継続参照 doc は README / index / 相対リンクの追従を確認する。
- 秘密情報、認証情報、private config を doc に残さない。
