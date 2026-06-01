# Consistency Checks

差分から参照、docs、設定、ignore の追従漏れを確認する時だけ読む。

## 手順

- `git status -sb`、`git diff --name-status`、`git diff` で対象差分を確認する。
- 追加、rename、削除された path、見出し、skill 名、設定名を `rg` で検索する。
- README、docs、index、一覧、相対リンク、設定 path、命名参照のずれを見る。
- `.gitignore` は Git 追跡対象、`.chezmoiignore` は chezmoi 配布対象として独立に見る。
- `dot_claude/skills/`、`dot_claude/agents/`、`dot_claude/settings.json` の surface 変更では、関連 docs や regression check の追従要否を見る。
- docs 追従漏れの更新まで行う場合は `doc-followup` を使う。
- `inspect` では確認した漏れ、確認範囲、未確認事項を整理する。

## 境界

- evidence は差分、対象 path 周辺の検索、既存ファイルで確認できる事実に限定する。
- 公開インターフェース、既存挙動、削除判断、永続化、認証認可、権限に触れる判断は修正せず `remaining_risks` に残す。
- 実装そのものは `implement` スキルを使う。
- 変更後の README、index、ADR、notes、CONTEXT、skill references の追従更新は `doc-followup` スキルを使う。
- 新規本文作成、artifact 整形、ADR 本文作成を主成果物として扱う場合は `scribe` スキルを使う。
- 更新先や判断が曖昧で問い詰めが必要な場合は `grill` スキルを使う。
