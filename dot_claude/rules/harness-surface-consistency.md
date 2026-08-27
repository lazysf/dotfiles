---
paths:
  - ".claude/**"
  - ".codex/**"
  - "dot_claude/**"
  - "dot_codex/**"
---

# Harness Surface Consistency Rules

- runtime 設定（`settings.json` / `config.toml`）、`CLAUDE.md` / `AGENTS.md`、`skills/`、`rules/`、`agents/`、`output-styles/` の surface 変更では、関連 docs と参照 path の追従漏れを確認する。
- 追加、rename、削除された path、skill 名、rule 名、agent 名、設定名は `rg` で検索する。
- 片方の surface だけ変えた場合は、他方を対称にするか、意図的差分として notes に残すかを明示する。
- `.gitignore` は Git 追跡対象、`.chezmoiignore` は chezmoi 配布対象として独立に見る。
- 見つけた追従漏れは別 commit に分ける。`coding-standards` の最小差分（全変更行が依頼にトレースできるか）を優先する。
- 公開挙動、既存運用、権限、secret、削除判断に触れる場合は修正前に確認する。
