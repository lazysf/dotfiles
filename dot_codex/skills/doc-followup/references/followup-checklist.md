# Docs Follow-up Checklist

変更後の docs 追従更新で、必要な範囲だけ確認する。

## 追従元

ユーザー指定 path / issue / PR / request folder がある場合はそれを最優先にする。指定 scope 外の docs 更新が必要なら、更新せず理由を確認事項に残す。

未指定時だけ以下の順で確認する。

- `git diff --name-status`: unstaged の変更
- `git diff --staged --name-status`: staged の変更
- `git status --short`: tracked / untracked を含む作業ツリー全体
- `git ls-files --others --exclude-standard`: untracked file list
- `git show --name-status --stat <commit>`: commit 済み変更

追従元がない場合は、対象変更を確認してから進める。

## 探すもの

- 追加 / rename / delete された file path
- skill / agent / rule / setting / command / artifact 名
- README、index、一覧、目次、関連文書 list
- ADR の新規追加、状態、`Supersedes` / `Superseded-By` / `Amends` / `Amended by`
- `docs/notes/` の運用説明、回帰チェック、設計原則
- `CONTEXT.md` / `CONTEXT-MAP.md` の用語と context
- Codex / Claude の対応 surface の片側漏れ

## よく使う確認

- 旧 path / 旧名称: `rg -n "old-name|old/path" .`
- docs index: `docs/README.md`
- runtime surface: `docs/notes/runtime-surface-guidance.md`
- 回帰チェック: `docs/notes/harness-regression-checks.md`
- ADR 運用: `docs/notes/adr-ledger-model.md`
- skill references: `dot_codex/skills/**/references/`, `dot_claude/skills/**/references/`
- agent 定義: `dot_codex/agents/`, `dot_claude/agents/`

## 更新判断

- 参照切れ、古い名称、古い導線は更新する。
- index / README に新しい durable artifact が載っていなければ追加する。ただしユーザー指定 scope 外なら、更新せず確認事項に残す。
- rename / delete で旧 file を参照している docs は新 path へ更新する。
- 方針変更は既存 ADR 本文に上書きせず、新 ADR と metadata で記録する。
- 手順メモや軽量な背景は ADR ではなく `docs/notes/` に置く。
- diff だけから判断理由を推測して ADR を作らない。

## 完了確認

- `git diff --check`
- 関連する旧 path / 旧名称の `rg`
- Codex / Claude 対応 surface の差分確認
- 可能なら project の `mise run lint` / `mise run test`

実行できない確認は、理由と代替確認を残す。
