---
paths:
  - ".claude/**"
  - "dot_claude/**"
---

# Claude Surface Consistency Rules

- `settings.json`、`CLAUDE.md`、`skills/`、`rules/`、`agents/` の surface 変更では、関連 docs と参照 path の追従漏れを確認する。
- 追加、rename、削除された path、skill 名、rule 名、設定名は `rg` で検索する。
- `.gitignore` は Git 追跡対象、`.chezmoiignore` は chezmoi 配布対象として独立に見る。
- 事実だけで判断できる漏れは同じ変更単位で修正してよい。
- 公開挙動、既存運用、権限、secret、削除判断に触れる場合は修正前に確認する。
