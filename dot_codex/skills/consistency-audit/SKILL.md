---
name: consistency-audit
description: 「変更後の整合性を精査したい」「追従漏れを直したい」「rename / 削除後の参照ずれを確認したい」といった差分の整合確認で使う。README、docs、リンク、ignore、設定、一覧の明らかな漏れだけ修正する。実装は `code-implementation-loop`、docs 本文更新は `docs-update` スキルを使う。
metadata:
  short-description: 整合性精査
---

# 整合性精査

変更差分から、参照、docs、設定、ignore の追従漏れを確認し、明らかな漏れだけを補う。

## 手順

- `git status -sb`、`git diff --name-status`、`git diff` で対象差分を確認する。
- 追加、rename、削除された path、見出し、skill 名、設定名を `rg` で検索する。
- README、docs、index、一覧、相対リンク、設定の path 参照、命名参照のずれを見る。
- `.gitignore` は Git 追跡対象、`.chezmoiignore` は chezmoi 配布対象として独立に見る。
- `dot_codex/skills/`、`dot_codex/agents/`、`dot_codex/rules/` の surface 変更では、関連 docs や regression check の追従要否を見る。
- 事実だけで判断できる漏れは同じ変更単位で修正する。
- 修正後は `git diff` で、元の変更意図から外れていないか確認する。

## 境界

- evidence は差分、対象 path 周辺の検索、既存ファイルで確認できる事実に限定する。
- 公開インターフェース、既存挙動、削除判断、永続化、認証認可、権限に触れる判断は修正せず `needs_confirmation` に残す。
- 実装そのものは `code-implementation-loop` スキルを使う。
- 既存 docs 本文を主成果物として更新する場合は `docs-update` スキルを使う。
- 知見蓄積や ADR 状態更新は `grill-with-docs` スキルを使う。

## 出力

- `checked`: 確認した観点と path
- `fixed`: 修正した追従漏れ
- `needs_confirmation`: 利用者判断が必要な未解決事項
- `residual_risks`: 確認できなかったこと、または残るリスク
