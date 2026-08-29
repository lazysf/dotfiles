# Harness Surface Consistency

- `dot_claude/` と `.claude/` の配下、root の `AGENTS.md` / `CLAUDE.md`、`docs/` を変えたら、関連 doc と参照 path の追従漏れを確認する。
- 追加、rename、削除した path、skill 名、rule 名、agent 名、設定キーは `rg` で検索する。
- `.gitignore` は Git 追跡対象、`.chezmoiignore` は chezmoi 配布対象として独立に見る。
- 追従漏れは別 commit に分ける。`coding-standards` の最小差分を優先する。
- `chezmoi apply` した後は、`chezmoi managed` の一覧と `~/.claude/` の実体を突き合わせる。source から消したファイルは target に残る。
