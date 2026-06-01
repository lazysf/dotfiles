---
paths:
  - "docs/**/*.md"
  - "**/README.md"
  - "**/CLAUDE.md"
---

# Docs / Artifact Rules

- 根拠の既定は 1 要求 1 request folder（`docs/requests/<slug>/`）。工程別 artifact として `request.md`、`requirements.md`、`basic-design.md`、`detailed-design.md`、`tasks.md`、`implementation.md`、`test.md`、`review.md` を置く。
- typo / 1 行 / 自明な変更では、必要最小の記録だけでよい。工程をまたぐ作業では request folder artifact を使う。
- 受入条件に `AC-*` を振り、設計、task、検証をその `AC-*` に対応付ける。下流成果物は必ず `AC-*` へ辿れるようにする。
- ADR（不可逆・非自明・複数変更にまたがる判断）と CONTEXT（用語）は別建ての恒久知見として残す。
- 文書化する内容と根拠となる一次情報を先に確認する。
- 新規 artifact より、既存の自然な位置への最小追記を優先する。
- 対象 scope と non-scope を分け、責務外の内容を混ぜない。
- 未確認事項を確認済み前提として書かない。
- 受入条件、確認方法、期待結果は観測可能な形で書く。
- 追加、削除、rename した継続参照 doc は README / index / 相対リンクの追従を確認する。
