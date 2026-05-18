---
name: consistency-audit
description: 「変更後の整合性を精査したい」「追従漏れを直したい」「ファイル追加・rename・削除後の参照や docs/config のずれを確認したい」といった依頼で使う。変更差分をもとに、README、docs、参照リンク、.gitignore、.chezmoiignore、設定ファイル、一覧の整合を確認し、事実から明らかな漏れは修正する。実装そのものを進めたい時は `code-implementation-loop` スキル、既存 docs 本文だけを更新したい時は `docs-update` スキルを使う。
metadata:
  short-description: 整合性精査
---

# Consistency Audit

変更差分から、参照、docs、設定、ignore の追従漏れを確認する。
この skill は実装や文書作成の主役ではなく、既にある変更の整合性を精査して、明らかな漏れだけを補う。

## 対象

- ファイル追加、ファイル名変更、ディレクトリ名変更、削除後の参照追従確認
- README、docs、index、一覧、リンク、設定ファイルの追従漏れ確認
- `.gitignore` と `.chezmoiignore` の独立した影響確認
- commit 前に、差分単位で整合性リスクを軽く確認したい場合

## 対象外

- 実装そのものを進める作業
- 既存 docs 本文を主成果物として更新する作業
- 仕様判断、公開面変更、削除可否など、利用者確認が必要な判断の代行
- `grill-with-docs` が担う知見蓄積や ADR 状態更新

## 基本方針

- evidence は `git diff --name-status`、`git diff`、対象 path 周辺の `rg` などで確認できる事実に限定する。
- `.gitignore` は Git の追跡対象、`.chezmoiignore` は chezmoi の配布対象として、それぞれ独立に確認する。
- 事実から明らかな追従漏れは同じ変更単位で修正する。
- 公開インターフェース、既存挙動、削除判断、永続化、認証認可、権限に触れる判断は修正せず `needs_confirmation` に残す。
- 修正後は、整合性修正が元の変更意図から外れていないかを確認する。

## 手順

### 1) evidence packet をそろえる

- `git status -sb` で対象差分の状態を確認する。
- `git diff --name-status` で追加、変更、rename、削除の種類を確認する。
- `git diff` で変更内容を確認する。
- 追加、rename、削除された path や見出し、skill 名、設定名を `rg` で検索する。
- 推測や未確認事項は evidence に含めない。

### 2) 整合観点を確認する

- README、docs、index、一覧に古い path や欠けた項目がないかを見る。
- 参照リンク、相対リンク、設定の path 参照、命名参照にずれがないかを見る。
- `.gitignore` に Git 追跡対象としての除外漏れ、不要になった除外、既存 pattern との衝突がないかを見る。
- `.chezmoiignore` に chezmoi 配布対象としての除外漏れ、不要になった除外、既存 pattern との衝突がないかを見る。
- `dot_codex/skills/`、`dot_codex/agents/`、`dot_codex/rules/` の surface 変更では、関連 docs や regression checks の追従要否を見る。

### 3) 修正または停止を決める

- 参照先の存在、path 変更、一覧漏れなど、事実だけで判断できる漏れは修正する。
- どの対象を正とするか判断が必要な場合は、修正せず `needs_confirmation` に残す。
- 修正した場合は `git diff` で、整合性修正が同じ変更単位に収まるかを確認する。

### 4) 結果を整理する

- `checked`: 確認した観点と path
- `fixed`: 修正した追従漏れ
- `needs_confirmation`: 利用者判断が必要な未解決事項
- `residual_risks`: 確認できなかったこと、または残るリスク

## 完了条件

- 差分に対する整合観点が evidence 付きで確認されている
- 明らかな追従漏れは修正されている
- 判断が必要な事項は `needs_confirmation` として分離されている
- 残リスクがある場合は `residual_risks` に残っている
